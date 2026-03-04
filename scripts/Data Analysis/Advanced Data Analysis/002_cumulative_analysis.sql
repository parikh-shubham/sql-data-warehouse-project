/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the total sales per month and the running total of sales over time
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales
FROM(
SELECT
	DATETRUNC(month, order_date) AS order_date,
	SUM(sales_amount) AS total_sales
FROM gold.facts_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)) AS t

-- Calculate the total sales per month and the running avg of sales over time 
SELECT
	order_date,
	total_sales,
	avg_sales,
	SUM(avg_sales) OVER(ORDER BY order_date) AS running_avg
FROM(
SELECT
	DATETRUNC(month, order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(sales_amount) AS avg_sales
FROM gold.facts_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)) AS t
