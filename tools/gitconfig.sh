#!/bin/bash

source ./gpg.sh

set_base() {
  gitfile="$1"
  gitfile="${gitfile/#\~/$HOME}"
  echo "Setting up gitconfig at $gitfile"

  echo "Enter your default git name: "
  read name

  echo "Enter your default git email: "
  read email

  git config --file "$gitfile" user.name "$name"
  git config --file "$gitfile" user.email "$email"
  
  check_gpg
  if [ "$?" == "1" ]; then
    echo "No GPG keys found. Not setting up GPG signing."
    return 1
  fi

  set_git_gpg_signing "$gitfile"
}

setup_sub_config() {
  sub_path=$1
  gitconfig_path=$2

  if [ -z "$gitconfig_path" ]; then
    echo "Enter the path to your sub gitconfig: "
    read gitconfig_path
  fi

  git config --global includeIf."$sub_path".path "$gitconfig_path"
  set_base "$gitconfig_path"
  return 0
}

if ! [ -x "$(command -v git)" ]; then
  echo 'Error: git is not installed.' >&2
  exit 1
fi

while [ "$1" != "" ]; do
  case $1 in
    --sub ) shift
            sub_path=$1
            ;;
    --path ) shift
             gitconfig_path=$1
            ;;
    --help ) echo "Usage: gitconfig.sh [--sub path] [--path path]"
             exit 0
             ;;
    * ) echo "Invalid argument: $1"
  esac
  shift
done

# If the --sub flag is passed, set the sub gitconfig
if [ -n "$sub_path" ]; then
  setup_sub_config "$sub_path" "$gitconfig_path"
  exit 0
fi

set_base "$HOME/.gitconfig"

if [ -x "$(command -v nvim)" ]; then
  git config --global core.editor "nvim"
  git config --global merge.tool "nvim"
else
  git config --global core.editor "nano"
  git config --global merge.tool "nano"
fi

git config --global alias.st status
git config --global rerere.enabled true
git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global push.autoSetupRemote true
git config --global color.ui true
git config --global alias.lg1 "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all"
git config --global alias.lg2 "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'"
git config --global alias.lg "lg1"

git config --global core.autocrlf input

