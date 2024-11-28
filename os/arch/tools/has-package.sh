#!/bin/bash

base_url="https://archlinux.org/packages/search/json/?name="

help() {
  echo "Usage: has-package.sh [options] [package1] [package2] ..."
  echo "Options:"
  echo -e "\t-h, --help\tShow this help message and exit"
}

PACKAGES=()

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
  "-h" | "--help")
    help
    exit 0
    ;;
  *)
    PACKAGES+=("$1")
    shift
    ;;
  esac
done

echo "Gathered packages: ${PACKAGES[@]}"

check_package() {
  local pkgname=$1
  response=$(curl -s "${base_url}${pkgname}")
  exists=$(echo "$response" | jq '.results | length > 0')
  if [[ $exists == "true" ]]; then
    echo "$pkgname: Yes"
  else
    echo "$pkgname: No"
  fi
}

for pkg in "${PACKAGES[@]}"; do
  check_package "$pkg"
done
