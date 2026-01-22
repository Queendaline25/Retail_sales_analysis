# Retail_sales_analysis  
An end‑to‑end SQL analytics project exploring sales performance, profitability, customer behaviour, shipping efficiency, and discount impact using the Superstore dataset (9,994 records).
## Dataset Overview
The Superstore dataset contains 9,994 rows of retail transactions, including order details, customer information, product categories, shipping methods, discounts, sales, and profit. 

## Objectives of the Analysis
The analysis answered all the below questions
- Which ship modes are used most frequently
- Which ship modes are associated with losses
- How profit changes as discount levels increase
- Running total of sales over time
- Monthly sales, profit, and profit margin
- Ranking cities within each region by total profit
- Products most frequently sold with high discounts
- Rank sub-categories by profit within each category
- Does faster shipping correlate with higher profit?

##  Tools & Technologies Used
-  MySQL (core analysis)
-  VS Code (SQL development)
- Git & GitHub (version control)

## SQL Techniques Demonstrated
- Window functions (RANK, SUM OVER, LAG)
- Aggregations & grouping
- CTEs
- Date functions (DATE_TRUNC, DATEDIFF)
- Creating SQL views
- Filtering with HAVING
- Profit margin calculations
- Discount bucketing
## Key Insights & Findings
Standard Class was the most frequently used ship mode.
- Same Day shipping showed the highest proportion of unprofitable orders.
- Profit declines sharply when discounts exceed 20%.
- Technology category drives the highest profit margin.
- Certain cities consistently outperform others within their regions.
- Monthly sales show strong seasonality (e.g., spikes in Q4).
- Running total analysis shows steady growth with occasional dips.

## How to Reproduce the Analysis
- Import dataset into MySQL
- Run scripts in /sql

## Future Improvements
- Build a dashboard
- Add predictive modelling (e.g., forecast sales)
- Automate ETL

## Acknowledgements
Dataset: Superstore sample dataset
(Commonly used for analytics education and BI demos).