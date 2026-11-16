# Lead Funnel Analysis for a Global Talent Mobility Company (SQL + MySQL)

## The business question
Where do leads drop off between first enquiry and an approved visa, and which marketing channels bring the best leads?

## Important: the data is simulated
`leads_raw.csv` is a synthetic dataset created by `generate_data.py` (5,000 leads plus deliberate data-quality problems). It is not real company data. All findings below describe this simulated data. Say this clearly when you present the project.

## Tools
MySQL, SQL (aggregation, CASE, UNION ALL, window function LAG), MySQL Workbench, Python (only to generate the dataset), Looker Studio or Metabase (dashboard).

## Files
| File | What it does |
|---|---|
| `generate_data.py` | Creates the simulated dataset |
| `leads_raw.csv` | 5,060 raw rows (includes 60 duplicates, 80 missing sources, messy text) |
| `schema.sql` | Creates the MySQL database and table, and explains how to load the CSV |
| `queries.sql` | Data checks, cleaning and all analysis queries, with comments |
| `results_for_dashboard/` | Query results as CSVs, ready to upload to Looker Studio (via Google Sheets) |

## How to run it
1. Open MySQL Workbench and run `schema.sql`.
2. Import `leads_raw.csv` into the `leads_raw` table (Table Data Import Wizard).
3. Run `queries.sql` step by step.
4. Upload the CSVs in `results_for_dashboard/` to Google Sheets and connect them to Looker Studio.

## Method
1. **Checked quality:** 5,060 rows but only 5,000 distinct leads, 80 blank sources, and the same source written in different cases and with extra spaces.
2. **Cleaned:** removed duplicates with `DISTINCT`, standardised source names with `TRIM`, `LOWER` and `CASE`, and labelled blanks as `Unknown`.
3. **Measured the funnel:** leads, consultation booked, documents submitted, visa applied, visa approved.
4. **Compared channels and countries**, then **tracked monthly leads** with `LAG` to spot unusual changes.

## Findings (on the simulated data)
- Of 5,000 leads, 51.5% book a consultation and 17.3% reach an approved visa. The biggest single drop is before the consultation: almost half of leads never book one.
- Referral leads convert best, with 37.2% reaching approval. Instagram brings the most leads (1,483) but the lowest approval rate (8.2%).
- Google Ads leads fell to 62 in January 2026, against 84 to 114 in most other months, which would be worth flagging early.
- Australia has the lowest approval rate by country (15.0%), but the gap between countries is small.

## What I would recommend
Move some marketing spend from Instagram toward referrals and WhatsApp, and test follow-up reminders to get more leads to book a consultation.

## Limitations
Simulated data, no cohort or A/B analysis, and the dashboard is built from exported query results rather than a live database connection.
