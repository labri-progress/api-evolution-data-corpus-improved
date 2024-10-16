#!/bin/bash

OUTPUT_DIR="output"
REPORTS_DIR="$OUTPUT_DIR/reports"

COMPATIBILITY_CSV_FILE="$OUTPUT_DIR/compatibility.csv"
COMPATIBILITY_CSV_FILE_TMP="$OUTPUT_DIR/compatibility.csv.tmp"
CSV_BENCHMARK_FILE="$OUTPUT_DIR/benchmark.csv"
PRECISIONS_CSV_FILE="$OUTPUT_DIR/precisions.csv"
RECALLS_CSV_FILE="$OUTPUT_DIR/recalls.csv"


## return "1" if incompatibility was detected in the row
## detected incompatibility is found by grep pattern matching
function incompatibilityDetected() {
    report="$REPORTS_DIR/$1"

    if grep -q "$2" "$report" ; then echo 1
    else echo 0 ; fi
}



# make sure the compatibility table is generated
#./compatibility.sh

# make sure the reports are generated
./tools/run.sh

# All tools.
TOOL_REPORTS=()

# iterate reports and get report names from file-names
for d in "$REPORTS_DIR"/* ; do

    # cut only file name
    filename=$(basename "$d")
    TOOL_REPORTS+=("$filename")
done


#####
# Caution: we grep only incompatible results
# The reason is: a test scenario could actually pass source/binary compatibility check
####

# cp $COMPATIBILITY_CSV_FILE $CSV_BENCHMARK_FILE
# header
echo "change,source,binary" > $CSV_BENCHMARK_FILE
# compatible results (it has at least one "0" in the row
cp $COMPATIBILITY_CSV_FILE $CSV_BENCHMARK_FILE
# source incompatible only
#grep "0,1" $COMPATIBILITY_CSV_FILE >> $CSV_BENCHMARK_FILE
# binary incompatible + any source 
#grep '.*,0$' $COMPATIBILITY_CSV_FILE >> $CSV_BENCHMARK_FILE


# Initialize arrays for source and binary columns
source_array=()
binary_array=()

# Read the benchmark CSV file
while IFS=, read -r change source binary; do
    # Skip the header line
    if [ "$change" = "change" ]; then
        continue
    fi

    # Append values to arrays
    source_array+=("$source")
    binary_array+=("$binary")
done < "$CSV_BENCHMARK_FILE"



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

# Print the number of breaking changes (allRelevant)
echo "Sum of Array Elements: $allRelevant"






# Initialize arrays to store the stats for each tool
precisionsArray=()
recallsArray=()


# iterate tools
for filename in "${TOOL_REPORTS[@]}"; do
    rm -f "$COMPATIBILITY_CSV_FILE_TMP"
    allRetrieved=0  # Reset the sum of all retrieved BCs for each tool
    relevantRetrieved=0 # Reset the sum of relevant retrieved BCs for each tool
    index=0 
    toolValues=() # Initialize an array to store values for the current tool

    # iterate compatibility.csv
    while read -r line; do
        change=$(echo "$line" | cut -d, -f1)
        toolName=$(echo "$filename" | cut -f 1 -d '.')

        if [ "$change" = "change" ]; then
            value="$toolName"
        else
            value=$(incompatibilityDetected "$filename" "$change")
            allRetrieved=$((allRetrieved + value))  # Sum the values for each tool
            
            toolValues+=("$value")
            
            # Check the condition for relevantRetrieved increment
            if [ "${binary_array[index]}" -eq 0 ] || [ "${source_array[index]}" -eq 0 ]; then
                relevantRetrieved=$((relevantRetrieved + value))
            fi
            index=$((index + 1))
        fi
        
        
   
        echo "${line},${value}" >> "$COMPATIBILITY_CSV_FILE_TMP"
    done < "$CSV_BENCHMARK_FILE"

    # Calculate precision if allRetrieved is not zero
    if [ "$allRetrieved" -ne 0 ]; then
        precision=$(echo "scale=4; $relevantRetrieved / $allRetrieved * 100 "  | bc)
        
        
    else
        precision=0.00
    fi

    # Calculate recall if allRetrieved is not zero
    if [ "$allRetrieved" -ne 0 ]; then
        recall=$(echo "scale=4; $relevantRetrieved / $allRelevant * 100 "  | bc)
        
        
    else
        recall=0.00
    fi

    echo "Precision for $filename: $precision"
    echo "Recall for $filename: $recall"

    # Append to the precisions array
    recallsArray+=("$recall")
    precisionsArray+=("$precision")
    
    cp "$COMPATIBILITY_CSV_FILE_TMP" "$CSV_BENCHMARK_FILE"
done


# Add the tools' precisions and recalls lines to the benchmark.csv file
precisionsArrayLine="Precision, ,"
for precision in "${precisionsArray[@]}"; do
    precisionsArrayLine+=",$precision"
done
echo "$precisionsArrayLine" >> "$CSV_BENCHMARK_FILE"

recallsArrayLine="Recall, ,"
for recall in "${recallsArray[@]}"; do
    recallsArrayLine+=",$recall"
done
echo "$recallsArrayLine" >> "$CSV_BENCHMARK_FILE"



# Clean up
rm "$COMPATIBILITY_CSV_FILE_TMP"

# Save the precisions and recalls arrays to separate CSV files

echo "tool,precision" > "$PRECISIONS_CSV_FILE"
paste -d ',' <(printf "%s\n" "${TOOL_REPORTS[@]}") <(printf "%s\n" "${precisionsArray[@]}") >> "$PRECISIONS_CSV_FILE"
echo "tool,recall" > "$RECALLS_CSV_FILE"
paste -d ',' <(printf "%s\n" "${TOOL_REPORTS[@]}") <(printf "%s\n" "${recallsArray[@]}") >> "$RECALLS_CSV_FILE"

pip3 install -r requirements.txt
python3 plot.py
