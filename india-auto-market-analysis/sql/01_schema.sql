-- ===============================================================================
-- PROJECT: India Passenger Vehicle Market Analysis (2021-2026)
-- PHASE: PROCESS - Database Schema
-- ===============================================================================

DROP TABLE IF EXISTS vehicle_registrations;

CREATE TABLE vehicle_registrations (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    state_code      TEXT NOT NULL,
    state_name      TEXT NOT NULL,
    year            INTEGER NOT NULL,
    month_num       INTEGER NOT NULL,
    month_abbr      TEXT NOT NULL,
    maker           TEXT NOT NULL,
    registrations   INTEGER NOT NULL,
    is_partial_year INTEGER NOT NULL DEFAULT 0,
    CHECK (month_num BETWEEN 1 AND 12),
    CHECK (registrations >= 0)
);

CREATE INDEX idx_state_year ON vehicle_registrations(state_code, year);
CREATE INDEX idx_maker ON vehicle_registrations(maker);
CREATE INDEX idx_year_month ON vehicle_registrations(year, month_num);
