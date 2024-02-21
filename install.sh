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
    exit 1
fi

# install the necessary dependencies

sudo bash $YOZORA_PATH/tools/install-packages.sh $YOZORA_PATH/pkg-collections/base.conf
bash $YOZORA_PATH/tools/install-packages.sh $YOZORA_PATH/pkg-collections/base.conf

