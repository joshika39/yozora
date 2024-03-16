#!/bin/bash

# This script is used to install the necessary dependencies for the project

# check the $YOZORA_PATH environment variable

if [ -z "$YOZORA_PATH" ]; then
  echo "YOZORA_PATH is not set. Please set the environment variable to the root of the project"
  exit 1
fi

# Usage: ./install.sh <package_collection>
# or if the bashrc is sourced then: `update <package_collection>`
#
# -l or --list to list the available package collections
# -h or --help to display the help message
# -a or --all to install all the available package collections

# Check if the user has other yozora supported packages installed (yozora-i3, yozora-hyprland)

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

is_directory() {
  local path=$1
  local component=$2

  if ! [ -z "$component" ]; then
    path="$HOME/.config/$component/pkgs/$path"
  else
    path="$YOZORA_PATH/pkg-collections/$path"
  fi

  if [ -d "$path" ]; then
    echo "true"
  else
    echo "false"
  fi
}

list_component_packages() {
  local component=$1
  local component_path=$HOME/.config/$component
  local packages=$(ls $component_path/pkgs | sed 's/\.conf//g')
  package_array=(${package_array[@]/base/})

  for package in $packages; do
    echo -e "\t-> $package ($component)"
  done
}

# TODO: Add support for same named packages in different components
get_component_by_package() {
  local package="$1"

  for component in "${!components_health_status[@]}"; do
    local component_path="$HOME/.config/$component/pkgs"
    if [ -d "$component_path" ]; then
      if [ -f "$component_path/$package.conf" ]; then
        echo "$component"
        return 0
      fi
    fi
  done
  return 1
}

get_multiple_components_by_package() {
  local package="$1"
  local components=()

  for component in "${!components_health_status[@]}"; do
    local component_path="$HOME/.config/$component/pkgs"
    if [ -d "$component_path" ]; then
      if [ -f "$component_path/$package.conf" ]; then
        components+=($component)
      fi
    fi
  done

  echo "${components[@]}"
}

install_package() {
  local package=$1
  local component=$2
  local install_script="$YOZORA_PATH/tools/install-packages.sh"

  if ! [ -z $component ]; then
    echo "Component found: $component"
    folder="$HOME/.config/$component/pkgs"
  else
    folder="$YOZORA_PATH/pkg-collections"
  fi

  if ! [ -f "$folder/$package.conf" ]; then
    echo "The package: $package does not exist"
    return 1
  fi

  bash "$install_script" --path "$folder" --package "$package.conf"
  sudo bash "$install_script" --path "$folder" --package "$package.conf"
}

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

list_packages() {
  packages=$(ls $YOZORA_PATH/pkg-collections | sed 's/\.conf//g')
  
  echo "Available package collections:"
  for package in $packages; do
    if [ $(is_directory $package) == "true" ]; then
      continue
    fi
    echo -e "\t-> $package"
  done
}

is_unique_named_package() {
  local package=$1
  
  for a_component in "${!components_health_status[@]}"; do
    for b_component in "${!components_health_status[@]}"; do
      if [[ $a_component == $b_component ]]; then
        continue
      fi
      if [ -f "$HOME/.config/$a_component/pkgs/$package.conf" ] && [ -f "$HOME/.config/$b_component/pkgs/$package.conf" ]; then
        echo "false"
        return 0
      fi
    done
  done

  echo "true"
  return 0
}

help() {
  echo "Usage: ./install.sh <package_collection>"
  echo "or if the bashrc is sourced then: 'update <package_collection>'"
  echo ""
  echo "-l or --list to list the available package collections"
  echo "-h or --help to display the help message"
  echo "-a or --all to install all the available package collections"
  echo "-c or --component to specify the component"
  echo "-p or --package to specify the package"
}

list() {
  check_component_health

  list_packages

  for component in "${!components_health_status[@]}"; do
    if [ "${components_health_status[$component]}" == "healthy" ]; then
      list_component_packages $component
    fi
  done
}

install_all() {
  packages=$(ls $YOZORA_PATH/pkg-collections | sed 's/\.conf//g')  
  for package in $packages; do
    if [ $(is_directory $package) == "true" ]; then
      continue
    fi
    install_package "$YOZORA_PATH/pkg-collections/$package.conf"
  done
}

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -l|--list)
      list
      exit 0
      ;;
    -h|--help)
      help
      exit 0
      ;;
    -a|--all)
      install_all
      exit 0
      ;;
    -c|--component)
      component=$2
      shift
      shift
      ;;
    -p|--package)
      package=$2
      shift
      shift
      ;;
    *)
      package=$1
      shift
  esac
done
# Process the arguments in switch case

if ! [ -z "$package" ]; then
  if ! [ -z "$component" ]; then
    install_package $package $component
  else
    unique_package=$(has_same_named_package $package)
    if [ $unique_package == "true" ]; then
      component=$(get_component_by_package $package)
      install_package $package $component
    else
      echo "The package: $package is found in multiple components. Please specify the component with the -c flag"
    fi

    if [ $? -eq 0 ]; then
      echo "The package: $1 has been installed successfully"
    else
      echo "The package: $1 could not be installed"
    fi
fi

if [ -z "$1" ]; then
  install_package "base"
fi


