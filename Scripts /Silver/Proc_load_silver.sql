/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL process to populate the 'silver' 
    schema tables from the 'bronze' schema in MySQL.

Actions Performed:
    - Truncates Silver tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.
    - Logs timing metrics and step progress into a single consolidated output.

Parameters:
    None.

Usage Example:
    CALL silver.load_silver();
===============================================================================
*/

USE silver;

DROP PROCEDURE IF EXISTS load_silver;

DELIMITER //

CREATE PROCEDURE load_silver()
BEGIN
    -- Declare local timing variables
    DECLARE v_start_time DATETIME;
    DECLARE v_end_time DATETIME;
    DECLARE v_batch_start_time DATETIME;
    DECLARE v_batch_end_time DATETIME;

    -- Error Handler: Logs error details and returns single consolidated message
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 
            @mysql_errno = MYSQL_ERRNO, 
            @sql_state = RETURNED_SQLSTATE, 
            @msg_text = MESSAGE_TEXT;

        INSERT INTO tmp_log (log_message) VALUES 
            ('=========================================='),
            ('ERROR OCCURED DURING LOADING SILVER LAYER'),
            (CONCAT('Error Code: ', @mysql_errno)),
            (CONCAT('SQL State: ', @sql_state)),
            (CONCAT('Error Message: ', @msg_text)),
            ('==========================================');

        SELECT log_message AS execution_log FROM tmp_log ORDER BY id;
        DROP TEMPORARY TABLE IF EXISTS tmp_log;
    END;

    -- Step 1: Create a temporary table to store log messages silently
    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_log (
        id INT AUTO_INCREMENT PRIMARY KEY,
        log_message VARCHAR(255)
    );
    TRUNCATE TABLE tmp_log;

    SET v_batch_start_time = NOW();

    INSERT INTO tmp_log (log_message) VALUES 
        ('================================================'),
        ('Loading Silver Layer'),
        ('================================================'),
        ('------------------------------------------------'),
        ('Loading CRM Tables'),
        ('------------------------------------------------');

    -- -------------------------------------------------------------------------
    -- 1. Loading silver.crm_cust_info
    -- -------------------------------------------------------------------------
    SET v_start_time = NOW();
    INSERT INTO tmp_log (log_message) VALUES 
        ('>> Truncating Table: silver.crm_cust_info'),
        ('>> Inserting Data Into: silver.crm_cust_info');

    TRUNCATE TABLE silver.crm_cust_info;

    INSERT INTO silver.crm_cust_info (
        cst_id, 
        cst_key, 
        cst_firstname, 
        cst_lastname, 
        cst_marital_status, 
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE 
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,
        CASE 
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,
        clean_create_date
    FROM (
        SELECT
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            CASE 
                WHEN cst_create_date IS NULL THEN NULL
                WHEN TRIM(CAST(cst_create_date AS CHAR)) IN ('', '0', '0000-00-00', '0000-00-00 00:00:00') THEN NULL
                WHEN CHAR_LENGTH(TRIM(CAST(cst_create_date AS CHAR))) = 8 
                     THEN STR_TO_DATE(TRIM(CAST(cst_create_date AS CHAR)), '%Y%m%d')
                ELSE STR_TO_DATE(LEFT(TRIM(CAST(cst_create_date AS CHAR)), 10), '%Y-%m-%d')
            END AS clean_create_date,
            ROW_NUMBER() OVER (
                PARTITION BY cst_id 
                ORDER BY 
                    CASE 
                        WHEN cst_create_date IS NULL THEN '1900-01-01'
                        WHEN TRIM(CAST(cst_create_date AS CHAR)) IN ('', '0', '0000-00-00', '0000-00-00 00:00:00') THEN '1900-01-01'
                        WHEN CHAR_LENGTH(TRIM(CAST(cst_create_date AS CHAR))) = 8 
                             THEN STR_TO_DATE(TRIM(CAST(cst_create_date AS CHAR)), '%Y%m%d')
                        ELSE STR_TO_DATE(LEFT(TRIM(CAST(cst_create_date AS CHAR)), 10), '%Y-%m-%d')
                    END DESC
            ) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) t
    WHERE flag_last = 1;

    SET v_end_time = NOW();
    INSERT INTO tmp_log (log_message) VALUES 
        (CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time), ' seconds')),
        ('>> -------------');

    -- -------------------------------------------------------------------------
    -- 2. Loading silver.crm_prd_info
    -- -------------------------------------------------------------------------
    SET v_start_time = NOW();
    INSERT INTO tmp_log (log_message) VALUES 
        ('>> Truncating Table: silver.crm_prd_info'),
        ('>> Inserting Data Into: silver.crm_prd_info');

    TRUNCATE TABLE silver.crm_prd_info;

    INSERT INTO silver.crm_prd_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
        SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
        prd_nm,
        IFNULL(prd_cost, 0) AS prd_cost,
        CASE 
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,
        CAST(prd_start_dt AS DATE) AS prd_start_dt,
        CAST(
            DATE_SUB(
                LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt), 
                INTERVAL 1 DAY
            ) AS DATE
        ) AS prd_end_dt
    FROM bronze.crm_prd_info;

    SET v_end_time = NOW();
    INSERT INTO tmp_log (log_message) VALUES 
        (CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time), ' seconds')),
        ('>> -------------');

    -- -------------------------------------------------------------------------
    -- 3. Loading silver.crm_sales_details
    -- -------------------------------------------------------------------------
    SET v_start_time = NOW();
    INSERT INTO tmp_log (log_message) VALUES 
        ('>> Truncating Table: silver.crm_sales_details'),
        ('>> Inserting Data Into: silver.crm_sales_details');

    TRUNCATE TABLE silver.crm_sales_details;

    INSERT INTO silver.crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE 
            WHEN sls_order_dt = 0 OR CHAR_LENGTH(CAST(sls_order_dt AS CHAR)) != 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d')
        END AS sls_order_dt,
        CASE 
            WHEN sls_ship_dt = 0 OR CHAR_LENGTH(CAST(sls_ship_dt AS CHAR)) != 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_ship_dt AS CHAR), '%Y%m%d')
        END AS sls_ship_dt,
        CASE 
            WHEN sls_due_dt = 0 OR CHAR_LENGTH(CAST(sls_due_dt AS CHAR)) != 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_due_dt AS CHAR), '%Y%m%d')
        END AS sls_due_dt,
        CAST(
            CASE 
                WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
                    THEN NULLIF(sls_quantity * ABS(
                        CASE 
                            WHEN sls_price IS NULL OR sls_price = 0 
                                THEN sls_sales / NULLIF(sls_quantity, 0)
                            ELSE ABS(sls_price)
                        END
                    ), 0)
                ELSE sls_sales
            END AS SIGNED
        ) AS sls_sales,
        sls_quantity,
        CAST(
            CASE 
                WHEN sls_price IS NULL OR sls_price = 0 
                    THEN NULLIF(ABS(sls_sales) / NULLIF(sls_quantity, 0), 0)
                ELSE ABS(sls_price)
            END AS SIGNED
        ) AS sls_price
    FROM bronze.crm_sales_details;

    SET v_end_time = NOW();
    INSERT INTO tmp_log (log_message) VALUES 
        (CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time), ' seconds')),
        ('>> -------------');

    -- -------------------------------------------------------------------------
    -- 4. Loading silver.erp_cust_az12
    -- -------------------------------------------------------------------------
    SET v_start_time = NOW();
    INSERT INTO tmp_log (log_message) VALUES 
        ('------------------------------------------------'),
        ('Loading ERP Tables'),
        ('------------------------------------------------'),
        ('>> Truncating Table: silver.erp_cust_az12'),
        ('>> Inserting Data Into: silver.erp_cust_az12');

    TRUNCATE TABLE silver.erp_cust_az12;

    INSERT INTO silver.erp_cust_az12 (
        cid,
        bdate,
        gen
    )
    SELECT
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
            ELSE cid
        END AS cid, 
        CASE
            WHEN bdate > CURRENT_DATE() THEN NULL
            ELSE bdate
        END AS bdate,
        CASE
            WHEN UPPER(REPLACE(REPLACE(TRIM(gen), '\r', ''), '\n', '')) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(REPLACE(REPLACE(TRIM(gen), '\r', ''), '\n', '')) IN ('M', 'MALE') THEN 'Male'
            ELSE 'n/a'
        END AS gen
    FROM bronze.erp_cust_az12;

    SET v_end_time = NOW();
    INSERT INTO tmp_log (log_message) VALUES 
        (CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time), ' seconds')),
        ('>> -------------');

    -- -------------------------------------------------------------------------
    -- 5. Loading silver.erp_loc_a101
    -- -------------------------------------------------------------------------
    SET v_start_time = NOW();
    INSERT INTO tmp_log (log_message) VALUES 
        ('>> Truncating Table: silver.erp_loc_a101'),
        ('>> Inserting Data Into: silver.erp_loc_a101');

    TRUNCATE TABLE silver.erp_loc_a101;

    INSERT INTO silver.erp_loc_a101 (
        cid,
        cntry
    )
    SELECT
        REPLACE(cid, '-', '') AS cid, 
        CASE
            WHEN UPPER(REPLACE(REPLACE(TRIM(cntry), '\r', ''), '\n', '')) = 'DE' THEN 'Germany'
            WHEN UPPER(REPLACE(REPLACE(TRIM(cntry), '\r', ''), '\n', '')) IN ('US', 'USA') THEN 'United States'
            WHEN REPLACE(REPLACE(TRIM(cntry), '\r', ''), '\n', '') = '' OR cntry IS NULL THEN 'n/a'
            ELSE REPLACE(REPLACE(TRIM(cntry), '\r', ''), '\n', '')
        END AS cntry
    FROM bronze.erp_loc_a101;

    SET v_end_time = NOW();
    INSERT INTO tmp_log (log_message) VALUES 
        (CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time), ' seconds')),
        ('>> -------------');

    -- -------------------------------------------------------------------------
    -- 6. Loading silver.erp_px_cat_g1v2
    -- -------------------------------------------------------------------------
    SET v_start_time = NOW();
    INSERT INTO tmp_log (log_message) VALUES 
        ('>> Truncating Table: silver.erp_px_cat_g1v2'),
        ('>> Inserting Data Into: silver.erp_px_cat_g1v2');

    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    INSERT INTO silver.erp_px_cat_g1v2 (
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT
        id,
        cat,
        subcat,
        maintenance
    FROM bronze.erp_px_cat_g1v2;

    SET v_end_time = NOW();
    INSERT INTO tmp_log (log_message) VALUES 
        (CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time), ' seconds')),
        ('>> -------------');

    -- Calculate Batch Total Execution Duration
    SET v_batch_end_time = NOW();
    INSERT INTO tmp_log (log_message) VALUES 
        ('=========================================='),
        ('Loading Silver Layer is Completed'),
        (CONCAT('   - Total Load Duration: ', TIMESTAMPDIFF(SECOND, v_batch_start_time, v_batch_end_time), ' seconds')),
        ('==========================================');

    -- Output log messages in ONE single result grid
    SELECT log_message AS execution_log FROM tmp_log ORDER BY id;

    -- Clean up temporary table
    DROP TEMPORARY TABLE IF EXISTS tmp_log;

END //

DELIMITER ;

  CALL silver.load_silver();
