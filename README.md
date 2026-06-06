# 🛒 E-commerce Sales & Customer Analytics
### Data Analytics Case Study — OlistMart S.A. | Brazil

![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat&logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791?style=flat&logo=postgresql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=flat&logo=powerbi&logoColor=black)
![Pandas](https://img.shields.io/badge/Pandas-Data%20Wrangling-150458?style=flat&logo=pandas&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-28a745?style=flat)
![Dataset](https://img.shields.io/badge/Dataset-Olist%20Brazilian%20E--Commerce-orange?style=flat)

---

## 📌 Project Overview

An end-to-end data analytics engagement on the **Olist Brazilian E-Commerce Public Dataset**, simulating a real-world analytics consulting project for **OlistMart S.A.** — a multi-category marketplace headquartered in São Paulo, Brazil.

The project covers the full analytics pipeline: raw data ingestion → cleaning & feature engineering → SQL business queries → Python visualisations → Power BI executive dashboard → strategic recommendations.

> **Bottom line:** Identified **R$2.6M–R$5.0M** in annual value creation opportunities across freight optimisation, customer retention, seller quality, and payment strategy.

---

## 📁 Table of Contents

- [Business Problem](#-business-problem)
- [Dataset](#-dataset)
- [Project Architecture](#-project-architecture)
- [Tech Stack](#-tech-stack)
- [Data Cleaning & Feature Engineering](#-data-cleaning--feature-engineering)
- [SQL Analysis — 11 Business Queries](#-sql-analysis--11-business-queries)
- [Python Analytics Workflow](#-python-analytics-workflow)
- [Power BI Dashboard](#-power-bi-dashboard)
- [Key Findings & Insights](#-key-findings--insights)
- [Strategic Recommendations](#-strategic-recommendations)
- [ROI Summary](#-roi-summary)
- [Project Structure](#-project-structure)
- [How to Run](#-how-to-run)

---

## 🚨 Business Problem

OlistMart faced **five interconnected operational challenges** by mid-2018:

| # | Problem | Impact |
|---|---------|--------|
| 01 | **Revenue Leakage** | Freight costs averaging 18–22% of order value eroding net margins |
| 02 | **Customer Churn** | Repeat purchase rate below 4% — structurally unsustainable |
| 03 | **Seller Quality Variance** | Tail of underperforming sellers damaging platform NPS |
| 04 | **Logistics SLA Gaps** | 7–8% of orders delivered late; no systematic tracking |
| 05 | **Payment Intelligence Gap** | No analysis on payment mix, instalment behaviour, or AOV by method |

---

## 📦 Dataset

**Source:** [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — Kaggle

| Property | Detail |
|----------|--------|
| Tables | 9 relational CSV files |
| Total Size | ~126 MB |
| Date Range | September 2016 – October 2018 |
| Orders | ~99,441 |
| Customers | ~96,000 unique |
| Sellers | ~3,095 |
| Products | ~32,951 |
| Reviews | ~100,000 |

### Schema Overview

```
orders ──────────────────────────────┐
    │                                │
order_items ──── products ────────── category_translation
    │
payments
    │
reviews ──── customers
    │
sellers ──── geolocation
```

### Key Tables

| Table | Rows | Purpose |
|-------|------|---------|
| `orders` | 99,441 | Master order lifecycle |
| `order_items` | 112,650 | Revenue & logistics cost data |
| `customers` | 99,441 | Customer identity & location |
| `payments` | 103,886 | Payment method & transaction value |
| `reviews` | 100,000 | Customer satisfaction signals |
| `products` | 32,951 | Product catalogue attributes |
| `sellers` | 3,095 | Seller geographic data |
| `geolocation` | ~1M | Geographic coordinate data |
| `category_translation` | 71 | Portuguese → English mapping |

---

## 🏗 Project Architecture

```
Raw CSVs (9 files)
        │
        ▼
Python Preprocessing (pandas)
  ├── Type standardisation
  ├── Missing value treatment
  ├── Feature engineering (6 derived metrics)
  ├── RFM segmentation
  └── Cohort assignment
        │
        ▼
PostgreSQL (olist_db via SQLAlchemy)
        │
        ▼
11 SQL Business Queries
        │
        ▼
Python Visualisations (matplotlib / seaborn)
        │
        ▼
Power BI Dashboard (4 pages)
        │
        ▼
Executive Business Report & Strategic Recommendations
```

---

## 🛠 Tech Stack

| Tool | Purpose |
|------|---------|
| **Python 3.10+** | Data ingestion, cleaning, feature engineering, visualisation |
| **pandas** | DataFrame manipulation, RFM scoring, cohort construction |
| **matplotlib / seaborn** | Revenue charts, seller scatter plots, retention heatmaps |
| **SQLAlchemy** | Python → PostgreSQL bridge |
| **PostgreSQL 15** | 11 analytical SQL queries |
| **Power BI** | 4-page executive dashboard |
| **Jupyter Notebook** | Interactive development environment |

---

## 🧹 Data Cleaning & Feature Engineering

### Cleaning Steps

| Step | Method | Business Impact |
|------|--------|-----------------|
| Type standardisation | `pd.to_datetime(errors='coerce')` on 5 timestamp columns | Enabled date arithmetic for SLA features |
| Missing delivery timestamps | Engineered boolean flags (`is_delivered`, `is_shipped`, `is_approved`) | No synthetic data — preserved SLA integrity |
| Review text nulls (~41–59%) | Filled with neutral placeholder strings | Clean NLP-ready text fields |
| Product dimension nulls (~0.4%) | Median imputation per column | Preserved statistical distributions |
| Geolocation duplicates | Deduplicated by zip code before joins | Accurate geographic joins |

### Engineered Features

```python
# 6 derived business metrics created:
delivery_delay_days   = order_delivered_customer_date - order_estimated_delivery_date
actual_delivery_days  = order_delivered_customer_date - order_purchase_timestamp
sla_breached          = delivery_delay_days > 0
net_revenue           = price - freight_value
order_month           = order_purchase_timestamp.dt.to_period('M')
order_status_clean    = 3-tier simplified status hierarchy
```

### RFM Segmentation

```python
# Quartile-based scoring using pd.qcut()
R = days since last delivered order   (4 = most recent)
F = count of unique delivered orders  (4 = most frequent)
M = sum of total payment value        (4 = highest spend)

# Segments:
Champions       → R=4, F=4, M=4   (~2,000 customers)
At-Risk         → R=2, F≥2        (~15,000 customers)
Hibernating     → R=1, F=1        (dormant base)
New Customers   → R=4, F=1
```

---

## 🗄 SQL Analysis — 11 Business Queries

| Q# | Business Question | Key Finding |
|----|-------------------|-------------|
| **Q1** | Monthly revenue trend — gross vs net? | Freight erodes 18–22% of GMV monthly; Nov 2017 peak (Black Friday) |
| **Q2** | Which categories generate most net revenue? | Health & Beauty and Watches lead; some categories exceed 30% freight ratio |
| **Q3** | What is the repeat purchase rate? | **~3–4%** — 97% of customers are one-time buyers |
| **Q4** | Top sellers by revenue vs rating? | High-revenue sellers ≠ high-rated; volume-quality tension visible |
| **Q5** | Platform-wide SLA compliance rate? | **~92–93%** on-time; avg late delay = 7–9 days |
| **Q6** | How does delay severity affect review scores? | On-time = 4.2★; 15+ days late = 2.2★ — **2-point collapse** |
| **Q7** | High-spend one-time buyers for re-engagement? | Thousands spent R$300–800+ once and never returned |
| **Q8** | Sellers with high late-ship AND low rating? | **~50–80 high-risk sellers** identified; some >40% late-ship rate |
| **Q9** | Revenue and AOV by payment method? | Credit card = **74% of GMV**; avg 3–4 instalments |
| **Q10** | Top sellers within each category? | #1 seller controls 40–70% of category revenue in most categories |
| **Q11** | Cohort retention by first-purchase month? | 2016 cohorts ~5–6% retention; 2017–2018 cohorts ~2–4% |

### Sample Query — Repeat Purchase Rate

```sql
WITH customer_order_counts AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*)                                            AS total_customers,
    SUM(CASE WHEN total_orders >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(
        SUM(CASE WHEN total_orders >= 2 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                                   AS repeat_rate_pct
FROM customer_order_counts;
```

### Sample Query — Seller Risk Identification

```sql
WITH seller_metrics AS (
    SELECT
        oi.seller_id,
        AVG(r.review_score)                                        AS avg_rating,
        COUNT(DISTINCT oi.order_id)                                AS total_orders,
        ROUND(
            SUM(CASE WHEN o.order_delivered_customer_date > oi.shipping_limit_date
                     THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
        )                                                          AS late_ship_pct
    FROM order_items oi
    JOIN orders o    ON oi.order_id    = o.order_id
    JOIN reviews r   ON o.order_id     = r.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id
)
SELECT *
FROM seller_metrics
WHERE avg_rating   < 3.0
  AND late_ship_pct > 20
ORDER BY avg_rating ASC;
```

---

## 🐍 Python Analytics Workflow

```
notebooks/
└── olist_analytics.ipynb
    ├── 01 — Data Ingestion (9 CSVs → DataFrames)
    ├── 02 — Type Standardisation & Missing Value Treatment
    ├── 03 — Feature Engineering (6 derived metrics)
    ├── 04 — RFM Segmentation (quartile-based scoring)
    ├── 05 — Cohort Construction (first-purchase month)
    ├── 06 — Revenue Analysis (GMV vs Net, dual-line chart)
    ├── 07 — Category Analysis (top-10 net revenue barplot)
    ├── 08 — Seller Risk Matrix (scatter: revenue vs rating)
    ├── 09 — Logistics Analysis (delay vs review score)
    ├── 10 — Cohort Retention Heatmap
    └── 11 — PostgreSQL Load (SQLAlchemy → olist_db)
```

### Key Visualisations Produced

| Chart | Insight Delivered |
|-------|------------------|
| GMV vs Net Revenue (dual-line) | Freight cost gap widening over time |
| Top-10 Category Net Revenue (barplot) | Health & Beauty leads; furniture lags |
| Seller Risk Scatter (bubble plot) | ~80 high-risk sellers in low-rating/high-volume quadrant |
| Delay vs Review Score (line chart) | Monotonic score drop with increasing delay |
| Cohort Retention Heatmap | Declining retention in newer acquisition cohorts |

---

## 📊 Power BI Dashboard

Four-page executive dashboard built on cleaned PostgreSQL data:

| Page | Focus | Key KPIs |
|------|-------|----------|
| **Page 1** | Revenue & Financial Performance | GMV, Net Revenue, Freight %, YoY Growth |
| **Page 2** | Customer Analytics & Retention | Repeat Rate, RFM Segments, Cohort Heatmap |
| **Page 3** | Seller Performance & Risk | Seller Revenue, Avg Rating, Risk Flag Count |
| **Page 4** | Logistics & Delivery Intelligence | SLA Compliance %, Avg Delay Days, Review by Delay Bucket |

---

## 💡 Key Findings & Insights

### 1. 97% One-Time Customer Rate
> The platform is an acquisition machine, not a retention machine. Every sale costs full CAC with near-zero repeat revenue recovery.

### 2. R$1M+ Annual Freight Leakage
> Freight costs consume 18–22% of gross revenue consistently. Some categories exceed 30%, making them net-margin negative after operational costs.

### 3. 2-Point Review Score Collapse from Delays
> On-time orders average **4.2★**. Orders delayed 15+ days average **2.2★** — a 2-point collapse driven purely by logistics failure.

### 4. 80+ High-Risk Sellers
> Sellers with `avg_rating < 3.0` AND `late_ship_pct > 20%` represent a concentrated, identifiable source of platform NPS damage.

### 5. R$500K+ Win-Back Opportunity
> Thousands of high-LTV one-time buyers spent R$300–800+ and never returned. A targeted win-back campaign could recover this dormant GMV at near-zero acquisition cost.

### 6. Credit Card Instalment Opportunity
> 74% of GMV flows through credit card with avg 3–4 instalments. Promoting 6–12 instalment plans on high-ticket categories could lift AOV by 20–30%.

---

## 📋 Strategic Recommendations

### Short-Term (0–3 Months)
| # | Action | Expected Impact |
|---|--------|-----------------|
| S1 | Launch high-LTV win-back email campaign (10–15% voucher) | R$1–2M GMV uplift |
| S2 | Offboard / probation: 20 worst-rated high-delay sellers | +0.15 platform rating |
| S3 | Deploy Power BI dashboard to ops & finance teams | Real-time SLA visibility |
| S4 | Escalate top 10 high-freight categories to logistics team | R$200K freight savings |
| S5 | Implement automated late-order SLA alert system | 5% SLA improvement |

### Medium-Term (3–12 Months)
| # | Action | Expected Impact |
|---|--------|-----------------|
| M1 | Launch tiered seller programme (Bronze/Silver/Gold) | +1pp retention per cohort |
| M2 | Negotiate category-level freight rate agreements | R$1M+ annual saving |
| M3 | Build ML-based delivery delay prediction model | -20% bad review rate |
| M4 | Launch instalment promotion on AOV > R$200 categories | +20% AOV in segment |

### Long-Term (1–3 Years)
| # | Action | Expected Impact |
|---|--------|-----------------|
| L1 | Build regional fulfilment centre in Northeast Brazil | Unlock R$5M+ GMV |
| L2 | Develop customer loyalty programme (points + tiers) | +5pp retention rate |
| L3 | Predictive LTV model for acquisition channel optimisation | -15% CAC |

---

## 💰 ROI Summary

| Initiative | Annual Value (R$) | Confidence |
|------------|-------------------|------------|
| Win-back campaign (10K customers × 15% response × R$150 AOV) | R$225,000 | Medium |
| Freight renegotiation (3pp saving on R$16M GMV) | R$480,000 | High |
| Seller offboarding (3pp SLA improvement → 2% GMV lift) | R$320,000 | Medium |
| Instalment promotion on AOV>R$200 categories | R$300,000 | Medium |
| Retention programme (2pp repeat rate improvement) | R$500,000 | Low–Medium |
| Regional fulfilment (10% NE GMV growth) | R$800,000 | Low |
| **Total Estimated Annual Value** | **R$2.6M – R$5.0M** | — |

> Net ROI: **180%–340%** over 24 months at an assumed 30% implementation cost ratio.

---

## 📂 Project Structure

```
ecommerce-sales-customer-analytics/
│
├── data/                        # Original Olist CSV files (not tracked in git)
│   │   ├── olist_orders_dataset.csv
│   │   ├── olist_order_items_dataset.csv
│   │   ├── olist_customers_dataset.csv
│   │   ├── olist_order_payments_dataset.csv
│   │   ├── olist_order_reviews_dataset.csv
│   │   ├── olist_products_dataset.csv
│   │   ├── olist_sellers_dataset.csv
│   │   ├── olist_geolocation_dataset.csv
│   │   └── product_category_name_translation.csv
│
├── notebooks/
│   └── analysis.ipynb         # Full end-to-end analysis notebook
│
├── sql/
│   ├── analytics_query.sql
│
├── dashboard/
│   └── Data_Analytics_Dashboard.pbix # Power BI dashboard file
│
├── reports/
│   └── Olist_Business_Case_Study.pdf # Full executive report
|
├── .gitignore
└── README.md
```

---

## ▶ How to Run

### Prerequisites

```bash
# Python 3.10+
pip install -r requirements.txt

# PostgreSQL 15 running locally
# Create database: olist_db
```

### requirements.txt

```
pandas>=2.0.0
numpy>=1.24.0
matplotlib>=3.7.0
seaborn>=0.12.0
sqlalchemy>=2.0.0
psycopg2-binary>=2.9.0
jupyter>=1.0.0
```

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/tusharrparihar/ecommerce-sales-customer-analytics.git
cd ecommerce-sales-customer-analytics

# 2. Download the Olist dataset from Kaggle
# https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
# Place all CSV files in data/raw/

# 3. Create PostgreSQL database
createdb olist_db

# 4. Run the notebook
jupyter notebook notebooks/olist_analytics.ipynb

# 5. (Optional) Run individual SQL queries against olist_db
psql -d olist_db -f sql/q03_repeat_purchase_rate.sql
```

### Environment Variables (optional)

```bash
# Create a .env file for database credentials
DB_HOST=localhost
DB_PORT=5432
DB_NAME=olist_db
DB_USER=tushar
DB_PASSWORD=tushar
```

---

## 📄 .gitignore

```
# Data files (large / not redistributable)
data/raw/
data/processed/
*.csv

# Jupyter checkpoints
.ipynb_checkpoints/

# Environment
.env
__pycache__/
*.pyc
venv/
.venv/

# OS
.DS_Store
Thumbs.db
```

---

## 📚 References

- Dataset: [Olist Brazilian E-Commerce Public Dataset — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- Original data provided by [Olist](https://olist.com/) under CC BY-NC-SA 4.0 licence

---

## 👤 Author

**Your Name**
- LinkedIn: [linkedin.com/in/tusharrparihar](https://linkedin.com/in/tusharrparihar)
- GitHub: [github.com/tusharrparihar](https://github.com/tusharrparihar)

---

*Analytics Consulting Engagement · OlistMart S.A. · June 2026 · Confidential*
