# Grafana Data Engineer Assignment

---

## 📌 Overview

This project demonstrates a minimal yet production-oriented Grafana integration pipeline using PostgreSQL as the data source. The focus is on clean data flow, practical visualization, and integration-ready system design.

The solution is divided into:

* **Part A**: Working Grafana dashboard with PostgreSQL
* **Part B**: Integration of Grafana into an on-premise CMMS product

---

## ⚙️ Tech Stack

* Grafana (Visualization Layer)
* PostgreSQL (Data Storage)
* Python (Data Simulation - optional)
* macOS Local Setup

---

# 🔹 PART A — Visualization Implementation

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
   * Displays count of machines grouped by status

2. **Temperature Trend Over Time**

   * Type: Time Series
   * Supports filtering via machine variable


---

## 🎛️ Variables

* `machine`

```sql
SELECT DISTINCT machine_id FROM machine_metrics;
```

---

## 🖼️ Dashboard Preview

![Dashboard](screenshots/part_a.png)

---

## 🔌 Integration Readiness

This implementation is designed with integration in mind:

* PostgreSQL acts as a shared data layer
* Grafana is kept as a separate visualization service
* Dashboard supports dynamic filtering via variables

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

# 🔹 PART B — Grafana Integration Design (CMMS)

---

## 🎯 Objective

Design how Grafana can be integrated into an on-premise CMMS (Computerized Maintenance Management System) to provide seamless monitoring capabilities.

---

## 🏗️ Architecture Overview

```
[ User (Browser) ]
        ↓
[ CMMS Frontend ]
        ↓
[ CMMS Backend (API Layer) ]
        ↓ (Reverse Proxy + Auth)
[ Grafana Server ]
        ↓
[ PostgreSQL Database ]
```

---

## 🧩 Component Responsibilities

### CMMS Frontend

* Primary user interface
* Provides navigation (e.g., Monitoring section)
* Embeds Grafana dashboards via iframe

### CMMS Backend

* Handles authentication and session management
* Acts as a reverse proxy for Grafana
* Injects authentication tokens

### Grafana

* Visualization layer
* Queries PostgreSQL
* Renders dashboards

### PostgreSQL

* Stores machine and operational data
* Serves as a central data layer

---

## 🔌 Integration Approach

### Selected Approach:

**Hybrid (Reverse Proxy + iframe embedding)**

---

### How It Works

1. User accesses monitoring page in CMMS
2. CMMS embeds Grafana dashboard using iframe
3. Requests are routed through backend reverse proxy
4. Authentication context is injected
5. Grafana renders dashboards securely

---

### Why This Approach

* Seamless user experience (no context switching)
* Centralized authentication control
* No modification to Grafana core
* Suitable for production environments

---

### Tradeoffs

| Approach               | Pros     | Cons                  |
| ---------------------- | -------- | --------------------- |
| iframe only            | Simple   | Security limitations  |
| API-based              | Flexible | High complexity       |
| Reverse Proxy + iframe | Balanced | Slight setup overhead |

---

## 🔐 Authentication Design

### Method:

**JWT-based Single Sign-On (SSO)**

---

### Authentication Flow

```
1. User logs into CMMS
2. CMMS backend generates JWT token
3. User navigates to monitoring page
4. Request passes through reverse proxy
5. Token is validated by Grafana
6. Dashboard loads without additional login
```

---

### Security Considerations

* Centralized authentication in CMMS
* Grafana not exposed publicly
* Token-based access control
* HTTPS enforced
* Role-based access control (RBAC)

---

## 👤 User Access Flow

```
Login → CMMS Dashboard → Monitoring → Embedded Grafana Dashboard
```

---

## 🧩 Component Separation

| Component     | Type        |
| ------------- | ----------- |
| Grafana       | Open Source |
| CMMS          | Proprietary |
| Backend Proxy | Proprietary |
| PostgreSQL    | Open Source |

---

## 🧠 Data Flow in Integrated System

```
System / Machines → Data Ingestion → PostgreSQL
Grafana → Query PostgreSQL → Render Dashboards
User → Access via CMMS → View Insights
```

---

## 🔐 Design Principles

* Loose coupling between components
* Grafana used as independent service
* No modification to Grafana core (AGPL-safe)
* Backend-controlled access layer
* Separation of concerns

---

## 🚀 Scalability Considerations

* Grafana can scale independently
* PostgreSQL can be optimized or replaced (e.g., time-series DB)
* Backend proxy can handle routing and access control

---

# 🔹 PART C — Engineering Decisions

---

## Q1. Integration Approach Rationale

### Selected Approach:

Hybrid integration using **Reverse Proxy + iframe embedding**

### Reasoning:

This approach allows Grafana dashboards to be seamlessly embedded within the CMMS UI while maintaining centralized control over authentication and access through the backend.

### Tradeoff Analysis:

| Approach                        | Pros                              | Cons                                     |
| ------------------------------- | --------------------------------- | ---------------------------------------- |
| iframe only                     | Simple to implement               | Weak security, no auth control           |
| API-based integration           | Full customization                | High complexity, longer development time |
| Reverse Proxy + iframe (Chosen) | Balanced security, simplicity, UX | Slight setup overhead                    |

### Final Decision:

The hybrid approach provides the best balance between **security, implementation simplicity, and user experience**, making it suitable for both prototype and production environments.

---

## Q2. AGPL License Risk Management

### Problem:

Grafana OSS is licensed under AGPL, which requires source code disclosure if modified and distributed.

### Approach:

* Use Grafana as an **unmodified standalone service**
* Avoid altering Grafana core code
* Perform all custom logic in CMMS backend

### Mitigation Strategy:

* Integrate via APIs and embedding only
* Keep proprietary logic outside Grafana

### Final Decision:

Grafana is treated as an independent service to **avoid AGPL obligations**, ensuring no requirement to disclose proprietary CMMS code.

---

## Q3. 100x Data Growth Scenario

### First Bottleneck:

PostgreSQL performance under large-scale time-series workloads

### Scaling Strategy:

1. **Query Optimization**

   * Add indexes (timestamp, machine_id)
   * Optimize Grafana queries

2. **Table Partitioning**

   * Partition data by time (daily/monthly)

3. **Time-Series Database Migration**

   * TimescaleDB (PostgreSQL extension)
   * ClickHouse (high-performance analytics DB)

4. **Data Retention Policies**

   * Archive or delete old data
   * Keep recent data for fast access

### Tradeoffs:

| Solution           | Pros             | Cons                         |
| ------------------ | ---------------- | ---------------------------- |
| PostgreSQL scaling | Simple           | Limited at large scale       |
| TimescaleDB        | Easy migration   | Slight overhead              |
| ClickHouse         | High performance | Additional system complexity |

### Final Decision:

Start with PostgreSQL optimization, then migrate to a **time-series optimized database** as data grows.

---

## Q4. SaaS Transition Considerations

### Key Changes:

#### 1. Multi-Tenancy

* Introduce tenant isolation:

  * Shared DB with tenant_id
  * OR separate DB per tenant

#### 2. Grafana Layer

* Use **Grafana Organizations** for tenant isolation

#### 3. Authentication

* Integrate with centralized Identity Provider (OAuth/SSO)

#### 4. Security

* Enforce tenant-level RBAC
* API gateway for access control

#### 5. Infrastructure

* Containerization (Docker/Kubernetes)
* Enable auto-scaling

### Tradeoffs:

| Approach               | Pros             | Cons                   |
| ---------------------- | ---------------- | ---------------------- |
| Separate DB per tenant | Strong isolation | Higher cost            |
| Shared DB              | Cost efficient   | Complex access control |

### Final Decision:

Adopt a **multi-tenant architecture with tenant-aware data isolation and scalable infrastructure**, ensuring both security and cost efficiency.

---

# 🔹 PART D — ML Insights Panel Extension (Custom Grafana Plugin)

---

## 🎯 Overview

I developed a custom Grafana panel extension called **ML Insights**, designed to provide predictive analytics on system metrics (e.g., CPU usage).

The panel offers two modes:

* **Quick Visuals** → On-demand predictive analysis
* **Stream Visuals** → Real-time predictive insights

This extends Grafana from a visualization tool into a **predictive monitoring system**.

---

## 🏗️ Architecture

```text
Grafana Panel (React + TypeScript)
            ↓ (HTTP / Streaming API)
FastAPI Backend (ML Inference Layer)
            ↓
Machine Learning Models (scikit-learn)
            ↓
PostgreSQL / Metric Data
```

---

## ⚙️ Backend — FastAPI + ML Models

The backend is implemented using FastAPI and serves as an **ML inference layer**.

### Technologies Used:

* FastAPI (API layer)
* StreamingResponse (real-time updates)
* scikit-learn:

  * Ridge Regression
  * Huber Regressor (robust to outliers)
  * Polynomial Features (trend modeling)
  * Isolation Forest (anomaly detection)

---

## 🧠 ML Capabilities

### 1. Predictive Analysis

* Forecasts future values of metrics (e.g., CPU usage)
* Uses regression models for trend prediction

### 2. Anomaly Detection

* Detects unusual spikes or drops in metrics
* Implemented using Isolation Forest

---

## 📊 Panel Modes

---

### ⚡ Quick Visuals (Batch Prediction)

**Description:**

* Performs on-demand analysis when user loads the panel
* Returns predictions and anomalies in a single response

**Flow:**

```text
User → Panel Load → API Call → ML Model → JSON Response → Visualization
```

**Use Case:**

* Quick insights into system behavior
* Historical trend analysis

---

### 🔴 Stream Visuals (Real-Time Prediction)

**Description:**

* Provides continuous, real-time predictive insights
* Uses streaming responses from backend

**Flow:**

```text
User → Panel → Streaming API → Continuous ML Inference → Live Updates
```

**Implementation:**

* FastAPI `StreamingResponse` used for pushing updates
* Simulates real-time monitoring scenarios

**Use Case:**

* Live anomaly detection
* Real-time system monitoring

---

## 🔄 Data Flow

```text
Metrics Data → FastAPI → ML Processing → API/Stream Response → Grafana Panel → User
```

---

## 🎨 Frontend — Grafana Panel (React + TypeScript)

### Responsibilities:

* Provide toggle between **Quick** and **Stream** modes
* Fetch data from backend APIs
* Render predictions and anomalies visually

### Features:

* Interactive UI for switching modes
* Real-time updates for streaming mode
* Visualization of predicted vs actual values

---

## 🔐 Security & Design Considerations

* Backend abstracts ML logic from frontend
* No direct database access from Grafana
* API layer can be secured via token-based authentication
* Supports integration into enterprise environments

---

## 🚀 Key Benefits

* Adds **predictive intelligence** to Grafana dashboards
* Enables **real-time anomaly detection**
* Demonstrates integration of **ML + observability**
* Keeps architecture modular and scalable

---

## 💡 Summary

The ML Insights panel transforms Grafana into a **proactive monitoring system** by combining:

* Custom panel plugins (React + TypeScript)
* FastAPI backend for ML inference
* Real-time streaming and batch prediction modes

This approach enables advanced analytics while maintaining a clean separation between visualization and computation layers.

### ▶️ Full Demo Video

[Download / Watch Demo](screenshots/ml_insights_demo.mov)

---


# 📁 Deliverables

* Dashboard JSON: `/dashboards/machine-monitoring-dashboard.json`
* SQL Setup: `/data/sample_data.sql`
* Screenshot: `/screenshots/part_a.png`

---

# 💡 Notes

* Focused on simplicity, clarity, and production readiness
* Avoided over-engineering while maintaining scalability
* Designed with real-world integration scenarios in mind

---
