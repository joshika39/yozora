#!/usr/bin/env bash

# This script is used to install packages from the official repositories and the AUR
# `e` is used to execute a command
# `s` is used to execute a command as root
# `o` is used to install an official package
# `a` is used to install an AUR package
# `i` is used to import another configuration file
# The `->` is used to split the command from the package name

AUR=()
OFFICIAL=()
COMMANDS=()
SUDO_COMMANDS=()
IMPORTS=() sep="->"

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    "-p"|"--path")
      root_path="$2"
      shift
      shift
      ;;
    "-pkg"|"--package")
      package_collection="$2"
      shift
      shift
      ;;
    "-h"|"--help")
      echo "Usage: ./install-packages.sh <package_collection>"
      echo "or if the bashrc is sourced then: update <package_collection>"
      echo ""
      echo "--help, -h to display the help message"
      echo "--path, -p to set the YOZORA_PATH"
      echo "--package, -pkg to set the package collection"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done


if [[ -z $root_path ]]; then
  if [[ -d $YOZORA_PATH/pkg-collections ]]; then
    root_path="$YOZORA_PATH/pkg-collections"
  else
    exit 1
  fi
fi

full_path="$root_path/$package_collection"

while read PKG; do
  if [[ ${PKG::1} != "#" && ${PKG::1} != "" ]]; then
    if [[ ${PKG::1} == "i" ]]; then
      split="${PKG#*$sep}"
      IMPORTS+=( "${split}" )
    fi
  fi
done < $full_path

TEMP_FILE=$(mktemp)

if [[ ${#IMPORTS[@]} -gt 0 ]]; then
  for file in ${IMPORTS[@]}; do
    file="$root_path/$file"
    cat $file >> $TEMP_FILE
  done
  echo cat $full_path | grep -v "^i"
  cat $full_path | grep -v "^i" >> $TEMP_FILE
else
  cat $full_path > $TEMP_FILE
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

if (( $(id -u) != 0 )); then

  if [[ ${#COMMANDS[@]} -eq 0 ]]; then
    echo "No sudo commands to execute"
  else
    echo " --> Executing commands <--"
    for ((i = 0; i < ${#COMMANDS[@]}; i++)); do
      eval ${COMMANDS[$i]}
    done
  fi
  if [[ ${#AUR[@]} -eq 0 ]]; then
    echo "No AUR packages to install"
  else
    echo " --> Installing AUR Packages <--"
    if [[ ! -d $HOME/.aur-installs ]]; then
      mkdir $HOME/.aur-installs/	
    fi
    TEMP_DIR=$HOME/.aur-installs
    CURRENT_DIR=$(pwd)
    for ((i = 0; i < ${#COMMANDS[@]}; i++)); do
      eval ${COMMANDS[$i]}
    done
    
    for pkg in ${AUR[@]}; do
      # If the package is not installed or the version is different
      if [[ ! $(pacman -Q $pkg) ]]; then
        echo "Installing $pkg"
        cd $TEMP_DIR
        git clone https://aur.archlinux.org/$pkg.git
        cd $pkg
        makepkg -si
        cd $CURRENT_DIR
      else
        echo "$pkg is already installed with version: $(pacman -Q $pkg)"
      fi
    done
  fi
fi

if (( $(id -u) == 0 )); then
  echo
  if [[ ${#OFFICIAL[@]} -eq 0 ]]; then
    echo "No official packages to install"
  else
    echo " --> Installing Official Packages <--"
    official_packages=$(IFS=" "; echo "${OFFICIAL[*]}")
    echo "Installing: $official_packages"
    pacman -Syu
    pacman -S $official_packages
  fi
  if [[ ${#SUDO_COMMANDS[@]} -eq 0 ]]; then
    echo "No sudo commands to execute"
  else
    echo " --> Executing sudo commands <--"
    for ((i = 0; i < ${#SUDO_COMMANDS[@]}; i++)); do
      eval ${SUDO_COMMANDS[$i]}
    done
  fi
fi

echo " --> Cleaning up <--"
rm $TEMP_FILE
echo " --> Done <--"
