/*
===============================================================================
Script: Measures Exploration (Key Performance Indicators)
===============================================================================
Purpose:
    Computes high-level business aggregates and builds a centralized KPI 
    summary report for executive review.

Target DBMS: MySQL Workbench (MySQL 8.0+)
===============================================================================
*/

USE gold;

-- 1. Core High-Level Aggregations from Fact Sales
SELECT 
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantities_sold,
    COUNT(order_number) AS total_order_rows,
    COUNT(DISTINCT order_number) AS total_unique_orders,
    COUNT(DISTINCT customer_key) AS total_active_customers
FROM gold.fact_sales;

-- 2. Master Executive KPI Report (Unified Summary)
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Total Quantity Sold' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Total Unique Orders' AS measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Total Products' AS measure_name, COUNT(product_key) AS measure_value FROM gold.dim_products
UNION ALL 
SELECT 'Total Customers' AS measure_name, COUNT(customer_key) AS measure_value FROM gold.dim_customers;
