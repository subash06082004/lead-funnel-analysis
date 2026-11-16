-- ===== STEP 1: Check data quality =====
-- Rows vs distinct leads (duplicates)
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT lead_id) AS distinct_leads FROM leads_raw;

-- Missing or messy source values
SELECT source, COUNT(*) AS rows_count FROM leads_raw GROUP BY source ORDER BY rows_count DESC;

-- ===== STEP 2: Clean the data =====
DROP TABLE IF EXISTS leads_clean;
CREATE TABLE leads_clean AS
SELECT DISTINCT
    lead_id, lead_date, lead_month,
    CASE LOWER(TRIM(source))
        WHEN 'instagram'       THEN 'Instagram'
        WHEN 'google ads'      THEN 'Google Ads'
        WHEN 'website organic' THEN 'Website Organic'
        WHEN 'whatsapp'        THEN 'WhatsApp'
        WHEN 'referral'        THEN 'Referral'
        ELSE 'Unknown'
    END AS source,
    country_interest, service,
    consultation_booked, documents_submitted, visa_applied, visa_approved
FROM leads_raw;

-- ===== STEP 3: Overall funnel (where do leads drop off?) =====
SELECT 'Leads' AS stage, COUNT(*) AS leads, 100.0 AS pct_of_all_leads FROM leads_clean
UNION ALL SELECT 'Consultation booked', SUM(consultation_booked), ROUND(100.0*SUM(consultation_booked)/COUNT(*),1) FROM leads_clean
UNION ALL SELECT 'Documents submitted', SUM(documents_submitted), ROUND(100.0*SUM(documents_submitted)/COUNT(*),1) FROM leads_clean
UNION ALL SELECT 'Visa applied',        SUM(visa_applied),        ROUND(100.0*SUM(visa_applied)/COUNT(*),1)        FROM leads_clean
UNION ALL SELECT 'Visa approved',       SUM(visa_approved),       ROUND(100.0*SUM(visa_approved)/COUNT(*),1)       FROM leads_clean;

-- ===== STEP 4: Funnel by lead source (which channel brings quality leads?) =====
SELECT source,
       COUNT(*) AS leads,
       SUM(consultation_booked) AS consultations,
       SUM(visa_approved)       AS approvals,
       ROUND(100.0*SUM(consultation_booked)/COUNT(*),1) AS lead_to_consult_pct,
       ROUND(100.0*SUM(visa_approved)/COUNT(*),1)       AS lead_to_approval_pct
FROM leads_clean
GROUP BY source
ORDER BY lead_to_approval_pct DESC;

-- ===== STEP 5: Approval rate by country of interest =====
SELECT country_interest,
       COUNT(*) AS leads,
       SUM(visa_approved) AS approvals,
       ROUND(100.0*SUM(visa_approved)/COUNT(*),1) AS lead_to_approval_pct
FROM leads_clean
GROUP BY country_interest
ORDER BY lead_to_approval_pct DESC;

-- ===== STEP 6: Monthly leads and month-over-month change (spot unusual swings) =====
SELECT lead_month,
       COUNT(*) AS leads,
       ROUND(100.0*(COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY lead_month))
             / LAG(COUNT(*)) OVER (ORDER BY lead_month), 1) AS mom_change_pct
FROM leads_clean
GROUP BY lead_month
ORDER BY lead_month;

-- ===== STEP 7: Google Ads leads by month (investigate the anomaly) =====
SELECT lead_month, COUNT(*) AS google_ads_leads
FROM leads_clean
WHERE source = 'Google Ads'
GROUP BY lead_month
ORDER BY lead_month;
