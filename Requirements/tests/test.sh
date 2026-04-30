#!/bin/bash
echo "Running verifier..."
python3 /task/tests/verify.py
echo "Reward: $(cat /task/reward)"
