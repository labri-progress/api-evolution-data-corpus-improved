#!/bin/bash

DATASETS_DIR="datasets"
RESULTS_DIR="results"

BUILD_SCRIPT="build.sh"
GROUND_TRUTH_SCRIPT="ground_truth.sh"

GROUND_TRUTH_CSV_FILE="ground_truth.csv"
BENCHMARK_CSV_FILE="benchmark.csv"
PRECISIONS_CSV_FILE="precisions.csv"
RECALLS_CSV_FILE="recalls.csv"


## return "1" if incompatibility was detected in the row
## detected incompatibility is found by grep pattern matching
function incompatibilityDetected() {
    if grep -q "$2" "$1" ; then echo 1
    else echo 0 ; fi
}


# Check necessary tools are installed
tools=("ant" "mvn" "pip3" "python3")
for tool in "${tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "$tool is not installed. Please install it."
        exit 1
    fi
done

pip3 install -r requirements.txt

[ -d "$RESULTS_DIR" ] || mkdir "$RESULTS_DIR"

for bench_dir in "$DATASETS_DIR"/* ; do
    bench_name="${bench_dir##*/}"
    if [ "$bench_name" == "japicmp" ] || [ "$bench_name" == "revapi" ] || [ "$bench_name" == "jezek_dietrich" ] ; then
        continue
    fi
    echo "Current Benchmark: $bench_name"

    cd "$bench_dir" || return

    echo "Running build script..."
    sh "$BUILD_SCRIPT"

    echo "Running ground truth script..."
    sh "$GROUND_TRUTH_SCRIPT"

    cd ../..

    bench_results_dir="$RESULTS_DIR/$bench_name"
    dataset_dir="$DATASETS_DIR/$bench_name"
    echo "Running tools..."
    sh tools/run.sh "$dataset_dir" "$bench_results_dir"

    echo "Analyzing results..."
    tool_reports=()
    for d in "$bench_results_dir/reports"/* ; do
        filename=$(basename "$d")
        tool_reports+=("$filename")
    done

    ground_truth_csv_path="$dataset_dir/output/$GROUND_TRUTH_CSV_FILE"
    benchmark_csv_path="$bench_results_dir/$BENCHMARK_CSV_FILE"

    echo "change,source,binary" > "$benchmark_csv_path"
    cp "$ground_truth_csv_path" "$benchmark_csv_path"

    # Read the benchmark CSV file
    source_array=()
    binary_array=()
    while IFS=, read -r change source binary; do
        if [ "$change" = "change" ]; then
            continue
        fi

        source_array+=("$source")
        binary_array+=("$binary")
    done < "$benchmark_csv_path"

    # Calculating the number of BCs (allRelevant)
    breaking_array=()
    allRelevant=0
    for ((i = 0; i < ${#source_array[@]}; i++)); do
        # A change is breaking if source == 0 or binary == 0
        if [ "${source_array[i]}" = "0" ] || [ "${binary_array[i]}" = "0" ]; then
            breaking_array+=("0")
            allRelevant=$((allRelevant + 1))
        else
            breaking_array+=("1")
        fi
    done

    echo "Number of breaking changes: $allRelevant"

    # Compute stats for each tool
    benchmark_tmp_csv_path="$bench_results_dir/$BENCHMARK_CSV_FILE.tmp"
    precisionsArray=()
    recallsArray=()
    for filename in "${tool_reports[@]}"; do
        rm -f "$benchmark_tmp_csv_path"

        report_path="$bench_results_dir/reports/$filename"
        toolName=$(echo "$filename" | cut -f 1 -d '.')
        allRetrieved=0
        relevantRetrieved=0
        index=0
        toolValues=()

        while read -r line; do
            change=$(echo "$line" | cut -d, -f1)

            if [ "$change" = "change" ]; then
                value="$toolName"
            else
                value=$(incompatibilityDetected "$report_path" "$change")
                allRetrieved=$((allRetrieved + value))

                toolValues+=("$value")

                if [ "${binary_array[index]}" -eq 0 ] || [ "${source_array[index]}" -eq 0 ]; then
                    relevantRetrieved=$((relevantRetrieved + value))
                fi
                index=$((index + 1))
            fi

            echo "${line},${value}" >> "$benchmark_tmp_csv_path"
        done < "$benchmark_csv_path"

        if [ "$allRetrieved" -ne 0 ]; then
            precision=$(echo "scale=4; $relevantRetrieved / $allRetrieved * 100 " | bc)
        else
            precision=0.00
        fi

        if [ "$allRelevant" -ne 0 ]; then
            recall=$(echo "scale=4; $relevantRetrieved / $allRelevant * 100 " | bc)
        else
            recall=0.00
        fi

        echo "Precision for $toolName: $precision"
        echo "Recall for $toolName: $recall"

        recallsArray+=("$recall")
        precisionsArray+=("$precision")

        cp "$benchmark_tmp_csv_path" "$benchmark_csv_path"
    done

    precisionsArrayLine="Precision,,"
    for precision in "${precisionsArray[@]}"; do
        precisionsArrayLine+=",$precision"
    done
    echo "$precisionsArrayLine" >> "$benchmark_csv_path"

    recallsArrayLine="Recall,,"
    for recall in "${recallsArray[@]}"; do
        recallsArrayLine+=",$recall"
    done
    echo "$recallsArrayLine" >> "$benchmark_csv_path"

    # Clean up
    rm "$benchmark_tmp_csv_path"

    # Save the precisions and recalls arrays to separate CSV files
    precisions_csv_path="$bench_results_dir/$PRECISIONS_CSV_FILE"
    recalls_csv_path="$bench_results_dir/$RECALLS_CSV_FILE"
    echo "tool,precision" > "$precisions_csv_path"
    paste -d ',' <(printf "%s\n" "${tool_reports[@]}") <(printf "%s\n" "${precisionsArray[@]}") >> "$precisions_csv_path"
    echo "tool,recall" > "$recalls_csv_path"
    paste -d ',' <(printf "%s\n" "${tool_reports[@]}") <(printf "%s\n" "${recallsArray[@]}") >> "$recalls_csv_path"

    python3 plot.py "$bench_results_dir"
done
