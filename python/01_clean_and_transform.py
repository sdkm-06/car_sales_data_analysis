"""
===============================================================================
PROJECT: India Passenger Vehicle Market Analysis (2021-2026)
PHASE: PROCESS - Data Cleaning & Transformation
===============================================================================
Source: VAHAN Dashboard (Ministry of Road Transport & Highways, Govt of India)
Scope : 5 makers (Hyundai, Kia, Maruti Suzuki, Mahindra, Renault)
        x 5 states (Delhi, Karnataka, Maharashtra, Odisha, Tamil Nadu)
        x 6 years (2021-2026, 2026 partial through Sep)
Raw   : 30 CSV files, one per state-year, wide format (Maker x Month columns)
Output: One tidy long-format table -> data/cleaned/vahan_master_dataset.csv

WHY THIS TRANSFORMATION IS NEEDED (documented for the case study write-up):
The VAHAN dashboard only exports a 2D pivot at a time (Maker x Month, filtered
to one state and one year). To analyze State x Maker x Time together, the
30 individual exports must be reshaped from wide (months as columns) to long
(one row per state-year-month-maker) and stacked into a single table.
===============================================================================
"""

import pandas as pd
import glob
import os
import re

# Paths are built from this file's location, so the script runs from any clone
# of the repo (no machine-specific absolute paths).
PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW_DIR = os.path.join(PROJECT_DIR, "data", "raw")
CLEAN_DIR = os.path.join(PROJECT_DIR, "data", "cleaned")
LOG_PATH = os.path.join(PROJECT_DIR, "docs", "data_cleaning_log_output.txt")

STATE_NAMES = {
    "DL": "Delhi", "KA": "Karnataka", "MH": "Maharashtra",
    "OD": "Odisha", "TN": "Tamil Nadu",
}

MAKER_CLEAN_NAMES = {
    "HYUNDAI MOTOR INDIA LTD": "Hyundai",
    "KIA INDIA PRIVATE LIMITED": "Kia",
    "MARUTI SUZUKI INDIA LTD": "Maruti Suzuki",
    "MAHINDRA & MAHINDRA LIMITED": "Mahindra",
    "RENAULT INDIA PVT LTD": "Renault",
}

MONTH_MAP = {
    "Jan": 1, "Feb": 2, "Mar": 3, "Apr": 4, "May": 5, "Jun": 6,
    "Jul": 7, "Aug": 8, "Sep": 9, "Oct": 10, "Nov": 11, "Dec": 12,
}

pattern = re.compile(r"^([A-Z]{2})_(\d{4})\.csv$")

log_lines = []
def log(msg):
    print(msg)
    log_lines.append(str(msg))

log("=" * 70)
log("STEP 1: LOAD + VALIDATE FILE NAMING & STRUCTURE")
log("=" * 70)

all_rows = []
processed, skipped = [], []
expected_states = set(STATE_NAMES.keys())
expected_years = set(range(2021, 2027))
seen_state_year = set()

for filepath in sorted(glob.glob(os.path.join(RAW_DIR, "*.csv"))):
    filename = os.path.basename(filepath)
    m = pattern.match(filename)
    if not m:
        skipped.append(filename)
        continue
    state_code, year = m.group(1), int(m.group(2))
    seen_state_year.add((state_code, year))

    df_raw = pd.read_csv(filepath, skiprows=2, encoding="utf-8-sig")
    df_raw.columns = [c.strip() for c in df_raw.columns]

    # VALIDATION 1: expected 5 makers present
    makers_in_file = set(df_raw["Maker"].str.strip())
    expected_makers = set(MAKER_CLEAN_NAMES.keys())
    if makers_in_file != expected_makers:
        log(f"  [WARNING] {filename}: maker mismatch -> {makers_in_file ^ expected_makers}")

    month_cols = [c for c in df_raw.columns if c not in ("Maker", "Total")]

    # VALIDATION 2: row total == sum of month columns (data integrity check
    # against VAHAN's own "Total" column)
    computed_total = df_raw[month_cols].apply(pd.to_numeric, errors="coerce").sum(axis=1)
    stated_total = pd.to_numeric(df_raw["Total"], errors="coerce")
    mismatch = (computed_total != stated_total)
    if mismatch.any():
        bad_makers = df_raw.loc[mismatch, "Maker"].tolist()
        log(f"  [WARNING] {filename}: Total column mismatch for {bad_makers}")

    long_df = df_raw.melt(id_vars=["Maker"], value_vars=month_cols,
                           var_name="year_month", value_name="registrations")
    long_df["month_abbr"] = long_df["year_month"].str.split("-").str[1]
    long_df["month_num"] = long_df["month_abbr"].map(MONTH_MAP)
    long_df["year"] = year
    long_df["state_code"] = state_code
    long_df["state_name"] = STATE_NAMES.get(state_code, state_code)
    long_df["maker"] = long_df["Maker"].str.strip().map(MAKER_CLEAN_NAMES).fillna(long_df["Maker"].str.strip())
    long_df["registrations"] = pd.to_numeric(long_df["registrations"], errors="coerce")

    long_df = long_df[["state_code", "state_name", "year", "month_num", "month_abbr",
                        "maker", "registrations"]]
    all_rows.append(long_df)
    processed.append(filename)

log(f"\nFiles processed: {len(processed)}")
log(f"Files skipped (name didn't match STATE_YEAR.csv pattern): {skipped}")

# VALIDATION 3: confirm all 30 expected state-year combos are present (5 states x 6 years)
missing_combos = [(s, y) for s in expected_states for y in expected_years if (s, y) not in seen_state_year]
log(f"Missing state-year files (expected none): {missing_combos if missing_combos else 'None - all 30 present'}")

master = pd.concat(all_rows, ignore_index=True)

log("\n" + "=" * 70)
log("STEP 2: DATA QUALITY CHECKS ON MERGED DATASET")
log("=" * 70)

log(f"\nTotal rows before cleaning: {len(master)}")
log(f"Nulls per column:\n{master.isnull().sum().to_string()}")

# VALIDATION 4: null registrations -> should be genuine 0s, not missing data.
# Cross-check: VAHAN CSVs never leave a cell blank for a valid maker-month,
# so a null here would indicate a parsing issue, not a business "zero sales" case.
null_regs = master[master["registrations"].isnull()]
log(f"\nRows with null registrations: {len(null_regs)}")
if len(null_regs) > 0:
    log(null_regs.to_string())

# VALIDATION 5: negative values (should never occur for registration counts)
negatives = master[master["registrations"] < 0]
log(f"\nRows with negative registrations (should be 0): {len(negatives)}")

# VALIDATION 6: duplicate rows (same state+year+month+maker appearing twice)
dupes = master[master.duplicated(subset=["state_code", "year", "month_num", "maker"], keep=False)]
log(f"\nDuplicate state-year-month-maker rows (should be 0): {len(dupes)}")

# VALIDATION 7: month range sanity check for 2026 (should stop at Sep, not go to Dec)
year_2026 = master[master["year"] == 2026]
log(f"\n2026 months present (should be 1-9, YTD only): {sorted(year_2026['month_num'].unique())}")

# CLEANING DECISION: drop true nulls (parsing failures), keep legitimate zeros
before = len(master)
master_clean = master.dropna(subset=["registrations"]).copy()
master_clean["registrations"] = master_clean["registrations"].astype(int)
after = len(master_clean)
log(f"\nRows dropped due to null registrations: {before - after}")

# Add a flag for partial-year data so downstream analysis doesn't compare
# 2026 YTD directly against full prior years without adjustment
master_clean["is_partial_year"] = master_clean["year"] == 2026

master_clean = master_clean.sort_values(
    ["state_code", "year", "month_num", "maker"]
).reset_index(drop=True)

log("\n" + "=" * 70)
log("STEP 3: FINAL OUTPUT SUMMARY")
log("=" * 70)
log(f"\nFinal row count: {len(master_clean)}")
log(f"States: {sorted(master_clean['state_code'].unique())}")
log(f"Years: {sorted(master_clean['year'].unique())}")
log(f"Makers: {sorted(master_clean['maker'].unique())}")
log(f"Total registrations across full dataset: {master_clean['registrations'].sum():,}")

os.makedirs(CLEAN_DIR, exist_ok=True)
out_path = os.path.join(CLEAN_DIR, "vahan_master_dataset.csv")
master_clean.to_csv(out_path, index=False)
log(f"\nSaved cleaned dataset to: {out_path}")

with open(LOG_PATH, "w") as f:
    f.write("\n".join(log_lines))
log(f"Saved full run log to: {LOG_PATH}")
