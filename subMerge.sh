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

    echo "progress: $ITER / $NUMBER_OF_FILES"
    
    if($ITER -eq 1) ; then

	# hadd options:
	# -k : skip corrupt or non-existant files, do not exit
	# -v 0: set verbosity to 0
	hadd -k -v 0 $OUTPUT_FILENAME $FILE

    elif($ITER -gt 1) ; then

	# add together new file merged file, save in TMP
	hadd -k -v 0 $TMP_FILENAME $FILE $OUTPUT_FILENAME

	# remove the "old merged file"
	rm $OUTPUT_FILENAME

	# save the output of the "new merged file"
	cp $TMP_FILENAME $OUTPUT_FILENAME

	# remove the temporary file
	rm $TMP_FILENAME

    fi    

done


