#!/usr/bin/env bash

# Update the bash shell customizations in the home directory
# if the --upload option is specified, the local files are synced back to the repository
# if the --download option is specified, the repository files are synced to the local directory
# the files are the: .bashrc, .bash_aliases, .bash_functions, .bash_profile, .bash_prompt, .bash_exports

REPO_DIR=$YOZORA_PATH/
LOCAL_DIR=~/

if [ ! -d $REPO_DIR ]; then
	echo "The repository directory does not exist: $REPO_DIR"
	exit 1
fi

# Returns the operating system name (mac, arch, ...)
get_os() {
	os="$OSTYPE"
	case os in
	darwin*) echo "mac" ;;
	linux*) echo "arch" ;;
	*) echo "unknown" ;;
	esac
}

downlaod_files() {
	folder=${2:-"os/shell/bash"}
	files=$1
	full_path=$REPO_DIR$folder

	if [[ -z $files ]]; then
		echo "The files are not specified"
		exit 1
	fi

	for file in $files; do
		if [ -f $full_path/${file#.} ]; then
			cp $full_path/${file#.} $LOCAL_DIR$file
		else
			echo "-/> The file does not exist: $full_path/${file#.}"
		fi
	done
	echo "--> The files have been downloaded to the local directory: $LOCAL_DIR from the repository: $full_path"
}

upload_files() {
	folder=${2:-"os/shell/bash"}
	files=$1
	full_path=$REPO_DIR$folder

	if [[ -z $files ]]; then
		echo "The files are not specified"
		exit 1
	fi

	for file in $files; do
		if [ -f $LOCAL_DIR$file ]; then
			cp $LOCAL_DIR$file $full_path/${file#.}
		else
			echo "-/> The file does not exist: $LOCAL_DIR$file"
		fi
	done
	echo "--> The files have been uploaded to the repository: $REPO_DIR"
}

FILES=".bashrc .bash_aliases .bash_functions .bash_profile .bash_prompt .bash_exports"

# HOME_FILES=".xinitrc .xprofile"   # TODO: Implement the home files properly

UPLOAD=false

if [ "$1" == "--upload" ]; then
	UPLOAD=true
fi

DOWNLOAD=false

if [ "$1" == "--download" ]; then
	DOWNLOAD=true
fi

if [ "$UPLOAD" == "true" ]; then
	upload_files "$FILES"
	upload_files
	# upload_files "$HOME_FILES" "home"  # TODO: Implement the home files properly
fi

if [ "$DOWNLOAD" == "true" ]; then
	downlaod_files "$FILES"
	# downlaod_files "$HOME_FILES" "home"  # TODO: Implement the home files properly
	echo "--> Run the command: 'refresh' to apply the changes in the current shell session."
fi
