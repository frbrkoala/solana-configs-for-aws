#!/bin/bash

echo "Running cfn-nag"
cfn_nag_scan --input-path ../cloudformation/*.yaml

echo "Running cfn-lint"
cfn-lint ../cloudformation/*.yaml

echo "Running Semgrep"
cd ../
semgrep scan --config auto