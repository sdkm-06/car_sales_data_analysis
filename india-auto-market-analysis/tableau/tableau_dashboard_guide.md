# Tableau Dashboard Build Guide (Share Phase)

**Data source:** `vahan_tableau_extract.csv`
**Fields:** `state_code, state_name, year, month_num, month_abbr, maker, registrations, is_partial_year`

Before building, create a **Date field**: right-click in the data pane →
Create Calculated Field → `Reg_Date`:
```
MAKEDATE([year], [month_num], 1)
```
This gives you a proper date field for time-series charts (Tableau's `year`/`month_num`
as separate integers won't sort/animate correctly on their own).

Also filter out `is_partial_year = True` for any full-year comparison sheet
(keep it only for YTD-specific views).

## Sheet 1 — Market Share Overview
- Chart: Pie or 100% stacked bar
- Columns: `maker` (color), `SUM(registrations)`
- Filter: `is_partial_year = False`
- Add a label showing % of total (Analysis → Percentage Of → Total)

## Sheet 2 — YoY Growth Trend
- Chart: Line chart
- Columns: `year` (as discrete)
- Rows: `SUM(registrations)`
- Color: `maker`
- Filter: `is_partial_year = False`
- This is the sheet that shows Mahindra's compounding growth — make sure
  each maker's line is a distinct, legible color

## Sheet 3 — State-wise Deep Dive
- Chart: Bar chart, one bar group per state
- Columns: `state_name`
- Rows: `SUM(registrations)`
- Color: `maker`
- Add a parameter or filter action so clicking a state on Sheet 1 filters this sheet

## Sheet 4 — Seasonality Heatmap
- Chart: Heatmap (Marks type = Square)
- Columns: `month_abbr` (sort by `month_num`, not alphabetically — right-click
  the field → Sort → by `month_num`)
- Rows: `maker`
- Color: `AVG(registrations)`
- Filter: `is_partial_year = False`
- This should visually confirm the October peak / February trough pattern

## Dashboard Assembly
- Combine all 4 sheets into one Dashboard
- Add filter actions: clicking a maker on Sheet 1 filters Sheets 2–4
- Add a title referencing the scope: "India Passenger Vehicle Market —
  5 States, 2021–2026 (VAHAN Registration Data)"
- Publish to Tableau Public for a shareable link to put in your README/LinkedIn

## Interview tip
Be ready to explain *why* you built each chart type — e.g. "I used a heatmap
for seasonality because it makes a cyclical pattern across 12 months and
5 makers visually scannable in a way a line chart with 5 overlapping lines
wouldn't be."
