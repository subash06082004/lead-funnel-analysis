"""Generate a SIMULATED dataset of global-mobility leads (5,000 rows + deliberate data-quality issues).
All data is synthetic. Seeded so results are reproducible."""
import csv, random
from datetime import date, timedelta

random.seed(42)
N = 5000
start = date(2025, 7, 1)
days = 365

sources = {
    # name: (volume weight, consult, docs, visa_applied, approved)
    "Instagram":       (0.30, 0.35, 0.55, 0.60, 0.70),
    "Google Ads":      (0.25, 0.50, 0.60, 0.65, 0.72),
    "Website Organic": (0.20, 0.55, 0.65, 0.70, 0.75),
    "WhatsApp":        (0.15, 0.60, 0.70, 0.72, 0.75),
    "Referral":        (0.10, 0.75, 0.80, 0.82, 0.80),
}
countries = ["Canada", "Germany", "Australia", "UK", "UAE"]
services = ["Visa Support", "Job Search Guidance"]
names, weights = zip(*[(k, v[0]) for k, v in sources.items()])

rows = []
for i in range(1, N + 1):
    d = start + timedelta(days=random.randrange(days))
    src = random.choices(names, weights)[0]
    # simulated incident: Google Ads leads collapse in Jan 2026 (tracking issue) -> lets analyst spot an anomaly
    if src == "Google Ads" and d.year == 2026 and d.month == 1 and random.random() < 0.6:
        src = random.choices(names, weights)[0]
    _, pc, pd_, pv, pa = sources[src]
    consult = random.random() < pc
    docs = consult and random.random() < pd_
    applied = docs and random.random() < pv
    approved = applied and random.random() < pa
    rows.append([i, d.isoformat(), d.strftime("%Y-%m"), src, random.choice(countries),
                 random.choice(services), int(consult), int(docs), int(applied), int(approved)])

# deliberate data-quality issues to clean in SQL
for r in random.sample(rows, 80):            # missing source
    r[3] = ""
for r in random.sample(rows, 120):           # inconsistent text
    r[3] = random.choice([r[3].lower(), r[3].upper(), " " + r[3] + " "]) if r[3] else r[3]
dupes = random.sample(rows, 60)              # exact duplicate rows
rows.extend([list(r) for r in dupes])
random.shuffle(rows)

with open("leads_raw.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["lead_id", "lead_date", "lead_month", "source", "country_interest", "service",
                "consultation_booked", "documents_submitted", "visa_applied", "visa_approved"])
    w.writerows(rows)
print(len(rows), "rows written")
