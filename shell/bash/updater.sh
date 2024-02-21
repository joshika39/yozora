#!/usr/bin/env bash

# Update the bash shell customizations in the home directory
# if the --upload option is specified, the local files are synced back to the repository
# if the --download option is specified, the repository files are synced to the local directory
# the files are the: .bashrc, .bash_aliases, .bash_functions, .bash_profile, .bash_prompt, .bash_exports

REPO_DIR=~/.config/yozora/shell/bash/

if [ ! -d $REPO_DIR ]; then
    echo "The repository directory does not exist: $REPO_DIR"
    exit 1
fi


# The local directory
LOCAL_DIR=~/

FILES=".bashrc .bash_aliases .bash_functions .bash_profile .bash_prompt .bash_exports"

UPLOAD=false

if [ "$1" == "--upload" ]; then
    UPLOAD=true
fi

DOWNLOAD=false

if [ "$1" == "--download" ]; then
    DOWNLOAD=true
fi

if [ "$UPLOAD" == "true" ]; then
    for FILE in $FILES; do
        if [ ! -f $LOCAL_DIR$FILE ]; then
            echo "The file does not exist: $LOCAL_DIR$FILE"
            continue
        fi
        cp $LOCAL_DIR$FILE $REPO_DIR/${FILE#.}
    done
    echo "The local files have been uploaded to the repository"
fi

if [ "$DOWNLOAD" == "true" ]; then
    for FILE in $FILES; do
        if [ ! -f $REPO_DIR/${FILE#.} ]; then
            echo "The file does not exist: $REPO_DIR/${FILE#.}"
            continue
        fi
        cp $REPO_DIR/${FILE#.} $LOCAL_DIR$FILE
    done
    echo "The repository files have been downloaded to the local directory"
fi

source ~/.bashrc
