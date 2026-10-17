/*
===============================================================================
Script: Cumulative Analysis (Running Totals)
===============================================================================
Purpose:
    Computes monthly sales performance alongside a running cumulative total 
    over time to track cumulative business momentum.

Target DBMS: MySQL Workbench (MySQL 8.0+)
===============================================================================
*/

USE gold;

SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m-01') AS order_date,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL 
    GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')
) AS monthly_sales;
