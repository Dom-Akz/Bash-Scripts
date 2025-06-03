#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

neofetch
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0;33m\]$(parse_git_branch)\[\e[0m\]\$ '


if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

##-----------------------------------------------------
## synth-shell-greeter.sh

##-----------------------------------------------------
## synth-shell-prompt.sh
if [ -f /home/soufiane/.config/synth-shell/synth-shell-prompt.sh ] && [ -n "$( echo $- | grep i )" ]; then
	source /home/soufiane/.config/synth-shell/synth-shell-prompt.sh
fi

##-----------------------------------------------------
## better-ls
if [ -f /home/soufiane/.config/synth-shell/better-ls.sh ]; then
	source /home/soufiane/.config/synth-shell/better-ls.sh
fi

##-----------------------------------------------------
## alias
if [ -f /home/soufiane/.config/synth-shell/alias.sh ] && [ -n "$( echo $- | grep i )" ]; then
	source /home/soufiane/.config/synth-shell/alias.sh
fi

##-----------------------------------------------------
## better-history
if [ -f /home/soufiane/.config/synth-shell/better-history.sh ] && [ -n "$( echo $- | grep i )" ]; then
	source /home/soufiane/.config/synth-shell/better-history.sh
fi

# Created by `pipx` on 2025-06-01 12:54:19
export PATH="$PATH:/home/soufiane/.local/bin"
