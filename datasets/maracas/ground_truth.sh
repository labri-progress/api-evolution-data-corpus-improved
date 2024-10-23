#!/usr/bin/env bash

OUTPUT_DIR="output"
GROUND_TRUTH_FILE="$OUTPUT_DIR/ground_truth.csv"

mvn clean > /dev/null 2>&1
mvn package -P new-version > "$OUTPUT_DIR/compile.out"
