# Yozora (夜空) dotfiles

### Installation

```bash
git clone https://github.com/joshika39/yozora.git ~/.config/yozora && cd ~/.config/yozora

# Install the dotfiles
bash shell/bash/update.sh --download
```

## Convinience commands

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

### Available update retrieval commands
```bash
# These commands will store the result in a json file under ~/.yozora/

checkupdates # This will check for updates for the official packages in all of the components

checkupdates aur # This will check for updates for the aur packages in all of the components
```

You can retrieve the string of the packages using the core scripts: 
```bash

.$YOZORA_PATH/tools/package-manager/official-updates.sh <string|count> # This will return the string of the official packages

```

## Git repository cloner
```bash
gclone <repo-name> # This is used to clone repositories from any specified host or github (default). If there is no user specified then it will clone the repository from the current user (whoami)
gclone <repo-name> <user-name> # This is used to clone repositories from any specified host or github (default). If there is a user specified then it will clone the repository from the specified user
gclone <repo-name> <user-name> <host-name> # This is used to clone repositories from any specified host or github (default). If there is a user and host specified then it will clone the repository from the specified user and host
gclone <repo-name> <user-name> <host-name> [is_ssh] # This is used to clone repositories from any specified host or github (default). If there is a user and host specified then it will clone the repository from the specified user and host. If the is_ssh is set to true then it will use the ssh protocol to clone the repository
```
### Notes

#### Future plans

- [ ] Add switchable work environment: wayland to xorg
