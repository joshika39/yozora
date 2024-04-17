#!/bin/bash

# This script returns how many official updates are available

if [ -z "$YOZORA_PATH" ]; then
  echo "YOZORA_PATH is not set. Please set the environment variable to the root of the project"
  exit 1
fi

source "$YOZORA_PATH/tools/package-manager/lib.sh"

all_packages="$(get_official_packages_in_files 'all') $(get_official_packages_in_files)"

if [ -z "$all_packages" ] || [ "$all_packages" == " " ]; then
  echo "Official packages not found"
  exit 0
fi

IFS=' ' read -r -a packages <<< "$all_packages"
echo "Number of official packages: ${#packages[@]}"

updates=0
updatable_packages=()
for package in "${packages[@]}"; do
  if pacman -Q "$package" &> /dev/null; then
    if pacman -Qu "$package" &> /dev/null; then
      updates=$((updates + 1))
      updatable_packages+=( "$package" )
    fi
  fi
done

echo "Number of official updates available: $updates"
echo "Packages that can be updated: ${updatable_packages[@]}"
