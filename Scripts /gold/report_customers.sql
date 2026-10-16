/*
===============================================================================
View: Gold Layer Customer Report (gold.report_customers)
===============================================================================
Script Purpose:
    This view consolidates key customer-level metrics, purchasing behaviors, 
    demographics, and lifetime value (LTV) indicators to support marketing 
    and customer segmentation analytics.

Highlights:
    1. Base Extraction: Retrieves core demographics and transaction details.
    2. Customer Segmentation: Categorizes customers into age groups and behavior 
       tiers (VIP, Regular, New) based on lifespan and total spend.
    3. Customer-Level Aggregations: Summarizes total orders, sales revenue, 
       quantities purchased, unique products bought, and active lifespan.
    4. Advanced KPIs:
       - Recency (months elapsed since the customer's last order)
       - Average Order Value (AOV)
       - Average Monthly Spend

Target DBMS: MySQL Workbench (MySQL 8.0+)
===============================================================================
*/

USE gold;

-- Drop the view if it already exists to allow seamless script re-execution
DROP VIEW IF EXISTS gold.report_customers;

CREATE VIEW gold.report_customers AS 
WITH base_query AS (
    /* ------------------------------------------------------------------------
       1) Base Query: Retrieves core customer and transaction attributes
       ------------------------------------------------------------------------ */
    SELECT 
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        TIMESTAMPDIFF(YEAR, c.birthdate, CURDATE()) AS age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key
    WHERE f.order_date IS NOT NULL
), 
customer_aggregation AS (
    /* ------------------------------------------------------------------------
       2) Customer Aggregation: Summarizes metrics at the individual customer level
       ------------------------------------------------------------------------ */
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantities,
        COUNT(DISTINCT product_key) AS total_products,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS life_span
    FROM base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age
)
/* ----------------------------------------------------------------------------
   3) Final Output: Enriches aggregated metrics with age brackets, tiers, and KPIs
   ---------------------------------------------------------------------------- */  
SELECT 
    customer_key, 
    customer_number, 
    customer_name, 
    age,
    -- Categorize customers into clean demographic age groups
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 39 THEN '20-39'
        WHEN age BETWEEN 40 AND 59 THEN '40-59'
        ELSE '60+'
    END AS age_group,
    -- Segment customers based on loyalty duration (lifespan) and revenue contribution
    CASE 
        WHEN life_span >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN life_span >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    first_order_date,
    last_order_date,
    -- Recency: Months elapsed since the customer's last purchase
    TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) AS recency_in_months,
    life_span,
    total_orders,
    total_sales,
    total_quantities,
    total_products,
    -- Compute Average Order Value (AOV) with division-by-zero safety
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,
    -- Compute Average Monthly Spend with division-by-zero safety
    CASE 
        WHEN life_span = 0 THEN total_sales
        ELSE total_sales / life_span
    END AS avg_monthly_spend
FROM customer_aggregation;

-- ============================================================================
-- Verification Query: Preview the created customer report view
-- ============================================================================
SELECT * 
FROM gold.report_customers
LIMIT 100;
