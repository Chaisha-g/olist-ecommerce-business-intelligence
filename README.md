# Olist E-Commerce | SQL & Tableau Business Intelligence

### End-to-End Data Analytics Portfolio Project 2

## Project Overview

Analyzed historical Brazilian e-commerce transactions from the **Olist Brazilian E-Commerce Public Dataset** to explore revenue performance, customer purchasing behavior, product category performance, seller contributions, and geographic sales distribution.

This project demonstrates an end-to-end data analytics workflow using **MySQL for data preparation and analysis and Tableau for interactive business intelligence visualization**.

**Tools:** MySQL | MySQL Workbench | Tableau | GitHub

**Dataset:** Olist Brazilian E-Commerce Public Dataset (2016–2018)

**Project Type:** Data Cleaning, Data Validation, Exploratory Data Analysis (EDA), Customer Analytics, Revenue Analysis, Business Intelligence & Data Visualization

---

## Interactive Tableau Dashboard

**Dashboard:** Olist E-Commerce | Sales & Business Intelligence Dashboard

The interactive Tableau dashboard includes five key performance indicators:

1. Total Orders
2. Total Revenue
3. Total Customers
4. Average Order Value
5. Repeat Customer Rate

The dashboard also includes five business visualizations:

1. Monthly Revenue Trend
2. Top 10 Product Categories
3. Revenue by Customer State
4. Top 10 Sellers by Revenue
5. Top 10 Customer Cities by Revenue

The dashboard allows users to explore historical e-commerce performance through interactive visualizations.

**[Explore the Interactive Tableau Dashboard](PASTE_YOUR_TABLEAU_PUBLIC_LINK_HERE)**

---

## Business Questions

This project addresses eight key analytical questions:

1. How much revenue did the marketplace generate during the analyzed period?
2. How did monthly revenue change over time?
3. Which product categories contributed the most revenue?
4. Which sellers generated the highest merchandise sales?
5. Which Brazilian states and cities contributed the most revenue?
6. What was the average order value?
7. What percentage of customers made repeat purchases?
8. How did delivery performance and customer satisfaction vary across orders?

---

## Data Analytics Workflow

### 1. Data Import | MySQL

Imported the Olist e-commerce dataset into a relational MySQL database.

The database contains nine related tables covering orders, customers, products, sellers, payments, reviews, and geographic information.

**Database:** `olist_business_intelligence`

### 2. Data Profiling | SQL

Examined the dataset to understand its structure, record counts, relationships, and potential data quality issues.

Performed validation checks across the imported tables to identify missing records and inconsistencies.

### 3. Data Cleaning & Validation | SQL

Prepared the dataset for business analysis by reviewing data completeness and relational consistency.

Identified **611 missing product records** during validation and restored them to the products table.

Verified the corrected dataset before continuing with analytical queries.

### 4. Exploratory Data Analysis | SQL

Analyzed revenue trends, product categories, seller performance, geographic distribution, and customer purchasing behavior.

Developed SQL queries using joins, aggregations, conditional logic, common table expressions, and window functions.

### 5. Business Insights | SQL

Developed analytical queries to evaluate:

- Monthly revenue growth
- Average order value
- Customer retention
- Product category revenue contribution
- Seller performance
- Geographic revenue distribution
- Payment methods
- Delivery performance
- Customer satisfaction

**SQL Script:** `Olist_Ecommerce_Business_Analysis.sql`

### 6. Interactive Visualization | Tableau

Developed a Tableau business intelligence dashboard containing five executive KPIs and five analytical visualizations.

The dashboard communicates key findings through revenue trends, geographic comparisons, product performance, seller contributions, and customer metrics.

---

## Key Findings

### 1. Total Revenue Reached R$13.22 Million

| Business Metric | Result |
|---|---:|
| Total Orders | 96,478 |
| Total Revenue | R$13.22M |
| Total Customers | 93,358 |
| Average Order Value | R$137.04 |
| Repeat Customer Rate | 3.00% |

**Insight:** The analyzed marketplace transactions generated approximately **R$13.22 million in merchandise revenue**, with an average order value of **R$137.04**.

### 2. Revenue Increased Over Time

Monthly revenue generally increased throughout the main operating period represented in the dataset.

The monthly revenue visualization highlights substantial growth during 2017 and continued strong sales activity during much of 2018.

**Insight:** The marketplace experienced significant historical revenue growth, although monthly performance fluctuated.

### 3. Health & Beauty Was a Leading Product Category

The highest revenue-generating product categories included:

| Product Category |
|---|
| Health & Beauty |
| Watches & Gifts |
| Bed, Bath & Table |
| Sports & Leisure |
| Computers & Accessories |

**Insight:** Revenue was concentrated across several major product categories, with Health & Beauty and Watches & Gifts among the strongest contributors.

### 4. Customer Retention Was Approximately 3%

| Customer Metric | Result |
|---|---:|
| Total Customers | 93,358 |
| Repeat Customer Rate | 3.00% |

**Insight:** Approximately **3% of customers** made repeat purchases in the analyzed dataset, suggesting that most customers purchased only once during the observed period.

### 5. São Paulo Was a Major Revenue Contributor

Geographic analysis revealed substantial differences in revenue across Brazilian states.

São Paulo (SP) generated the highest merchandise revenue among the states represented in the dashboard.

**Insight:** Geographic revenue concentration highlights the importance of major regional markets to marketplace performance.

### 6. Seller Revenue Varied Significantly

Analysis of the top 10 sellers identified differences in revenue contributions across marketplace sellers.

**Insight:** Seller-level performance analysis can help identify high-performing sellers and opportunities for further marketplace evaluation.

---

## Repository Structure

| File | Description |
|---|---|
| `Olist_Ecommerce_Business_Analysis.sql` | SQL data validation, exploratory analysis, and business intelligence queries |
| `README.md` | Project overview, methodology, findings, and documentation |
| `dashboard.png` | Tableau business intelligence dashboard screenshot |

---

## Technical Skills Demonstrated

### SQL & MySQL

- Relational database management
- Data importing and querying
- Data profiling and validation
- Data cleaning and quality assessment
- Multi-table joins
- Common table expressions (CTEs)
- Window functions
- Aggregate functions
- Revenue and customer analysis
- Business-focused analytical queries

### Tableau

- Interactive dashboard development
- KPI creation
- Calculated fields
- Time-series visualization
- Revenue trend analysis
- Geographic performance visualization
- Product and seller comparisons
- Business intelligence reporting

### Business Analytics

- Revenue performance evaluation
- Customer retention analysis
- Average order value calculation
- Product category performance
- Seller performance analysis
- Geographic market analysis
- Translating data into business insights

### GitHub

- Version control
- Project documentation
- Portfolio presentation

---

## Project Limitations

- This project analyzes historical e-commerce transactions from **2016–2018**, not current marketplace performance.
- Revenue represents merchandise sales value and should not be interpreted as net profit.
- The first and last months of the dataset may contain incomplete transaction periods.
- Customer retention calculations reflect purchasing behavior within the available historical dataset.
- Findings are based on the available transaction records and may not represent the marketplace's complete business operations.
- Geographic analysis reflects customer locations recorded in the dataset.

---

## Conclusion

This project demonstrates a structured, end-to-end data analytics workflow, transforming historical e-commerce transaction data into meaningful business insights using **MySQL and Tableau**.

The analysis highlights revenue growth, customer retention, product category performance, seller contributions, and geographic sales patterns.

By combining SQL-based analysis with interactive business intelligence visualization, the project demonstrates practical skills in data preparation, analytical problem-solving, KPI development, and communicating business performance.

**[Explore the Interactive Tableau Dashboard](PASTE_YOUR_TABLEAU_PUBLIC_LINK_HERE)**
