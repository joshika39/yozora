#!/bin/bash

# This is a library of functions that can be used in the package related scripts.
# This script should be sourced in the package related scripts.

# Usage: source lib.sh

if [ -z "$YOZORA_PATH" ]; then
  echo "YOZORA_PATH is not set. Please set the environment variable to the root of the project"
  exit 1
fi

declare -A components_health_status=(
  ["i3"]="unhealthy"
  ["hyprland"]="unhealthy"
  ["polybar"]="unhealthy"
  ["nvim"]="unhealthy"
  ["tmux"]="unhealthy"
  ["ranger"]="unhealthy"
  ["kitty"]="unhealthy"
  ["eww"]="unhealthy"
  ["floorp"]="unhealthy"
  ["rofi"]="unhealthy"
)

sep="->"

check_component_health() {
  for component in "${!components_health_status[@]}"; do
    if [ -d "$HOME/.config/$component" ] && [ -f "$HOME/.config/$component/healthcheck.sh" ]; then
      response=$(bash "$HOME/.config/$component/healthcheck.sh")
      components_health_status[$component]=$response
      echo "-> ✅ $component found"
    else
      echo "-> ❌ $component not found or unhealthy"
    fi
  done

  echo "-> INFO: If there where any unhealthy components, please check the healthcheck.sh file in the component's directory"
}

get_collection_files_in_component() {
  local component=$1
  for file in $(ls $HOME/.config/$component/pkgs); do
    echo "$HOME/.config/$component/pkgs/$file"
  done
}

get_collection_files_in_all_components() {
  check_component_health
  for component in "${!components_health_status[@]}"; do
    if [ "${components_health_status[$component]}" == "healthy" ]; then
      for file in $(ls "$HOME/.config/$component/pkgs"); do
        echo "$HOME/.config/$component/pkgs/$file"
      done
    fi
  done
}

get_base_collection_files() {
  for file in $(ls $YOZORA_PATH/pkg-collections); do
    echo "$YOZORA_PATH/pkg-collections/$file"
  done
}

# This function will return the official packages in the files
# Usage: get_official_packages_in_files <package_file1> <package_file2> ...
# Or with pipe the result of the get_base_collection_files function
get_official_packages_in_files() {
  local component=$1
  if [ -z "$component" ]; then
    echo "No component provided" > /dev/tty
    local package_files=($(get_base_collection_files))
  elif [ "$component" == "all" ]; then
    echo "Getting all component package files" > /dev/tty
    local package_files=($(get_collection_files_in_all_components))
  else
    echo "Component provided: $component" > /dev/tty
    local package_files=($(get_collection_files_in_component $component))
  fi

  local official_packages=()
  for file in "${package_files[@]}"; do
    # Id the file's extension is not .conf then skip the file
    if [[ $file != *.conf ]]; then
      continue
    fi
    while IFS= read -r PKG; do
      if [[ ${PKG::1} != "#" && ${PKG::1} != "" ]]; then
        if [[ ${PKG::1} == "o" ]]; then
          split="${PKG#*$sep}"

          if [[ ${split:0:4} == "-lts" ]]; then
            echo "-lts is deprecated, please remove it from the package name" >&2
            official_packages+=("${split#*-lts}$2")
          else
            official_packages+=("$split")
          fi
        fi
      fi
    done < "$file"
  done
  echo "${official_packages[@]}"
}
