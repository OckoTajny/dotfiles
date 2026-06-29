#!/usr/bin/env bash
# dotswap installer — clone the rice profiles + tools onto a fresh machine.
# Usage: curl -fsSL https://raw.githubusercontent.com/OckoTajny/dotfiles/installer/install.sh | bash
#
# Resilient by design: a failing package or step is reported and skipped, the
# run keeps going, and a summary of what failed is printed at the end.
set -uo pipefail   # NOTE: no `-e` — we never want one error to abort the whole install.

REPO="https://github.com/OckoTajny/dotfiles.git"
SRC_BASE="$HOME/.local/share"
BIN="$HOME/.local/bin"

PROFILES=(ambxst illogical win11 caelestia)
declare -A BRANCH=( [ambxst]=ambxst [illogical]=main [win11]=win11 [caelestia]=caelestia )
DEFAULT_PROFILE=ambxst

CORE_PKGS=(hyprland foot fish mako btop fastfetch fuzzel hypridle hyprlock
  wl-clipboard slurp grim swappy cliphist dart-sass dconf hyprpicker brightnessctl jq)
AUR_PKGS=(quickshell-git caelestia-cli caelestia-shell)
# Desktop apps the keybinds launch — so every bind works out of the box.
# (yay handles both repo and AUR; brave-bin/spotify are AUR on plain Arch.)
APP_PKGS=(kitty nautilus discord brave-bin spotify)

FAILS=()

# --- colors (disabled when not a tty or NO_COLOR set) ------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  B=$'\033[1m'; DIM=$'\033[2m'; R=$'\033[0m'
  RED=$'\033[38;5;203m'; GRN=$'\033[38;5;114m'; YEL=$'\033[38;5;221m'
  BLU=$'\033[38;5;75m'; MAG=$'\033[38;5;176m'; CYN=$'\033[38;5;81m'
else
  B=; DIM=; R=; RED=; GRN=; YEL=; BLU=; MAG=; CYN=
fi

banner() {
  printf '%s' "${MAG}${B}"
  cat <<'EOF'

   ╔══════════════════════════════════════════╗
   ║   d o t s w a p   ·   installer           ║
   ║   four Hyprland rices, one keypress       ║
   ╚══════════════════════════════════════════╝
EOF
  printf '%s' "$R"
}

step=0
say()  { step=$((step+1)); printf '\n%s[%s%d%s/5]%s %s%s%s\n' \
          "$DIM" "$CYN" "$step" "$DIM" "$R" "$B" "$1" "$R"; }
ok()   { printf '   %s✓%s %s\n' "$GRN" "$R" "$1"; }
warn() { printf '   %s⚠%s  %s\n' "$YEL" "$R" "$1"; }
err()  { printf '   %s✗%s %s\n' "$RED" "$R" "$1"; }
fail() { err "$1"; FAILS+=("$1"); }            # record + keep going
need() { command -v "$1" >/dev/null 2>&1; }
have() { pacman -Qq "$1" >/dev/null 2>&1; }    # already installed?

banner

# 1. base tooling --------------------------------------------------------------
say "Checking base tools"
# clear a stale pacman lock (only if no pacman is actually running)
if [ -f /var/lib/pacman/db.lck ] && ! pgrep -x pacman >/dev/null 2>&1; then
  warn "stale pacman lock — removing /var/lib/pacman/db.lck"
  sudo rm -f /var/lib/pacman/db.lck || true
fi
# refresh package databases (fixes 'unrecognized archive format' / unsynced db)
if ! sudo pacman -Syy --noconfirm; then
  warn "couldn't refresh pacman db (mirror down?) — run 'sudo pacman -Syy' and retry"
fi
need git     || sudo pacman -S --needed --noconfirm git     || fail "install git"
need chezmoi || sudo pacman -S --needed --noconfirm chezmoi || fail "install chezmoi"
if need yay; then
  ok "yay present"
elif need git; then
  warn "yay missing — bootstrapping AUR helper"
  sudo pacman -S --needed --noconfirm base-devel git || fail "base-devel for yay"
  tmp=$(mktemp -d)
  if git clone https://aur.archlinux.org/yay.git "$tmp/yay" && ( cd "$tmp/yay" && makepkg -si --noconfirm ); then
    ok "yay installed"
  else
    fail "bootstrap yay"
  fi
fi
need git && need chezmoi && ok "base tools ready" || warn "base tools incomplete — see summary"

# 2. dependencies (per-package so one bad pkg doesn't sink the rest) -----------
say "Installing packages & apps"
for p in "${CORE_PKGS[@]}"; do
  if have "$p"; then printf '   %s✓%s %s\n' "$GRN" "$R" "$p"; continue; fi
  sudo pacman -S --needed --noconfirm "$p" >/dev/null 2>&1 \
    && printf '   %s✓%s %s\n' "$GRN" "$R" "$p" \
    || { printf '   %s✗%s %s\n' "$RED" "$R" "$p"; FAILS+=("pkg: $p"); }
done
if need yay; then
  printf '   %sAUR (caelestia shell stack)…%s\n' "$DIM" "$R"
  for p in "${AUR_PKGS[@]}"; do
    if have "$p"; then printf '   %s✓%s %s (installed)\n' "$GRN" "$R" "$p"; continue; fi
    yay -S --needed --noconfirm "$p" >/dev/null 2>&1 \
      && printf '   %s✓%s %s\n' "$GRN" "$R" "$p" \
      || { printf '   %s⚠%s  %s (AUR)\n' "$YEL" "$R" "$p"; FAILS+=("aur: $p"); }
  done
else
  warn "no yay — skipping caelestia shell stack (install quickshell-git, caelestia-cli, caelestia-shell later)"
fi

# desktop apps the keybinds launch (kitty, discord, spotify, brave, files…)
printf '   %sApps (keybind targets)…%s\n' "$DIM" "$R"
for p in "${APP_PKGS[@]}"; do
  if have "$p"; then printf '   %s✓%s %s\n' "$GRN" "$R" "$p"; continue; fi
  if need yay; then yay -S --needed --noconfirm "$p" >/dev/null 2>&1; else sudo pacman -S --needed --noconfirm "$p" >/dev/null 2>&1; fi \
    && printf '   %s✓%s %s\n' "$GRN" "$R" "$p" \
    || { printf '   %s⚠%s  %s\n' "$YEL" "$R" "$p"; FAILS+=("app: $p"); }
done

# brrtfetch — the purple-glitch fastfetch bound to Super+Return (custom Go build)
if need brrtfetch; then
  ok "brrtfetch present"
else
  sudo pacman -S --needed --noconfirm go expect >/dev/null 2>&1 || true
  [ -d "$HOME/brrtfetch/.git" ] || git clone --quiet https://github.com/ferrebarrat/brrtfetch "$HOME/brrtfetch" >/dev/null 2>&1
  if need go && ( cd "$HOME/brrtfetch" && go build -o ./bin/brrtfetch ./go/main.go ) >/dev/null 2>&1 \
     && sudo install -m755 "$HOME/brrtfetch/bin/brrtfetch" /usr/local/bin/brrtfetch >/dev/null 2>&1; then
    ok "brrtfetch built → /usr/local/bin (gifs in ~/brrtfetch)"
  else
    fail "brrtfetch (needs go; clone ferrebarrat/brrtfetch + 'go build')"
  fi
fi

# 3. clone profile sources (one branch each) ----------------------------------
say "Cloning rice profiles"
for p in "${PROFILES[@]}"; do
  dst="$SRC_BASE/chezmoi-$p"
  if [ -d "$dst/.git" ]; then
    printf '   %s↻%s %-10s updating\n' "$BLU" "$R" "$p"
    git -C "$dst" pull --ff-only >/dev/null 2>&1 || warn "$p: pull failed (local changes?)"
  elif git clone --quiet --branch "${BRANCH[$p]}" "$REPO" "$dst"; then
    printf '   %s⬇%s %-10s ← %s%s%s\n' "$GRN" "$R" "$p" "$DIM" "${BRANCH[$p]}" "$R"
  else
    fail "clone $p (branch ${BRANCH[$p]})"
  fi
done

# 4. install the dotswap tools -------------------------------------------------
say "Installing dotswap tools"
mkdir -p "$BIN"
self_dir=$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")
if [ -n "$self_dir" ] && [ -d "$self_dir/bin" ]; then
  install -Dm755 "$self_dir/bin/"dotswap* "$BIN/" && ok "tools installed → $BIN" || fail "install tools"
else
  okcount=0
  for t in dotswap dotswap-cycle dotswap-postapply; do
    if curl -fsSL "https://raw.githubusercontent.com/OckoTajny/dotfiles/installer/bin/$t" -o "$BIN/$t"; then
      chmod +x "$BIN/$t"; okcount=$((okcount+1))
    fi
  done
  [ "$okcount" -eq 3 ] && ok "tools installed → $BIN" || fail "download dotswap tools ($okcount/3)"
fi

# 5. PATH + apply default profile ---------------------------------------------
say "Finishing up"
case ":$PATH:" in
  *":$BIN:"*) ;;
  *) grep -q "$BIN" "$HOME/.profile" 2>/dev/null || \
       echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
     warn "added $BIN to ~/.profile — re-login or: source ~/.profile" ;;
esac
if [ -x "$BIN/dotswap" ] && [ -d "$SRC_BASE/chezmoi-$DEFAULT_PROFILE" ]; then
  "$BIN/dotswap" use "$DEFAULT_PROFILE" && ok "applied default profile: ${B}${DEFAULT_PROFILE}${R}" \
    || fail "apply profile $DEFAULT_PROFILE"
else
  warn "skipping 'dotswap use $DEFAULT_PROFILE' (tool or profile missing)"
fi

# --- summary ------------------------------------------------------------------
echo
if [ "${#FAILS[@]}" -eq 0 ]; then
  printf '%s%s✓ all done.%s cycle rices with %sCtrl+Shift+Super+Left/Right%s, or %sdotswap use <profile>%s\n\n' \
    "$GRN" "$B" "$R" "$B" "$R" "$B" "$R"
else
  printf '%s%s⚠ finished with %d issue(s):%s\n' "$YEL" "$B" "${#FAILS[@]}" "$R"
  for f in "${FAILS[@]}"; do printf '   %s•%s %s\n' "$YEL" "$R" "$f"; done
  printf '   %sFix the above (often: bad mirror → %ssudo pacman -Syy%s%s) and re-run this script — it is safe to repeat.%s\n\n' \
    "$DIM" "$B" "$R" "$DIM" "$R"
fi
exit 0
