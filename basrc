#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

print_pre_prompt ()
{
    TIME=`date +%H時%M分`
    printf "\e[0m%$(($COLUMNS))s" "${TIME}"
}

. ~/.config/yozora/git-completition.sh
. ~/.config/yozora/git-prompt.sh
# \[$(tput sc; print_pre_prompt; tput rc)\]
export PS1='
╔═╦═══ [\[\e[32m\]\u\[\e[0m\]@\[\e[36m\]\h\[\e[0m\]] - (\[\e[39;1m\]\j\[\e[0m\]) - [\[\e[34m\]\w\e[1;33m`__git_ps1 " (%s)"`\e[0m\[\e[0m\]]
╚═╩═ [$?] ¥ \[\e[0m\]'

# Display running command in GNU Screen window status
#
# In .screenrc, set: shelltitle "( |~"
#
# See: http://aperiodic.net/screen/title_examples#setting_the_title_to_the_name_of_the_running_program
case $TERM in screen*)
  PS1=${PS1}'\[\033k\033\\\]'
esac

export GPG_TTY=$(tty)

# export GIT_PS1_SHOWDIRTYSTATE=1
# export PS1='[\[\e[32m\]\u\[\e[0m\]@\[\e[36m\]\h: \[\e[34m\]\W\e[1;33m$(__git_ps1 " (%s)")\e[0m\[\e[0m\]]\$ '
# export PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
