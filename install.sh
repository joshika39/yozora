#!/usr/env/bin bash

# This script is used to install the necessary dependencies for the project

# check the $YOZORA_PATH environment variable

if [ -z "$YOZORA_PATH" ]; then
  echo "YOZORA_PATH is not set. Please set the environment variable to the root of the project"
  exit 1
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
    # Rename the `base` to "(*) base" to indicate that it is the default package collection
    packages=$(echo "${package_array[@]/base/(*)-base}")

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


