#!/bin/bash
python3 - << 'EOF'
import pandas as pd
import json

INPUT_DIR = '/task/input_artifacts'
OUTPUT    = '/task/report.json'

SCHEMA_MAP = [
    ('sales_west.csv',    'row_id',         'sub_category',    'sales',        'west'),
    ('sales_east.csv',    'transaction_id', 'product_category','revenue',      'east'),
    ('sales_central.csv', 'txn_id',         'category',        'sales_amount', 'central'),
    ('sales_south.csv',   'id',             'item_category',   'amount',       'south'),
]

frames = []
total_skipped = 0

for fname, id_col, cat_col, sales_col, region in SCHEMA_MAP:
    d = pd.read_csv(f'{INPUT_DIR}/{fname}')
    d = d.rename(columns={id_col: 'row_id', cat_col: 'sub_category', sales_col: 'sales'})
    d = d[['row_id', 'sub_category', 'sales']].copy()

    # Count and remove null and negative sales
    invalid = int(d['sales'].isna().sum()) + int((d['sales'].dropna() < 0).sum())
    total_skipped += invalid
    d = d.dropna(subset=['sales'])
    d = d[d['sales'] > 0]

    # Strip whitespace from sub_category
    d['sub_category'] = d['sub_category'].str.strip()
    d['region'] = region
    frames.append(d)

combined = pd.concat(frames, ignore_index=True)

# Deduplicate by row_id, keep first occurrence
before   = len(combined)
combined = combined.drop_duplicates(subset=['row_id'], keep='first')
after    = len(combined)

# Compute output fields
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
