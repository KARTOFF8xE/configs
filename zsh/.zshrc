# Enable colors and change prompt:
autoload -U colors && colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zstyle ":completion:*" verbose yes
zmodload zsh/complist
compinit
_comp_options+=(globdots)        # Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
# bindkey -v '^?' backward-delete-char
bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey '^ ' autosuggest-accept
bindkey -M viins '^[.' insert-last-word
# bindkey -M emacs '^[.' insert-last-word
bindkey -M viins '^A' beginning-of-line
# bindkey -M emacs '^A' beginning-of-line
bindkey -M viins '^[[1;5D' vi-backward-word
# bindkey -M emacs '^[[1;5D' backward-word
bindkey -M viins '^[[1;5C' vi-forward-word
# bindkey -M emacs '^[[1;5C' forward-word
bindkey -M viins '^[[1;3C' vi-forward-word
# bindkey -M emacs '^[[1;3C' forward-word
bindkey -M viins '^[[5D' vi-backward-word
# bindkey -M emacs '^[[5D' backward-word
bindkey -M viins '^[[5C' vi-forward-word
# bindkey -M emacs '^[[5C' forward-word
bindkey -M viins '^[f' vi-forward-word
# bindkey -M emacs '^[f' forward-word
# Ctrl+Delete: delete word to the right; avoid accidental switch to insert/overwrite mode.
bindkey -M viins '^[[3;5~' kill-word
# bindkey -M emacs '^[[3;5~' kill-word
bindkey -M vicmd '^[[3;5~' kill-word
bindkey -M viins '^[[2;5~' kill-word
# bindkey -M emacs '^[[2;5~' kill-word
bindkey -M vicmd '^[[2;5~' kill-word
bindkey -M viins '^[[2~' kill-word
# bindkey -M emacs '^[[2~' kill-word
bindkey -M vicmd '^[[2~' kill-word

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Ctrl+E: jump to end of line.
bindkey -M viins '^E' end-of-line
bindkey -M emacs '^E' end-of-line

if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors)"
  alias ls="eza --color=always --group-directories-first"
  alias dir="dir --color=auto"
  alias vdir="vdir --color=auto"
  alias grep="grep --color=auto"
  alias fgrep="fgrep --color=auto"
  alias egrep="egrep --color=auto"
fi

autoload -U compinit && compinit
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select

alias ll='ls -alF'
alias tree='eza --tree'
alias oc='opencode'

# plugins -- all of these are cloned into ~/.zsh_scripts by zsh_startscript.sh
ZSH_SCRIPTS="$HOME/.zsh_scripts"
[[ -r "$ZSH_SCRIPTS/chromatic-zsh/chromatic-zsh.zsh" ]] && source "$ZSH_SCRIPTS/chromatic-zsh/chromatic-zsh.zsh"
[[ -r "$ZSH_SCRIPTS/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$ZSH_SCRIPTS/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -r "$ZSH_SCRIPTS/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$ZSH_SCRIPTS/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ -r "$ZSH_SCRIPTS/plugins/zsh-bat/zsh-bat.plugin.zsh" ]] && source "$ZSH_SCRIPTS/plugins/zsh-bat/zsh-bat.plugin.zsh"
[[ -r "$ZSH_SCRIPTS/plugins/zsh-you-should-use/you-should-use.plugin.zsh" ]] && source "$ZSH_SCRIPTS/plugins/zsh-you-should-use/you-should-use.plugin.zsh"
[[ -r "$ZSH_SCRIPTS/plugins/git.aliases-only.zsh" ]] && source "$ZSH_SCRIPTS/plugins/git.aliases-only.zsh"
[[ -r "$ZSH_SCRIPTS/plugins/zsh-z/zsh-z.plugin.zsh" ]] && source "$ZSH_SCRIPTS/plugins/zsh-z/zsh-z.plugin.zsh"
if (( $+commands[vivid] )); then
  export LS_COLORS="$(vivid -m 8-bit generate snazzy)"
fi

export HISTFILE="$HOME/.cache/zsh/history"
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

export PATH=$PATH:/usr/local/go/bin

export KUBE_EDITOR="nano"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# fzf -- only useful with a line editor, and fzf's integration files complain
# loudly (and fail) when they are loaded without a terminal
if [ -t 0 ]; then
  fzf_dir=''
  for dir in "$HOME/.zsh_scripts/fzf" /usr/share/fzf /usr/lib/fzf /usr/share/doc/fzf/examples "$HOME/.fzf"; do
    if [[ -r $dir/key-bindings.zsh || -r $dir/completion.zsh ]]; then
      fzf_dir=$dir
      break
    fi
  done
  if [[ -n $fzf_dir ]]; then
    [[ -r $fzf_dir/completion.zsh ]] && source "$fzf_dir/completion.zsh"
    if fzf --zsh >/dev/null 2>&1; then
      eval "$(fzf --zsh)"          # fzf >= 0.48 wires itself up
    elif [[ -r $fzf_dir/key-bindings.zsh ]]; then
      source "$fzf_dir/key-bindings.zsh"
    fi
  fi
  unset fzf_dir
fi
