#!/bin/bash

# This script returns how many official updates are available

if [ -z "$YOZORA_PATH" ]; then
  echo "YOZORA_PATH is not set. Please set the environment variable to the root of the project"
  exit 1
fi

source "$YOZORA_PATH/tools/package-manager/lib.sh"

get_package_updates() {
  all_packages="$(get_official_packages_in_files 'all') $(get_official_packages_in_files)"

  if [ -z "$all_packages" ] || [ "$all_packages" == " " ]; then
    echo "Official packages not found"
    exit 0
  fi
  IFS=' ' read -r -a packages <<< "$all_packages"
  updatable_packages=()
  for package in "${packages[@]}"; do
    if pacman -Q "$package" &> /dev/null; then
      if pacman -Qu "$package" &> /dev/null; then
        updatable_packages+=( "$package" )
      fi
    fi
  done
  echo "${updatable_packages[@]}"
}

convert_to_string() {
  local packages=("$@")
  pgk_str=""
  for ((i=0; i<"${#packages[@]}"; i++)); do
    if [ $i -lt $((${#packages[@]} - 1)) ]; then
      pgk_str+="${packages[i]} "
    else
      pgk_str+="${packages[i]}"
    fi
  done
  echo "$pgk_str"
}

get_package_updates_count() {
  local updatable_packages=("$@")
  echo "${#updatable_packages[@]}"
}

convert_array_to_json() {
  local packages=("$@")
  json="{\"packages\": ["
  for ((i=0; i<"${#packages[@]}"; i++)); do
    json+="\"${packages[i]}\""
    if [ $i -lt $((${#packages[@]} - 1)) ]; then
      json+=", "
    fi
  done
  json+="], \"count\": ${#packages[@]}}"
  echo "$json"
}

if [ "$1" == "count" ]; then
  packges=$(get_package_updates)
  json=$(convert_array_to_json $packges)
  mkdir -p $HOME/.yozora
  echo $json > $HOME/.yozora/official-updates.json
  count=$(get_package_updates_count $packges)
  echo $count
fi

if [ "$1" == "string" ]; then
  packges=$(get_package_updates)
  json=$(convert_array_to_json $packges)
  mkdir -p $HOME/.yozora
  echo $json > $HOME/.yozora/official-updates.json
  string=$(convert_to_string $packges)
  echo $string
fi

if [ "$1" == "json" ]; then
  packges=$(get_package_updates)
  json=$(convert_array_to_json $packges)
  mkdir -p $HOME/.yozora
  echo $json > $HOME/.yozora/official-updates.json
  echo $json
fi

if [ "$1" == "json-silent" ]; then
  packges=$(get_package_updates)
  json=$(convert_array_to_json $packges)
  mkdir -p $HOME/.yozora
  echo $json > $HOME/.yozora/official-updates.json
fi
