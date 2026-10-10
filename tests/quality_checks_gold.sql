/*
===============================================================================
Script: Gold Layer Data Quality Auditing & Validation Queries
===============================================================================
Script Purpose:
    This script provides data quality validation checks for the Gold layer views 
    of the data warehouse. 

    It performs the following verification checks:
    - Surrogate Key Uniqueness: Validates that dimension views have no duplicate records.
    - Data Integration & Conflict Resolution: Inspects overlapping attributes 
      (e.g., gender across CRM and ERP sources) to ensure accurate master mapping.
    - Referential Integrity: Checks for orphan records by validating foreign 
      key relationships between the sales fact view and dimension views.

Usage:
    Run these queries independently after creating the Gold layer views to 
    ensure data accuracy and relational integrity before downstream reporting.
===============================================================================
*/

USE gold;

-- =============================================================================
-- SECTION 1: Customer Dimension Quality Checks (gold.dim_customers)
-- =============================================================================

-- 1.1 Uniqueness Check: Verify no duplicate customer keys or IDs exist
-- Expectation: 0 Rows
SELECT 
    cst_id, 
    COUNT(*) AS duplicate_count
FROM (
    SELECT 
        ci.cst_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        ci.cst_marital_status,
        ci.cst_gndr,
        ci.cst_create_date,
        ca.bdate,
        ca.gen,
        la.cntry
    FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_az12 ca
        ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 la
        ON ci.cst_key = la.cid
) t 
GROUP BY cst_id
HAVING COUNT(*) > 1;


-- 1.2 Data Integration Check: Evaluate overlapping gender attributes from CRM and ERP sources
-- Purpose: Identifies conflicting values between source systems to establish master source priority.
SELECT DISTINCT 
    ci.cst_gndr,
    ca.gen AS erp_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid
ORDER BY 1, 2;


-- 1.3 Business Rule Validation: Test master source prioritization for gender integration
-- Purpose: Confirms that CRM data takes precedence, falling back to ERP data when CRM is unavailable.
SELECT DISTINCT 
    ci.cst_gndr,
    ca.gen AS erp_gen,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM system serves as the primary master source for gender info
        ELSE COALESCE(ca.gen, 'n/a')
    END AS resolved_gender
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid
ORDER BY 1, 2;


-- =============================================================================
-- SECTION 2: Product Dimension Quality Checks (gold.dim_products)
-- =============================================================================

-- 2.1 Uniqueness Check: Verify active product records for duplicate keys
-- Expectation: 0 Rows
SELECT 
    prd_key, 
    COUNT(*) AS duplicate_count 
FROM (
    SELECT  
        pn.prd_id,
        pn.cat_id,
        pn.prd_key,
        pn.prd_nm,
        pn.prd_cost,
        pn.prd_line,
        pn.prd_start_dt,
        pc.cat,
        pc.subcat,
        pc.maintenance
    FROM silver.crm_prd_info pn
    LEFT JOIN silver.erp_px_cat_g1v2 pc
        ON pn.cat_id = pc.id
    WHERE pn.prd_end_dt IS NULL -- Filter out historical records to inspect active items only
) t 
GROUP BY prd_key
HAVING COUNT(*) > 1;


-- =============================================================================
-- SECTION 3: Sales Fact Referential Integrity Checks (gold.fact_sales)
-- =============================================================================

-- 3.1 Foreign Key Integrity Check: Validate that all sales records link successfully to customers
-- Expectation: 0 Rows (Ensures no orphan sales transactions exist without a valid customer)
SELECT * 
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c 
    ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL;


-- 3.2 Foreign Key Integrity Check: Validate that all sales records link successfully to products
-- Expectation: 0 Rows (Ensures no orphan sales transactions exist without a valid product)
SELECT * 
FROM gold.fact_sales f 
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL;
