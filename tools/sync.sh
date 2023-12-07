#!/bin/bash

# Sync the files and folders from the source to the destination from a file with the following format:
# <source> <destination>
#
# Usage: sync.sh <source_file> [--reverse]

# Check if the reverse flag is provided
# If yes, then swap the source and destination
if [ "$2" == "--reverse" ]; then
    while read line; do
	# Skip the line if it starts with #
	if [[ $line == \#* ]]; then
	    continue
	fi

	# Split the line into source and destination
	source=$(echo $line | awk '{print $1}')
	destination=$(echo $line | awk '{print $2}')

	# Check if the source and destination are provided
	if [ -z "$source" ] || [ -z "$destination" ]; then
	    echo "Source and destination are required"
	    exit 1
	fi

	# Check if the source exists
	if [ ! -d "$source" ]; then
	    echo "Source $source does not exist"
	    exit 1
	fi

	# Check if the destination exists
	if [ ! -d "$destination" ]; then
	    echo "Destination $destination does not exist"
	    exit 1
	fi

	# Sync the source and destination
	cp -rv $destination $source
    done < $1
    exit 0
fi

# Check if the source file is provided
if [ $# -eq 0 ]; then
    echo "Usage: sync.sh <source_file>"
    exit 1
fi


# Loop through the source file

while read line; do
    # Skip the line if it starts with #
    if [[ $line == \#* ]]; then
	continue
    fi

    # Split the line into source and destination
    source=$(echo $line | awk '{print $1}')
    destination=$(echo $line | awk '{print $2}')

    # Get the absolute path of the source and Destination
    source=$(readlink -f $source)
    destination=$(readlink -f $destination)

    # Check if the source and destination are provided
    if [ -z "$source" ] || [ -z "$destination" ]; then
	echo "Source and destination are required"
	exit 1
    fi

    # Check if the source exists
    if [ ! -d "$source" ]; then
	echo "Source $source does not exist"
	exit 1
    fi

    # Check if the destination exists
    if [ ! -d "$destination" ]; then
	echo "Destination $destination does not exist"
	exit 1
    fi

    if [ "$2" == "--reverse" ]; then
	cp -rv $destination $source
    else
	cp -rv $source $destination
    fi

    # Sync the source and destination
done < $1

