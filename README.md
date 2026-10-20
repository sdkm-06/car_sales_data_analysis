# India Passenger Vehicle Market Analysis (2021–2026)
### A Data Analyst Case Study — Ask, Prepare, Process, Analyze, Share, Act

## 1. ASK (Business Task)

**Scenario:** Acting as a market analyst supporting a passenger-vehicle manufacturer's
sales/strategy team, this project answers:

> Across India's top passenger-vehicle markets (Delhi, Karnataka, Maharashtra,
> Odisha, Tamil Nadu), how are Hyundai, Kia, Maruti Suzuki, Mahindra, and
> Renault performing in registrations from 2021–2026, and where should a
> manufacturer focus regional and seasonal strategy?

**Key stakeholder questions:**
1. Who holds market share, and is it shifting?
2. Which maker is growing/declining fastest, and in which states?
3. Is there a predictable seasonal pattern sales/inventory planning should account for?
4. Where are the anomalies (COVID-19 disruption, festive-season spikes) and what do they mean?

## 2. PREPARE (Data Source)

**Source:** [VAHAN Dashboard](https://vahan.parivahan.gov.in/vahan4dashboard/vahan/dashboardview.xhtml) —
the Ministry of Road Transport & Highways, Government of India's official vehicle
registration system.

**ROCCC evaluation:**
| Criteria | Assessment |
|---|---|
| Reliable | Official government registry, not third-party estimates |
| Original | Sourced directly from VAHAN, not a secondary aggregator |
| Comprehensive | Partial by design: 5 makers x 5 states only (no Tata, Toyota, Honda, etc.), so results describe this sample, not the whole Indian market |
| Current | Data through September 2026 |
| Cited | Publicly attributable to Govt. of India, MoRTH |

**Known limitation:** VAHAN's dashboard only exports a 2D pivot (Maker × Month,
one state/year at a time) — there is no single bulk export across state, year,
and maker simultaneously. This required 30 separate manual exports
(5 states × 6 years), documented and reshaped in the Process phase below.
Registrations are also a proxy for sales (a vehicle is booked before it's
registered), which is standard practice in Indian auto-market analysis but
worth noting as a modeling assumption.

**Raw files:** `data/raw/` — 30 CSVs named `{STATE}_{YEAR}.csv`

## 3. PROCESS (Cleaning & Transformation)

Tools used: **Python (pandas)** for reshaping/validation, **SQL (SQLite)** for
schema, integrity checks, and analysis queries.

Full step-by-step log: [`docs/data_cleaning_log.md`](docs/data_cleaning_log.md)

Summary of what was done:
- Reshaped 30 wide-format files (months as columns) into one long-format table
  (`python/01_clean_and_transform.py`)
- Standardized maker names (e.g. `"HYUNDAI MOTOR INDIA LTD"` → `"Hyundai"`)
- Validated: file completeness (all 30 expected files present), maker
  completeness per file, VAHAN's own row "Total" column cross-checked against
  the sum of monthly values, null/negative/duplicate checks, and confirmed
  2026 is correctly capped at September (partial year, flagged with
  `is_partial_year`)
- Loaded into a SQLite database (`india_auto_market.db`) using
  `sql/01_schema.sql`, re-validated independently in SQL (`sql/02_data_validation.sql`)

**Result:** 1,725 clean rows, zero nulls, zero duplicates, zero integrity
mismatches. 5,173,661 total vehicle registrations across the dataset.

## 4. ANALYZE

All analysis queries: [`sql/03_analysis_queries.sql`](sql/03_analysis_queries.sql)

Key results (2021–2025 full years, 2026 tracked separately as YTD):

- **Market share:** Maruti Suzuki 54.1%, Hyundai 21.0%, Mahindra 11.8%, Kia 9.9%, Renault 3.1%
- **Fastest grower:** Mahindra — +81% (2022), +39% (2023), +19% (2024), +17% (2025), consistently compounding
- **Market leader by state:** Maruti Suzuki #1 in all 5 states, but by a much
  smaller margin in some (see full breakdown in findings doc)
- **Who lost share to Mahindra:** Mahindra gained +9.2 share points (2021 to 2025),
  offset mainly by Hyundai (-4.1) and Renault (-3.9). Maruti (-0.8) and Kia (-0.4) barely moved
- **Seasonality:** October is the peak month (festive season — Navratri/Diwali) and
  February the trough, a swing of about 59% (2022-2025, excluding the COVID-distorted 2021)
- **Anomaly:** May 2021 collapsed in Delhi (-99.6%), Karnataka (-95.8%), Odisha (-87.0%)
  and Tamil Nadu (-81.9%) versus April, but only -23.5% in Maharashtra — matches
  India's COVID-19 second wave lockdowns, which hit states unevenly

Full findings write-up: [`docs/key_findings.md`](docs/key_findings.md)

## 5. SHARE (Visualization)

Tableau-ready extract: `tableau/vahan_tableau_extract.csv`
Dashboard build guide: [`tableau/tableau_dashboard_guide.md`](tableau/tableau_dashboard_guide.md)

**Status: dashboard not yet built or published.** The guide below is the build
plan. Once built, add a screenshot and the Tableau Public link here.

Planned dashboard pages:
1. Market share overview (all makers, all states)
2. YoY growth trend by maker
3. State-wise deep dive
4. Seasonality heatmap (month × maker)

## 6. ACT (Recommendations)

See [`docs/key_findings.md`](docs/key_findings.md) for the full recommendation
set, framed as stakeholder-ready action items with supporting numbers.

## Project Structure
```
car_sales_data_analysis/
├── data/
│   ├── raw/              # 30 original VAHAN export CSVs
│   └── cleaned/          # Final tidy dataset
├── sql/
│   ├── 01_schema.sql
│   ├── 02_data_validation.sql
│   └── 03_analysis_queries.sql
├── python/
│   ├── 01_clean_and_transform.py
│   ├── 02_load_to_sql.py
│   └── run_sql.py
├── tableau/
│   ├── vahan_tableau_extract.csv
│   └── tableau_dashboard_guide.md
├── docs/
│   ├── data_cleaning_log.md
│   └── key_findings.md
├── india_auto_market.db
├── requirements.txt
├── .gitignore
└── README.md
```

## How to Reproduce
```bash
pip install -r requirements.txt
python python/01_clean_and_transform.py     # raw CSVs -> data/cleaned/vahan_master_dataset.csv
python python/02_load_to_sql.py             # cleaned CSV -> india_auto_market.db
python python/run_sql.py sql/02_data_validation.sql
python python/run_sql.py sql/03_analysis_queries.sql
```
Scripts build their paths from their own location, so they run from any clone.

## Tech Stack
Python (pandas) · SQL (SQLite) · Tableau · Data source: VAHAN / Govt. of India
