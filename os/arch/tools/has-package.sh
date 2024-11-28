#!/bin/bash

packages=$1

base_url="https://archlinux.org/packages/search/json/?name="

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

for pkg in $packages; do
  check_package $pkg
done
