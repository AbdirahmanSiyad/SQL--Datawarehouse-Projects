Markdown<div align="center">

# 📊 Data Warehouse & Analytics Portfolio Project
### End-to-End ETL Pipeline & Dimensional Modeling (MySQL & SQL Server)

[![Database](https://img.shields.io/badge/Database-MySQL_8.0_%7C_SQL_Server-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](#)
[![Architecture](https://img.shields.io/badge/Architecture-Medallion_(Bronze_Silver_Gold)-00599C?style=for-the-badge)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

---

</div>

## 👋 Welcome!

Welcome to my **Data Warehouse and Analytics Portfolio Project**! 🚀

Whether you are a data professional, a recruiter, or a fellow learner, I am glad you are here. This repository showcases a complete, production-ready implementation of a Modern Data Warehouse built using the **Medallion Architecture**. It covers the full lifecycle of data—from raw CSV ingestion and multi-source data cleaning to dimensional modeling (Star Schema) for business intelligence.

Feel free to explore the scripts, clone the repository, and review the technical workflows. If you have any questions, feedback, or collaboration ideas, don't hesitate to reach out!

---

## 📖 Executive Summary

This repository presents an end-to-end **Data Warehouse and Analytics Solution** built following industry best practices for data engineering and business intelligence. 

The primary objective of this project is to extract raw transactional datasets from disparate source systems (CRM and ERP), transform and cleanse the data, and model it into an enterprise-ready analytical data warehouse using the **Medallion Architecture**.

> **Note on Cross-Platform Implementation:**  
> While the foundational project logic follows the course by **Data with Baraa** (originally designed for Microsoft SQL Server), this repository provides full optimization for **MySQL 8.0 on macOS**. It includes custom batch ingestion scripts handling local file privileges, table truncation, and combined logging protocols.

---

## 🏗️ Data Architecture

The data pipeline adopts a 3-tier **Medallion Architecture Pattern** to ensure strict data lineage, quality control, and scalable analytics delivery:

+------------------+      +------------------+      +------------------+      +------------------+|                  |      |   BRONZE LAYER   |      |   SILVER LAYER   |      |    GOLD LAYER    ||   Source Systems |      |  (Raw Ingestion) |      | (Data Cleansing) |      | (Data Modeling)  ||                  | ---> |                  | ---> |                  | ---> |                  ||  - CRM Datasets  |      | Raw CSV files    |      | Cleansed,        |      | Star Schema      ||  - ERP Datasets  |      | loaded as-is     |      | normalized tables|      | Fact & Dimensions|+------------------+      +------------------+      +------------------+      +------------------+|v+------------------+| BI Analytics &   || Reporting        |+------------------+
### Architectural Breakdown
1. **Bronze Layer (Raw Ingestion)**: Ingests structured CSV source files as-is into staging tables using optimized bulk operations (`LOAD DATA LOCAL INFILE` in MySQL / `BULK INSERT` in SQL Server).
2. **Silver Layer (Data Cleansing & Normalization)**: Standardizes data types, trims white space, handles `NULL` values, and enforces relational integrity rules across systems.
3. **Gold Layer (Analytical Star Schema)**: Transforms cleansed data into dimension and fact tables optimized for OLAP analytical queries, executive dashboards, and business reporting.

---

## 🛠️ Tech Stack & Prerequisites

* **Database Systems**: MySQL 8.0+, Microsoft SQL Server Express
* **Database Clients**: MySQL Workbench, SQL Server Management Studio (SSMS)
* **Data Modeling & System Architecture**: Draw.io
* **Version Control**: Git & GitHub

---

## 🎓 Attribution & Learning Credits

This implementation was developed as part of advanced hands-on data engineering training guided by **Data with Baraa**.

* **Instructor**: Data with Baraa
* **YouTube Channel**: [Data with Baraa - Official Channel](https://www.youtube.com/@datawithbaraa)
* **Curriculum Roadmap**: [SQL Data Warehouse Project - Notion Guide](https://thankful-pangolin-2ca.notion.site/SQL-Data-Warehouse-Project-16ed041640ef80489667cfe2f380b269?pvs=4)

---

## 📂 Repository Structure

```text
sql-data-warehouse-project/
│
├── datasets/                 # Raw source CSV files (CRM & ERP system exports)
│   ├── source_crm/           # Customer, product, and sales transaction data
│   └── source_erp/           # Location, customer category, and product mapping data
│
├── docs/                     # Technical documentation & architectural schematics
│   ├── data_architecture.png # Visual system architecture diagram
│   ├── data_catalog.md       # Field definitions, data types, and business rules
│   └── naming-conventions.md # SQL database and schema naming standards
│
├── scripts/                  # Production-ready SQL scripts
│   ├── bronze/               # Automated raw data batch ingestion scripts
│   ├── silver/               # Data quality, standardization, and cleaning procedures
│   └── gold/                 # Dimensional modeling scripts (Star Schema views/tables)
│
├── tests/                    # Data validation and record audit queries
├── LICENSE                   # Open-source MIT License
└── README.md                 # Project documentation


🌟 About the Author
Hi! I am Abdirahman Osman Siyad, a Petroleum Engineering graduate (B.E., NED University) actively specializing in Data Engineering and Analytics. I bridge domain engineering discipline with analytical technical tools to construct scalable database pipelines and data-driven solutions.

Technical Skill Set
Data Engineering: SQL (MySQL, PostgreSQL, SQL Server), Data Pipelines, Data Warehousing, Data Modeling (Star Schema)

Analytics & Visualization: Power BI, Python, Data Cleansing, SQL Reporting

Domain Background: Petroleum Engineering, Reservoir Analytics, Process Workflow Modeling

🛡️ License
Distributed under the MIT License. See LICENSE for more information.
