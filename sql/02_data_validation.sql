-- ===============================================================================
-- PHASE: PROCESS - Data Validation (run against india_auto_market.db)
-- These mirror the checks already done in Python, run again in SQL so the
-- validation itself is reproducible from the database layer, independent
-- of the Python script.
-- ===============================================================================

-- 1. Row count sanity check: 5 states x 5 makers x (5 full years x 12mo + 1 partial year x 9mo)
--    = 5 x 5 x (60 + 9) = 1725
SELECT COUNT(*) AS total_rows FROM vehicle_registrations;

-- 2. Confirm exactly 5 states, 5 makers, and expected year range
SELECT COUNT(DISTINCT state_code) AS n_states,
       COUNT(DISTINCT maker) AS n_makers,
       MIN(year) AS min_year,
       MAX(year) AS max_year
FROM vehicle_registrations;

-- 3. Check for duplicate state-year-month-maker combinations
SELECT state_code, year, month_num, maker, COUNT(*) AS cnt
FROM vehicle_registrations
GROUP BY state_code, year, month_num, maker
HAVING COUNT(*) > 1;

-- 4. Check for any negative or null registrations
SELECT * FROM vehicle_registrations
WHERE registrations < 0 OR registrations IS NULL;

-- 5. Confirm 2026 only has months 1-9 (partial year, correctly flagged)
SELECT DISTINCT month_num FROM vehicle_registrations
WHERE year = 2026
ORDER BY month_num;

-- 6. Row count per state-year (should be exactly 60 for full years [5 makers x 12mo],
--    45 for 2026 [5 makers x 9mo])
SELECT state_code, year, COUNT(*) AS row_count
FROM vehicle_registrations
GROUP BY state_code, year
ORDER BY state_code, year;
