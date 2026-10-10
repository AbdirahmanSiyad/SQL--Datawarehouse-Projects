/*
===============================================================================
DDL Script: Create Gold Views (Star Schema Modeling)
===============================================================================
Script Purpose:
    This script creates analytical views for the Gold layer in the data warehouse[cite: 4]. 
    The Gold layer represents the final dimension and fact tables organized in a Star Schema[cite: 4].

    Each view performs transformations, integrates data from multiple Silver tables, 
    and produces a clean, enriched, and business-ready dataset[cite: 4].

Usage:
    - These views can be queried directly for business intelligence, analytics, and reporting[cite: 4].
===============================================================================
*/

-- Select target Gold schema
USE gold;

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
-- Description:
--     Integrates customer data from three Silver sources (silver.crm_cust_info, 
--     silver.erp_cust_az12, and silver.erp_loc_a101) with crm_cust_info as the master table[cite: 4].
--     Applies business rules for gender prioritization, standardizes location attributes, 
--     and generates a unique sequential surrogate key (`customer_key`)[cite: 4].
-- =============================================================================

DROP VIEW IF EXISTS gold.dim_customers;

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, -- Unique surrogate key for dimension mapping[cite: 4]
    ci.cst_id                          AS customer_id,
    ci.cst_key                         AS customer_number,
    ci.cst_firstname                   AS first_name,
    ci.cst_lastname                    AS last_name,
    la.cntry                           AS country,
    ci.cst_marital_status              AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM system serves as the primary master source for gender info[cite: 4]
        ELSE COALESCE(ca.gen, 'n/a')               -- Fallback to ERP biographical data if CRM gender is unavailable[cite: 4]
    END                                AS gender,
    ca.bdate                           AS birthdate,
    ci.cst_create_date                 AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;

-- Verification Query: Inspect customer dimension records
SELECT * 
FROM gold.dim_customers;


-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
-- Description:
--     Combines product catalog details from silver.crm_prd_info with category 
--     hierarchies from silver.erp_px_cat_g1v2[cite: 4]. 
--     Filters out historical records where `prd_end_dt` is not null to retain 
--     only currently active products[cite: 4].
-- =============================================================================

DROP VIEW IF EXISTS gold.dim_products;

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Unique surrogate key for product tracking[cite: 4]
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL; -- Filter out all historical product records to keep active data only[cite: 4]

-- Verification Query: Inspect product dimension records
SELECT * 
FROM gold.dim_products;


-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
-- Description:
--     Constructs the transactional sales fact view by bridging order details 
--     from silver.crm_sales_details with Gold dimension tables using surrogate 
--     keys (`product_key` and `customer_key`)[cite: 4].
-- =============================================================================

DROP VIEW IF EXISTS gold.fact_sales;

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;

-- Verification Query: Inspect sales fact records
SELECT * 
FROM gold.fact_sales;
