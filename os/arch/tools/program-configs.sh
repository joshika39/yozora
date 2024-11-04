#!/bin/bash

# This script sets up the configurations for the programs!

get_repo_url() {
  user=$1
  repo=$2
  is_ssh=${3:-"false"}

  if [ "$is_ssh" = "true" ]; then
    echo "git@github.com:$user/$repo.git"
  else
    echo "https://github.com/$user/$repo.git"
  fi
}

while [ "$1" != "" ]; do
  case $1 in
    --user ) shift
            user=${1:-"joshika39"}
            ;;
    --ssh ) shift
            ssh=${1:-"false"}
            ;;
    --help ) echo "Usage: program-configs.sh [--user name] [--ssh true|false]"
             exit 0
            ;;
    * ) echo "Invalid argument: $1"
  esac
  shift
done

declare -A config_repos=(
  ["nvim"]="yozora-nvim"
  ["ranger"]="yozora-ranger"
  ["kitty"]="yozora-kitty"
  ["rofi"]="yozora-rofi"
  ["tmux"]="yozora-tmux"
)
