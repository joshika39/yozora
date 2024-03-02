#!/bin/bash

AUR=()
OFFICIAL=()
COMMANDS=()
SUDO_COMMANDS=()
sep="->"
while read PKG
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
done < $1

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
		if ! pacman -Qs ${pkg} > /dev/null; then  
			echo "\t--> Installing: $pkg"
			echo 
			cd $TEMP_DIR
			git clone https://aur.archlinux.org/${pkg}.git
			cd ${pkg} && makepkg -si && cd $TEMP_DIR
			sudo rm -r $TEMP_DIR/*
		fi
	done
fi

if (( $(id -u) == 0 )); then
  echo
  echo " --> Installing Official Packages <--"
  for pkg in ${OFFICIAL[@]}; do
      pacman -S $pkg --noconfirm
  done

  echo " Running sudo commands"
  for ((i = 0; i < ${#SUDO_COMMANDS[@]}; i++)); do
    eval ${SUDO_COMMANDS[$i]}
  done
fi
