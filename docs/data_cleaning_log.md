# Data Cleaning & Validation Log

This documents every cleaning and validation decision made in the Process
phase, in the order it was performed. Referenced scripts:
`python/01_clean_and_transform.py`, `sql/02_data_validation.sql`.

## 1. Why cleaning was needed

The VAHAN dashboard exports one 2D pivot (Maker × Month) per state per year,
in wide format, with a title row and a blank row above the header. To analyze
State × Maker × Time together, 30 files needed to be:
- Stripped of their title/blank rows
- Reshaped from wide (12 month columns) to long (one row per month)
- Tagged with `state` and `year` (parsed from the filename, since the data
  itself doesn't repeat this per row)
- Stacked into a single table

## 2. Cleaning steps performed (Python)

| Step | Action | Why |
|---|---|---|
| 1 | Parsed filename (`{STATE}_{YEAR}.csv`) into `state_code` and `year` columns | Source files don't carry this info in the data rows |
| 2 | Skipped the title row and blank row, read from the real header row | Avoids the title text being misread as data |
| 3 | Melted 12 month columns into 2 columns: `month_abbr`, `registrations` | Converts wide format to tidy long format for analysis |
| 4 | Mapped month abbreviations (`Jan`...`Dec`) to `month_num` (1–12) | Enables correct chronological sorting and time-series functions |
| 5 | Standardized maker names (e.g. `HYUNDAI MOTOR INDIA LTD` → `Hyundai`) | Cleaner labels for charts/dashboards |
| 6 | Converted `registrations` to numeric, coercing errors to null for inspection | Catches any non-numeric/corrupted cells |
| 7 | Flagged `is_partial_year = True` for all 2026 rows | 2026 data is Jan–Sep only; prevents this being mistaken for a full-year total downstream |

## 3. Validation checks performed

| Check | Method | Result |
|---|---|---|
| All 30 expected files present | Compared found `(state, year)` combos against the expected 5×6 set | Pass — all 30 present |
| Correct makers in every file | Compared maker set per file against the expected 5 makers | Pass — no mismatches |
| VAHAN's own row totals match the sum of months | Computed `SUM(Jan..Dec)` per row and compared to the file's `Total` column | Pass — no mismatches |
| No missing (null) registration values | `df.isnull().sum()` on final merged table | Pass — 0 nulls |
| No negative registration values | Filter `registrations < 0` | Pass — 0 rows |
| No duplicate state-year-month-maker rows | Grouped and counted, flagged any `count > 1` | Pass — 0 duplicates |
| 2026 correctly limited to Jan–Sep | Checked distinct `month_num` values where `year = 2026` | Pass — only months 1–9 present |
| Row count per state-year matches expectation (5 makers × 12mo = 60, or × 9mo = 45 for 2026) | Grouped and counted rows per state-year | Pass — all match |

All checks were repeated independently in SQL (`sql/02_data_validation.sql`)
after loading into SQLite, so the validation isn't dependent on the Python
script alone — the database itself passes the same checks.

## 4. Outcome

- **Rows before cleaning:** 1,725 (no rows needed to be dropped — source data
  was already complete and well-formed; validation confirmed this rather than
  fixing errors)
- **Rows after cleaning:** 1,725
- **Total registrations across dataset:** 5,173,661
- **Output:** `data/cleaned/vahan_master_dataset.csv`, and loaded into
  `india_auto_market.db`

## 5. Known limitations (documented, not hidden)

- Registrations are a proxy for sales — a small lag exists between a vehicle
  being sold and being registered, which is standard in Indian auto-market
  reporting but worth stating explicitly.
- Only 5 of India's 34 states/UTs are included — chosen for a mix of large
  metro markets (Delhi, Maharashtra, Karnataka, Tamil Nadu) and one smaller
  state (Odisha) as a size contrast, not as a nationally representative sample.
- 2026 is a partial year (through September) and is excluded from full-year
  comparisons (market share, YoY growth) but included in YTD comparisons.
