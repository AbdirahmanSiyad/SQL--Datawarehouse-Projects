 
 /*
===============================================================================
DDL Script: Create Bronze Layer Tables (MySQL)
            Create Bronze Layer Tables with Prefixes (MySQL)
===============================================================================
Script Purpose:
    This script creates tables in the 'datawarehouse_bronze' database, dropping 
    existing tables if they already exist.
===============================================================================
*/
 
 
 -- Source crm
 -- Table: bronze_crm_cust_info
DROP TABLE IF EXISTS bronze.crm_cust_info;
Create Table bronze.crm_cust_info(
	cst_id int,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_marital_status nvarchar(50),
	cst_gndr nvarchar(50),
	cst_create_date date
);


-- Table: bronze_crm_prd_info;
 DROP TABLE IF EXISTS bronze.crm_prd_info;
create table bronze.crm_prd_info(
 prd_id int,
 prd_key nvarchar(50),
 prd_nm nvarchar(50),
 prd_cost int,
 prd_line nvarchar(50),
 prd_start_dt datetime,
 prd_end_dt datetime
 );
 
 
-- Table: bronze.crm_sales_details;
 DROP TABLE IF EXISTS bronze.crm_sales_details;
 create table bronze.crm_sales_details(
 sls_ord_num  nvarchar(50),
 sls_prd_key nvarchar(50),
 sls_cust_id int,
 sls_order_dt int,
 sls_ship_dt int,
 sls_due_dt int,
 sls_sales int,
 sls_quantity int,
 sls_price int
 );
 
 
 -- Source erp
-- Table: bronze.erp_cust_az12;
 DROP TABLE IF EXISTS bronze.erp_cust_az12;
 create table bronze.erp_cust_az12(
 cid nvarchar(50),
 bdate date,
 gen nvarchar(50)
 );
 
 
-- Table: bronze.erp_loc_a101;
DROP TABLE IF EXISTS bronze.erp_loc_a101;
 create table bronze.erp_loc_a101(
 cid nvarchar(50),
cntry nvarchar(50)
 );
 
 
-- Table: bronze.erp_px_cat_g1v2;
 DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
 create table bronze.erp_px_cat_g1v2(
 id nvarchar(50),
 cat nvarchar(50),
 subcat nvarchar(50),
 maintenance nvarchar(50)
 );
 
 
 
 
 
 
 
