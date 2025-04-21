#!/bin/bash

# Prompt user for directory path
echo "Enter the path to the data directory:"
read DATAPATH

# Prompt for batch size
echo "Enter number of files per batch:"
read BATCH_SIZE

ROOT_FILES=("$DATAPATH"/*.root)
NUMBER_OF_FILES=${#ROOT_FILES[@]}

echo "Number of ROOT files in data directory = $NUMBER_OF_FILES"
echo "Batch size = $BATCH_SIZE"

FINAL_OUTPUT="subMerge_output.root"
TMP_OUTPUT="subMerge_tmp.root"
BATCH_OUTPUTS=()
ITER=0
BATCH_COUNT=0

date

# Loop over ROOT files in batches
while [ $ITER -lt $NUMBER_OF_FILES ]; do
    BATCH_FILES=()
    
    for ((j=0; j<$BATCH_SIZE && $ITER<$NUMBER_OF_FILES; j++)); do
        BATCH_FILES+=("${ROOT_FILES[$ITER]}")
        ((ITER++))
    done

    BATCH_FILENAME="batch_merge_$BATCH_COUNT.root"
    BATCH_OUTPUTS+=("$BATCH_FILENAME")
    
    echo "Merging batch $BATCH_COUNT with ${#BATCH_FILES[@]} files..."
    hadd -k -v 0 "$BATCH_FILENAME" "${BATCH_FILES[@]}"
    
    ((BATCH_COUNT++))

    PERCENT_COMPLETE=$((100 * ITER / NUMBER_OF_FILES))
    echo -ne "$PERCENT_COMPLETE % \033[0K\r"
done

echo
echo "Merging all batch files into final output..."

# Merge all batch outputs into final file
hadd -k -v 0 "$FINAL_OUTPUT" "${BATCH_OUTPUTS[@]}"

# Clean up batch files
rm "${BATCH_OUTPUTS[@]}"

echo "100 % - DONE!"
echo "Merged ROOT file : $FINAL_OUTPUT"

date
