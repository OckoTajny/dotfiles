#!/usr/bin/env bash
# dotswap installer — clone the rice profiles + tools onto a fresh machine.
# Usage: curl -fsSL https://raw.githubusercontent.com/OckoTajny/dotfiles/installer/install.sh | bash
set -euo pipefail

REPO="https://github.com/OckoTajny/dotfiles.git"
SRC_BASE="$HOME/.local/share"
BIN="$HOME/.local/bin"

# profile -> branch
PROFILES=(ambxst illogical win11 caelestia)
declare -A BRANCH=( [ambxst]=ambxst [illogical]=main [win11]=win11 [caelestia]=caelestia )
DEFAULT_PROFILE=ambxst

say() { printf '\033[1;36m::\033[0m %s\n' "$*"; }

need() { command -v "$1" >/dev/null 2>&1; }

# 1. base tooling --------------------------------------------------------------
say "checking base tools"
need git || sudo pacman -S --needed --noconfirm git
need chezmoi || sudo pacman -S --needed --noconfirm chezmoi
if ! need yay; then
  say "bootstrapping yay (AUR helper)"
  sudo pacman -S --needed --noconfirm base-devel git
  tmp=$(mktemp -d); git clone https://aur.archlinux.org/yay.git "$tmp/yay"
  ( cd "$tmp/yay" && makepkg -si --noconfirm )
fi

# 2. dependencies --------------------------------------------------------------
# Glue set only. The three shells own their full dep trees via their upstream
# installers (see README): Ambxst, illogical-impulse (end-4/dots-hyprland), caelestia.
say "installing core deps"
sudo pacman -S --needed --noconfirm \
  hyprland foot fish mako btop fastfetch fuzzel hypridle hyprlock \
  wl-clipboard slurp grim swappy cliphist dart-sass dconf hyprpicker brightnessctl

say "installing AUR deps (caelestia shell stack)"
yay -S --needed --noconfirm quickshell-git caelestia-cli caelestia-shell || \
  say "WARN: AUR deps failed — caelestia profile may not start until installed manually"

# 3. clone profile sources (one branch each) ----------------------------------
for p in "${PROFILES[@]}"; do
  dst="$SRC_BASE/chezmoi-$p"
  if [ -d "$dst/.git" ]; then
    say "updating $p"; git -C "$dst" pull --ff-only || true
  else
    say "cloning $p (branch ${BRANCH[$p]})"
    git clone --branch "${BRANCH[$p]}" "$REPO" "$dst"
  fi
done

# 4. install the dotswap tools -------------------------------------------------
say "installing dotswap tools to $BIN"
mkdir -p "$BIN"
# this script lives in the installer branch alongside bin/; resolve its dir
self_dir=$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)
if [ -d "$self_dir/bin" ]; then
  install -Dm755 "$self_dir/bin/"dotswap* "$BIN/"
else
  # piped via curl: grab the tools from the installer branch
  for t in dotswap dotswap-cycle dotswap-postapply; do
    curl -fsSL "https://raw.githubusercontent.com/OckoTajny/dotfiles/installer/bin/$t" -o "$BIN/$t"
    chmod +x "$BIN/$t"
  done
fi

# 5. PATH (set in .profile; .zshrc historically had it commented) -------------
case ":$PATH:" in
  *":$BIN:"*) ;;
  *) grep -q "$BIN" "$HOME/.profile" 2>/dev/null || \
       echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
     say "added $BIN to ~/.profile (re-login or 'source ~/.profile')" ;;
esac

# 6. apply default profile -----------------------------------------------------
say "applying default profile: $DEFAULT_PROFILE"
"$BIN/dotswap" use "$DEFAULT_PROFILE"

say "done. cycle with Ctrl+Shift+Super+Left/Right, or: dotswap use <profile>"
