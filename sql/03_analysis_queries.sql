-- ===============================================================================
-- PHASE: ANALYZE - Core business questions answered in SQL
-- ===============================================================================

-- Q1. Overall market share by maker (2021-2025 full years only, excl. partial 2026)
SELECT maker,
       SUM(registrations) AS total_registrations,
       ROUND(100.0 * SUM(registrations) / (
           SELECT SUM(registrations) FROM vehicle_registrations WHERE is_partial_year = 0
       ), 2) AS market_share_pct
FROM vehicle_registrations
WHERE is_partial_year = 0
GROUP BY maker
ORDER BY total_registrations DESC;

-- Q2. Year-over-year growth by maker (national, across all 5 states)
SELECT maker, year, SUM(registrations) AS yearly_registrations,
       ROUND(100.0 * (SUM(registrations) - LAG(SUM(registrations)) OVER (PARTITION BY maker ORDER BY year))
             / LAG(SUM(registrations)) OVER (PARTITION BY maker ORDER BY year), 2) AS yoy_growth_pct
FROM vehicle_registrations
WHERE is_partial_year = 0
GROUP BY maker, year
ORDER BY maker, year;

-- Q3. State-wise market leader (which maker wins in each state)
SELECT state_name, maker, SUM(registrations) AS total_registrations
FROM vehicle_registrations
WHERE is_partial_year = 0
GROUP BY state_name, maker
HAVING total_registrations = (
    SELECT MAX(sub.total) FROM (
        SELECT maker, SUM(registrations) AS total
        FROM vehicle_registrations v2
        WHERE v2.state_name = vehicle_registrations.state_name AND is_partial_year = 0
        GROUP BY maker
    ) sub
)
ORDER BY state_name;

-- Q4. Seasonality: average registrations by month across 2021-2025 (find festive-season spikes)
-- NOTE: this INCLUDES 2021, so May is pulled down by the COVID second wave.
-- Use Q4b below for the clean seasonal pattern.
SELECT month_num, month_abbr,
       ROUND(AVG(registrations), 0) AS avg_registrations
FROM vehicle_registrations
WHERE is_partial_year = 0
GROUP BY month_num, month_abbr
ORDER BY month_num;

-- Q4b. Seasonality excluding 2021 (the COVID-distorted recovery year)
-- With 2021 removed, February (not May) is the trough and October the peak.
SELECT month_num, month_abbr,
       ROUND(AVG(registrations), 0) AS avg_registrations
FROM vehicle_registrations
WHERE is_partial_year = 0 AND year >= 2022
GROUP BY month_num, month_abbr
ORDER BY month_num;

-- Q5. Largest single month-over-month drop (anomaly detection, e.g. COVID wave)
WITH monthly AS (
    SELECT state_name, maker, year, month_num, registrations,
           LAG(registrations) OVER (PARTITION BY state_name, maker ORDER BY year, month_num) AS prev_month_regs
    FROM vehicle_registrations
)
SELECT state_name, maker, year, month_num, registrations, prev_month_regs,
       (registrations - prev_month_regs) AS change
FROM monthly
WHERE prev_month_regs IS NOT NULL
ORDER BY change ASC
LIMIT 10;
-- NOTE: ranking by absolute change is dominated by big Maharashtra Maruti rows
-- falling after the festive peak (Oct to Nov, Jan to Feb). It does NOT surface
-- the COVID drop. Q5b measures that by percentage change per state instead.

-- Q5b. COVID second wave: April vs May 2021 registrations by state
SELECT state_name,
       SUM(CASE WHEN month_num = 4 THEN registrations END) AS apr_2021,
       SUM(CASE WHEN month_num = 5 THEN registrations END) AS may_2021,
       ROUND(100.0 * (SUM(CASE WHEN month_num = 5 THEN registrations END)
                    - SUM(CASE WHEN month_num = 4 THEN registrations END))
             / SUM(CASE WHEN month_num = 4 THEN registrations END), 1) AS pct_change
FROM vehicle_registrations
WHERE year = 2021 AND month_num IN (4, 5)
GROUP BY state_name
ORDER BY pct_change;

-- Q6. 2026 YTD (Jan-Sep) vs the same Jan-Sep window in every prior year, by maker, with growth
WITH ytd AS (
    SELECT maker, year, SUM(registrations) AS jan_to_sep_registrations
    FROM vehicle_registrations
    WHERE month_num <= 9
    GROUP BY maker, year
)
SELECT maker, year, jan_to_sep_registrations,
       ROUND(100.0 * (jan_to_sep_registrations - LAG(jan_to_sep_registrations) OVER (PARTITION BY maker ORDER BY year))
             / LAG(jan_to_sep_registrations) OVER (PARTITION BY maker ORDER BY year), 1) AS yoy_growth_pct
FROM ytd
ORDER BY maker, year;

-- Q7. Odisha vs. the other 4 states: small-market share comparison
SELECT state_name,
       SUM(registrations) AS total_registrations,
       ROUND(100.0 * SUM(registrations) / (SELECT SUM(registrations) FROM vehicle_registrations WHERE is_partial_year = 0), 2) AS pct_of_5state_total
FROM vehicle_registrations
WHERE is_partial_year = 0
GROUP BY state_name
ORDER BY total_registrations DESC;

-- Q8. Market share by maker for each full year (share of all 5 makers' registrations that year)
WITH y AS (
    SELECT year, maker, SUM(registrations) AS yearly_registrations
    FROM vehicle_registrations
    WHERE is_partial_year = 0
    GROUP BY year, maker
)
SELECT year, maker, yearly_registrations,
       ROUND(100.0 * yearly_registrations / SUM(yearly_registrations) OVER (PARTITION BY year), 1) AS share_pct
FROM y
ORDER BY maker, year;

-- Q9. Who gained and who lost share, 2021 to 2025 (change in percentage points)
WITH y AS (
    SELECT year, maker,
           100.0 * SUM(registrations) / SUM(SUM(registrations)) OVER (PARTITION BY year) AS share
    FROM vehicle_registrations
    WHERE is_partial_year = 0
    GROUP BY year, maker
)
SELECT maker,
       ROUND(MAX(CASE WHEN year = 2021 THEN share END), 1) AS share_2021,
       ROUND(MAX(CASE WHEN year = 2025 THEN share END), 1) AS share_2025,
       ROUND(MAX(CASE WHEN year = 2025 THEN share END) - MAX(CASE WHEN year = 2021 THEN share END), 1) AS change_pts
FROM y
GROUP BY maker
ORDER BY change_pts;
