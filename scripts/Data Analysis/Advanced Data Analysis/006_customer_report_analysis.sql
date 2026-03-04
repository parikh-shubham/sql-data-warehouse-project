/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

CREATE VIEW gold.report_customers AS 

WITH base_query AS (
/* -----------------------------------------------------
1) Base Query: Retrieves core columns from tables 
------------------------------------------------------- */
SELECT
	gs.order_number,
	gs.product_key,
	gs.order_date,
	gs.sales_amount,
	gs.quantity,
	gc.customer_key,
	gc.customer_number,
	CONCAT(gc.first_name, ' ', gc.last_name) AS customer_name,
	DATEDIFF(year,gc.birthdate, GETDATE()) AS age
FROM gold.facts_sales AS gs
LEFT JOIN gold.dim_customers AS gc ON gs.customer_key = gc.customer_key
WHERE order_date IS NOT NULL
)

, customer_aggregation AS (
/* -------------------------------------------------------------------- 
2) Customer Aggregations: Summarizes key metrics at the customer level
----------------------------------------------------------------------- */
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT(order_number)) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT(product_key)) AS total_products,
	MAX(order_date) AS last_order,
	DATEDIFF(month,MIN(order_date), MAX(order_date)) AS life_span 
FROM base_query
GROUP BY customer_key, customer_number, customer_name, age
) 

SELECT
	customer_key,
	customer_number,
	customer_name,
	CASE	
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50 and above'
	END AS age_segmentation,
	CASE
		WHEN life_span >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN life_span >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segment,
	DATEDIFF(month,last_order, GETDATE()) AS recency,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	life_span,
	-- Compute average order value (AVO)
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders 
	END AS avg_order_value,
	-- Compute average monthly spend
	CASE
		WHEN life_span = 0 THEN total_sales
		ELSE total_sales / life_span
	END AS avg_monthly_spend
FROM customer_aggregation ;
