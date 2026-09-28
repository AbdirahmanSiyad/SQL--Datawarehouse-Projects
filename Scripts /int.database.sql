/*
=============================================================
Create Single Data Warehouse Database
Create Data Warehouse Layered Databases
=============================================================
Script Purpose:
This script drops and recreates a single database named 'Datawarehouse'.
    In MySQL, schema separation is implemented via table naming 
    conventions (e.g., bronze_tablename, silver_tablename).
    
    This script drops and recreates three MySQL databases to represent
    the data warehouse layers: 'bronze', 'silver', 
    and 'gold'.
    
WARNING:
    Running this script will drop the target databases if they exist. 
    All existing data will be permanently deleted.
=============================================================
*/

use mysql;
-- Drop and recreate the 'datawarehouse' database
DROP DATABASE IF EXISTS datawarehouse;
CREATE DATABASE datawarehouse;

USE datawarehouse;

-- Create the 'DataWarehouse' database
create database Datawarehouse;
use Datawarehouse;

-- Create Schemas
create schema bronze;
create schema silver;
create schema gold;
