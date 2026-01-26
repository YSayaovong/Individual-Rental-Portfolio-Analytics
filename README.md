# Rental Portfolio Analytics Platform

This project applies data analytics, forecasting, and KPI engineering to analyze and project rental property performance. It highlights skills in ETL workflows, data preprocessing, financial modeling, exploratory analysis, and automated portfolio insights.

---

## Overview

The platform ingests rental, expense, and maintenance data across multiple properties and transforms it into actionable intelligence. It generates performance KPIs, forecasts cash flow and rent trends, evaluates ROI, and supports long-term decision-making for a real estate rental portfolio.
The project demonstrates an end-to-end analytics pipeline from raw data → cleaned datasets → forecasting → KPI reporting.

---

## Tech Stack

- Python  
- pandas, NumPy  
- Matplotlib, Seaborn  
- SQL (optional integration)  
- Scikit-learn  
- Power BI / Excel (optional dashboarding)  
- Jupyter Notebook  

---

## Features

- Automated ETL workflows for rental, expense, and maintenance data  
- KPI generation (cash flow, ROI, expense ratios, occupancy impact, rent cycle metrics, etc.)  
- Exploratory data analysis with visualizations  
- Financial and operational trend analysis  
- Forecasting for rent pricing, CAPEX planning, and portfolio performance  
- Modular code structure allowing scalable data pipelines  

---

## Project Structure

```
.
├── data/                         # Raw and processed datasets
├── notebooks/                    # Jupyter notebooks for ETL, EDA, KPIs, forecasting
├── etl/                          # Data ingestion & cleaning workflows
├── kpi_engine/                   # KPI calculations and financial metrics
├── forecasting/                  # Predictive models & evaluation
├── visuals/                      # Generated plots and charts
└── README.md                     # Documentation
```

---

## Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/YSayaovong/PropTech-Analytics-Platform-ETL-Forecasting-KPI-Engine.git
cd PropTech-Analytics-Platform-ETL-Forecasting-KPI-Engine
```

### 2. Install dependencies
```bash
pip install -r requirements.txt
```

### 3. Open notebooks
```bash
jupyter notebook
```

---

## Potential Enhancements

- Deploy forecasting and KPI engine as a REST API  
- Add a Power BI or Streamlit dashboard for real-time visualization  
- Integrate automated pipelines (Airflow/Prefect) for scheduled data updates  
- Expand forecasting models to include seasonal decomposition and advanced ML  
- Add anomaly detection for rent fluctuations or unusual expenses  

---

## License

This project is open-source under the MIT License.
