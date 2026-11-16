-- 1. Create the raw table (MySQL)
CREATE DATABASE IF NOT EXISTS lead_funnel;
USE lead_funnel;

DROP TABLE IF EXISTS leads_raw;
CREATE TABLE leads_raw (
    lead_id              INT,
    lead_date            DATE,
    lead_month           VARCHAR(7),
    source               VARCHAR(50),
    country_interest     VARCHAR(50),
    service              VARCHAR(50),
    consultation_booked  TINYINT,
    documents_submitted  TINYINT,
    visa_applied         TINYINT,
    visa_approved        TINYINT
);

-- 2. Load leads_raw.csv: in MySQL Workbench use Table Data Import Wizard on leads_raw,
--    or run (if local_infile is enabled):
-- LOAD DATA LOCAL INFILE 'leads_raw.csv' INTO TABLE leads_raw
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
