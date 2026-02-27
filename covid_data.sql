/******************************************************************
* COVID-19 Database and Analysis Script
* Author: [Your Name]
* Date: [Today’s Date]
* Description:
* This script creates a COVID-19 database, imports data into the
* SERIES table, checks for missing values, cleans the data, and
* performs exploratory data analysis including aggregation,
* central tendency, dispersion, percentiles, and correlation.
******************************************************************/

/**********************************************************
* 1. CREATE DATABASE AND TABLE
**********************************************************/

-- Create COVID database
CREATE DATABASE COVID;

-- Switch to COVID database
USE COVID;
GO

-- Create SERIES table to store COVID-19 data
CREATE TABLE SERIES (
    PROVINCE VARCHAR(50),
    COUNTRY_REGION VARCHAR(50),
    LATITUDE FLOAT,
    LONGITUDE FLOAT,
    DATE_ DATE,
    CONFIRMED INT,
    DEATHS INT,
    RECOVERED INT
);

-- Preview all data (after import)
SELECT * FROM SERIES;

-- Count total rows
SELECT COUNT(*) AS total_rows FROM SERIES;

/**********************************************************
* 2. DATA CHECKING AND CLEANING
**********************************************************/

-- Check for missing values
SELECT *
FROM SERIES
WHERE PROVINCE IS NULL
   OR COUNTRY_REGION IS NULL
   OR LATITUDE IS NULL
   OR LONGITUDE IS NULL
   OR DATE_ IS NULL
   OR CONFIRMED IS NULL
   OR DEATHS IS NULL
   OR RECOVERED IS NULL;

-- Handle missing LONGITUDE and LATITUDE
UPDATE SERIES SET LONGITUDE = 0 WHERE LONGITUDE IS NULL;
UPDATE SERIES SET LATITUDE = 0 WHERE LATITUDE IS NULL;

-- Delete rows with missing DATE_
DELETE FROM SERIES WHERE DATE_ IS NULL;

-- Set missing CONFIRMED, DEATHS, RECOVERED to 0
UPDATE SERIES SET CONFIRMED = 0 WHERE CONFIRMED IS NULL;
UPDATE SERIES SET DEATHS = 0 WHERE DEATHS IS NULL;
UPDATE SERIES SET RECOVERED = 0 WHERE RECOVERED IS NULL;

-- Preview first 10 rows
SELECT * FROM SERIES LIMIT 10;

-- Verify total rows after cleaning
SELECT COUNT(*) AS total_rows FROM SERIES;

/**********************************************************
* 3. DATA OVERVIEW AND TIME RANGE
**********************************************************/

-- Count distinct months per year
SELECT 
    EXTRACT(YEAR FROM DATE_) AS year,
    COUNT(DISTINCT EXTRACT(MONTH FROM DATE_)) AS number_of_months
FROM SERIES
GROUP BY EXTRACT(YEAR FROM DATE_)
ORDER BY year;

-- Start and end date of dataset
SELECT 
    MIN(DATE_) AS start_date,
    MAX(DATE_) AS end_date
FROM SERIES;

-- Monthly data availability
SELECT 
    EXTRACT(YEAR FROM DATE_) AS year,
    EXTRACT(MONTH FROM DATE_) AS month,
    COUNT(*) AS number_of_rows
FROM SERIES
GROUP BY 1,2
ORDER BY 1,2;

/**********************************************************
* 4. MONTHLY AGGREGATIONS
**********************************************************/

-- Minimum monthly values
SELECT 
    EXTRACT(YEAR FROM DATE_) AS year,
    EXTRACT(MONTH FROM DATE_) AS month,
    MIN(CONFIRMED) AS min_confirmed,
    MIN(DEATHS) AS min_deaths,
    MIN(RECOVERED) AS min_recovered
FROM SERIES
GROUP BY 1,2
ORDER BY 1,2;

-- Maximum monthly values
SELECT 
    EXTRACT(YEAR FROM DATE_) AS year,
    EXTRACT(MONTH FROM DATE_) AS month,
    MAX(CONFIRMED) AS max_confirmed,
    MAX(DEATHS) AS max_deaths,
    MAX(RECOVERED) AS max_recovered
FROM SERIES
GROUP BY 1,2
ORDER BY 1,2;

-- Total monthly values
SELECT 
    EXTRACT(YEAR FROM DATE_) AS year,
    EXTRACT(MONTH FROM DATE_) AS month,
    SUM(CONFIRMED) AS total_confirmed,
    SUM(DEATHS) AS total_deaths,
    SUM(RECOVERED) AS total_recovered
FROM SERIES
GROUP BY 1,2
ORDER BY 1,2;

/**********************************************************
* 5. CENTRAL TENDENCY (MEAN, MEDIAN, MODE)
**********************************************************/

-- Average monthly confirmed, deaths, recovered
SELECT 
    EXTRACT(YEAR FROM DATE_) AS year,
    EXTRACT(MONTH FROM DATE_) AS month,
    ROUND(AVG(CONFIRMED),0) AS avg_confirmed,
    ROUND(AVG(DEATHS),0) AS avg_deaths,
    ROUND(AVG(RECOVERED),0) AS avg_recovered
FROM SERIES
GROUP BY 1,2
ORDER BY 1,2;

-- Median of confirmed cases
SELECT 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CONFIRMED) AS median_confirmed
FROM SERIES;

-- Mode of confirmed cases per month
SELECT 
    EXTRACT(YEAR FROM DATE_) AS year,
    EXTRACT(MONTH FROM DATE_) AS month,
    CONFIRMED,
    COUNT(*) AS frequency
FROM SERIES
WHERE CONFIRMED IS NOT NULL
GROUP BY 1,2,CONFIRMED
ORDER BY frequency DESC
LIMIT 1;

/**********************************************************
* 6. MEASURES OF DISPERSION
**********************************************************/

-- Overall dispersion of confirmed, deaths, recovered
SELECT SUM(CONFIRMED) AS total_confirmed,
       ROUND(AVG(CONFIRMED),0) AS avg_confirmed,
       ROUND(VAR_SAMP(CONFIRMED),0) AS var_confirmed,
       ROUND(STDDEV_SAMP(CONFIRMED),0) AS stddev_confirmed
FROM SERIES;

SELECT SUM(DEATHS) AS total_deaths,
       ROUND(AVG(DEATHS),0) AS avg_deaths,
       ROUND(VAR_SAMP(DEATHS),0) AS var_deaths,
       ROUND(STDDEV_SAMP(DEATHS),0) AS stddev_deaths
FROM SERIES;

SELECT SUM(RECOVERED) AS total_recovered,
       ROUND(AVG(RECOVERED),0) AS avg_recovered,
       ROUND(VAR_SAMP(RECOVERED),0) AS var_recovered,
       ROUND(STDDEV_SAMP(RECOVERED),0) AS stddev_recovered
FROM SERIES;

-- Monthly dispersion of confirmed, deaths, recovered
SELECT EXTRACT(YEAR FROM DATE_) AS year,
       EXTRACT(MONTH FROM DATE_) AS month,
       SUM(CONFIRMED) AS total_confirmed,
       ROUND(AVG(CONFIRMED),0) AS avg_confirmed,
       ROUND(VAR_SAMP(CONFIRMED),0) AS var_confirmed,
       ROUND(STDDEV_SAMP(CONFIRMED),0) AS stddev_confirmed
FROM SERIES
GROUP BY 1,2
ORDER BY 1,2;

SELECT EXTRACT(YEAR FROM DATE_) AS year,
       EXTRACT(MONTH FROM DATE_) AS month,
       SUM(DEATHS) AS total_deaths,
       ROUND(AVG(DEATHS),0) AS avg_deaths,
       ROUND(VAR_SAMP(DEATHS),0) AS var_deaths,
       ROUND(STDDEV_SAMP(DEATHS),0) AS stddev_deaths
FROM SERIES
GROUP BY 1,2
ORDER BY 1,2;

SELECT EXTRACT(YEAR FROM DATE_) AS year,
       EXTRACT(MONTH FROM DATE_) AS month,
       SUM(RECOVERED) AS total_recovered,
       ROUND(AVG(RECOVERED),0) AS avg_recovered,
       ROUND(VAR_SAMP(RECOVERED),0) AS var_recovered,
       ROUND(STDDEV_SAMP(RECOVERED),0) AS stddev_recovered
FROM SERIES
GROUP BY 1,2
ORDER BY 1,2;

/**********************************************************
* 7. PERCENTILES AND FREQUENCY ANALYSIS
**********************************************************/

-- Preview first 5 records
SELECT * FROM SERIES LIMIT 5;

-- Top 10 highest confirmed cases
SELECT * FROM SERIES ORDER BY CONFIRMED DESC LIMIT 10;

-- Top 10 highest deaths
SELECT * FROM SERIES ORDER BY DEATHS DESC LIMIT 10;

-- Top 10 highest recovered cases
SELECT * FROM SERIES ORDER BY RECOVERED DESC LIMIT 10;

-- Average confirmed, deaths, recovered
SELECT ROUND(AVG(CONFIRMED)::numeric,0) AS avg_confirmed,
       ROUND(AVG(DEATHS)::numeric,0) AS avg_deaths,
       ROUND(AVG(RECOVERED)::numeric,0) AS avg_recovered
FROM SERIES;

-- 50th percentile (median)
SELECT PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY CONFIRMED) AS pct_50_confirmed,
       PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY DEATHS) AS pct_50_deaths,
       PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY RECOVERED) AS pct_50_recovered
FROM SERIES;

-- Percentiles for confirmed cases (50th, 60th, 90th, 95th)
SELECT PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY CONFIRMED) AS pct_50_confirmed,
       PERCENTILE_DISC(0.6) WITHIN GROUP (ORDER BY CONFIRMED) AS pct_60_confirmed,
       PERCENTILE_DISC(0.9) WITHIN GROUP (ORDER BY CONFIRMED) AS pct_90_confirmed,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY CONFIRMED) AS pct_95_confirmed
FROM SERIES;

-- 95th percentile: continuous vs discrete
SELECT PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY CONFIRMED) AS pct_95_cont_confirmed,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY CONFIRMED) AS pct_95_disc_confirmed
FROM SERIES;

/**********************************************************
* 8. CORRELATION AND REGRESSION
**********************************************************/

-- Correlation between confirmed, deaths, recovered
SELECT CORR(CONFIRMED, DEATHS) AS cor_cf_dt,
       CORR(CONFIRMED, RECOVERED) AS cor_cf_rc,
       CORR(DEATHS, RECOVERED) AS cor_dt_rc
FROM SERIES;

-- Add row numbers based on confirmed cases
SELECT ROW_NUMBER() OVER (ORDER BY CONFIRMED DESC) AS row_number,
       PROVINCE, COUNTRY_REGION, CONFIRMED
FROM SERIES;

-- Linear regression: DEATHS ~ CONFIRMED (slope)
SELECT 
    (COUNT(CONFIRMED)::numeric * SUM(CONFIRMED::bigint * DEATHS::bigint) - 
     SUM(CONFIRMED::bigint) * SUM(DEATHS::bigint))
    /
    (COUNT(CONFIRMED)::numeric * SUM(CONFIRMED::bigint * CONFIRMED::bigint) - 
     SUM(CONFIRMED::bigint)^2) AS slope;

-- Linear regression: DEATHS ~ CONFIRMED (intercept)
SELECT AVG(DEATHS) - 
       (
         (COUNT(CONFIRMED)::numeric * SUM(CONFIRMED::numeric * DEATHS::numeric) - SUM(CONFIRMED::numeric) * SUM(DEATHS::numeric))
         /
         NULLIF((COUNT(CONFIRMED)::numeric * SUM(CONFIRMED::numeric * CONFIRMED::numeric) - SUM(CONFIRMED::numeric) * SUM(CONFIRMED::numeric)), 0)
       ) * AVG(CONFIRMED) AS intercept
FROM SERIES
WHERE CONFIRMED IS NOT NULL AND DEATHS IS NOT NULL;

