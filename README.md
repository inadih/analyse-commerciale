# Analyse Commerciale — dbt + Snowflake

Modèle décisionnel de la performance commerciale, construit avec **dbt** sur **Snowflake**
selon une **architecture médaillon** (Bronze / Silver / Gold). De la donnée brute
jusqu'à un modèle en étoile testé, documenté et prêt pour la BI.

**Stack :** Snowflake · dbt Core · SQL · Git · GitHub Actions (CI/CD)

---

## Architecture médaillon

Les données transitent par trois couches successives, chacune matérialisée dans son
propre schéma Snowflake. Chaque couche ne lit que la précédente.

| Couche | Schéma Snowflake | Rôle | Contenu |
|--------|------------------|------|---------|
| **Bronze** | `ANALYTICS.DBT` | Données brutes, ingérées telles quelles, jamais transformées | `ventes_10000` (source) |
| **Silver** | `ANALYTICS.SILVER` | Nettoyage, typage, standardisation, conformité | `stg_ventes` (+ `int_*` à venir) |
| **Gold** | `ANALYTICS.GOLD` | Modèle métier en étoile, prêt pour le reporting | `dim_*`, `fct_ventes` |

Le routage des models vers leur schéma est piloté par la macro
`macros/generate_schema_name.sql`, qui utilise le nom de schéma déclaré tel quel
(sans préfixe de développement).

---

## Modèle en étoile (couche Gold)

**Table de faits** — `fct_ventes`
Grain : une ligne par vente (`order_id` unique). Porte les clés étrangères vers
chaque dimension et les mesures (chiffre d'affaires, volume, remise, frais de
livraison, marge).

**Dimensions**

| Dimension | Description |
|-----------|-------------|
| `dim_produit` | Référentiel produit, avec hiérarchie catégorie → produit |
| `dim_client` | Référentiel client |
| `dim_pays` | Référentiel géographique |
| `dim_canal` | Canal de vente (App, Magasin, Web) |
| `dim_date` | Calendrier généré dynamiquement (bornes calées sur la plage réelle des ventes) |

> **Marge** : dérivée en `montant_total - remise - frais_livraison`. Convention interne
> documentée, en l'absence de coût d'achat dans la source.

---

## Qualité des données

15 tests dbt garantissent l'intégrité du modèle à chaque exécution :

- `unique` + `not_null` sur les clés primaires des dimensions et le grain du fait
- `relationships` : intégrité référentielle entre `fct_ventes` et chaque dimension
- `accepted_values` : contrôle des valeurs autorisées (ex. canal de vente)

---

## Intégration continue (CI/CD)

Une CI **GitHub Actions** exécute `dbt build` (construction + tests) à chaque
Pull Request, sur une machine vierge connectée à Snowflake.

- Identifiants Snowflake stockés dans les **secrets GitHub** (chiffrés)
- `profiles.yml` généré à la volée pendant la CI — jamais versionné
- Un changement n'est mergé que si le modèle se construit **et** passe tous les tests

---

## Structure du projet

```
analyse_commerciale/
├── models/
│   ├── staging/          # Silver — nettoyage 1:1 de la source
│   │   ├── _sources.yml       # déclaration de la source Bronze
│   │   ├── _stg.yml           # tests + documentation
│   │   └── stg_ventes.sql
│   └── marts/            # Gold — modèle en étoile
│       ├── _marts.yml         # tests + documentation
│       ├── dim_*.sql
│       └── fct_ventes.sql
├── macros/
│   └── generate_schema_name.sql   # routage des schémas (Bronze/Silver/Gold)
├── seeds/
│   └── ventes_10000.csv       # données sources (Bronze)
├── dbt_project.yml
└── packages.yml               # dbt_utils
```

---

## Utilisation

Prérequis : Python, dbt Core (`dbt-snowflake`), et les variables d'environnement
de connexion Snowflake définies dans la session.

```bash
# Variables de connexion (session)
export SNOWFLAKE_ACCOUNT=...
export SNOWFLAKE_USER=...
export SNOWFLAKE_PASSWORD=...

dbt deps                    # installer les packages (dbt_utils)
dbt seed                    # charger les données sources (Bronze)
dbt build                   # construire + tester tout le modèle
dbt docs generate && dbt docs serve   # documentation + graphe de lignage
```

---

## Feuille de route

- [x] Modèle en étoile (staging → dimensions → fait)
- [x] Tests de qualité + CI `dbt build`
- [x] Architecture médaillon (schémas Bronze / Silver / Gold)
- [ ] Historisation (snapshots dbt / SCD type 2)
- [ ] Chargement incrémental (delta, `is_incremental`)
- [ ] Ingestion depuis API (Python)
- [ ] Rapport Power BI (Synthèse · Produits · Clients)
