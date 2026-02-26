/*
==========================================================================================
Quality Checks
==========================================================================================
Script Purpose:
  This script performs various  quality checks for data consistency, accuracy,
  and standardization across the 'silver' schema. It includes checks for:
  - Null or duplicate primary keys.
  - Unwanted spaces in string fields.
  - Data standardization and consistency.
  - Invalid date ranges and orders.
  - Data consistency between related fields.

Usage Notes:
  - Run these checks after data loading Silver Layer.
  - Investigate and resolve any discrepancies found during the checks.
==========================================================================================
*/

/* CRM Customer Table*/

-- 1. Check for nulls or duplicates in the primary key
-- Expectation: No duplicates present in PK 
SELECT
	cst_id,
	COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- 2. Check for unwanted spaces
-- Expectation: No unwanted spaces
SELECT
	cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT
	cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

SELECT
	cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

-- 3. Data Standardization & Consistency
-- Expectation: Use clear words rather than abbreviations
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info

-- =========================================================================================

/* CRM Product Table*/

-- 1. Check for Nulls or Duplicates in Primary Key
-- Expectation: No Result

SELECT
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- 2. Check for unwanted spaces
-- Expectation: No Results

SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- 3. Check for Nulls or Negative Numbers
-- Eexpectation: No Results

SELECT
	prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- 4. Data Standardization & Consistency
-- Expectation: Use clear words rather than abbreviations

SELECT DISTINCT
	prd_line
FROM silver.crm_prd_info

-- 5. Check for Invalid Date Orders
-- Expectations: End date must not be earlier than the start date

SELECT
	*
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt

-- =========================================================================================

/* CRM Sales Table*/

-- 1. Check for Invalid Dates

SELECT
	NULLIF(sls_order_dt, 0)
FROM silver.crm_sales_details
WHERE sls_order_dt < = 0 OR LEN(sls_order_dt) != 8 OR sls_order_dt > 20500101 OR sls_order_dt < 19000101

-- 2. Check if order date is greater than shipping date

SELECT
	*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- 3. Check Data Consistency: Between Sales, Quantity, and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, Zero or Negative

SELECT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

-- =========================================================================================

/* ERP Customer Table */

-- 1. Identify out of rabge dates

SELECT DISTINCT
	bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- 2. Data Standardization & Consistency

SELECT DISTINCT
	gen
FROM silver.erp_cust_az12

-- =========================================================================================

/* ERP Product Table */

-- 1. Data Standardization & Consistency

SELECT DISTINCT
cntry AS old_cntry,
CASE
		WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
		WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		ELSE TRIM(cntry)
	END AS cntry
FROM silver.erp_loc_a101

-- =========================================================================================

/* ERP Category Table */

-- 1. Check for unwanted spaces

SELECT
	*
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- 2. Data Standardization & Consistent

SELECT DISTINCT
	cat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT
	subcat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT
	maintenance
FROM bronze.erp_px_cat_g1v2
