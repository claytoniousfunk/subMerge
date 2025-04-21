#!/bin/bash

# Prompt user for directory path
echo "Enter the path to the data directory:"
read DATAPATH

# Prompt for batch size
echo "Enter number of files per batch:"
read BATCH_SIZE

# Detect available CPU cores
if command -v nproc &> /dev/null; then
    TOTAL_CORES=$(nproc)
elif [[ "$OSTYPE" == "darwin"* ]]; then
    TOTAL_CORES=$(sysctl -n hw.ncpu)
else
    TOTAL_CORES=1  # fallback
fi

# Calculate 75% of total cores for default parallel jobs
SAFE_JOBS=$(awk -v cores="$TOTAL_CORES" 'BEGIN { print int(cores * 0.75); if (cores * 0.75 < 1) print 1; }')

echo "Detected $TOTAL_CORES CPU cores. Recommended parallel jobs: $SAFE_JOBS"
read -p "Enter number of parallel jobs to use [default: $SAFE_JOBS]: " N_JOBS
N_JOBS=${N_JOBS:-$SAFE_JOBS}

ROOT_FILES=("$DATAPATH"/*.root)
NUMBER_OF_FILES=${#ROOT_FILES[@]}

echo "Number of ROOT files in data directory = $NUMBER_OF_FILES"
echo "Batch size = $BATCH_SIZE"
echo "Parallel jobs = $N_JOBS"

FINAL_OUTPUT="subMerge_output.root"
TMP_DIR="./tmp_batch_merge"
mkdir -p "$TMP_DIR"

date

# Prepare batch commands
BATCH_COUNT=0
ITER=0
BATCH_CMDS=()
BATCH_OUTPUTS=()

while [ $ITER -lt $NUMBER_OF_FILES ]; do
    BATCH_FILES=()
    for ((j=0; j<$BATCH_SIZE && $ITER<$NUMBER_OF_FILES; j++)); do
        BATCH_FILES+=("\"${ROOT_FILES[$ITER]}\"")
        ((ITER++))
    done

    BATCH_FILENAME="$TMP_DIR/batch_merge_$BATCH_COUNT.root"
    BATCH_OUTPUTS+=("$BATCH_FILENAME")

    CMD="hadd -k -v 0 \"$BATCH_FILENAME\" ${BATCH_FILES[*]}"
    BATCH_CMDS+=("$CMD")

    ((BATCH_COUNT++))
done

# Export TMP_DIR so it's available in parallel env
export TMP_DIR

# Run batch merges in parallel
printf "%s\n" "${BATCH_CMDS[@]}" | parallel -j "$N_JOBS"

echo "Merging all batch files into final output..."
hadd -k -v 0 "$FINAL_OUTPUT" "$TMP_DIR"/*.root

# Optional cleanup
rm -r "$TMP_DIR"

echo "DONE!"
echo "Merged ROOT file : $FINAL_OUTPUT"

date
