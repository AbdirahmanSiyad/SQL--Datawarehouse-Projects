/*
===============================================================================
DDL & Batch Loading Script: Bronze Layer Ingestion
===============================================================================
Script Purpose:
    This script loads raw source data into the 'bronze' database from external CSV files.
    It performs the following actions:
    - Sets session permissions for local file loading.
    - Truncates existing data in bronze tables before loading fresh datasets.
    - Uses `LOAD DATA LOCAL INFILE` to ingest CSV files into MySQL tables.
    - Logs detailed execution steps, individual table load times, and row summaries 
      into a single combined result log.

Sources Processed:
    - CRM System: cust_info.csv, prd_info.csv, sales_details.csv
    - ERP System: LOC_A101.csv, CUST_AZ12.csv, PX_CAT_G1V2.csv

===============================================================================
TECHNICAL NOTES & MACOS/MYSQL COMPATIBILITY
===============================================================================
- STORED PROCEDURE LIMITATION:
  - MySQL strictly forbids `LOAD DATA LOCAL INFILE` inside Stored Procedures 
    (Error Code 1295: Command not supported in prepared statement protocol).
  - Setting `secure_file_priv = NULL` blocks server-side file reading (`LOAD DATA INFILE`).

- SINGLE RESULT OUTPUT SOLUTION:
  - To avoid MySQL Workbench creating dozens of separate result tabs for each PRINT/SELECT,
    all log messages are captured in a temporary table `tmp_log` and rendered as ONE 
    consolidated output at the end of the script execution.
===============================================================================
*/

-- Enable local file loading permission for the current connection
SET GLOBAL local_infile = 1;

-- Select target database schema
USE bronze;

-- Create temporary log table to consolidate output into a single result window
DROP TEMPORARY TABLE IF EXISTS tmp_log;
CREATE TEMPORARY TABLE tmp_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Log_Message VARCHAR(255)
);

-- Record script batch execution start time
SET @batch_start_time = NOW();

INSERT INTO tmp_log (Log_Message) VALUES ('================================================');
INSERT INTO tmp_log (Log_Message) VALUES ('Loading Bronze Layer');
INSERT INTO tmp_log (Log_Message) VALUES ('================================================');


-- ============================================================================
-- 1. LOADING CRM TABLES
-- ============================================================================

INSERT INTO tmp_log (Log_Message) VALUES ('------------------------------------------------');
INSERT INTO tmp_log (Log_Message) VALUES ('Loading CRM Tables');
INSERT INTO tmp_log (Log_Message) VALUES ('------------------------------------------------');

-- 1.1 Table: bronze.crm_cust_info
SET @start_time = NOW();
INSERT INTO tmp_log (Log_Message) VALUES ('>> Truncating Table: bronze.crm_cust_info');
TRUNCATE TABLE crm_cust_info;

INSERT INTO tmp_log (Log_Message) VALUES ('>> Inserting Data Into: bronze.crm_cust_info');
LOAD DATA LOCAL INFILE '/Users/abdirahmanosmansiyad/Desktop/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
INTO TABLE crm_cust_info
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;

SET @end_time = NOW();
INSERT INTO tmp_log (Log_Message) VALUES (CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds'));
INSERT INTO tmp_log (Log_Message) VALUES ('>> -------------');


-- 1.2 Table: bronze.crm_prd_info
SET @start_time = NOW();
INSERT INTO tmp_log (Log_Message) VALUES ('>> Truncating Table: bronze.crm_prd_info');
TRUNCATE TABLE crm_prd_info;

INSERT INTO tmp_log (Log_Message) VALUES ('>> Inserting Data Into: bronze.crm_prd_info');
LOAD DATA LOCAL INFILE '/Users/abdirahmanosmansiyad/Desktop/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
INTO TABLE crm_prd_info
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;

SET @end_time = NOW();
INSERT INTO tmp_log (Log_Message) VALUES (CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds'));
INSERT INTO tmp_log (Log_Message) VALUES ('>> -------------');


-- 1.3 Table: bronze.crm_sales_details
SET @start_time = NOW();
INSERT INTO tmp_log (Log_Message) VALUES ('>> Truncating Table: bronze.crm_sales_details');
TRUNCATE TABLE crm_sales_details;

INSERT INTO tmp_log (Log_Message) VALUES ('>> Inserting Data Into: bronze.crm_sales_details');
LOAD DATA LOCAL INFILE '/Users/abdirahmanosmansiyad/Desktop/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
INTO TABLE crm_sales_details
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;

SET @end_time = NOW();
INSERT INTO tmp_log (Log_Message) VALUES (CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds'));
INSERT INTO tmp_log (Log_Message) VALUES ('>> -------------');


-- ============================================================================
-- 2. LOADING ERP TABLES
-- ============================================================================

INSERT INTO tmp_log (Log_Message) VALUES ('------------------------------------------------');
INSERT INTO tmp_log (Log_Message) VALUES ('Loading ERP Tables');
INSERT INTO tmp_log (Log_Message) VALUES ('------------------------------------------------');

-- 2.1 Table: bronze.erp_loc_a101
SET @start_time = NOW();
INSERT INTO tmp_log (Log_Message) VALUES ('>> Truncating Table: bronze.erp_loc_a101');
TRUNCATE TABLE erp_loc_a101;

INSERT INTO tmp_log (Log_Message) VALUES ('>> Inserting Data Into: bronze.erp_loc_a101');
LOAD DATA LOCAL INFILE '/Users/abdirahmanosmansiyad/Desktop/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv'
INTO TABLE erp_loc_a101
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;

SET @end_time = NOW();
INSERT INTO tmp_log (Log_Message) VALUES (CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds'));
INSERT INTO tmp_log (Log_Message) VALUES ('>> -------------');


-- 2.2 Table: bronze.erp_cust_az12
SET @start_time = NOW();
INSERT INTO tmp_log (Log_Message) VALUES ('>> Truncating Table: bronze.erp_cust_az12');
TRUNCATE TABLE erp_cust_az12;

INSERT INTO tmp_log (Log_Message) VALUES ('>> Inserting Data Into: bronze.erp_cust_az12');
LOAD DATA LOCAL INFILE '/Users/abdirahmanosmansiyad/Desktop/sql-data-warehouse-project/datasets/source_erp/CUST_AZ12.csv'
INTO TABLE erp_cust_az12
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;

SET @end_time = NOW();
INSERT INTO tmp_log (Log_Message) VALUES (CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds'));
INSERT INTO tmp_log (Log_Message) VALUES ('>> -------------');


-- 2.3 Table: bronze.erp_px_cat_g1v2
SET @start_time = NOW();
INSERT INTO tmp_log (Log_Message) VALUES ('>> Truncating Table: bronze.erp_px_cat_g1v2');
TRUNCATE TABLE erp_px_cat_g1v2;

INSERT INTO tmp_log (Log_Message) VALUES ('>> Inserting Data Into: bronze.erp_px_cat_g1v2');
LOAD DATA LOCAL INFILE '/Users/abdirahmanosmansiyad/Desktop/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE erp_px_cat_g1v2
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;

SET @end_time = NOW();
INSERT INTO tmp_log (Log_Message) VALUES (CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds'));
INSERT INTO tmp_log (Log_Message) VALUES ('>> -------------');


-- ============================================================================
-- BATCH EXECUTION SUMMARY & VERIFICATION
-- ============================================================================

SET @batch_end_time = NOW();

INSERT INTO tmp_log (Log_Message) VALUES ('==========================================');
INSERT INTO tmp_log (Log_Message) VALUES ('Loading Bronze Layer Completed Successfully');
INSERT INTO tmp_log (Log_Message) VALUES (CONCAT('   - Total Load Duration: ', TIMESTAMPDIFF(SECOND, @batch_start_time, @batch_end_time), ' seconds'));
INSERT INTO tmp_log (Log_Message) VALUES ('==========================================');


-- OUTPUT 1: Consolidated Single Execution Log
SELECT Log_Message FROM tmp_log ORDER BY id ASC;

-- OUTPUT 2: Final Row Count Verification Across All Tables
SELECT 'crm_cust_info' AS Table_Name, COUNT(*) AS Total_Rows FROM crm_cust_info
UNION ALL 
SELECT 'crm_prd_info', COUNT(*) FROM crm_prd_info
UNION ALL 
SELECT 'crm_sales_details', COUNT(*) FROM crm_sales_details
UNION ALL 
SELECT 'erp_loc_a101', COUNT(*) FROM erp_loc_a101
UNION ALL 
SELECT 'erp_cust_az12', COUNT(*) FROM erp_cust_az12
UNION ALL 
SELECT 'erp_px_cat_g1v2', COUNT(*) FROM erp_px_cat_g1v2;
