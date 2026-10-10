/*
===============================================================================
Script: Data Quality Auditing & Verification Queries (Silver Layer)
===============================================================================
Script Purpose:
    This script contains a comprehensive suite of data validation and quality 
    assurance queries designed for the Silver layer of the Data Warehouse.
    
    It performs the following verification checks:
    - Primary Key Uniqueness & NULL Validation: Ensures no duplicate records or missing keys exist.
    - String & Whitespace Sanitization: Verifies that leading/trailing spaces and hidden 
      control characters (\r, \n) have been successfully cleaned.
    - Data Standardization & Consistency: Inspects categorical mappings (e.g., gender, 
      marital status, country names, product lines) for uniformity.
    - Referential Integrity & Relational Joins: Validates foreign key relationships 
      between CRM and ERP tables.
    - Business Rule Validation: Confirms mathematical integrity (Sales = Quantity x Price) 
      and checks for chronological date anomalies.

Usage:
    Run these queries independently after executing the Silver Layer ETL pipeline 
    to verify data hygiene and ensure readiness for the Gold layer.
===============================================================================
*/

-- ==============================================================================================
-- SECTION 2: DATA QUALITY AUDITING & VERIFICATION QUERIES
-- ==============================================================================================


-- ----------------------------------------------------------------------------------------------
-- Audits for crm_cust_info
-- ----------------------------------------------------------------------------------------------

-- Check loaded Silver records
SELECT * 
FROM silver.crm_cust_info;

-- Check Primary Key uniqueness and NULL values
-- Expectation: 0 Rows
SELECT 
    cst_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unstripped leading or trailing spaces
-- Expectation: 0 Rows
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Verify distinct standardized values for marital status
SELECT DISTINCT cst_marital_status 
FROM silver.crm_cust_info;


-- ----------------------------------------------------------------------------------------------
-- Audits for crm_prd_info
-- ----------------------------------------------------------------------------------------------

-- Check Primary Key uniqueness and NULL values
-- Expectation: 0 Rows
SELECT 
    prd_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted whitespace in product names
-- Expectation: 0 Rows
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for invalid product costs (NULL or negative)
-- Expectation: 0 Rows
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Verify distinct standardized product line values
SELECT DISTINCT prd_line 
FROM silver.crm_prd_info;

-- Verify logical date ordering (End date must be greater than or equal to start date)
-- Expectation: 0 Rows
SELECT * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- Test LEAD window function calculation for product effective dates
SELECT 
    prd_id,
    prd_key,
    prd_nm,
    prd_start_dt,
    prd_end_dt,
    DATE_SUB(
        LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt), 
        INTERVAL 1 DAY
    ) AS calculated_end_dt
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');


-- ----------------------------------------------------------------------------------------------
-- Audits for crm_sales_details
-- ----------------------------------------------------------------------------------------------

-- Check loaded Silver sales records
SELECT * 
FROM silver.crm_sales_details;

-- Check Primary Key uniqueness
-- Expectation: 0 Rows
SELECT 
    sls_prd_key,
    COUNT(*) AS duplicate_count
FROM silver.crm_sales_details
GROUP BY sls_prd_key
HAVING COUNT(*) > 1 OR sls_prd_key IS NULL;

-- Check for unstripped spaces in order numbers
-- Expectation: 0 Rows
SELECT sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

-- Test foreign key relationship between sales and customer information using LEFT JOIN
-- Expectation: 0 Rows
SELECT 
    s.sls_ord_num,
    s.sls_cust_id
FROM bronze.crm_sales_details s
LEFT JOIN silver.crm_cust_info c
    ON s.sls_cust_id = c.cst_id
WHERE c.cst_id IS NULL;

-- Check for invalid date formatting or date boundaries
SELECT 
    NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
   OR CHAR_LENGTH(CAST(sls_order_dt AS CHAR)) != 8
   OR sls_order_dt > 20500101 
   OR sls_order_dt < 19000101;

-- Check for chronological date order anomalies (Order date should precede shipping and due dates)
SELECT * 
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Test business rules for sales, quantity, and price calculation
SELECT DISTINCT
    sls_sales AS old_sls_sales,
    sls_quantity,
    sls_price AS old_sls_price,

    -- Recalculated Sales
    CAST(
        CASE 
            WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
                THEN NULLIF(sls_quantity * ABS(
                    CASE 
                        WHEN sls_price IS NULL OR sls_price = 0 
                            THEN sls_sales / NULLIF(sls_quantity, 0)
                        ELSE ABS(sls_price)
                    END
                ), 0)
            ELSE sls_sales
        END AS SIGNED
    ) AS recalculated_sales,

    -- Recalculated Price
    CAST(
        CASE 
            WHEN sls_price IS NULL OR sls_price = 0 
                THEN NULLIF(ABS(sls_sales) / NULLIF(sls_quantity, 0), 0)
            ELSE ABS(sls_price)
        END AS SIGNED
    ) AS recalculated_price
FROM bronze.crm_sales_details
WHERE sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
   OR sls_sales != sls_quantity * sls_price
ORDER BY old_sls_sales, sls_quantity, old_sls_price;


-- ----------------------------------------------------------------------------------------------
-- Audits for erp_cust_az12
-- ----------------------------------------------------------------------------------------------

-- Check loaded Silver ERP customer table
SELECT * 
FROM silver.erp_cust_az12;

-- Check for out-of-range birth dates in Silver
-- Expectation: 0 Rows
SELECT DISTINCT bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > CURRENT_DATE();

-- Verify non-matching customer keys between Bronze ERP and Silver CRM using optimized LEFT JOIN
-- Expectation: 0 Rows
SELECT 
    CASE 
        WHEN e.cid LIKE 'NAS%' THEN SUBSTRING(e.cid, 4, LENGTH(e.cid))
        ELSE e.cid 
    END AS cid,
    e.bdate,
    e.gen
FROM bronze.erp_cust_az12 e
LEFT JOIN silver.crm_cust_info c
    ON CASE 
        WHEN e.cid LIKE 'NAS%' THEN SUBSTRING(e.cid, 4, LENGTH(e.cid))
        ELSE e.cid 
       END = c.cst_key
WHERE c.cst_key IS NULL;

-- Test gender string cleaning and control character removal (\r, \n)
SELECT DISTINCT
    gen AS raw_gen,
    CASE 
        WHEN UPPER(REPLACE(REPLACE(TRIM(gen), '\r', ''), '\n', '')) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(REPLACE(REPLACE(TRIM(gen), '\r', ''), '\n', '')) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END AS gen_clean
FROM bronze.erp_cust_az12;


-- ----------------------------------------------------------------------------------------------
-- Audits for erp_loc_a101
-- ----------------------------------------------------------------------------------------------

-- Test country standardization and control character removal (\r, \n)
SELECT DISTINCT
    cntry AS old_cntry,
    CASE 
        WHEN UPPER(REPLACE(REPLACE(TRIM(cntry), '\r', ''), '\n', '')) = 'DE' 
            THEN 'Germany'
        WHEN UPPER(REPLACE(REPLACE(TRIM(cntry), '\r', ''), '\n', '')) IN ('US', 'USA') 
            THEN 'United States'
        WHEN REPLACE(REPLACE(TRIM(cntry), '\r', ''), '\n', '') = '' OR cntry IS NULL 
            THEN 'n/a'
        ELSE REPLACE(REPLACE(TRIM(cntry), '\r', ''), '\n', '')
    END AS cntry_clean
FROM bronze.erp_loc_a101
ORDER BY cntry_clean;


-- ----------------------------------------------------------------------------------------------
-- Audits for erp_px_cat_g1v2
-- ----------------------------------------------------------------------------------------------

-- Check for unstripped leading or trailing spaces in category fields
-- Expectation: 0 Rows
SELECT * 
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Check distinct values across category hierarchy
SELECT DISTINCT cat, subcat, maintenance 
FROM silver.erp_px_cat_g1v2;
