/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- Find the total sales
SELECT
	SUM(sales_amount) AS total_sales
FROM gold.facts_sales

-- Find how many items are sold
SELECT
	SUM(quantity) AS total_items_sold
FROM gold.facts_sales

-- Find the avg selling price
SELECT
	AVG(sales_amount) AS average_selling_price
FROM gold.facts_sales

-- Find the total number of orders
SELECT
	COUNT(DISTINCT(order_number)) AS total_orders
FROM gold.facts_sales

-- Find the total number of products
SELECT
	COUNT(DISTINCT(product_name)) AS total_product 
FROM gold.dim_products

-- Find the total number of customers
SELECT
	COUNT(DISTINCT(customer_key)) AS total_customers
FROM gold.dim_customers
	
-- Find the total number of customers that has places an order
SELECT
	COUNT(DISTINCT(customer_key)) AS total_customers_orders
FROM gold.facts_sales
WHERE order_number IS NOT NULL
