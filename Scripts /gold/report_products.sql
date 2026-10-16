/*
===============================================================================
View: Gold Layer Product Report (gold.report_products)
===============================================================================
Script Purpose:
    This view consolidates key product metrics, behaviors, and financial 
    performance indicators to support business reporting and analytics.

Highlights:
    1. Base Extraction: Retrieves core transactional attributes from fact sales 
       and product dimension tables.
    2. Product-Level Aggregations: Computes total orders, revenue, quantities, 
       unique customers, product lifespan, and average selling price.
    3. Advanced Metrics & Segmentation:
       - Recency (months elapsed since the product's last sale)
       - Performance Segmentation (High-Performing, Mid-Range, Low-Performing)
       - Average Order Revenue (AOR)
       - Average Monthly Revenue

Target DBMS: MySQL Workbench (MySQL 8.0+)
===============================================================================
*/

USE gold;

-- Drop the view if it already exists to allow seamless script re-execution
DROP VIEW IF EXISTS gold.report_products;

CREATE VIEW gold.report_products AS 
WITH base_query AS (
    /* ------------------------------------------------------------------------
       1) Base Query: Retrieves core columns and filters out invalid records
       ------------------------------------------------------------------------ */
    SELECT
        f.customer_key,
        f.order_number,
        f.order_date,
        f.sales_amount,
        f.quantity, 
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key 
    WHERE f.order_date IS NOT NULL
), 
product_aggregation AS (
    /* ------------------------------------------------------------------------
       2) Product Aggregation: Summarizes metrics at the individual product level
       ------------------------------------------------------------------------ */
    SELECT 
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_revenue,
        SUM(quantity) AS total_quantities,
        COUNT(DISTINCT customer_key) AS total_customers,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS life_span,
        ROUND(AVG(CAST(sales_amount AS DECIMAL(15, 4)) / NULLIF(quantity, 0)), 1) AS avg_selling_price
    FROM base_query
    GROUP BY 
        product_key,
        product_name,
        category,
        subcategory,
        cost
)
/* ----------------------------------------------------------------------------
   3) Final Output: Enriches aggregated data with business logic and segmentation
   ---------------------------------------------------------------------------- */  
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    first_order_date,
    last_order_date,
    TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) AS recency_in_months,
    CASE 
        WHEN total_revenue > 50000 THEN 'High-Performing'  
        WHEN total_revenue >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performing'
    END AS performance_segment,
    life_span,
    total_orders,
    total_revenue,
    total_quantities,
    total_customers,
    avg_selling_price,
    -- Compute Average Order Revenue (AOR) with division-by-zero safety
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_revenue / total_orders
    END AS avg_order_revenue,
    -- Compute Average Monthly Revenue with division-by-zero safety
    CASE 
        WHEN life_span = 0 THEN total_revenue
        ELSE total_revenue / life_span
    END AS avg_monthly_revenue
FROM product_aggregation;

-- ============================================================================
-- Verification Query: Preview the created report view
-- ============================================================================
SELECT * 
FROM gold.report_products
LIMIT 100;
