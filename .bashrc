# .bashrc
[ -z "$PS1" ] && return
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

export PATH

# Expand the history size
export HISTFILESIZE=10000
export HISTSIZE=500

# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
PROMPT_COMMAND='history -a'

export EDITOR=nvim
export VISUAL=nvim

#Set Aliases
alias vi=nvim
alias ll='ls -lh'

# Function to get the current Git branch
# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		if [ "$BRANCH" == "master" ] || [ "$BRANCH" == "main" ]; then
			echo -e "\e[31m[${BRANCH}]\e[0m"
		else
			echo -e "\e[32m[${BRANCH}]\e[0m"
		fi
	else
		echo ""
	fi
}
# Funktion um den Pfad auf die letzten 3 Verzeichnisse zu kürzen
function shorten_path() {
    local full_path=$PWD
    local shortened_path=$(echo "$full_path" | awk -F'/' '{ if (NF>3) {print "…/"$(NF-2)"/"$(NF-1)"/"$NF} else {print $0} }')
    echo "$shortened_path"
}

export PS1="[\u@\h \$(shorten_path) \$(parse_git_branch)]$ "

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi
unset rc
