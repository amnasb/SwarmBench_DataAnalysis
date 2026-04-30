# Task: Regional Sales Reconciliation

You are given 16 regional sales CSV files located in `/task/input_artifacts/`:

```
sales_west_q1.csv    sales_east_q1.csv    sales_central_q1.csv    sales_south_q1.csv
sales_west_q2.csv    sales_east_q2.csv    sales_central_q2.csv    sales_south_q2.csv
sales_west_q3.csv    sales_east_q3.csv    sales_central_q3.csv    sales_south_q3.csv
sales_west_q4.csv    sales_east_q4.csv    sales_central_q4.csv    sales_south_q4.csv
```

Each file represents one quarter of sales for one region. **Every file uses different column names for the same logical fields.** A schema reference is available at `/task/input_artifacts/schema_reference.json` — it maps each filename to its actual column names for `row_id`, `sub_category`, and `sales`.

Sales values are stored as dirty strings and may include formatting such as `" $1,234.56 "`, `"USD 123.45"`, or `"1,234.56"`. You must parse these into clean numeric values.

Sub-category values may have inconsistent casing (all-caps, all-lowercase) and leading/trailing whitespace. Normalize them before grouping.

## Your Goal

Analyze all 16 files and produce a single reconciliation report at `/task/report.json`.

## Data Cleaning Rules

Apply these rules before computing any totals:

1. **Normalize** each file's columns to: `row_id`, `sub_category`, `sales` — use `schema_reference.json` to identify which column is which
2. **Parse sales** — strip currency symbols (`$`, `USD`), commas, and whitespace, then convert to numeric; treat anything non-numeric as invalid
3. **Remove invalid sales** — skip any row where `sales` is null, empty, non-numeric, or negative (count all skipped rows)
4. **Remove duplicates** — if the same `row_id` appears more than once across all files, keep only the first occurrence (count all removed duplicates)
5. **Normalize sub_category** — strip whitespace and normalize casing before grouping

## Output Format

Write `/task/report.json` with exactly this structure:

```json
{
  "total_sales": <float rounded to 2 decimal places>,
  "region_totals": {
    "west": <float>,
    "east": <float>,
    "central": <float>,
    "south": <float>
  },
  "top_3_sub_categories": [<string>, <string>, <string>],
  "duplicate_rows_removed": <integer>,
  "records_skipped_missing_sales": <integer>
}
```

- `total_sales`: sum of all valid sales across all regions after cleaning
- `region_totals`: per-region sales sum after cleaning (sum all quarters per region)
- `top_3_sub_categories`: top 3 sub-categories by total sales, descending order
- `duplicate_rows_removed`: total count of duplicate `row_id` entries removed across all files
- `records_skipped_missing_sales`: total count of rows removed due to null, non-numeric, or negative sales
