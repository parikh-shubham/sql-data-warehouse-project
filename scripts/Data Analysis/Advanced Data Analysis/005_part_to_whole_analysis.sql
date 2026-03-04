/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/

-- Which category contribute the most to overall sales
WITH category_sales AS (
SELECT
	gp.category,
	SUM(sales_amount) AS total_sales
FROM gold.facts_sales AS gs
LEFT JOIN gold.dim_products AS gp ON gs.product_key = gp.product_key
GROUP BY gp.category 
)

SELECT
	category,
	total_sales,
	SUM(total_sales) OVER() AS overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales) OVER())*100, 2), '%') AS percentage_contribution
FROM category_sales
ORDER BY total_sales DESC
