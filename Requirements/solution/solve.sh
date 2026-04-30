#!/bin/bash
python3 - << 'EOF'
import pandas as pd
import json
import os

INPUT_DIR   = '/task/input_artifacts'
OUTPUT      = '/task/report.json'
SCHEMA_FILE = os.path.join(INPUT_DIR, 'schema_reference.json')

with open(SCHEMA_FILE) as f:
    schema = json.load(f)

frames = []
total_skipped = 0

for entry in schema:
    fname  = os.path.basename(entry['file'].replace('\\', '/'))
    region = fname.replace('sales_', '').rsplit('_', 1)[0]

    id_col  = entry['id_column']
    cat_col = entry['category_column']
    sal_col = entry['sales_column']

    d = pd.read_csv(os.path.join(INPUT_DIR, fname))
    d = d.rename(columns={id_col: 'row_id', cat_col: 'sub_category', sal_col: 'sales'})
    d = d[['row_id', 'sub_category', 'sales']].copy()

    # Parse dirty sales strings: strip $, USD, commas, whitespace -> numeric
    d['sales'] = (
        d['sales'].astype(str)
        .str.strip()
        .str.replace('$', '', regex=False)
        .str.replace('USD', '', regex=False)
        .str.replace(',', '', regex=False)
        .str.strip()
    )
    d['sales'] = pd.to_numeric(d['sales'], errors='coerce')

    # Count invalid (NaN or negative) before dropping
    invalid = int(d['sales'].isna().sum()) + int((d['sales'].dropna() <= 0).sum())
    total_skipped += invalid

    d = d.dropna(subset=['sales'])
    d = d[d['sales'] > 0]

    # Normalize sub_category: strip whitespace + title case
    d['sub_category'] = d['sub_category'].str.strip().str.title()

    d['region'] = region
    frames.append(d)

combined = pd.concat(frames, ignore_index=True)

# Deduplicate by row_id, keep first occurrence
before   = len(combined)
combined = combined.drop_duplicates(subset=['row_id'], keep='first')
after    = len(combined)

region_totals = {
    r: round(float(combined[combined['region'] == r]['sales'].sum()), 2)
    for r in ['west', 'east', 'central', 'south']
}
total_sales = round(float(combined['sales'].sum()), 2)
top3 = list(
    combined.groupby('sub_category')['sales']
    .sum()
    .sort_values(ascending=False)
    .head(3)
    .index
)

result = {
    "total_sales": total_sales,
    "region_totals": region_totals,
    "top_3_sub_categories": top3,
    "duplicate_rows_removed": before - after,
    "records_skipped_missing_sales": total_skipped,
}

with open(OUTPUT, 'w') as f:
    json.dump(result, f, indent=2)

print("Oracle solution written to /task/report.json")
print(json.dumps(result, indent=2))
EOF
