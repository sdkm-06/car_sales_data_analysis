"""Run a .sql file (semicolon-separated statements) against the project DB and print results."""
import sqlite3
import sys
import pandas as pd

DB_PATH = "/home/claude/india-auto-market-analysis/india_auto_market.db"

def run_sql_file(path):
    with open(path) as f:
        content = f.read()
    raw_statements = [s for s in content.split(";") if s.strip()]
    conn = sqlite3.connect(DB_PATH)
    i = 0
    for stmt in raw_statements:
        # strip comment lines within a statement block, then check what's left
        lines = [l for l in stmt.split("\n") if not l.strip().startswith("--")]
        clean_stmt = "\n".join(lines).strip()
        if not clean_stmt:
            continue
        i += 1
        print(f"\n>>> Query {i}:\n{clean_stmt}\n")
        try:
            df = pd.read_sql_query(clean_stmt, conn)
            print(df.to_string(index=False) if len(df) <= 20 else df.head(20).to_string(index=False) + f"\n... ({len(df)} rows total)")
        except Exception as e:
            print(f"[Not a SELECT or error: {e}]")
    conn.close()

if __name__ == "__main__":
    run_sql_file(sys.argv[1])
