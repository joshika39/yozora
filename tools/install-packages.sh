#!/usr/bin/env bash

# This script is used to install packages from the official repositories and the AUR
# `e` is used to execute a command
# `s` is used to execute a command as root
# `o` is used to install an official package
# `a` is used to install an AUR package
# `i` is used to import another configuration file
# The `->` is used to split the command from the package name
#

AUR=()
OFFICIAL=()
COMMANDS=()
SUDO_COMMANDS=()
IMPORTS=()
sep="->"

# Read the file and take the imports first

while read PKG; do
  if [[ ${PKG::1} != "#" && ${PKG::1} != "" ]]; then
    if [[ ${PKG::1} == "i" ]]; then
      split="${PKG#*$sep}"
      IMPORTS+=( "${split}" )
    fi
  fi
done < $1

# Combine the files into a temporary install file

TEMP_FILE=$(mktemp)

# If the pkg-collections directory is not found, then exit

if [[ ! -d $YOZORA_PATH/pkg-collections ]]; then
  echo "The pkg-collections directory was not found"
  exit 1
fi

if [[ ${#IMPORTS[@]} -gt 0 ]]; then
  for file in ${IMPORTS[@]}; do
    file="${YOZORA_PATH}/pkg-collections/$file"
    cat $file >> $TEMP_FILE
  done
  # Finally add the original file to the end of the temp file but remove the import lines (which start with `i`)
  cat $1 | grep -v "^i" >> $TEMP_FILE
  # Now we can use the temp file as the main file
fi

while read PKG;
do
  	if [[ ${PKG::1} != "#" && ${PKG::1} != "" ]]; then 
  		if [[ ${PKG::1} == "o" ]]; then 
  			 split="${PKG#*$sep}"
			 
			if [[ ${split:0:4} == "-lts" ]]; then
				OFFICIAL+="${split#*-lts}$2"	
			else	
				OFFICIAL+=" $split"
			fi
		fi
		
		if [[ ${PKG::1} == "e" ]]; then 
  			split="${PKG#*$sep}"
			COMMANDS+=( "${split}" )
		fi

    if [[ ${PKG::1} == "s" ]]; then 
  			split="${PKG#*$sep}"
      SUDO_COMMANDS+=( "${split}" )
    fi
		
		if [[ ${PKG::1} == "a" ]]; then 
  			 split="${PKG#*$sep}"
			 AUR+=( "${split}" )
		fi
	fi
done < $TEMP_FILE

echo " --> before aur"
if (( $(id -u) != 0 )); then
	echo
	echo " --> Installing AUR Packages <--"
	if [[ ! -d $HOME/.aur-installs ]];then
		mkdir $HOME/.aur-installs/	
	fi
	TEMP_DIR=$HOME/.aur-installs
	CURRENT_DIR=$(pwd)
	for ((i = 0; i < ${#COMMANDS[@]}; i++))
	do
		eval ${COMMANDS[$i]}
	done
	
	for pkg in ${AUR[@]}; do
    # If the package is not installed or the version is different
    if [[ ! $(pacman -Q $pkg) ]]; then
      echo "Installing $pkg"
      cd $TEMP_DIR
      git clone https://aur.archlinux.org/$pkg.git
      cd $pkg
      makepkg -si --noconfirm
      cd $CURRENT_DIR
    else
      echo "$pkg is already installed with version: $(pacman -Q $pkg)"
    fi
	done
fi

if (( $(id -u) == 0 )); then
  echo
  echo " --> Installing Official Packages <--"
  PKGS=$(IFS=" "; echo "${OFFICIAL[*]}")
  echo "Installing: $PKGS"
  pacman -S --noconfirm $PKGS
  echo " Running sudo commands"
  for ((i = 0; i < ${#SUDO_COMMANDS[@]}; i++)); do
    eval ${SUDO_COMMANDS[$i]}
  done
fi
