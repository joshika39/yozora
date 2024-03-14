# Yozora (夜空) dotfiles

### Installation

```bash

git clone https://github.com/joshika39/yozora.git ~/.config/yozora
cd ~/.config/yozora

# Install the dotfiles
bash shell/bash/update.sh --download
```

### Package collection updater

If you sourced the bashrc file with: `source ~/.bashrc` then you can use the following command to update the package collection:

```bash
update # This will update the base packages

update <collection-name> # This will update the specified collection

update --list # This will list all the available collections
update --all # This will update all the collections
```

### Bashrc file updater
You can use the following command to update the bashrc and the other bashrc related files (bash_aliases, bash_functions, bash_exports, bash_profile, bash_prompt, bashrc, bashrc.d):

```bash
brc # This will update the bashrc file from the repository
refresh # This will refresh (source) the bashrc file

brc --upload # This will upload the local bashrc file to the repository

```

### Notes

Add switchable work environment: wayland to xorg
