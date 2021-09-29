# -*- mode: shell-script; sh-shell: zsh; -*-

# This code mostly copied from https://github.com/akermu/emacs-libvterm

[[ "${INSIDE_EMACS}" = "vterm" ]] || return

# standard vterm zsh stuff doesn't quite work with omz:
# if [[ "$INSIDE_EMACS" = 'vterm' ]] \
#        && [[ -n ${EMACS_VTERM_PATH} ]] \
#        && [[ -f ${EMACS_VTERM_PATH}/etc/emacs-vterm-zsh.sh ]]; then
# 	  source ${EMACS_VTERM_PATH}/etc/emacs-vterm-zsh.sh
# fi

function vterm_printf(){
    if [ -n "$TMUX" ] && ([ "${TERM%%-*}" = "tmux" ] || [ "${TERM%%-*}" = "screen" ] ); then
        # Tell tmux to pass the escape sequences through
        printf "\ePtmux;\e\e]%s\007\e\\" "$1"
    elif [ "${TERM%%-*}" = "screen" ]; then
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$1"
    else
        printf "\e]%s\e\\" "$1"
    fi
}

# Completely clear the buffer. With this, everything that is not on screen
# is erased.
alias clear='vterm_printf "51;Evterm-clear-scrollback";tput clear'


# With vterm_cmd you can execute Emacs commands directly from the shell.
# For example, vterm_cmd message "HI" will print "HI".
# To enable new commands, you have to customize Emacs's variable
# vterm-eval-cmds.
vterm_cmd() {
    local vterm_elisp
    vterm_elisp=""
    while [ $# -gt 0 ]; do
        vterm_elisp="$vterm_elisp""$(printf '"%s" ' "$(printf "%s" "$1" | sed -e 's|\\|\\\\|g' -e 's|"|\\"|g')")"
        shift
    done
    vterm_printf "51;E$vterm_elisp"
}

# This stuff not needed in omz - but we do need to patch lib/termsupport.zsh to allow INSIDE_EMACS = vterm
# 
# # This is to change the title of the buffer based on information provided by the
# # shell. See, http://tldp.org/HOWTO/Xterm-Title-4.html, for the meaning of the
# # various symbols.
# autoload -U add-zsh-hook
# add-zsh-hook -Uz chpwd (){ print -Pn "\e]2;%m:%2~\a" }

# TODO: Fix this for omz

# Sync directory and host in the shell with Emacs's current directory.
# You may need to manually specify the hostname instead of $(hostname) in case
# $(hostname) does not return the correct string to connect to the server.
#
# The escape sequence "51;A" has also the role of identifying the end of the
# prompt
vterm_prompt_end() {
    vterm_printf "51;A$(whoami)@$(hostname):$(pwd)";
}
# setopt PROMPT_SUBST
# PROMPT=$PROMPT'%{$(vterm_prompt_end)%}'


find_file() {
    vterm_cmd find-file "$(realpath "${@:-.}")"
}

say() {
    vterm_cmd message "%s" "$*"
}
