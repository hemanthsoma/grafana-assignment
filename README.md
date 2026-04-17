# Grafana Data Engineer Assignment

## 📌 Overview

This project demonstrates a minimal yet production-oriented Grafana integration pipeline using PostgreSQL as the data source. The focus is on clean data flow, practical visualization, and integration-ready design.

---

## ⚙️ Tech Stack

* Grafana (Visualization Layer)
* PostgreSQL (Data Storage)
* Python (Data Simulation - optional)
* macOS Local Setup

---

## 🔄 Data Flow

```
Data Generator (Python / SQL)
        ↓
PostgreSQL Database
        ↓
Grafana (via PostgreSQL Data Source)
        ↓
Dashboard Visualization
```

---

## 🗄️ Database Setup

### Create Database

```sql
CREATE DATABASE grafana_demo;
```

### Create Table

```sql
CREATE TABLE machine_metrics (
    id SERIAL PRIMARY KEY,
    machine_id TEXT,
    status TEXT,
    temperature FLOAT,
    timestamp TIMESTAMP
);
```

---

## 📊 Data Generation

Synthetic data was generated using PostgreSQL:

```sql
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
```

---

## 📈 Grafana Dashboard

### Dashboard Name:

**Machine Monitoring Dashboard**

### Panels

1. **Machine Status Distribution**

   * Type: Bar Chart
   * Shows count of machines by status

2. **Temperature Trend Over Time**

   * Type: Time Series
   * Filtered using machine variable

3. **Average Machine Temperature**

   * Type: Stat Panel

---

## 🎛️ Variables

* `machine`

```sql
SELECT DISTINCT machine_id FROM machine_metrics;
```

---

## 🖼️ Dashboard Preview

![Dashboard](screenshots/dashboard.png)

---

## 🔌 Integration Readiness

This setup is designed to be easily integrated into a larger system (e.g., CMMS) by:

* Using PostgreSQL as a shared data layer
* Keeping Grafana as a separate visualization service
* Supporting dynamic filtering via variables

---

## 🚀 How to Run

1. Start PostgreSQL
2. Create database and table
3. Insert sample data
4. Start Grafana:

   ```
   brew services start grafana
   ```
5. Open http://localhost:3000
6. Add PostgreSQL data source
7. Import dashboard JSON from `/dashboards`

---

## 📁 Deliverables

* Dashboard JSON: `/dashboards/machine-monitoring-dashboard.json`
* SQL Setup: `/data/sample_data.sql`
* Screenshot: `/screenshots/dashboard.png`

---

## 💡 Notes

* Focus was on simplicity, clarity, and real-world data flow
* Avoided over-engineering to align with assignment scope
* Designed with scalability and integration in mind

---
