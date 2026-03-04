/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/

CREATE VIEW gold.report_product AS

WITH product_base_query AS (
SELECT
	gp.product_name,
	gp.product_key,
	gp.category,
	gp.subcategory,
	gp.cost,
	gs.order_number,
	gs.sales_amount,
	gs.quantity,
	gs.customer_key,
	gs.order_date
FROM gold.facts_sales AS gs
LEFT JOIN gold.dim_products AS gp ON gs.product_key = gp.product_key
WHERE order_date IS NOT NULL
)

, product_aggregation AS ( 
SELECT
	product_name,
	product_key,
	category,
	subcategory,
	cost,
	COUNT(DISTINCT(order_number)) AS total_orders,
	SUM(sales_amount) AS total_sales,
	COUNT(quantity) AS total_quantity,
	COUNT(DISTINCT(customer_key)) AS total_customer,
	MAX(order_date) AS last_order,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS life_span,
	ROUND(AVG(CAST(sales_amount AS FLOAT)/ NULLIF(quantity,0)),1) AS avg_selling_price
FROM product_base_query
GROUP BY product_name, product_key, category, subcategory, cost
)

SELECT
	product_name,
	product_key,
	category,
	subcategory,
	cost,
	last_order,
	total_orders,
	CASE
		WHEN total_sales >= 50000 THEN 'High-Performers'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS average_revenue,
	CASE
		WHEN life_span = 0 THEN total_sales
		ELSE total_sales / life_span
	END AS avg_monthly_revenue,
	DATEDIFF(month, last_order, GETDATE()) AS months_since_last_order,
	life_span,
	total_sales,
	total_quantity,
	total_customer,
	avg_selling_price
FROM product_aggregation
