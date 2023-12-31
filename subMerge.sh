#!/bin/bash

# Prompt user for directory path
echo "Enter the path to the data directory:"
read DATAPATH

NUMBER_OF_FILES=$(ls "$DATAPATH"/*.root | wc -l)

echo "Number of ROOT files in data directory = $NUMBER_OF_FILES"

OUTPUT_FILENAME="subMerge_output.root"
TMP_FILENAME="subMerge_tmp.root"

ITER=0

PERCENT_COMPLETE=0.0

date

for FILE in "$DATAPATH"/*.root; do

    let ITER=$ITER+1

    #echo "progress: $ITER / $NUMBER_OF_FILES"
    
    if [ $ITER -eq 1 ] ; then

	# hadd options:
	# -k : skip corrupt or non-existant files, do not exit
	hadd -k $OUTPUT_FILENAME $FILE

    elif [ $ITER -gt 1 ] ; then

	# add together new file merged file, save in TMP
	hadd -k $TMP_FILENAME $FILE $OUTPUT_FILENAME

	# remove the "old merged file"
	rm $OUTPUT_FILENAME

	# save the output of the "new merged file"
	mv $TMP_FILENAME $OUTPUT_FILENAME

    fi

    let PERCENT_COMPLETE=100*$ITER/$NUMBER_OF_FILES
    echo -ne "$PERCENT_COMPLETE % \033[0K\r"

done

echo "100 % - DONE!"
echo "Merged ROOT file : $OUTPUT_FILENAME"

date

