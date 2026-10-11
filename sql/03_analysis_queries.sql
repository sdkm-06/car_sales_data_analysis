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

-- Q4. Seasonality: average registrations by month across all years (find festive-season spikes)
SELECT month_num, month_abbr,
       ROUND(AVG(registrations), 0) AS avg_registrations
FROM vehicle_registrations
WHERE is_partial_year = 0
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

-- Q6. 2026 YTD performance vs. same YTD period (Jan-Sep) in each prior year, by maker
SELECT maker, year, SUM(registrations) AS jan_to_sep_registrations
FROM vehicle_registrations
WHERE month_num <= 9
GROUP BY maker, year
ORDER BY maker, year;

-- Q7. Odisha vs. the other 4 states: small-market share comparison
SELECT state_name,
       SUM(registrations) AS total_registrations,
       ROUND(100.0 * SUM(registrations) / (SELECT SUM(registrations) FROM vehicle_registrations WHERE is_partial_year = 0), 2) AS pct_of_5state_total
FROM vehicle_registrations
WHERE is_partial_year = 0
GROUP BY state_name
ORDER BY total_registrations DESC;
