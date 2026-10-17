/*
===============================================================================
Script: Performance Analysis (Year-over-Year & vs. Benchmark)
===============================================================================
Purpose:
    Evaluates annual product sales performance by comparing each product's 
    revenue against its historical average and prior-year (PY) sales.

Target DBMS: MySQL Workbench (MySQL 8.0+)
===============================================================================
*/

USE gold;

WITH yearly_product_sales AS (
    SELECT 
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)
SELECT 
    order_year,
    product_name,
    current_sales,
    -- Benchmark 1: Historical Average Comparison
    ROUND(AVG(current_sales) OVER (PARTITION BY product_name), 2) AS avg_historical_sales,
    current_sales - ROUND(AVG(current_sales) OVER (PARTITION BY product_name), 2) AS diff_from_avg,
    CASE 
        WHEN current_sales > AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Above Average'
        WHEN current_sales < AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Below Average'
        ELSE 'Average'
    END AS avg_performance_status,
    
    -- Benchmark 2: Previous Year (PY) Comparison
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE 
        WHEN current_sales > LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Increase'
        WHEN current_sales < LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Decrease'
        ELSE 'No Change'
    END AS py_trend_status
FROM yearly_product_sales 
ORDER BY product_name, order_year;
