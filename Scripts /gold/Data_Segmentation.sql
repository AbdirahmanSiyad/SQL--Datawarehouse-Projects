/*
===============================================================================
Script: Data Segmentation (Products & Customers)
===============================================================================
Purpose:
    1. Segments products into cost ranges to evaluate catalog distribution.
    2. Groups customers into VIP, Regular, and New tiers based on tenure and spend.

Target DBMS: MySQL Workbench (MySQL 8.0+)
===============================================================================
*/

USE gold;

-- Part A: Product Cost Segmentation
WITH product_segments AS (
    SELECT 
        product_key,
        product_name, 
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 499.99 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;


-- Part B: Customer Behavioral Segmentation
WITH customer_spending AS (
    SELECT 
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(f.order_date) AS first_order,
        MAX(f.order_date) AS last_order,
        TIMESTAMPDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS life_span
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) as total_customers
FROM (
    SELECT 
        customer_key,
        total_spending,
        life_span, 
        CASE 
            WHEN life_span >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN life_span >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers 
GROUP BY customer_segment
ORDER BY total_customers DESC;
