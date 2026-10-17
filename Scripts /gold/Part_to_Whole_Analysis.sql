/*
===============================================================================
Script: Part-to-Whole Proportional Analysis
===============================================================================
Purpose:
    Analyzes which product categories contribute the highest percentage 
    to overall company sales revenue.

Target DBMS: MySQL Workbench (MySQL 8.0+)
===============================================================================
*/

USE gold;

WITH category_sales AS (
    SELECT 
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT 
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_company_sales,
    CONCAT(
        ROUND(
            (CAST(total_sales AS DECIMAL(15, 4)) / SUM(total_sales) OVER ()) * 100, 
            2
        ), 
        '%'
    ) AS percentage_of_total_sales
FROM category_sales
ORDER BY total_sales DESC;
