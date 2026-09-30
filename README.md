# Data Warehouse & Analytics Project (MySQL & SQL Server)

Welcome to the **Data Warehouse and Analytics Project** repository! 🚀

This project demonstrates an end-to-end Data Engineering and Analytics solution using the **Medallion Architecture (Bronze, Silver, Gold)**. Built originally as a portfolio project inspired by the course by **Data with Baraa**, this repository contains full implementations in **MySQL (macOS optimized)** as well as **SQL Server**.

---

## 🏗️ Data Architecture

The architecture follows the 3-tier **Medallion Pattern** to transform raw data into business-ready analytical assets:

![Data Architecture](docs/data_architecture.png)

1. **Bronze Layer**: Ingests raw source data (CRM & ERP) as-is from CSV files into the staging database using automated batch load scripts.
2. **Silver Layer**: Cleanses, standardizes, handles NULLs, and normalizes raw data to ensure data quality.
3. **Gold Layer**: Models transformed data into a Star Schema (Fact and Dimension tables) optimized for BI reporting and analytical queries.

---

## 📖 Project Overview

Key engineering and analytical milestones achieved in this project:

- **Architecture Design**: Building a modern Data Warehouse using Medallion Architecture.
- **ETL Pipeline Engineering**: Extracting, transforming, and loading multi-source data (CRM and ERP systems).
- **Data Modeling**: Designing dimensional models (Star Schema) tailored for business analytics.
- **BI & Analytics**: Writing SQL queries to extract key performance metrics on customers, sales, and products.

> **Note on MySQL vs. SQL Server Implementation:**  
> The original course curriculum utilizes Microsoft SQL Server. If you are working in **MySQL (macOS/Linux)**, you can directly execute the provided MySQL batch scripts in `scripts/bronze/` which address macOS file pathing and local execution restrictions.

---

## 🛠️ Tools & Technologies

- **Database Engines**: MySQL 8.0, Microsoft SQL Server Express
- **GUI Clients**: MySQL Workbench, SQL Server Management Studio (SSMS)
- **Data Modeling & Diagramming**: Draw.io
- **Version Control**: Git & GitHub

---

## 🎓 Credit & Learning Resources

This project was built while following the data engineering curriculum taught by **Data with Baraa**.
- **Instructor**: Data with Baraa
- **YouTube Channel**: [Data with Baraa on YouTube](https://www.youtube.com/@datawithbaraa)
- **Reference Project Resources**: [Notion Project Guide](https://thankful-pangolin-2ca.notion.site/SQL-Data-Warehouse-Project-16ed041640ef80489667cfe2f380b269?pvs=4)

---

## 📂 Repository Structure

```text
data-warehouse-project/
│
├── datasets/             # Raw CSV datasets (CRM and ERP source systems)
├── docs/                 # Architecture diagrams, data catalog, naming conventions
├── scripts/              # Production SQL scripts
│   ├── bronze/           # Batch ingestion scripts (CSV -> Bronze tables)
│   ├── silver/           # Data cleaning & transformation scripts (Bronze -> Silver)
│   └── gold/             # Dimensional modeling scripts (Silver -> Gold views/tables)
├── tests/                # Data quality check scripts
├── LICENSE               # MIT License
└── README.md             # Project documentation

🌟 About Me
Hi! I'm Abdirahman Osman Siyad, a Petroleum Engineer (B.E., NED University) transitioning into Data Analytics Data Engineering. Combining a rigorous engineering problem-solving background with data tools like SQL, MySQL, Python, and Tableau, Power BI, I build scalable data pipelines and analytical solutions.

📬 Connect with me:
Email: Abdirhman.Osman.Siyad@gmail.com
LinkedIn: Abdirahman Osman Siyad


🛡️ License
This project is open-source and licensed under the MIT License.
