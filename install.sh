#!/usr/bin/env bash
# dotswap installer — clone the rice profiles + tools onto a fresh machine.
# Usage: curl -fsSL https://raw.githubusercontent.com/OckoTajny/dotfiles/installer/install.sh | bash
set -euo pipefail

REPO="https://github.com/OckoTajny/dotfiles.git"
SRC_BASE="$HOME/.local/share"
BIN="$HOME/.local/bin"

PROFILES=(ambxst illogical win11 caelestia)
declare -A BRANCH=( [ambxst]=ambxst [illogical]=main [win11]=win11 [caelestia]=caelestia )
DEFAULT_PROFILE=ambxst

# --- colors (disabled when not a tty or NO_COLOR set) ------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  B=$'\033[1m'; DIM=$'\033[2m'; R=$'\033[0m'
  RED=$'\033[38;5;203m'; GRN=$'\033[38;5;114m'; YEL=$'\033[38;5;221m'
  BLU=$'\033[38;5;75m'; MAG=$'\033[38;5;176m'; CYN=$'\033[38;5;81m'
else
  B=; DIM=; R=; RED=; GRN=; YEL=; BLU=; MAG=; CYN=
fi

banner() {
  printf '%s\n' "${MAG}${B}"
  cat <<'EOF'
   ╔══════════════════════════════════════════╗
   ║   d o t s w a p   ·   installer           ║
   ║   four Hyprland rices, one keypress       ║
   ╚══════════════════════════════════════════╝
EOF
  printf '%s' "$R"
}

step=0
say()  { step=$((step+1)); printf '\n%s[%s%d%s/%s5%s]%s %s%s%s\n' \
          "$DIM" "$CYN" "$step" "$DIM" "$DIM" "$DIM" "$R" "$B" "$1" "$R"; }
ok()   { printf '   %s✓%s %s\n' "$GRN" "$R" "$1"; }
warn() { printf '   %s⚠%s  %s\n' "$YEL" "$R" "$1"; }
err()  { printf '   %s✗%s %s\n' "$RED" "$R" "$1"; }
run()  { printf '   %s$ %s%s\n' "$DIM" "$1" "$R"; }
need() { command -v "$1" >/dev/null 2>&1; }

banner

# 1. base tooling --------------------------------------------------------------
say "Checking base tools"
need git     || sudo pacman -S --needed --noconfirm git
need chezmoi || sudo pacman -S --needed --noconfirm chezmoi
if need yay; then
  ok "yay present"
else
  warn "yay missing — bootstrapping AUR helper"
  sudo pacman -S --needed --noconfirm base-devel git
  tmp=$(mktemp -d); git clone https://aur.archlinux.org/yay.git "$tmp/yay"
  ( cd "$tmp/yay" && makepkg -si --noconfirm )
fi
ok "git, chezmoi, yay ready"

# 2. dependencies --------------------------------------------------------------
# Glue set only — the three shells own their full dep trees via their upstream
# installers (see README): Ambxst, illogical-impulse, caelestia.
say "Installing core dependencies"
run "pacman -S hyprland foot fish mako btop fastfetch fuzzel …"
sudo pacman -S --needed --noconfirm \
  hyprland foot fish mako btop fastfetch fuzzel hypridle hyprlock \
  wl-clipboard slurp grim swappy cliphist dart-sass dconf hyprpicker brightnessctl
ok "core packages installed"

printf '   %sInstalling caelestia shell stack from AUR…%s\n' "$DIM" "$R"
if yay -S --needed --noconfirm quickshell-git caelestia-cli caelestia-shell; then
  ok "caelestia shell stack installed"
else
  warn "AUR deps failed — caelestia profile may not start until installed manually"
fi

# 3. clone profile sources (one branch each) ----------------------------------
say "Cloning rice profiles"
for p in "${PROFILES[@]}"; do
  dst="$SRC_BASE/chezmoi-$p"
  if [ -d "$dst/.git" ]; then
    printf '   %s↻%s %s%-10s%s updating\n' "$BLU" "$R" "$B" "$p" "$R"
    git -C "$dst" pull --ff-only >/dev/null 2>&1 || true
  else
    printf '   %s⬇%s %s%-10s%s ← %s%s%s\n' "$GRN" "$R" "$B" "$p" "$R" "$DIM" "${BRANCH[$p]}" "$R"
    git clone --quiet --branch "${BRANCH[$p]}" "$REPO" "$dst"
  fi
done
ok "4 profiles ready in ~/.local/share/chezmoi-*"

# 4. install the dotswap tools -------------------------------------------------
say "Installing dotswap tools + finishing up"
mkdir -p "$BIN"
self_dir=$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)
if [ -d "$self_dir/bin" ]; then
  install -Dm755 "$self_dir/bin/"dotswap* "$BIN/"
else
  for t in dotswap dotswap-cycle dotswap-postapply; do
    curl -fsSL "https://raw.githubusercontent.com/OckoTajny/dotfiles/installer/bin/$t" -o "$BIN/$t"
    chmod +x "$BIN/$t"
  done
fi
ok "dotswap, dotswap-cycle, dotswap-postapply → $BIN"

# 5. PATH + apply default profile ---------------------------------------------
case ":$PATH:" in
  *":$BIN:"*) ;;
  *) grep -q "$BIN" "$HOME/.profile" 2>/dev/null || \
       echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
     warn "added $BIN to ~/.profile — re-login or: source ~/.profile" ;;
esac
"$BIN/dotswap" use "$DEFAULT_PROFILE"
ok "applied default profile: ${B}${DEFAULT_PROFILE}${R}"

printf '\n%s%s✓ done.%s cycle rices with %sCtrl+Shift+Super+Left/Right%s — or %sdotswap use <profile>%s\n\n' \
  "$GRN" "$B" "$R" "$B" "$R" "$B" "$R"
