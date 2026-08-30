"""
Ingestion des taux de change depuis l'API Frankfurter.
Étape E (extract) + aplatissement du JSON en lignes.
"""

import requests   # pour appeler l'API HTTP
import csv         # pour écrire le résultat en CSV

# --- 1. L'appel API (ce que Bruno faisait) ---
URL = "https://api.frankfurter.dev/v1/2024-01-01..2024-01-31"
PARAMS = {
    "base": "EUR",
    "symbols": "USD,GBP,CHF",
}

print("Appel de l'API Frankfurter...")
reponse = requests.get(URL, params=PARAMS)

# --- 2. Vérifier le code de statut (le réflexe !) ---
print(f"Code de statut : {reponse.status_code}")
if reponse.status_code != 200:
    print("Erreur lors de l'appel API. Arrêt.")
    exit(1)

# --- 3. Récupérer le JSON ---
data = reponse.json()   # transforme la réponse en dictionnaire Python
print(f"Base : {data['base']}, période : {data['start_date']} → {data['end_date']}")

# --- 4. Aplatir le JSON imbriqué en lignes ---
# Structure : data['rates'] = { "2024-01-02": {"USD": 1.09, "GBP": 0.85, ...}, ... }
# On veut : une ligne par (date, devise, taux)
lignes = []
for date, taux_par_devise in data["rates"].items():
    for devise, taux in taux_par_devise.items():
        lignes.append({
            "date_taux": date,
            "devise": devise,
            "taux": taux,
        })

print(f"{len(lignes)} lignes aplaties.")

# --- 5. Écrire le CSV ---
chemin_csv = "C:/Users/inadi/dev/data/taux_change.csv"
with open(chemin_csv, "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=["date_taux", "devise", "taux"])
    writer.writeheader()
    writer.writerows(lignes)

print(f"CSV écrit : {chemin_csv}")