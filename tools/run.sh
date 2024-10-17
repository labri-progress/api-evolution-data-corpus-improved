#!/usr/bin/env bash

REPORTS_DIR="reports"

EXECUTION_TIMES_FILENAME="execution_times.csv"

# Function to record execution time
record_execution_time() {
    local tool="$1"
    start=$(date +%s.%3N)
    
    # Run the jar
    eval "$2"
    
    local duration
    duration=$(echo "$(date +%s.%3N) - $start" | bc)

    # Append execution time to CSV file (a little adjustment for roseau's bcs report to be in roseau's directory)
    echo "$tool, $duration" >> "$execution_times_path"
}

dataset_dir="$1"
results_dir="$2"

execution_times_path="$results_dir/$EXECUTION_TIMES_FILENAME"
reports_path="$results_dir/$REPORTS_DIR"

[ -d "$reports_path" ] || mkdir -p "$reports_path"

# Create or clear the CSV file
echo "Task, Execution Time (s)" > "$execution_times_path"

echo "********* Revapi *********"
record_execution_time "Revapi" "tools/revapi/revapi.sh --extensions=org.revapi:revapi-java:0.28.1,org.revapi:revapi-reporter-text:0.15.0 --old=$dataset_dir/output/build/v1.jar --new=$dataset_dir/output/build/v2.jar -Drevapi.reporter.text.minSeverity=POTENTIALLY_BREAKING > $reports_path/revapi.txt"

echo "********* japicmp *********"
record_execution_time "japicmp" "java -jar tools/japicmp/japicmp-0.23.0-jar-with-dependencies.jar -o $dataset_dir/output/build/v1.jar -n $dataset_dir/output/build/v2.jar -b -m > $reports_path/japicmp.txt"

echo "********* Roseau *********"
record_execution_time "Roseau" "java -jar tools/roseau/roseau-0.0.4-SNAPSHOT-jar-with-dependencies.jar --diff --v1 $dataset_dir/v1 --v2 $dataset_dir/v2 --report=$results_dir/roseau.csv  > $reports_path/roseau.txt"
rm "$results_dir/roseau.csv"

grep  -v '===  UNCHANGED' "$reports_path"/japicmp.txt > japicmp.txt.tmp
mv japicmp.txt.tmp "$reports_path"/japicmp.txt

grep  -v '===  UNCHANGED' "$reports_path"/roseau.txt > roseau.txt.tmp
mv roseau.txt.tmp "$reports_path"/roseau.txt
