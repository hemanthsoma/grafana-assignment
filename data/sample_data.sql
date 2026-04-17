-- =========================================
-- Grafana Assignment - Sample Data Setup
-- =========================================

-- Create Database (run separately if needed)
-- CREATE DATABASE grafana_demo;

-- Connect to database
-- \c grafana_demo

-- =========================================
-- Create Table
-- =========================================

DROP TABLE IF EXISTS machine_metrics;

CREATE TABLE machine_metrics (
id SERIAL PRIMARY KEY,
machine_id TEXT,
status TEXT,
temperature FLOAT,
timestamp TIMESTAMP
);

-- =========================================
-- Insert Synthetic Data (Basic Distribution)
-- =========================================

INSERT INTO machine_metrics (machine_id, status, temperature, timestamp)
SELECT
'machine_' || (1 + floor(random() * 5))::int,
CASE
WHEN random() > 0.8 THEN 'failed'
ELSE 'running'
END,
60 + random() * 40,
NOW() - (random() * interval '24 hours')
FROM generate_series(1, 1000);


-- =========================================
-- Optional: Add Index for Performance
-- =========================================

CREATE INDEX idx_machine_time ON machine_metrics(timestamp);
CREATE INDEX idx_machine_id ON machine_metrics(machine_id);

-- =========================================
-- Verification Queries
-- =========================================

-- Total rows
SELECT COUNT(*) AS total_rows FROM machine_metrics;

-- Sample data
SELECT * FROM machine_metrics LIMIT 10;

-- Status distribution
SELECT status, COUNT(*) FROM machine_metrics GROUP BY status;
