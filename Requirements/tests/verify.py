import json
import sys

ORACLE = {
    "total_sales": 1856319.28,
    "region_totals": {
        "west": 732757.98,
        "east": 575807.4,
        "central": 319601.36,
        "south": 228152.53
    },
    "top_3_sub_categories": ["Chairs", "Phones", "Binders"],
    "duplicate_rows_removed": 9937,
    "records_skipped_missing_sales": 1152
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
