"""
Chargement du CSV des taux de change dans Snowflake.
Étape L (load) : PUT + COPY INTO, directement depuis Python.
"""

import os
import snowflake.connector
from dotenv import load_dotenv

# --- 1. Charger les secrets depuis .env ---
load_dotenv()   # lit le fichier .env

# --- 2. Se connecter à Snowflake ---
print("Connexion à Snowflake...")
conn = snowflake.connector.connect(
    account=os.getenv("SNOWFLAKE_ACCOUNT"),
    user=os.getenv("SNOWFLAKE_USER"),
    password=os.getenv("SNOWFLAKE_PASSWORD"),
    warehouse="COMPUTE_WH",
    database="ANALYTICS",
    schema="DBT",
)
cur = conn.cursor()

try:
    # --- 3. Créer la table cible (si absente) ---
    print("Création de la table TAUX_CHANGE...")
    cur.execute("""
        CREATE TABLE IF NOT EXISTS ANALYTICS.DBT.TAUX_CHANGE (
            date_taux   DATE,
            devise      VARCHAR,
            taux        NUMBER(12,6)
        )
    """)

        # Vider la table avant rechargement (évite les doublons)
    print("Vidage de la table...")
    cur.execute("TRUNCATE TABLE ANALYTICS.DBT.TAUX_CHANGE")

    # --- 4. Créer un stage ---
    cur.execute("CREATE STAGE IF NOT EXISTS ANALYTICS.DBT.STAGE_TAUX")

    # --- 5. PUT : déposer le CSV local dans le stage ---
    print("PUT du fichier vers le stage...")
    cur.execute("PUT file://C:/Users/inadi/dev/data/taux_change.csv "
                "@ANALYTICS.DBT.STAGE_TAUX OVERWRITE=TRUE")

    # --- 6. COPY INTO : charger le stage vers la table ---
    print("COPY INTO de la table...")
    cur.execute("""
        COPY INTO ANALYTICS.DBT.TAUX_CHANGE
        FROM @ANALYTICS.DBT.STAGE_TAUX/taux_change.csv.gz
        FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
        ON_ERROR = 'ABORT_STATEMENT'
    """)

    # --- 7. Vérifier ---
    cur.execute("SELECT COUNT(*) FROM ANALYTICS.DBT.TAUX_CHANGE")
    nb = cur.fetchone()[0]
    print(f"✅ Chargement terminé : {nb} lignes dans TAUX_CHANGE.")

finally:
    cur.close()
    conn.close()
    print("Connexion fermée.")