#!/usr/bin/env bash

OUTPUT_DIR="output"
REVAPI_ANALYSIS_FILE="$OUTPUT_DIR/revapi.txt"
GROUND_TRUTH_FILE="$OUTPUT_DIR/ground_truth.csv"

../../tools/revapi/revapi.sh --extensions=org.revapi:revapi-java:0.28.1,org.revapi:revapi-reporter-text:0.15.0 --old=output/build/v1.jar --new=output/build/v2.jar -Drevapi.reporter.text.minSeverity=POTENTIALLY_BREAKING > "$REVAPI_ANALYSIS_FILE"

echo "change,source,binary" > $GROUND_TRUTH_FILE

#grep -E "^(\*|-){3}!\s" "$REVAPI_ANALYSIS_FILE" | while read -r line ; do
#    [[ "$line" =~ revapi\.test(\.[a-zA-Z0-9]+)+ ]]
#    change=${BASH_REMATCH[0]}
#
#    echo "$change,0,0" >> $GROUND_TRUTH_FILE
#done
