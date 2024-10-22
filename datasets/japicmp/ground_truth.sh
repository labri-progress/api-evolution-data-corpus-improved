#!/usr/bin/env bash

OUTPUT_DIR="output"
JAPICMP_ANALYSIS_FILE="$OUTPUT_DIR/japicmp.txt"
GROUND_TRUTH_FILE="$OUTPUT_DIR/ground_truth.csv"

java -jar ../../tools/japicmp/japicmp-0.23.0-jar-with-dependencies.jar -o output/build/v1.jar -n output/build/v2.jar -b -m --ignore-missing-classes > "$JAPICMP_ANALYSIS_FILE"

grep  -v "===  UNCHANGED" "$JAPICMP_ANALYSIS_FILE" > japicmp.txt.tmp
mv japicmp.txt.tmp "$JAPICMP_ANALYSIS_FILE"

echo "change,source,binary" > $GROUND_TRUTH_FILE

grep -E "^(\*|-){3}!\s" "$JAPICMP_ANALYSIS_FILE" | while read -r line ; do
    [[ "$line" =~ japicmp\.test(\.[a-zA-Z0-9]+)+ ]]
    change=${BASH_REMATCH[0]}

    echo "$change,0,0" >> $GROUND_TRUTH_FILE
done
