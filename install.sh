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

# MODE: install (default) writes configs; update only pulls in what's new
# (updated packages, new tools) and NEVER re-applies configs — so the user's
# ~/.config (keybinds, tweaks) is left untouched. doctor diagnoses a broken
# setup (session/process/config checks) without changing anything. uninstall
# removes what dotswap itself put down (tools, profile sources, state) —
# it does NOT touch installed packages, hyprland.conf, or Ambxst, since
# unwinding those safely on an arbitrary machine isn't something an
# unattended script should gamble on.
MODE=install
MODE_EXPLICIT=0
for a in "$@"; do
  case "$a" in
    --update|update|-u) MODE=update; MODE_EXPLICIT=1 ;;
    --doctor|doctor|--diagnose|diagnose) MODE=doctor; MODE_EXPLICIT=1 ;;
    --uninstall|uninstall) MODE=uninstall; MODE_EXPLICIT=1 ;;
    --help|-h)
      echo "Usage: install.sh [--update|--doctor|--uninstall]"
      echo "  (no flag)   asks interactively (install/update/doctor/uninstall) if run in a terminal"
      echo "  --update    pull new packages/tools, configs untouched"
      echo "  --doctor    diagnose a broken rice (session, processes, config) - read-only"
      echo "  --uninstall remove dotswap's own tools/profiles/state (not packages/configs)"
      exit 0 ;;
  esac
done

# No mode given on the command line: ask, rather than silently assuming a
# fresh install (this is also how a re-run picks up "did it actually work?").
# Uninstall is in the menu too, but run_uninstall() below still asks its
# own separate y/N before touching anything — picking "4" isn't enough
# by itself to delete anything.
if [ "$MODE_EXPLICIT" -eq 0 ] && [ -r /dev/tty ]; then
  printf 'What do you want to do?\n'
  printf '  1) Install (fresh setup)\n'
  printf '  2) Update (pull new packages/tools, configs untouched)\n'
  printf '  3) Doctor (diagnose a broken rice, read-only)\n'
  printf '  4) Uninstall (remove dotswap'\''s own tools/profiles/state)\n'
  printf 'Pick [1]: '
  choice=1
  IFS= read -r choice </dev/tty || choice=1
  case "$(printf '%s' "$choice" | tr -d '[:space:]')" in
    2) MODE=update ;;
    3) MODE=doctor ;;
    4) MODE=uninstall ;;
    *) MODE=install ;;
  esac
fi

CORE_PKGS=(hyprland foot fish mako btop fastfetch fuzzel hypridle hyprlock
  wl-clipboard slurp grim swappy cliphist dart-sass dconf hyprpicker brightnessctl jq
  # keybind targets: whisper-flow dictation, OCR, media, session menu, screenshots
  wtype uv pipewire pavucontrol playerctl wlogout hyprshot
  tesseract tesseract-data-eng tesseract-data-ces bc
  # zsh (default shell — the tracked .zshrc uses oh-my-zsh)
  zsh
  # neovim: the tracked ~/.config/nvim is LazyVim; it self-bootstraps on first
  # launch. node/npm let Mason install the LSP servers (pyright, ts, json, …).
  neovim nodejs npm
  # checkupdates — used by hypr custom update-check.sh startup script
  pacman-contrib)
# Required: the caelestia shell stack (the rices need it).
AUR_PKGS=(quickshell-git caelestia-cli caelestia-shell)
# Optional desktop apps the keybinds launch. The user picks which to install
# (all / a subset / none). "pkg|label" — label shown in the menu.
OPTIONAL_APPS=(
  "kitty|terminal"
  "nautilus|file manager"
  "zen-browser-bin|browser (Zen)"
  "discord|Discord"
  "spotify|Spotify"
  "whatsapp-linux-desktop|WhatsApp"
  "jetbrains-toolbox|JetBrains Toolbox (IntelliJ)"
  "onlyoffice-bin|OnlyOffice"
)

FAILS=()

# --- colors (disabled when not a tty or NO_COLOR set) ------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  B=$'\033[1m'; DIM=$'\033[2m'; R=$'\033[0m'
  RED=$'\033[38;5;203m'; GRN=$'\033[38;5;114m'; YEL=$'\033[38;5;221m'
  BLU=$'\033[38;5;75m'; MAG=$'\033[38;5;176m'; CYN=$'\033[38;5;81m'
else
  B=; DIM=; R=; RED=; GRN=; YEL=; BLU=; MAG=; CYN=
fi

# Centers $2 within a field of width $1, both sides padded so the box
# border always lines up regardless of text length (hand-counted spaces
# drifted out of sync before — this can't).
center() {
  local w=$1 s=$2 pad=$(( w - ${#2} )) l r
  l=$(( pad / 2 )); r=$(( pad - l ))
  printf '%*s%s%*s' "$l" "" "$s" "$r" ""
}

banner() {
  local w=40 bar title sub
  bar=$(printf '═%.0s' $(seq 1 "$w"))
  if [ "$MODE" = update ]; then
    title="d o t s w a p  ·  update"
    sub="new packages & tools · configs kept"
  else
    title="d o t s w a p  ·  installer"
    sub="four Hyprland rices, one keypress"
  fi
  printf '%s%s\n' "${MAG}${B}" ""
  printf '   ╔%s╗\n' "$bar"
  printf '   ║%s║\n' "$(center "$w" "$title")"
  printf '   ║%s║\n' "$(center "$w" "$sub")"
  printf '   ╚%s╝\n' "$bar"
  printf '%s' "$R"
}

step=0
say()  { step=$((step+1)); printf '\n%s[%s%d%s/6]%s %s%s%s\n' \
          "$DIM" "$CYN" "$step" "$DIM" "$R" "$B" "$1" "$R"; }
ok()   { printf '   %s✓%s %s\n' "$GRN" "$R" "$1"; }
warn() { printf '   %s⚠%s  %s\n' "$YEL" "$R" "$1"; }
err()  { printf '   %s✗%s %s\n' "$RED" "$R" "$1"; }
fail() { err "$1"; FAILS+=("$1"); }            # record + keep going
need() { command -v "$1" >/dev/null 2>&1; }
have() { pacman -Qq "$1" >/dev/null 2>&1; }    # already installed?

# Runs a long, otherwise-silent command with a spinner so it never looks
# frozen (AUR builds and full-system upgrades can take minutes with zero
# output). Sets SPIN_LOG to the captured output for the caller to inspect.
spin() {
  local label=$1; shift
  local logf; logf=$(mktemp)
  "$@" >"$logf" 2>&1 &
  local pid=$! frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏' i=0 start=$SECONDS
  while kill -0 "$pid" 2>/dev/null; do
    if [ -t 1 ]; then
      printf '\r   %s%s%s %s %s(%ds)%s' "$CYN" "${frames:i++%${#frames}:1}" "$R" "$label" "$DIM" "$((SECONDS-start))" "$R"
    fi
    sleep 0.15
  done
  wait "$pid"; local rc=$?
  [ -t 1 ] && printf '\r\033[K'
  SPIN_LOG=$logf
  return $rc
}

# --- doctor: read-only diagnosis of a broken rice, no changes made -----------
run_doctor() {
  printf '%s%sdotswap doctor%s — read-only, changes nothing\n\n' "$B" "$MAG" "$R"

  section() { printf '\n%s%s%s\n' "$B" "$1" "$R"; }

  section "Login sessions"
  if [ -d /usr/share/wayland-sessions ]; then
    grep -H '^Exec=' /usr/share/wayland-sessions/*.desktop 2>/dev/null \
      | sed 's/^/   /' || warn "no wayland-sessions found"
  else
    warn "/usr/share/wayland-sessions missing"
  fi
  printf '   current: XDG_CURRENT_DESKTOP=%s DESKTOP_SESSION=%s\n' \
    "${XDG_CURRENT_DESKTOP:-?}" "${DESKTOP_SESSION:-?}"

  section "dotswap profile"
  if [ -f "$HOME/.local/state/dotswap-profile" ]; then
    ok "active profile: $(cat "$HOME/.local/state/dotswap-profile")"
  else
    warn "no profile file at ~/.local/state/dotswap-profile — 'dotswap use <profile>' never ran"
  fi
  if [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
    ok "~/.config/hypr/hyprland.conf exists ($(wc -l < "$HOME/.config/hypr/hyprland.conf") lines)"
  else
    warn "~/.config/hypr/hyprland.conf missing"
  fi

  section "Ambxst"
  if need ambxst; then
    ok "ambxst binary present"
    [ -d "$HOME/.local/share/ambxst" ] && ok "~/.local/share/ambxst present" \
      || warn "~/.local/share/ambxst missing — run: ambxst install hyprland"
  else
    warn "ambxst not installed — run: curl -L get.axeni.de/ambxst | sh"
  fi

  section "Running shell/bar processes"
  local found=0
  for p in ambxst quickshell waybar; do
    if pgrep -fa "$p" >/dev/null 2>&1; then
      pgrep -fa "$p" | sed 's/^/   /'; found=1
    fi
  done
  [ "$found" -eq 1 ] || warn "none of ambxst/quickshell/waybar are running"

  section "systemd --user units (hypr/wayb/ambxst/cachy)"
  systemctl --user list-units --type=service --state=running 2>/dev/null \
    | grep -iE "wayb|hypr|cachy|ambxst" | sed 's/^/   /' \
    || warn "none found"

  echo
  printf '%sDone.%s Compare against: session should show plain Hyprland (not a\n' "$GRN" "$R"
  printf 'CachyOS-specific wrapper), profile should be set, ambxst/quickshell should\n'
  printf 'be running.\n\n'
  exit 0
}
[ "$MODE" = doctor ] && run_doctor

# --- uninstall: removes only what dotswap put down ----------------------------
run_uninstall() {
  printf '%s%sdotswap uninstall%s\n\n' "$B" "$MAG" "$R"
  echo "This removes:"
  echo "  - ~/.local/bin/{dotswap,dotswap-cycle,dotswap-postapply,whisper-flow,kb-toggle}"
  echo "  - ~/.local/share/chezmoi-{ambxst,illogical,win11,caelestia}"
  echo "  - ~/.local/state/dotswap-profile"
  echo
  echo "It does NOT remove: installed packages, ~/.config/hypr (your live config),"
  echo "Ambxst itself, or the SDDM theme — those are shared system state an"
  echo "unattended script shouldn't gamble on unwinding."
  echo
  local ans=no
  if [ -r /dev/tty ]; then
    printf 'Proceed? [y/N] '
    IFS= read -r ans </dev/tty || ans=no
  else
    warn "no terminal — refusing to uninstall non-interactively"
    exit 1
  fi
  case "$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]')" in
    y|yes) ;;
    *) echo "Aborted."; exit 0 ;;
  esac
  rm -f "$BIN/dotswap" "$BIN/dotswap-cycle" "$BIN/dotswap-postapply" "$BIN/whisper-flow" "$BIN/kb-toggle"
  ok "removed dotswap tools from $BIN"
  for p in "${PROFILES[@]}"; do
    rm -rf "${SRC_BASE:?}/chezmoi-$p"
  done
  ok "removed chezmoi profile sources"
  rm -f "$HOME/.local/state/dotswap-profile"
  ok "removed profile state file"
  echo
  printf '%sDone.%s ~/.config/hypr and installed packages were left untouched.\n\n' "$GRN" "$R"
  exit 0
}
[ "$MODE" = uninstall ] && run_uninstall

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
# update mode: upgrade what's already installed (the loops below then add any
# newly-introduced packages via the have-guard)
if [ "$MODE" = update ]; then
  if need yay; then
    spin "upgrading system & AUR packages…" yay -Syu --noconfirm && ok "system & AUR packages upgraded" \
      || warn "package upgrade hit issues — see summary / re-run"
  else
    spin "upgrading system packages…" sudo pacman -Syu --noconfirm && ok "system packages upgraded" \
      || warn "package upgrade hit issues"
  fi
fi
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
    spin "building $p (AUR)…" yay -S --needed --noconfirm "$p" \
      && printf '   %s✓%s %s\n' "$GRN" "$R" "$p" \
      || { printf '   %s⚠%s  %s (AUR, log: %s)\n' "$YEL" "$R" "$p" "$SPIN_LOG"; tail -n5 "$SPIN_LOG" | sed 's/^/       /'; FAILS+=("aur: $p ($SPIN_LOG)"); }
  done
else
  warn "no yay — skipping caelestia shell stack (install quickshell-git, caelestia-cli, caelestia-shell later)"
fi

# Ambxst shell (ambxst rice's bar/dock) — not a package, has its own installer.
# The tracked hyprland.conf already has `source = ~/.local/share/ambxst/hyprland.conf`,
# so without this, Hyprland loads fine but no bar/dock ever appears.
if need ambxst; then
  ok "Ambxst present"
elif [ -r /dev/tty ]; then
  # < /dev/tty: this script's own stdin is the curl|bash pipe (already
  # exhausted) — without a real tty attached, Ambxst's installer can't
  # read anything it needs to and silently no-ops.
  spin "installing Ambxst shell…" bash -c "curl -L get.axeni.de/ambxst | sh" < /dev/tty \
    && ok "Ambxst installed" \
    || { warn "Ambxst install failed (log: $SPIN_LOG) — install manually: curl -L get.axeni.de/ambxst | sh"; FAILS+=("ambxst: install ($SPIN_LOG)"); }
else
  warn "no terminal — install Ambxst manually: curl -L get.axeni.de/ambxst | sh"
fi
if need ambxst; then
  # Wires the hyprland.conf import (idempotent — matches what's already
  # tracked) and is what actually makes Ambxst autostart on future logins;
  # installing the binary alone was not enough on a real run.
  ambxst install hyprland >/dev/null 2>&1 || true
  ambxst & disown
  ok "Ambxst started (will autostart on future logins)"
fi

# optional desktop apps the keybinds launch — the user chooses which to install
printf '   %sApps (keybind targets) — optional%s\n' "$DIM" "$R"
n=${#OPTIONAL_APPS[@]}
i=1
for entry in "${OPTIONAL_APPS[@]}"; do
  printf '     %s%2d)%s %-24s %s%s%s\n' "$CYN" "$i" "$R" "${entry%%|*}" "$DIM" "${entry#*|}" "$R"
  i=$((i+1))
done
# read the choice from the real terminal (stdin is the piped script under curl|bash)
ans=all
if [ -r /dev/tty ]; then
  printf '   %sPick numbers (e.g. "1 3 5"), %sa%s%s=all, %sn%s%s=none [all]:%s ' \
    "$B" "$GRN" "$R" "$B" "$RED" "$R" "$B" "$R"
  IFS= read -r ans </dev/tty || ans=all
else
  warn "no terminal — installing all optional apps by default"
fi

chosen=()
case "$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')" in
  ""|a|all)  for e in "${OPTIONAL_APPS[@]}"; do chosen+=("${e%%|*}"); done ;;
  n|none)    warn "skipping optional apps" ;;
  *)         for tok in $ans; do
               case "$tok" in
                 (*[!0-9]*) warn "ignoring '$tok'" ;;
                 (*) if [ "$tok" -ge 1 ] && [ "$tok" -le "$n" ]; then
                       e="${OPTIONAL_APPS[$((tok-1))]}"; chosen+=("${e%%|*}")
                     else warn "ignoring out-of-range '$tok'"; fi ;;
               esac
             done ;;
esac

for p in "${chosen[@]}"; do
  if have "$p"; then printf '   %s✓%s %s\n' "$GRN" "$R" "$p"; continue; fi
  if need yay; then spin "installing $p…" yay -S --needed --noconfirm "$p"; else spin "installing $p…" sudo pacman -S --needed --noconfirm "$p"; fi \
    && { printf '   %s✓%s %s\n' "$GRN" "$R" "$p"; rm -f "$SPIN_LOG"; } \
    || { printf '   %s⚠%s  %s (log: %s)\n' "$YEL" "$R" "$p" "$SPIN_LOG"; tail -n5 "$SPIN_LOG" | sed 's/^/       /'; FAILS+=("app: $p ($SPIN_LOG)"); }
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

# zsh — the tracked .zshrc uses oh-my-zsh + zsh-autosuggestions + zsh-syntax-highlighting
printf '   %szsh (oh-my-zsh + plugins)…%s\n' "$DIM" "$R"
ZSH_DIR="$HOME/.oh-my-zsh"
if [ -d "$ZSH_DIR" ]; then
  ok "oh-my-zsh present"
elif need curl; then
  # --unattended: no shell change here (we do chsh below), don't overwrite .zshrc
  RUNZSH=no KEEP_ZSHRC=yes CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc >/dev/null 2>&1 \
    && ok "oh-my-zsh installed" || fail "oh-my-zsh install"
fi
for plug in zsh-autosuggestions zsh-syntax-highlighting; do
  dst="$ZSH_DIR/custom/plugins/$plug"
  if [ -d "$dst" ]; then printf '   %s✓%s %s\n' "$GRN" "$R" "$plug"; continue; fi
  git clone --quiet --depth 1 "https://github.com/zsh-users/$plug" "$dst" >/dev/null 2>&1 \
    && printf '   %s✓%s %s\n' "$GRN" "$R" "$plug" || { warn "clone $plug"; FAILS+=("plugin: $plug"); }
done
# make zsh the default login shell (sudo chsh avoids a password prompt)
if need zsh; then
  if [ "$(getent passwd "$USER" | cut -d: -f7)" = "$(command -v zsh)" ]; then
    ok "zsh already default shell"
  else
    sudo chsh -s "$(command -v zsh)" "$USER" >/dev/null 2>&1 \
      && ok "default shell → zsh (re-login to take effect)" \
      || warn "set zsh manually: chsh -s $(command -v zsh)"
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

# 4. install the dotswap tools + whisper-flow ---------------------------------
say "Installing dotswap tools"
mkdir -p "$BIN"
TOOLS=(dotswap dotswap-cycle dotswap-postapply whisper-flow kb-toggle)
self_dir=$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")
if [ -n "$self_dir" ] && [ -d "$self_dir/bin" ]; then
  install -Dm755 "$self_dir/bin/"* "$BIN/" && ok "tools installed → $BIN" || fail "install tools"
else
  okcount=0
  for t in "${TOOLS[@]}"; do
    if curl -fsSL "https://raw.githubusercontent.com/OckoTajny/dotfiles/installer/bin/$t" -o "$BIN/$t"; then
      chmod +x "$BIN/$t"; okcount=$((okcount+1))
    fi
  done
  [ "$okcount" -eq "${#TOOLS[@]}" ] && ok "tools installed → $BIN" \
    || fail "download dotswap tools ($okcount/${#TOOLS[@]})"
fi
# whisper-flow (Super+Y dictation) needs the transcription engine
if need uv; then
  if uv tool list 2>/dev/null | grep -q whisper-ctranslate2; then
    ok "whisper-ctranslate2 present"
  elif uv tool install whisper-ctranslate2 >/dev/null 2>&1; then
    ok "whisper-ctranslate2 installed (uv tool)"
  else
    warn "whisper-ctranslate2 (run 'uv tool install whisper-ctranslate2')"
  fi
else
  warn "uv missing — skipping whisper-ctranslate2 (dictation engine)"
fi

# 5. login screen theme (only if SDDM is the active display manager — no
#    bootloader/initramfs changes here, just an AUR package + a drop-in
#    config file, so it's safe to always attempt and easy to undo) ------------
if systemctl is-active --quiet sddm.service 2>/dev/null; then
  say "Login screen (SDDM theme)"
  if need yay; then
    spin "installing sddm-astronaut-theme…" yay -S --needed --noconfirm sddm-astronaut-theme \
      && ok "theme installed" \
      || warn "sddm-astronaut-theme (AUR, log: $SPIN_LOG) — pick a theme manually"
  fi
  if [ -d /usr/share/sddm/themes/sddm-astronaut-theme ]; then
    sudo mkdir -p /etc/sddm.conf.d
    if grep -rq "Current=sddm-astronaut-theme" /etc/sddm.conf.d/*.conf 2>/dev/null; then
      ok "SDDM theme already set"
    else
      printf '[Theme]\nCurrent=sddm-astronaut-theme\n' | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null \
        && ok "SDDM theme set → sddm-astronaut-theme (takes effect next login/reboot)" \
        || warn "couldn't write /etc/sddm.conf.d/theme.conf"
    fi
  fi
fi

# 6. PATH + apply default profile ---------------------------------------------
say "Finishing up"
case ":$PATH:" in
  *":$BIN:"*) ;;
  *) grep -q "$BIN" "$HOME/.profile" 2>/dev/null || \
       echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
     warn "added $BIN to ~/.profile — re-login or: source ~/.profile" ;;
esac
if [ "$MODE" = update ]; then
  ok "update mode — your ${B}~/.config${R} was left untouched (keybinds & tweaks kept)"
elif [ -x "$BIN/dotswap" ] && [ -d "$SRC_BASE/chezmoi-$DEFAULT_PROFILE" ]; then
  "$BIN/dotswap" use "$DEFAULT_PROFILE" && ok "applied default profile: ${B}${DEFAULT_PROFILE}${R}" \
    || fail "apply profile $DEFAULT_PROFILE"
else
  warn "skipping 'dotswap use $DEFAULT_PROFILE' (tool or profile missing)"
fi

# --- summary ------------------------------------------------------------------
echo
printf '%s%sreboot or re-login recommended%s — the default-shell change above only takes\n' "$YEL" "$B" "$R"
printf '  effect after that; %shyprctl reload%s (printed above) only refreshes the\n' "$B" "$R"
printf '  compositor for rice switches, not this first-time setup.\n\n'
if [ "${#FAILS[@]}" -eq 0 ]; then
  printf '%s%s✓ all done.%s cycle rices with %sCtrl+Shift+Super+Left/Right%s, or %sdotswap use <profile>%s\n\n' \
    "$GRN" "$B" "$R" "$B" "$R" "$B" "$R"
else
  printf '%s%s⚠ finished with %d issue(s):%s\n' "$YEL" "$B" "${#FAILS[@]}" "$R"
  for f in "${FAILS[@]}"; do printf '   %s•%s %s\n' "$YEL" "$R" "$f"; done
  printf '   %sFix the above (often: bad mirror → %ssudo pacman -Syy%s%s) and re-run this script — it is safe to repeat.%s\n\n' \
    "$DIM" "$B" "$R" "$DIM" "$R"
fi

if [ -r /dev/tty ]; then
  printf 'Reboot now? [y/N] '
  reboot_ans=no
  IFS= read -r reboot_ans </dev/tty || reboot_ans=no
  case "$(printf '%s' "$reboot_ans" | tr '[:upper:]' '[:lower:]')" in
    y|yes) systemctl reboot || sudo reboot ;;
  esac
fi
exit 0
