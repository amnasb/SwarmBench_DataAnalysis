  # Task: Regional Sales Reconciliation

  You are given four regional sales CSV files located in `/task/input_artifacts/`:

  - `sales_west.csv`
  - `sales_east.csv`
  - `sales_central.csv`
  - `sales_south.csv`

  Each file represents sales transactions from a different region.
  **The files use different column names for the same logical fields.**

  ## Your Goal

  Analyze all four files and produce a reconciliation report at `/task/report.json`.

  ## Data Cleaning Rules

  Apply these rules before computing any totals:

  1. **Normalize** each file's columns to: `row_id`, `sub_category`, `sales`
  2. **Remove duplicates** — if the same `row_id` appears more than once across
     all files, keep only the first occurrence
  3. **Remove invalid sales** — skip any row where `sales` is null, empty, or negative
  4. **Strip whitespace** from `sub_category` values before grouping

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

  - total_sales: sum of all valid sales across all regions after cleaning
  - region_totals: per-region sales sum after cleaning
  - top_3_sub_categories: top 3 sub-categories by total sales, descending order
  - duplicate_rows_removed: total count of duplicate row_id entries removed
  - records_skipped_missing_sales: total count of rows removed due to null or negative sales