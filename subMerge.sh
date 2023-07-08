#!/bin/bash

# Prompt user for directory path
echo "Enter the path to the data directory:"
read DATAPATH

NUMBER_OF_FILES=$(ls "$DATAPATH"/*.root | wc -l)

echo "Number of ROOT files in data directory = $NUMBER_OF_FILES"

OUTPUT_FILENAME="subMerge_output.root"
TMP_FILENAME="subMerge_tmp.root"

ITER=0

for FILE in "$DATAPATH"/*.root; do

    ((ITER++))

    echo "Reading file $ITER of $NUMBER_OF_FILES"
    echo "Filename = $FILE[$ITER]"

    # add together new file merged file, save in TMP
    hadd $TMP_FILENAME $FILE $OUTPUT_FILENAME

    # remove the "old merged file"
    rm $OUTPUT_FILENAME

    # save the output of the "new merged file"
    cp $TMP_FILENAME $OUTPUT_FILENAME

    # remove the temporary file
    rm $TMP_FILENAME
    

done


