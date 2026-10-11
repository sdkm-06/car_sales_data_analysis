"""
Loads the cleaned dataset into a SQLite database using the project's SQL schema.
This is the bridge between the Python cleaning step and the SQL analysis step -
the database itself is queried using plain SQL (see sql/ folder) from here on.
"""
import sqlite3
import pandas as pd
import os

PROJECT_DIR = "/home/claude/india-auto-market-analysis"
DB_PATH = os.path.join(PROJECT_DIR, "india_auto_market.db")
SCHEMA_PATH = os.path.join(PROJECT_DIR, "sql", "01_schema.sql")
CSV_PATH = os.path.join(PROJECT_DIR, "data", "cleaned", "vahan_master_dataset.csv")

conn = sqlite3.connect(DB_PATH)
cur = conn.cursor()

with open(SCHEMA_PATH) as f:
    cur.executescript(f.read())

df = pd.read_csv(CSV_PATH)
df["is_partial_year"] = df["is_partial_year"].astype(int)
df.to_sql("vehicle_registrations", conn, if_exists="append", index=False)

count = cur.execute("SELECT COUNT(*) FROM vehicle_registrations").fetchone()[0]
print(f"Loaded {count} rows into {DB_PATH}")

conn.commit()
conn.close()
