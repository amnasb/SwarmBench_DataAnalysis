This is my README.md file

This assessment checks whether you can design a benchmark task where a single agent is likely to fail, but a multi-agent system can succeed through decomposition, parallel work, and synthesis.
You are not expected to run single-agent or multi-agent trials, prove a 40-point gap, or submit execution logs during this assessment. Production tasks require real runs and above ask. This assessment evaluates whether your task design is structurally likely to create that gap.
You are expected to run the oracle once. The oracle must score 1.0. This proves your Dockerfile, solution/solve.sh, tests/test.sh, and verifier are wired correctly.


SwarmBench evaluates whether multi-agent AI systems outperform a single AI agent on tasks that are too broad, too long, or too coordination-heavy for one agent to solve reliably.
Each task is a self-contained benchmark package. It includes:
instruction.md - the task prompt the agent receives
task.toml - metadata, domain, timeout, verifier type, and coordination pattern
decomposition.yaml - how the multi-agent system should split the work. It is only shown to the multi-agent system.
environment/Dockerfile - the runtime environment for the agent
tests/ - verifier or llm judge logic
solution/solve.sh - the oracle solution path
The main comparison is:
swarm-kimi-single - one agent, no sub-agent spawning
swarm-kimi-multi - an orchestrator agent that reads decomposition.yaml and spawns sub-agents
A strong benchmark has a meaningful gap:
oracle solution scores 1.0
multi-agent scores near 1.0
single-agent scores much lower, ideally 0.60 or below
target production gap is at least 40 percentage points

Harbor is the evaluation harness used by SwarmBench.
At runtime, Harbor:
Reads the task directory.
Builds the Docker image from environment/Dockerfile.
Starts the task container.
Gives the agent the contents of instruction.md.
Lets the agent work inside the container.
Runs tests/test.sh.
Reads the reward produced by the verifier.
Saves execution logs and trajectories.
You do not need to manage containers manually. Your responsibility is to design the files Harbor needs and run the Oracle once to confirm the package is valid and your solution is valid for your written test case.

Files Are Used During Execution
The agent receives the task through instruction.md.
The environment is built from anything inside environment/ directory :
environment/Dockerfile
environment/input_artifacts/        optional data files
The verifier is run from:
tests/test.sh
tests/verify.py                     for executable verifier tasks
tests/judge.py                      for llm-judge tasks
tests/oracle.json                   recommended for llm-judge tasks
The oracle solution lives in:
solution/solve.sh
solution/oracle.json                for llm-judge tasks when useful
The multi-agent orchestrator additionally reads:
decomposition.yaml
Important rule:
instruction.md must be role-neutral. It is shared by single-agent and multi-agent runs. Do not put sub-agent instructions, map-agent instructions, shard assignments, or synthesizer instructions in instruction.md. Those details belong only in decomposition.yaml.
For this assessment, do not include execution_logs/. You are expected to run only the oracle and report the oracle score.


Task Shape: many artifacts -> independent subproblem solving -> reducer synthesis -> verified final output

The goal is not to trick the single agent. The goal is to create real structural pressure.

Good single-agent failure modes:
context overload
attention degradation
incomplete artifact coverage
missed secondary requirements
timeout under the same time budget
failure to reconcile outputs consistently

Good multi-agent success modes:
independent shard ownership
parallel extraction or inspection
clear sub-agent outputs
reducer verifies completeness
final synthesis reconciles all outputs
Strong task patterns:
fixing many independent issues across a large codebase
extracting structured evidence from many papers or reports
reconciling multiple inconsistent datasets
planning under many constraints across schedules, inventories, or incidents
solving many independent reasoning subproblems before a final synthesis step


Data Analysis Role Based Assesment:
Choose multiple CSVs, JSON files, spreadsheets, logs, or database exports.
Good task shape:
inconsistent schemas
missing values
duplicate records
per-shard calculations
final reconciliation across all shards
Single-agent likely fails by processing only some files or producing inconsistent aggregation.


full to-do list:
                                                                                                          
    ---                                                                                                   
    SwarmBench Assessment — To-Do List                                                                    
                                                                                                          
    Data & Setup  - DONE

    - Read and understand the README / assessment requirements
    - Confirm Docker is installed
    - Confirm file structure is complete
    - Download Superstore dataset from Kaggle
    - Run data_prep.ipynb to generate 4 regional CSV files
    - Verify oracle expected output (oracle_expected.json)

    Task Package Files

    - Write instruction.md
    - Write task.toml
    - Write decomposition.yaml
    - Write environment/Dockerfile
    - Write solution/solve.sh
    - Write solution/oracle.json
    - Write tests/verify.py
    - Write tests/test.sh
    - Write tests/oracle.json
    - Write tests/judge.py (minimal placeholder)

    Oracle Verification

    - Build Docker image
    - Run oracle (solution/solve.sh) inside container
    - Run verifier (tests/test.sh) inside container
    - Confirm oracle score = 1.0

    Final Submission

    - Review instruction.md is role-neutral
    - Review decomposition.yaml has clear sub-agent assignments
    - Remove any execution_logs/ if present
    - Final check — all files present and non-empty

    ---
    11 files to write, then one oracle run to confirm. That's it.


---
    INSTRUCTION.MD SPECS:
    - Role-neutral — no mention of sub-agents, shards, or splitting work
    - Column name differences are hinted at but not spelled out — agent must inspect each file
    - "First occurrence" deduplication rule requires tracking IDs across all files simultaneously — hard
    for a single agent to do reliably
    - Does not prescribe how to process files — single agent must manage all 4 in context at once

    TASK.TOML SPECS:
    - timeout = 600 — 10 minutes, enough for multi-agent parallel work but tight for a single agent
    processing all 4 files carefully and sequentially
    - verifier_type = "executable" — scoring is done by verify.py, not an LLM judge — output must be exact
    - coordination_pattern = "map_reduce" — signals to Harbor that this task is designed for parallel
    shard processing followed by a reduction step

    DECOMPOSITION.YAML SPECS:
    - Only shown to the multi-agent system, never to the single agent
    - Each map agent owns exactly one file — clear shard ownership, no overlap
    - Column mapping is spelled out explicitly per agent — removes ambiguity for sub-agents
    - depends_on on the reducer tells the orchestrator to wait for all 4 map agents to finish before
    running the reducer
    - Intermediate results go to /task/work/*.json — reducer reads from there, not directly from CSVs

    DOCKERFILE SPECS:
    - WORKDIR /task — establishes the base path used by all scripts and agents
    - COPY input_artifacts/ bakes the data into the image at build time — agent doesn't need to fetch
    anything
    - mkdir -p /task/work — pre-creates the folder map agents write intermediate results to
    - Only dependency is pandas — kept minimal on purpose

    SOLVE.SH SPECS:
    - Fully self-contained Python heredoc — no external script files needed inside the container
    - Processing order is fixed (west → east → central → south) — determines which occurrence is "first"
    during deduplication
    - Identical logic to data_prep.py oracle computation — guaranteed to produce the same numbers as
    oracle_expected.json
    - Writes to /task/report.json — same path the verifier reads from

    VERIFY.PY SPECS:
    - Oracle values are hardcoded — no dependency on external oracle.json file at runtime
    - Scoring is field-by-field — each of 5 fields worth 0.2 points, total = 1.0
    - Uses 0.01 tolerance for float comparisons to avoid floating point precision issues
    - Writes reward to /task/reward file — this is what Harbor reads to record the score

    TEST.SH SPECS:
    - Calls verify.py which handles all scoring logic
    - Prints the reward to stdout for Harbor to capture
    - Kept minimal — all logic lives in verify.py


full to-do list:
                                                                                                          
    ---                                                                                                   
    SwarmBench Assessment — To-Do List                                                                    
                                                                                                          
    Data & Setup  - DONE

    - Read and understand the README / assessment requirements
    - Confirm Docker is installed
    - Confirm file structure is complete
    - Download Superstore dataset from Kaggle
    - Run data_prep.ipynb to generate 4 regional CSV files
    - Verify oracle expected output (oracle_expected.json)

    Task Package Files

    - Write instruction.md  - DONE
    - Write task.toml       - DONE
    - Write decomposition.yaml   - DONE
    - Write environment/Dockerfile
    - Write solution/solve.sh  - Done
    - Write solution/oracle.json  
    - Write tests/verify.py     - DONE
    - Write tests/test.sh       - DONE
    - Write tests/oracle.json
    - Write tests/judge.py (minimal placeholder)

    Oracle Verification

    - Build Docker image                
    - Run oracle (solution/solve.sh) inside container
    - Run verifier (tests/test.sh) inside container
    - Confirm oracle score = 1.0

    Final Submission

    - Review instruction.md is role-neutral
    - Review decomposition.yaml has clear sub-agent assignments
    - Remove any execution_logs/ if present
    - Final check — all files present and non-empty

    ---
    11 files to write, then one oracle run to confirm. That's it.
	
	  File                    │                        Purpose                         │
  ├───────────────────────────────────────────┼────────────────────────────────────────────────────────┤
  │ Requirements/environment/Dockerfile       │ Container with pandas + 4 regional CSVs                │
  ├───────────────────────────────────────────┼────────────────────────────────────────────────────────┤
  │ Requirements/environment/input_artifacts/ │ 4 region CSVs with schema differences, duplicates,     │
  │                                           │ nulls, negatives, whitespace                           │
  ├───────────────────────────────────────────┼────────────────────────────────────────────────────────┤
  │ Requirements/instruction.md               │ Agent prompt                                           │
  ├───────────────────────────────────────────┼────────────────────────────────────────────────────────┤
  │ Requirements/task.toml                    │ Task metadata                                          │
  ├───────────────────────────────────────────┼────────────────────────────────────────────────────────┤
  │ Requirements/decomposition.yaml           │ Map-reduce multi-agent layout                          │
  ├───────────────────────────────────────────┼────────────────────────────────────────────────────────┤
  │ Requirements/solution/solve.sh            │ Oracle solution                                        │
  ├───────────────────────────────────────────┼────────────────────────────────────────────────────────┤
  │ Requirements/tests/verify.py + test.sh    │ Deterministic verifier, confirmed Score: 1.0    