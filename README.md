# SwarmBench Assessment — Regional Sales Reconciliation

## Overview

This project is a SwarmBench benchmark task designed to evaluate whether a **multi-agent AI system** can outperform a **single AI agent** on a coordination-heavy data reconciliation workflow.

The benchmark intentionally creates:

* multiple independent artifacts
* schema inconsistencies
* cross-file reconciliation pressure
* deduplication requirements
* synthesis-heavy aggregation

The task is structured so that:

* a **single agent** is likely to struggle with bookkeeping, consistency, and global reconciliation
* a **multi-agent system** can succeed through decomposition, parallel processing, and reducer synthesis

---

# Assessment Goal

The objective is **not** to trick the single agent.

The objective is to create a task where:

* one agent faces structural pressure from context and coordination complexity
* multiple agents can divide work cleanly and synthesize results reliably

This assessment evaluates whether the task design is **structurally likely** to produce a meaningful performance gap between:

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

```text
decomposition.yaml
```

---

# Benchmark Task

## Regional Sales Reconciliation

The task uses multiple regional sales CSV exports containing:

* inconsistent schemas
* duplicate records
* invalid sales values
* whitespace inconsistencies
* noisy irrelevant columns
* dirty numeric formats

The agent must:

* normalize schemas
* clean records
* reconcile duplicates globally
* compute aggregate metrics
* generate a final JSON report

---

# Multi-Agent Design Pattern

The benchmark follows a classic:

```text
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

# Current Task Structure

## Dataset Shape

The benchmark generates:

* 16 regional CSV shards
* randomized schemas
* cross-file duplicates
* invalid sales values
* casing inconsistencies
* whitespace inconsistencies
* shuffled rows/columns
* noisy metadata columns

This substantially increases reconciliation complexity while remaining fully solvable through decomposition.

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
* Tight execution timeout
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

# Oracle Verification Workflow

## Build Docker Image

```bash
docker build -f environment/Dockerfile -t regional-sales .
```

## Start Container

```bash
docker run -it regional-sales bash
```

## Run Oracle

```bash
bash solution/solve.sh
```

## Run Verifier

```bash
bash tests/test.sh
```

Expected output:

```text
Score: 1.0
```

---

# Submission Checklist

## Data & Setup

* [x] Download Superstore dataset
* [x] Generate benchmark CSV shards
* [x] Create inconsistent schemas
* [x] Inject duplicates and invalid values

## Benchmark Files

* [x] instruction.md
* [x] task.toml
* [x] decomposition.yaml
* [x] environment/Dockerfile
* [x] solution/solve.sh
* [x] tests/verify.py
* [x] tests/test.sh


* [x] solution/oracle.json
* [x]  tests/oracle.json
* [x] tests/judge.py

## Validation

* [x]  Build Docker image
* [x]  Run oracle
* [x]  Run verifier
* [x]  Confirm oracle score = 1.0

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
