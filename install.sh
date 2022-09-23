#!/usr/bin/env bash

DOTFILES="${DOTFILES:-$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}"

INSTALL_ACTIONS="omz zsh"

require_dir(){ [ -e "$1" ] || mkdir -p "$1"; }

do_omz(){
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  install_link "${DOTFILES}/omz" "$HOME/.oh-my-zsh/custom"
}

do_zsh(){
  install_link "${DOTFILES}/zsh/.zshrc" "$HOME/.zshrc"
}

_red(){
  printf "%s%s%s" "$(tput setaf 1 2>/dev/null || echo '\e[0;31m')" "$@" "$(tput sgr 0 2>/dev/null || echo '\e[0m')"
}
_green(){
	printf "%s%s%s" "$(tput setaf 2 2>/dev/null || echo '\e[0;32m')" "$@" "$(tput sgr 0 2>/dev/null || echo '\e[0m')"
}
_yellow(){
	printf "%s%s%s" "$(tput setaf 3 2>/dev/null || echo '\e[0;33m')" "$@" "$(tput sgr 0 2>/dev/null || echo '\e[0m')"
}
_cyan(){
	printf "%s%s%s" "$(tput setaf 6 2>/dev/null || echo '\e[0;36m')" "$@" "$(tput sgr 0 2>/dev/null || echo '\e[0m')"
}

msg_file_exists(){
  printf "%-25s %s\n" "$(_yellow "[EXISTS]")" "$(_cyan "$1")"
}

msg_link_exists(){
  printf "%-25s %s -> %s\n" "$(_yellow "[EXISTS]")" "$(_cyan "$1")" "$(readlink "$1")"
}

msg_link_failed(){
  printf "%-25s %s -> %s\n" "$(_red "[FAILED]")" "$(_cyan "$1")" "$2"
}

msg_dir_exists(){
  printf "%-25s %s (dir)\n" "$(_yellow "[EXISTS]")" "$1"
}

msg_file_created(){
  printf "%-25s %s -> %s\n" "$(_green "[CREATE]")" "$(_cyan "$1")" "$2"
}

msg_file_backup(){
  printf "%-25s %s -> %s\n" "$(_cyan "[BACKUP]")" "$1" "$2"
}

install_link(){
	if [ -L "$2" ]; then
	  msg_link_exists "$2"
  return

	elif [ -d "$2" ]; then
    msg_dir_exists "$2"
  return

	elif [ -f "$2" ]; then
		bakfile="$2.$(date +%y%m%d%H%M%S).bak"
		mv "${2}" "${bakfile}"
    msg_file_backup "$2" "$bakfile"
	fi


	if ln -s "$1" "$2" ; then
    msg_file_created "$2" "$(readlink "$2")"
	else
    msg_link_failed "$2" "$1"
	fi
}

# Script requires at least 1 argument
if [ $# -lt 1 ]; then print_usage; exit 1; fi

# run all do_ functions given as arguments
for arg in "$@"; do for action in ${INSTALL_ACTIONS}; do
	if [ "${arg}" = "${action}" ]; then
		printf "==================== %s ====================\n" "${action}"
		if type "do_${action}" &>/dev/null; then
			"do_${action}"
		else
			printf "%-25s %s\n" "$(_red "[ERROR]")" "Invalid Function: do_${action}"
		fi
		continue 2
	fi
done; printf "%-25s %s\n" "$(_red "[ERROR]")" "Invalid Action: ${arg}"
done
