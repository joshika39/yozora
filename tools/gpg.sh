#!/usr/bin/env bash

generate_gpg () {
  if ! [ -z "$(gpg --list-secret-keys)" ]; then
    read -p "GPG keys found. Do you want to generate a new one or list them or select an existing (Y/l/n): " generate
    if [ "$generate" == "n" ]; then
      return 1
    elif [ "$generate" == "l" ]; then
      gpg --list-secret-keys --keyid-format=long > /dev/tty
      generate_gpg 
    elif [ "$generate" == "Y" ]; then
      gpg --full-generate-key
    fi
  fi
}

check_gpg() {
  if [ -z "$(gpg --list-secret-keys)" ]; then
    read -p "No GPG keys found. Do you want to generate one? (y/n): " generate
    if [ "$generate" == "y" ]; then
      generate_gpg
      return $?
    else
      return 1
    fi
  fi
}

get_gpg_key() {
  isManual=$2
  check_gpg
  if [ "$?" == "1" ]; then
    return 1
  fi

  num_keys=$(gpg --list-secret-keys --keyid-format LONG | grep -c "sec")
  if [ -n "$1" ] || [ "$num_keys" -gt 1 ]; then
    gpg --list-secret-keys --keyid-format=long > /dev/tty
    echo "Enter any part of the [uid] (ex.: Joshua Hegedus (Software Developer) <josh.hegedus@outlook.com>): " > /dev/tty
    read -p "uid: " uid
  fi

  if [ -n "$uid" ]; then
    gpg_key=$(gpg --list-secret-keys --keyid-format LONG | awk -v uid="$uid" -v N=2 '{i=(1+(i%N)); if (buffer[i] && $0 ~ uid) print buffer[i]; buffer[i]=$2}' | cut -d '/' -f2)
  else
    gpg_key=$(gpg --list-secret-keys --keyid-format LONG | grep "sec" | awk '{print $2}' | cut -d'/' -f2)
  fi
  if ! [ -z "$isManual" ]; then
    echo $gpg_key | xclip -selection clipboard
  fi
  echo $gpg_key
}

set_git_gpg_signing() {
  gitfile="$1"
  generate_gpg
  res=$?
  if [ "$res" == "1" ]; then
    echo "Skipped GPG gnereation."
  fi
  gpg_key=$(get_gpg_key)
  if [ "$?" == "1" ]; then
    echo "No GPG key found. Skipping GPG signing."
    return 1
  fi

  git config --file "$gitfile" user.signingkey "$gpg_key"
  git config --file "$gitfile" commit.gpgsign true
  git config --file "$gitfile" tag.gpgsign true
  echo "GPG signing enabled with key: $gpg_key"

  export_gpg "$gpg_key"

  return 0
}

export_gpg() {
  gpg_key="$1"
  # Known GPG sites' gpg settings pages stored in dictionary by domains
  declare -A gpg_sites=(
    [github.com]="https://github.com/settings/keys"
    [gitlab.com]="https://gitlab.com/-/profile/gpg_keys"
    [bitbucket.org]="https://bitbucket.org/account/settings/gpg-keys/"
    [szofttech.inf.elte.hu]="https://szofttech.inf.elte.hu/-/profile/gpg_keys"
  )

  check_gpg

  echo "Where do you want to use the GPG key (GitHub/GitLab/Other)?"
  echo "List them separated by a comma (ex.: GitHub,GitLab,my.domain.com,other.ni)"
  echo "If you don't want to use it anywhere, just press Enter. It will be copied to the clipboard anyway."
  echo "Known sites: $(for site in "${!gpg_sites[@]}"; do echo -n "$site,"; done)"
  read -p "Sites: " sites

  gpg --armor --export "$gpg_key" | xclip -selection clipboard
  echo "GPG key copied to clipboard. Add it to your GitHub/GitLab or other server account."

  if [ -n "$sites" ]; then
    IFS=',' read -ra sites <<< "$sites"
    for site in "${sites[@]}"; do
      if [ -n "${gpg_sites[$site]}" ]; then
        echo "Opening $site..."
        xdg-open "${gpg_sites[$site]}"
      else
        echo "Custom site: $site"
        open_custom_site "$site"
      fi
    done
  fi
}
