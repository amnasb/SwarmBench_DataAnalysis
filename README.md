# SwarmBench — Regional Sales Reconciliation

A SwarmBench benchmark task designed to evaluate whether a multi-agent AI system can outperform a single AI agent on a coordination-heavy data reconciliation workflow.

The task intentionally creates:

* multiple independent artifacts
* inconsistent schemas
* cross-file deduplication pressure
* noisy and invalid data
* synthesis-heavy aggregation requirements

The benchmark is structured so that:

* a **single agent** is likely to struggle with bookkeeping, consistency, and reconciliation
* a **multi-agent system** can succeed through decomposition, parallel processing, and reducer synthesis

---

# Task Overview

The agent is given multiple regional sales CSV files located in:

```text id="3z0s8f"
environment/input_artifacts/
```

Each file:

* uses different column names
* contains duplicates
* contains invalid sales values
* contains formatting inconsistencies

The agent must:

1. normalize schemas
2. clean records
3. remove duplicates globally
4. compute aggregate metrics
5. generate a final reconciliation report

Final output:

```text id="h5v6aq"
/task/report.json
```

---

# Repository Structure

```text id="1k9u3x"
Requirements/
├── instruction.md
├── task.toml
├── decomposition.yaml
│
├── environment/
│   ├── Dockerfile
│   └── input_artifacts/
│       ├── sales_west.csv
│       ├── sales_east.csv
│       ├── sales_central.csv
│       └── sales_south.csv
│
├── solution/
│   └── solve.sh
│
└── tests/
    ├── verify.py
    ├── test.sh
    └── judge.py
```

---

# Dataset Characteristics

The benchmark dataset is generated from the Kaggle Superstore dataset and intentionally modified to create coordination pressure.

Injected issues include:

| Issue                      | Description                                       |
| -------------------------- | ------------------------------------------------- |
| Schema inconsistencies     | Different column names across files               |
| Cross-file duplicates      | Duplicate `row_id` values across regions          |
| Invalid sales values       | Null, empty, negative, and malformed sales values |
| Whitespace inconsistencies | Leading/trailing whitespace in categories         |
| Noisy columns              | Irrelevant metadata columns added                 |
| Dirty numeric formats      | Currency strings and inconsistent formatting      |
| Shuffled ordering          | Randomized row and column order                   |

These issues increase:

* reconciliation complexity
* bookkeeping burden
* context pressure
* aggregation difficulty

---

# Multi-Agent Decomposition

The benchmark follows a map-reduce style workflow.

```text id="x2r1eg"
map_west    ─┐
map_east    ─┤
map_central ─┤──► reducer ──► /task/report.json
map_south   ─┘
```

Each map agent:

* owns one regional CSV
* normalizes schemas
* cleans invalid records
* writes intermediate outputs

The reducer:

* merges all intermediate outputs
* removes duplicates globally
* computes aggregate metrics
* generates the final report

Decomposition details are defined in:

```text id="b2f5zx"
decomposition.yaml
```

---

# Running the Oracle

## Prerequisites

* Docker installed
* Docker daemon running

---

## Build Docker Image

From the `Requirements/` directory:

```bash id="zkwn4u"
docker build -f environment/Dockerfile -t swarm-sales-task .
```

---

## Run Oracle + Verifier

```bash id="a49q0m"
docker run --rm swarm-sales-task bash -c "bash /task/solution/solve.sh && bash /task/tests/test.sh"
```

---

# Expected Result

Successful execution should produce:

```text id="cx0hr7"
Score: 1.0
Reward: 1.0
```

---

# Expected Oracle Output

```json id="r7cqje"
{
  "total_sales": 2286590.24,
  "region_totals": {
    "west": 722066.44,
    "east": 674463.32,
    "central": 498656.98,
    "south": 391403.5
  },
  "top_3_sub_categories": [
    "Phones",
    "Chairs",
    "Storage"
  ],
  "duplicate_rows_removed": 12,
  "records_skipped_missing_sales": 53
}
```

---

# Verification

The verifier is implemented in:

```text id="7qef38"
tests/verify.py
```

Scoring is deterministic and field-based.

The verifier checks:

* total sales
* regional totals
* top sub-categories
* duplicate count
* skipped record count

Float comparisons use a tolerance of `0.01`.

The final reward is written to:

```text id="06ozoc"
/task/reward
```

which Harbor reads during evaluation.

---

# Task Metadata

| Field                | Value                              |
| -------------------- | ---------------------------------- |
| Domain               | data-analysis                      |
| Difficulty           | hard                               |
| Coordination Pattern | map_reduce                         |
| Verifier Type        | executable                         |
| Runtime Environment  | Docker                             |
| Primary Failure Mode | cross-file reconciliation overload |
