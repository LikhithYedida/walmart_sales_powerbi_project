-----------------------------------------------
-- WALMART SALES ANALYSIS - SQL PREPARATION
-- Author: Likhith Yedida
-- Description: Table creation, data checks, 
--              enrichment, and validation steps
-----------------------------------------------

------------------------------
-- 1. CREATE SOURCE TABLES
------------------------------

CREATE TABLE features (
    store INT,
    date DATE,
    temperature FLOAT,
    fuel_price FLOAT,
    markdown1 FLOAT,
    markdown2 FLOAT,
    markdown3 FLOAT,
    markdown4 FLOAT,
    markdown5 FLOAT,
    cpi FLOAT,
    unemployment FLOAT
);

CREATE TABLE sales_train (
    store INT,
    dept INT,
    date DATE,
    weekly_sales FLOAT,
    isholiday BOOLEAN
);

CREATE TABLE stores (
    store INT,
    store_type VARCHAR(10),
    store_size INT
);

-----------------------------------------
-- 2. INITIAL DATA CHECKS (POST-IMPORT)
-----------------------------------------

-- Check the row counts
SELECT 'features' AS table_name, COUNT(*) AS rows FROM features;
SELECT 'sales_train' AS table_name, COUNT(*) AS rows FROM sales_train;
SELECT 'stores' AS table_name, COUNT(*) AS rows FROM stores;

-- Quick preview of each dataset
SELECT * FROM features LIMIT 5;
SELECT * FROM sales_train LIMIT 5;
SELECT * FROM stores LIMIT 5;

------------------------------------------------------
-- 3. CREATE ENRICHED DATASET FOR POWER BI MODELING
------------------------------------------------------

-- This table combines sales, store info, and external features
CREATE TABLE walmart_sales_enriched AS
SELECT 
    s.store,
    s.dept,
    s.date,
    s.weekly_sales,
    s.isholiday,
    st.store_type,
    st.store_size,
    f.temperature,
    f.fuel_price,
    f.cpi,
    f.unemployment
FROM sales_train s
LEFT JOIN stores st
    ON s.store = st.store
LEFT JOIN features f
    ON s.store = f.store AND s.date = f.date;

-----------------------------------------------
-- 4. VALIDATION QUERIES FOR ENRICHED DATASET
-----------------------------------------------

-- Check final row count
SELECT COUNT(*) AS enriched_rows FROM walmart_sales_enriched;

-- Validate if any records are missing store metadata
SELECT COUNT(*) AS missing_store_info
FROM walmart_sales_enriched
WHERE store_type IS NULL OR store_size IS NULL;

-- Validate if any records missing feature values
SELECT COUNT(*) AS missing_feature_values
FROM walmart_sales_enriched
WHERE temperature IS NULL 
   OR fuel_price IS NULL
   OR cpi IS NULL
   OR unemployment IS NULL;

-----------------------------------------------
-- 5. SAMPLE ANALYTICAL SQL (for README insights)
-----------------------------------------------

-- Total sales
SELECT SUM(weekly_sales) AS total_weekly_sales
FROM walmart_sales_enriched;

-- Average temperature
SELECT AVG(temperature) AS avg_temperature
FROM walmart_sales_enriched;

-- Sales by year
SELECT EXTRACT(YEAR FROM date) AS year,
       SUM(weekly_sales) AS yearly_sales
FROM walmart_sales_enriched
GROUP BY year
ORDER BY year;

-- Sales by store
SELECT store,
       SUM(weekly_sales) AS total_sales
FROM walmart_sales_enriched
GROUP BY store
ORDER BY total_sales DESC;
