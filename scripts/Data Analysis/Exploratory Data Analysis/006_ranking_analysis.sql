/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- Which 5 products generate the highest revenue?
SELECT TOP 5
	gp.product_name,
	SUM(gs.sales_amount) AS total_sales
FROM gold.facts_sales AS gs
LEFT JOIN gold.dim_products AS gp ON gs.product_key = gp.product_key
GROUP BY gp.product_name
ORDER BY total_sales DESC

-- What are the 5 worst-performing products in terms of sales?
SELECT
	gp.product_name,
	SUM(gs.sales_amount) AS total_sales
FROM gold.facts_sales AS gs
LEFT JOIN gold.dim_products AS gp ON gs.product_key = gp.product_key
GROUP BY gp.product_name
ORDER BY total_sales

-- Find the top 10 customers who have generated the highest revenue
SELECT TOP 10
	gc.customer_key,
	gc.first_name,
	gc.last_name,
	SUM(gs.sales_amount) AS total_revenue
FROM gold.facts_sales AS gs
LEFT JOIN gold.dim_customers AS gc ON gs.customer_key = gc.customer_key
GROUP BY gc.customer_key, gc.first_name, gc.last_name
ORDER BY total_revenue DESC

-- Find 3 customers with the fewest orders placed
SELECT TOP 3
	gc.customer_key,
	gc.first_name,
	gc.last_name,
	COUNT(DISTINCT(gs.order_number)) AS total_orders
FROM gold.facts_sales AS gs
LEFT JOIN gold.dim_customers AS gc ON gs.customer_key = gc.customer_key
GROUP BY gc.customer_key, gc.first_name, gc.last_name
ORDER BY total_orders ASC
