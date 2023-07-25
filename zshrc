# Path to your oh-my-zsh installation.
# Change this accordingly!
export ZSH=/home/philipp/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
POWERLEVEL9K_MODE='nerdfont-complete'
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git docker zsh-syntax-highlighting kubectl kube-ps1 zsh-autosuggestions git-open autojump zsh-fzf-history-search)

source $ZSH/oh-my-zsh.sh

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="$PATH:~/home/philipp/.local/bin"

eval $(thefuck --alias)

# User configuration

export EDITOR=vim

# ssh
export SSH_KEY_PATH="~/.ssh/id_ed25519"

alias preview="fzf --preview=\"bat --theme={} --color=always {}\""
alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
alias ls="colorls"

# add support for ctrl+o to open selected file in VS Code
export FZF_DEFAULT_OPTS="--bind='ctrl-o:execute(code {})+abort'"

## POWERLEVEL9K SETTINGS ##
POWERLEVEL9K_VCS_STAGED_ICON='\u00b1'
POWERLEVEL9K_VCS_UNTRACKED_ICON='\u25CF'
POWERLEVEL9K_VCS_UNSTAGED_ICON='\u00b1'
POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='\u2193'
POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='\u2191'
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='yellow'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='yellow'
POWERLEVEL9K_STATUS_OK_BACKGROUND="black"
POWERLEVEL9K_STATUS_OK_FOREGROUND="green"
POWERLEVEL9K_STATUS_ERROR_BACKGROUND="black"
POWERLEVEL9K_STATUS_ERROR_FOREGROUND="red"
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="\n"
POWERLEVEL9K_STATUS_VERBOSE=false
POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE=true
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_MULTILINE_SECOND_PROMPT_PREFIX=""
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(root_indicator dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(time)
POWERLEVEL9K_OS_ICON_BACKGROUND="white"
POWERLEVEL9K_OS_ICON_FOREGROUND="white"
POWERLEVEL9K_DIR_HOME_FOREGROUND="white"
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND="white"
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND="white"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if [ /usr/local/bin/kubectl ]; then source <(kubectl completion zsh); fi

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=23'

# Set prompt to use kube_ps1
PROMPT=$PROMPT'$(kube_ps1) '

[[ -s /home/philipp/.autojump/etc/profile.d/autojump.sh ]] && source /home/philipp/.autojump/etc/profile.d/autojump.sh
autoload -Uz compinit && compinit -u
autoload -Uz compdef

fpath=( ~/.zfunc "${fpath[@]}" )
autoload -Uz gpaexport PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

j() {
    local preview_cmd="ls {2..}"
    if command -v exa &> /dev/null; then
        preview_cmd="exa -l {2}"
    fi

    if [[ $# -eq 0 ]]; then
                 cd "$(autojump -s | sort -k1gr | awk -F : '$1 ~ /[0-9]/ && $2 ~ /^\s*\// {print $1 $2}' | fzf --height 40% --reverse --inline-info --preview "$preview_cmd" --preview-window down:50% | cut -d$'\t' -f2- | sed 's/^\s*//')"
    else
        cd $(autojump $@)
    fi
}

# CTRL-/ to toggle small preview window to see the full command
# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

source /usr/share/doc/fzf/examples/completion.zsh