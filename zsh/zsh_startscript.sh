#!/usr/bin/env bash
#
# zsh bootstrapper -- built for Ubuntu.
#
# Installs zsh, eza, fzf, vivid and bat, drops this repo's .zshrc into the
# target user's home and clones the plugins into ~/.zsh_scripts.
# Running it twice is safe: your plugins are not touched.

set -euo pipefail

CONFIG_REPO="${CONFIG_REPO:-KARTOFF8xE/configs}"
CONFIG_REF="${CONFIG_REF:-main}"
RAW_BASE="https://raw.githubusercontent.com/${CONFIG_REPO}/${CONFIG_REF}/zsh"

log()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mfail:\033[0m %s\n' "$*" >&2; exit 1; }

# <url>|<path below ~/.zsh_scripts>
PLUGINS=(
    "https://github.com/jimmijj/chromatic-zsh.git|chromatic-zsh"
    "https://github.com/zsh-users/zsh-autosuggestions.git|plugins/zsh-autosuggestions"
    "https://github.com/zsh-users/zsh-syntax-highlighting.git|plugins/zsh-syntax-highlighting"
    "https://github.com/fdellwing/zsh-bat.git|plugins/zsh-bat"
    "https://github.com/MichaelAquilina/zsh-you-should-use.git|plugins/zsh-you-should-use"
    "https://github.com/agkozak/zsh-z.git|plugins/zsh-z"
)

# who are we installing for?
USER_NAME="${1:-${SUDO_USER:-${USER:-root}}}"
if [ "$EUID" -ne 0 ]; then
    exec sudo -- "$0" "$USER_NAME"
fi
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
[ -n "$USER_HOME" ] || die "no such user: ${USER_NAME}"
export HOME="$USER_HOME"
USER_GROUP="$(id -gn "$USER_NAME")"
OWNER="$USER_NAME:$USER_GROUP"

# install a file from this repo into the user's home
fetch_config() {
    local name="$1" dest="$2" tmp backup
    tmp="$(mktemp)"
    log "fetching ${name}"
    curl -fsSL "${RAW_BASE}/${name}" -o "$tmp" || die "could not download ${name} from ${CONFIG_REPO}@${CONFIG_REF}"
    if [ -e "$dest" ] && ! cmp -s "$tmp" "$dest"; then
        backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
        cp -a "$dest" "$backup"
        chown "$OWNER" "$backup"
        log "backed up the old $(basename "$dest")"
    fi
    install -o "$USER_NAME" -g "$USER_GROUP" -m 644 "$tmp" "$dest"
}

# --- packages --------------------------------------------------------------

command -v apt-get >/dev/null 2>&1 || die "this script is built for Ubuntu (no apt-get here)"

log "installing zsh, git, curl, fzf, bat"
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    zsh git curl ca-certificates fzf bat

# the pretty ones, if this Ubuntu knows them
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends eza vivid \
    || warn "eza and/or vivid are missing from your apt, try Ubuntu 24.04 or newer"

# Ubuntu ships the binary as "batcat", the zsh-bat plugin wants a plain "bat"
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    ln -sf "$(command -v batcat)" /usr/local/bin/bat
fi

# --- config files ----------------------------------------------------------

mkdir -p "$USER_HOME/.zsh_scripts/plugins" "$USER_HOME/.cache/zsh"
chown "$OWNER" "$USER_HOME/.zsh_scripts" "$USER_HOME/.zsh_scripts/plugins" \
    "$USER_HOME/.cache" "$USER_HOME/.cache/zsh"

fetch_config ".zshrc" "$USER_HOME/.zshrc"
fetch_config "git.aliases-only.zsh" "$USER_HOME/.zsh_scripts/plugins/git.aliases-only.zsh"

# --- plugins ---------------------------------------------------------------

log "cloning plugins into ~/.zsh_scripts"
for entry in "${PLUGINS[@]}"; do
    dir="$USER_HOME/.zsh_scripts/${entry##*|}"
    if [ -d "$dir/.git" ]; then
        log "already there: ${entry##*|}"
    elif [ -e "$dir" ]; then
        warn "${entry##*|} exists but is not a git clone, skipping it"
    else
        git clone --depth 1 --quiet "${entry%%|*}" "$dir" || warn "could not clone ${entry%%|*}"
    fi
done
chown -R "$OWNER" "$USER_HOME/.zsh_scripts"

# --- history ---------------------------------------------------------------

[ -e "$USER_HOME/.cache/zsh/history" ] \
    || install -o "$USER_NAME" -g "$USER_GROUP" -m 600 /dev/null "$USER_HOME/.cache/zsh/history"

# --- login shell -----------------------------------------------------------

if [ "$(getent passwd "$USER_NAME" | cut -d: -f7)" = "$(command -v zsh)" ]; then
    log "${USER_NAME} already logs into zsh"
else
    log "making zsh the login shell of ${USER_NAME}"
    chsh -s "$(command -v zsh)" "$USER_NAME" || usermod -s "$(command -v zsh)" "$USER_NAME"
fi

# --- done ------------------------------------------------------------------

runuser -u "$USER_NAME" -- zsh -n "$USER_HOME/.zshrc" \
    && log ".zshrc looks valid" \
    || warn ".zshrc has syntax errors, check it by hand"

cat <<EOF

  Done. Log out and back in (or run 'exec zsh') and enjoy the new shell.

  Your old ~/.zshrc, if there was one, is now ~/.zshrc.bak.<timestamp>.
  The plugins are yours: update them with 'git -C ~/.zsh_scripts/<plugin> pull'.
EOF
