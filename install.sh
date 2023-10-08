#!/usr/env/bin bash

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


if [ "$1" == "-l" ] || [ "$1" == "--list" ]; then
  # Store the available package collections, while removing the `.conf` extension
  package_array=($(ls $YOZORA_PATH/pkg-collections | sed 's/\.conf//g'))
  # Remove the `base` package collection from the list
  package_array=(${package_array[@]/base/})

  echo "Available package collections:"
  for package in $packages; do
    echo -e "\t-> $package"
  done
  exit 0
fi


if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "Usage: ./install.sh <package_collection>"
  echo "or if the bashrc is sourced then: update <package_collection>"
  echo ""
  echo "--list, -l to list the available package collections"
  echo "--help, -h to display the help message"
  exit 0
fi

if ! [ -z "$1" ]; then
  package_collection=$1

  if [ -f "$YOZORA_PATH/pkg-collections/$package_collection.conf" ]; then
    sudo bash $YOZORA_PATH/tools/install-packages.sh $YOZORA_PATH/pkg-collections/$package_collection.conf
    bash $YOZORA_PATH/tools/install-packages.sh $YOZORA_PATH/pkg-collections/$package_collection.conf
  else
    echo "The package collection $package_collection does not exist"
    # Store the available package collections, while removing the `.conf` extension
    package_array=($(ls $YOZORA_PATH/pkg-collections | sed 's/\.conf//g'))
    # Remove the `base` package collection from the list
    package_array=(${package_array[@]/base/})

    echo "Available package collections:"
    for package in $packages; do
      echo -e "\t-> $package"
    done
    exit 1
  fi
fi

# Install the base package collection if no package collection is specified

if [ -z "$1" ]; then
  sudo bash $YOZORA_PATH/tools/install-packages.sh $YOZORA_PATH/pkg-collections/base.conf
  bash $YOZORA_PATH/tools/install-packages.sh $YOZORA_PATH/pkg-collections/base.conf
fi


