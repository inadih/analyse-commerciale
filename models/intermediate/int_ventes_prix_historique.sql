with ventes as (

    select * from {{ ref('stg_ventes') }}

),

prix_historise as (

    select * from {{ ref('snap_produits') }}

),

ventes_avec_prix as (

    select
        v.order_id,
        v.date_vente,
        v.produit,
        v.quantite,
        v.montant_total,
        p.prix_unitaire as prix_en_vigueur,
        v.quantite * p.prix_unitaire as ca_theorique
    from ventes v
    left join prix_historise p
        on v.produit = p.produit
        and v.date_vente >= p.dbt_valid_from
        and (v.date_vente < p.dbt_valid_to or p.dbt_valid_to is null)

)

select * from ventes_avec_prix