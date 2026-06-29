# Telecom Subscriber Churn Prediction Pipeline

## 📌 Project Overview
In saturated telecommunications markets, preventing subscriber churn delivers a significantly higher ROI than acquiring new accounts. This repository contains an end-to-end, production-ready operational pipeline designed to proactively discover at-risk accounts and execute automated retention workflows.

The architecture bridges the gap between data engineering and machine learning by isolating raw file imports, managing a structured MySQL data warehouse, training an optimized ensemble classifier, and providing explainable post-hoc triggers for downstream customer service systems.

## 🛠️ Tech Stack & Tools
* **Database Warehousing:** MySQL (Star Schema layout, Set-based views)
* **Language & Core Environment:** Python 3.x
* **Data Engineering Libraries:** Pandas, NumPy
* **Machine Learning Framework:** Scikit-Learn (Ensemble Methods)
* **Model Explainability:** ELI5 (Post-hoc feature extraction)

## 🏗️ Pipeline Architecture & Steps

### 1. Data Ingestion & Star Schema Design (SQL)
* Raw flat-file CSV logs are systematically routed into an isolated staging table (`raw_churn_staging`) to validate structure integrity and prevent downstream schema drift.
* A two-phase normalization script builds a performance-tuned Star Schema comprising a compact `customers` dimension table (shrinking cardinality via binary plan flags) and a pre-aggregated `customer_usage_fact` fact table.

### 2. Warehouse Logic & Behavioral Cohorts
* To minimize operational latency, customer behavioral classification rules are embedded directly into the MySQL engine, facilitating weekly batch segmentation scans without exhausting machine learning computing overhead:
  * **At Risk:** Accounts experiencing customer service calls $\ge 3$ OR total day usage $> 280$ minutes.
  * **Loyal:** Active accounts with a baseline history exceeding 120 billing cycles and zero churn markers.
  * **Active Standard:** Baseline accounts operating within expected usage thresholds.

### 3. Predictive Modeling & Diagnostics
* High-cardinality text coordinates (e.g., area codes, states) are removed via Python to keep the feature matrix dense.
* Multi-collinearity between talk minutes and financial billing charges is handled robustly via a **Random Forest Classifier** ($n_{estimators}=100$).
* Implemented an 80/20 train/test split utilizing **stratified sampling** to safely respect the minority churn class baseline ($\sim 14.2\%$).

### 📈 Model Evaluation Metrics
* **Overall Test Accuracy:** 94.5%
* **Churn Class Precision:** 0.92 (Minimizes wasted retention budget on false-positive alerts)
* **Churn Class Recall:** 0.63
* **F1-Score:** 0.75

### 4. Explainability & Automation Triggers
* **ELI5 Extraction:** Post-hoc transparency analysis isolated a drop in daytime usage alongside a spike in support hotline friction as the absolute dominant drivers of account attrition.
* **Automated Support Webhook:** System triggers fire an API webhook whenever a customer hits $\ge 3$ support calls within 60 days, routing the subscriber profile to an elite retention squad.
* **High-Usage Migration Engine:** Automated weekly scripts scan the "At Risk" database partition to offer flat-rate contract upgrades, converting highly volatile billings into secured contracts.

## 🔮 Future Recommendations
* Implement continuous feature drift monitoring to track shifts in baseline consumer behavior.
* Orchestrate an automated data-quality alerting loop tracking staging-to-fact ETL operations.
