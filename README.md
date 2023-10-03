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
```

### Notes

Add switchable work environment: wayland to xorg
