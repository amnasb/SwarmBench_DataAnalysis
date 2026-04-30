import json
import sys

ORACLE = {
    "total_sales": 2286590.24,
    "region_totals": {
        "west": 722066.44,
        "east": 674463.32,
        "central": 498656.98,
        "south": 391403.5
    },
    "top_3_sub_categories": ["Phones", "Chairs", "Storage"],
    "duplicate_rows_removed": 12,
    "records_skipped_missing_sales": 53
}

def score(report):
    points = 0

    if abs(report.get("total_sales", 0) - ORACLE["total_sales"]) < 0.01:
        points += 1

    region_ok = all(
        abs(report.get("region_totals", {}).get(r, 0) - v) < 0.01
        for r, v in ORACLE["region_totals"].items()
    )
    if region_ok:
        points += 1

    if report.get("top_3_sub_categories") == ORACLE["top_3_sub_categories"]:
        points += 1

    if report.get("duplicate_rows_removed") == ORACLE["duplicate_rows_removed"]:
        points += 1

    if report.get("records_skipped_missing_sales") == ORACLE["records_skipped_missing_sales"]:
        points += 1

    return round(points / 5, 2)

try:
    with open('/task/report.json', 'r') as f:
        report = json.load(f)
    reward = score(report)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    reward = 0.0

with open('/task/reward', 'w') as f:
    f.write(str(reward))

print(f"Score: {reward}")
