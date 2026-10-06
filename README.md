# 📉 Global Tech Layoffs: SQL Data Cleaning & Exploratory Data Analysis

An end-to-end SQL project that takes a raw, messy layoffs dataset and turns it into an analysis-ready table, then explores it to uncover trends across companies, industries, countries, funding stages and time.

---

## 📑 Table of Contents

- [Project Overview](#-project-overview)
- [Dataset](#-dataset)
- [Repository Structure](#-repository-structure)
- [Part 1: Data Cleaning](#-part-1-data-cleaning)
- [Part 2: Exploratory Data Analysis](#-part-2-exploratory-data-analysis)
- [SQL Skills Demonstrated](#-sql-skills-demonstrated)
- [How to Run](#-how-to-run)
- [Key Takeaways](#-key-takeaways)
- [Future Improvements](#-future-improvements)
- [Author](#-author)

---

## 🎯 Project Overview

Raw data is rarely ready for analysis. This project walks through a realistic workflow in **MySQL**:

1. **Clean** the raw `layoffs` table safely, using staging tables so the original data is never modified.
2. **Explore** the cleaned data to answer questions about who was laid off, where, when and at what scale.

**Objectives**

- Remove duplicate records
- Standardise inconsistent text, country names and date formats
- Handle NULL and blank values
- Remove unusable rows and helper columns
- Analyse layoff trends by company, industry, country, stage and time period

---

## 📊 Dataset

**File:** [`layoffs.csv`](./layoffs.csv)

| Detail           | Value                     |
| ---------------- | ------------------------- |
| Records (raw)    | 2,361                     |
| Columns          | 9                         |
| Date range       | 11 Mar 2020 to 6 Mar 2023 |
| Unique companies | 1,893                     |
| Countries        | 60                        |

**Data dictionary**

| Column                  | Description                                                  |
| ----------------------- | ------------------------------------------------------------ |
| `company`               | Company that conducted the layoffs                           |
| `location`              | City / region of the company                                 |
| `industry`              | Industry sector (e.g. Crypto, Retail, Media)                 |
| `total_laid_off`        | Number of employees laid off                                 |
| `percentage_laid_off`   | Share of the workforce laid off (`1` = 100%)                 |
| `date`                  | Date of the layoff announcement (`M/D/YYYY` in the raw file) |
| `stage`                 | Funding stage (e.g. Seed, Series B, Post-IPO)                |
| `country`               | Country of the company                                       |
| `funds_raised_millions` | Total funds raised, in USD millions                          |

**Known data quality issues in the raw file** (addressed in the cleaning step)

- Duplicate rows
- Leading/trailing whitespace in company names
- Variants of the same industry (e.g. `Crypto`, `Crypto Currency`, `CryptoCurrency`)
- Variants of the same country (e.g. `United States` and `United States.`)
- Dates stored as text
- Missing industry values (NULL or blank)
- Many missing `total_laid_off` and `percentage_laid_off` values

---

## 📁 Repository Structure

```
.
├── layoffs.csv                          # Raw dataset
├── Layoffs_Data_cleaning.sql            # Data cleaning script
├── Layoffs_Exploratory_Data_Analaysis.sql  # Exploratory data analysis script
└── README.md
```

---

## 🧹 Part 1: Data Cleaning

**Script:** `Layoffs_Data_cleaning.sql`

The raw table is never edited directly. Work is done on staging copies (`layoffs_staging` → `layoffs_staging2`).

| Step                         | What was done                                                                             | How                                                                              |
| ---------------------------- | ----------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| **0. Staging**               | Created a working copy of the raw table                                                   | `CREATE TABLE ... LIKE`, `INSERT ... SELECT`                                     |
| **1. Remove duplicates**     | Identified rows identical across all columns and deleted the extras                       | `ROW_NUMBER() OVER (PARTITION BY ...)` in a CTE, then `DELETE WHERE row_num > 1` |
| **2a. Trim text**            | Removed stray whitespace from company names                                               | `TRIM()`                                                                         |
| **2b. Standardise industry** | Merged `Crypto` variants into one label                                                   | `UPDATE ... WHERE industry LIKE 'Crypto%'`                                       |
| **2c. Standardise country**  | Fixed `United States.` to `United States`                                                 | `TRIM(TRAILING '.' FROM country)`                                                |
| **2d. Fix date format**      | Converted text dates to a real `DATE` type                                                | `STR_TO_DATE(date, '%m/%d/%Y')`, then `ALTER TABLE ... MODIFY COLUMN`            |
| **3. Handle NULLs/blanks**   | Converted blank industries to NULL, then filled them using other rows of the same company | Self-join on `company`                                                           |
| **4. Remove unusable rows**  | Deleted rows with no `total_laid_off` **and** no `percentage_laid_off`                    | `DELETE ... WHERE ... IS NULL AND ... IS NULL`                                   |
| **5. Drop helper column**    | Removed the temporary `row_num` column                                                    | `ALTER TABLE ... DROP COLUMN`                                                    |

**Output:** a clean table named `layoffs_staging2`.

---

## 🔍 Part 2: Exploratory Data Analysis

**Script:** `Laayoff_Exploratory_Data_Analaysis.sql`

All queries run against the cleaned `layoffs_staging2` table.

| #   | Question                                                                                    | Technique                                          |
| --- | ------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| 1   | What are the largest single layoff and highest percentage?                                  | `MAX()`                                            |
| 2   | Which companies shut down completely (100% laid off), ranked by size and by funding raised? | `WHERE percentage_laid_off = 1`, `ORDER BY`        |
| 3   | Which companies had the most total layoffs?                                                 | `GROUP BY`, `SUM()`                                |
| 4   | What period does the data cover?                                                            | `MIN()` / `MAX()` on dates                         |
| 5   | Which industries were hit hardest?                                                          | `GROUP BY industry`                                |
| 6   | Which countries saw the most layoffs?                                                       | `GROUP BY country`                                 |
| 7   | How did layoffs change year to year?                                                        | `YEAR()`                                           |
| 8   | Which funding stages were most affected?                                                    | `GROUP BY stage`                                   |
| 9   | What is each company's average percentage laid off?                                         | `AVG()`                                            |
| 10  | What are monthly layoffs?                                                                   | `SUBSTRING(date, 1, 7)`                            |
| 11  | What is the **rolling (cumulative) total** by month?                                        | CTE + `SUM() OVER (ORDER BY ...)`                  |
| 12  | Who were the **top 5 companies by layoffs in each year**?                                   | Multi-CTE + `DENSE_RANK() OVER (PARTITION BY ...)` |

---

## 🛠 SQL Skills Demonstrated

- Staging tables and safe data-cleaning workflow
- Common Table Expressions (CTEs), including multiple chained CTEs
- Window functions: `ROW_NUMBER()`, `DENSE_RANK()`, running totals with `SUM() OVER()`
- Self-joins for data imputation
- Aggregations: `SUM`, `AVG`, `MAX`, `MIN`, `GROUP BY`
- String and date functions: `TRIM`, `SUBSTRING`, `STR_TO_DATE`, `YEAR`
- DDL/DML: `CREATE`, `ALTER`, `UPDATE`, `DELETE`, `INSERT`

---

## ▶️ How to Run

**Requirements:** MySQL 8.0+ (window functions are required) and MySQL Workbench or any SQL client.

1. **Create a database and import the data**

   ```sql
   CREATE DATABASE world_layoffs;
   USE world_layoffs;
   ```

   Import `layoffs.csv` into a table named `layoffs` (in MySQL Workbench: right-click _Tables_ → _Table Data Import Wizard_).

2. **Run the cleaning script**
   Execute `Layoffs_Data_cleaning.sql` to produce the `layoffs_staging2` table.

3. **Run the analysis**
   Execute `Layoffs_Exploratory_Data_Analaysis.sql` and review the results of each query.

> ⚠️ **Note:** Run the cleaning script in order, section by section. Some statements (e.g. `DELETE`, `ALTER`) change data permanently within the staging table.

---

## 💡 Key Takeaways

**Cleaning results:** 5 duplicate rows removed, and rows missing both `total_laid_off` and `percentage_laid_off` were deleted, leaving **1,995 usable records** (from 2,361 raw) covering **383,159 total layoffs**.

| Question                                         | Finding                                                                                                       |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------- |
| **Largest single layoff**                        | 12,000 employees (Google, 2023)                                                                               |
| **Companies that shut down (100% laid off)**     | 116 companies; largest by headcount is **Katerra** (2,434)                                                    |
| **Most funding raised by a company that closed** | **Britishvolt** ($2.4B), followed by Quibi ($1.8B) and Deliveroo Australia ($1.7B)                            |
| **Top companies overall**                        | Amazon (18,150), Google (12,000), Meta (11,000), Salesforce (10,090), Microsoft (10,000)                      |
| **Top industries**                               | Consumer (45,182), Retail (43,613), Other (36,289), Transportation (33,748), Finance (28,344)                 |
| **Top country**                                  | **United States**: 256,559 layoffs (about 67% of the total), then India (35,993) and the Netherlands (17,220) |
| **Top funding stage**                            | **Post-IPO**: 204,132 layoffs (about 53% of the total)                                                        |
| **Peak month**                                   | **January 2023**: 84,714 layoffs, followed by November 2022 (53,451)                                          |
| **Layoffs by year**                              | 2020: 80,998 · 2021: 15,823 · **2022: 160,661** · 2023 (Jan to early Mar only): 125,677                       |

**Top 5 companies per year**

| Year | Top companies (layoffs)                                                                                 |
| ---- | ------------------------------------------------------------------------------------------------------- |
| 2020 | Uber (7,525), Booking.com (4,375), Groupon (2,800), Swiggy (2,250), Airbnb (1,900)                      |
| 2021 | Bytedance (3,600), Katerra (2,434), Zillow (2,000), Instacart (1,877), WhiteHat Jr (1,800)              |
| 2022 | Meta (11,000), Amazon (10,150), Cisco (4,100), Peloton (4,084), Carvana and Philips (4,000 each)        |
| 2023 | Google (12,000), Microsoft (10,000), Ericsson (8,500), Amazon and Salesforce (8,000 each), Dell (6,650) |

**Insights**

- Layoffs surged in **2022 to 2023** after a sharp dip in 2021. The 2023 figure covers only about two months of data, yet is already close to 2022's total.
- Large, **publicly listed companies** account for over half of all layoffs, and the **US** dominates by a wide margin.
- Even heavily funded startups can collapse entirely, so high funding did not guarantee survival.
- Cleaning in a staging table preserves the raw data and keeps every step auditable.

> Figures reflect the cleaned dataset after the steps in Part 1. Percentages are rounded.

---

## 🚀 Future Improvements

- Visualise results in Tableau or Power BI
- Add a dashboard of monthly trends and top companies
- Automate the cleaning pipeline with a stored procedure
- Extend the analysis with funding vs. layoff-size comparisons

---

⭐ If you found this project useful, consider giving it a star!
