#!/bin/bash

# Prompt user for directory path
echo "Enter the path to the data directory:"
read DATAPATH

#find $DATAPATH -type f >> list-of-file-names.txt

#echo "List of file names saved to list-of-file-names.txt"

NUMBER_OF_FILES=$(ls "$DATAPATH"/*.root | wc -l)

echo "Number of ROOT files in data directory = $NUMBER_OF_FILES"

ITER=0

for file in "$DATAPATH"/*.root; do

    ITER=ITER+1

    echo "Reading file $ITER of $NUMBER_OF_FILES"

done


