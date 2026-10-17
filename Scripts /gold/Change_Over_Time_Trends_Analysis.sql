/*
===============================================================================
Script: Change Over Time Trends Analysis
===============================================================================
Purpose:
    Tracks key performance indicators (sales volume, active customers, and 
    quantities sold) annually to monitor business growth and seasonality.

Target DBMS: MySQL Workbench (MySQL 8.0+)
===============================================================================
*/

USE gold;

SELECT 
    YEAR(order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY order_year;
