/*
===============================================================================
Magnitude Analysis
===============================================================================
Purpose:
    - To quantify data and group results by specific dimensions.
    - For understanding data distribution across categories.

SQL Functions Used:
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
===============================================================================
*/

-- Find total customers by countries
SELECT
	country,
	COUNT(DISTINCT(customer_id)) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC

-- Find total customers by gender
SELECT
	gender,
	COUNT(DISTINCT(customer_key)) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC

-- Find total products by category
SELECT
	category,
	COUNT(DISTINCT(product_key)) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC

-- What is the average costs in each category?
SELECT
	category,
	AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC

-- What is the total revenue generate by each customer
SELECT
	gc.customer_key,
	gc.first_name,
	gc.last_name,
	SUM(gs.sales_amount) AS total_revenue
FROM gold.facts_sales AS gs
LEFT JOIN gold.dim_customers AS gc ON gc.customer_key = gs.customer_key
GROUP BY gc.customer_key, gc.first_name, gc.last_name
ORDER BY total_revenue DESC

-- What is the total revenue generate by each category
SELECT
	gp.category,
	SUM(gs.sales_amount) AS total_revenue
FROM gold.facts_sales AS gs
LEFT JOIN gold.dim_products AS gp ON gp.product_key = gs.product_key
GROUP BY gp.category
ORDER BY total_revenue DESC

-- What is the distribution of sold items across countries?
SELECT
	gc.country,
	SUM(gs.quantity) AS total_items
FROM gold.facts_sales AS gs
LEFT JOIN gold.dim_customers AS gc ON gc.customer_key = gs.customer_key
GROUP BY gc.country
ORDER BY total_items DESC
