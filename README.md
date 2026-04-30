# SwarmBench — Regional Sales Reconciliation

A SwarmBench benchmark task designed to evaluate whether a multi-agent AI system can outperform a single AI agent on a coordination-heavy data reconciliation workflow.

The benchmark intentionally creates:

* multiple independent artifacts
* inconsistent schemas
* cross-file deduplication pressure
* noisy and invalid data
* synthesis-heavy aggregation requirements

The task is structured so that:

* a **single agent** is likely to struggle with bookkeeping, consistency, and reconciliation
* a **multi-agent system** can succeed through decomposition, parallel processing, and reducer synthesis

---

# Goal

The objective is **not** to trick the single agent.

The objective is to create a task where:

* one agent faces structural pressure from context and coordination complexity
* multiple agents can divide work cleanly and synthesize results reliably

This assessment evaluates whether the task design is structurally likely to produce a meaningful performance gap between:

* `swarm-kimi-single`
* `swarm-kimi-multi`

---

# Important Clarification

You are **NOT required** to:

* run single-agent trials
* run multi-agent trials
* prove a 40-point benchmark gap
* submit execution logs

You **ARE required** to:

* build a valid benchmark package
* run the oracle solution once
* confirm the oracle scores `1.0`

The oracle verification proves:

* Docker setup works
* solution wiring works
* verifier logic works
* task package is valid

---

# What SwarmBench Evaluates

SwarmBench measures whether multi-agent systems outperform a single agent on tasks that are:

* too broad
* too coordination-heavy
* too artifact-heavy
* too synthesis-heavy

for a single agent to solve reliably within the same constraints.

---

# Task Overview

The agent is given multiple regional sales CSV files located in:

```text id="n2xg18"
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

```text id="u7qjcb"
/task/report.json
```

---

# Benchmark Structure

Each benchmark task is a self-contained package.

## Required Files

| File                           | Purpose                                   |
| ------------------------------ | ----------------------------------------- |
| `instruction.md`               | Task prompt shown to the agent            |
| `task.toml`                    | Task metadata and execution configuration |
| `decomposition.yaml`           | Multi-agent decomposition plan            |
| `environment/Dockerfile`       | Runtime environment                       |
| `environment/input_artifacts/` | Dataset artifacts                         |
| `solution/solve.sh`            | Oracle solution                           |
| `tests/test.sh`                | Verifier entrypoint                       |
| `tests/verify.py`              | Deterministic scoring logic               |
| `tests/oracle.json`            | Expected oracle output                    |
| `tests/judge.py`               | Placeholder LLM judge                     |

---

# Repository Structure

```text id="h6zpkm"
Requirements/
├── instruction.md
├── task.toml
├── decomposition.yaml
│
├── environment/
│   ├── Dockerfile
│   └── input_artifacts/
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

# Harbor Evaluation Flow

Harbor is the execution harness used by SwarmBench.

At runtime Harbor:

1. Reads the task directory
2. Builds the Docker image
3. Starts the task container
4. Provides `instruction.md` to the agent
5. Lets the agent operate inside the container
6. Runs `tests/test.sh`
7. Reads the reward produced by the verifier
8. Records logs and trajectories

You do not need to manually orchestrate containers during evaluation.

---

# Important Design Rule

## `instruction.md` MUST remain role-neutral

It is shared by:

* single-agent runs
* multi-agent runs

Do NOT include:

* sub-agent instructions
* shard assignments
* orchestration logic
* reducer instructions
* map-reduce details

Those belong ONLY inside:

```text id="3t9x4x"
decomposition.yaml
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

# Current Task Structure

## Dataset Shape

The benchmark generates:

* 16 regional CSV shards
* randomized schemas
* cross-file duplicates
* invalid sales values
* casing inconsistencies
* whitespace inconsistencies
* shuffled rows and columns
* noisy metadata columns

This substantially increases reconciliation complexity while remaining fully solvable through decomposition.

---

# Multi-Agent Design Pattern

The benchmark follows a classic:

```text id="pm49vf"
many artifacts
    ↓
independent shard processing
    ↓
reducer synthesis
    ↓
verified final output
```

This creates a natural advantage for multi-agent systems.

---

# Multi-Agent Decomposition

The benchmark follows a map-reduce workflow.

```text id="ln3r1x"
map_west    ─┐
map_east    ─┤
map_central ─┤──► reducer ──► /task/report.json
map_south   ─┘
```

Each map agent:

* owns one regional CSV shard
* normalizes schemas
* cleans invalid records
* writes intermediate outputs

The reducer:

* merges all intermediate outputs
* removes duplicates globally
* computes aggregate metrics
* generates the final report

Decomposition details are defined in:

```text id="67h3bp"
decomposition.yaml
```

---

# Intended Single-Agent Failure Modes

The benchmark is designed to pressure single agents through:

* context overload
* attention degradation
* incomplete artifact coverage
* missed edge cases
* inconsistent reconciliation
* bookkeeping errors
* timeout pressure

---

# Intended Multi-Agent Success Modes

The benchmark rewards:

* independent shard ownership
* parallel extraction
* isolated schema normalization
* reducer-based synthesis
* explicit intermediate outputs
* coordinated reconciliation

---

# File Responsibilities

| File                     | Responsibility                |
| ------------------------ | ----------------------------- |
| `instruction.md`         | Neutral task prompt           |
| `task.toml`              | Harbor execution metadata     |
| `decomposition.yaml`     | Map-reduce decomposition plan |
| `environment/Dockerfile` | Runtime container             |
| `solution/solve.sh`      | Oracle implementation         |
| `tests/verify.py`        | Deterministic verifier        |
| `tests/test.sh`          | Verifier runner               |
| `tests/oracle.json`      | Expected oracle output        |

---

# Design Decisions

## instruction.md

* Role-neutral
* No decomposition hints
* Requires global deduplication tracking
* Forces schema inspection across artifacts

## task.toml

* `coordination_pattern = "map_reduce"`
* `verifier_type = "executable"`
* Structured for reducer synthesis

## decomposition.yaml

* One map agent per shard group
* Explicit schema mappings
* Reducer waits on all map agents
* Intermediate outputs written to `/task/work/*.json`

## Dockerfile

* Minimal environment
* Pandas-based runtime
* Input artifacts baked into image
* `/task/work` pre-created

## solve.sh

* Fully deterministic oracle
* Fixed reconciliation order
* Produces `/task/report.json`

## verify.py

* Deterministic scoring
* Field-by-field validation
* Floating-point tolerance handling
* Writes reward to `/task/reward`

---

# Running the Oracle

## Prerequisites

* Docker installed
* Docker daemon running

---

## Build Docker Image

From the `Requirements/` directory:

```bash id="f8u3m9"
docker build -f environment/Dockerfile -t swarm-sales-task .
```

---

## Run Oracle + Verifier

```bash id="b1qf6x"
docker run --rm swarm-sales-task bash -c "bash /task/solution/solve.sh && bash /task/tests/test.sh"
```

---

# Expected Result

Successful execution should produce:

```text id="b6m8xd"
Score: 1.0
Reward: 1.0
```

---

# Expected Oracle Output

```json id="sj5m0z"
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

```text id="5qyl8u"
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

```text id="v9v7zi"
/task/reward
```

which Harbor reads during evaluation.

---



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

---

# Final Goal

The final benchmark should demonstrate a realistic coordination advantage where:

* single-agent systems struggle with scale and reconciliation
* multi-agent systems succeed through decomposition and synthesis

while remaining:

* deterministic
* verifiable
* reproducible
* structurally fair

  ┌────────────────────────────────────────────────────┬────────┐
  │                       Check                        │ Status │
  ├────────────────────────────────────────────────────┼────────┤
  │ Oracle score                                       │ 1.0 ✓  │
  ├────────────────────────────────────────────────────┼────────┤
  │ instruction.md is role-neutral                     │ ✓      │
  ├────────────────────────────────────────────────────┼────────┤
  │ decomposition.yaml has clear sub-agent assignments │ ✓      │
  ├────────────────────────────────────────────────────┼────────┤
  │ No execution_logs/                                 │ ✓      │
  ├────────────────────────────────────────────────────┼────────┤
  │ All required files present and non-empty           │ ✓      │
  └────────────────────────────────────────────────────┴────────┘