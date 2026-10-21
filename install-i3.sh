#!/usr/bin/env bash
# Hyper Terminal i3 installer: just the i3 (X11) session from OckoTajny/dotfiles.
# No Hyprland, no niri, no dotswap. Arch Linux (and Arch based, e.g. CachyOS).
#
#   curl -fsSL solta.tech/install/i3 | bash
#   curl -fsSL solta.tech/install/i3 | bash -s -- --battery-alert
#
# Safe to re-run: packages are --needed, configs are re-applied (the previous
# ones are backed up first). A failing step is reported and skipped, and the
# summary at the end lists what went wrong.
set -uo pipefail   # no -e on purpose: one failure must not abort the rest

REPO="https://github.com/OckoTajny/dotfiles.git"
BRANCH=niri   # every profile branch carries the i3 session; niri is the one kept current
SRC="$HOME/.local/share/i3-dotfiles"
ALERT_FLAG="$HOME/.local/state/i3-battery-alert"
# what the session reads; nothing else in $HOME is touched
TARGETS=(.config/i3 .config/kitty .config/nvim .config/btop .config/fastfetch
  .config/lazygit .config/touchegg .zshrc)

PKGS=(
  # session
  i3-wm i3status i3lock xss-lock xorg-server xorg-xinit xorg-xinput xorg-xrandr xorg-setxkbmap
  picom dunst rofi feh xcape touchegg network-manager-applet
  # Fn keys, screenshots, bar
  pipewire pipewire-pulse wireplumber pavucontrol playerctl brightnessctl maim xclip
  arandr jq bc intel-gpu-tools
  # terminal + tools the binds open
  kitty btop fastfetch lazygit neovim nodejs npm git chezmoi zsh go
  ttf-jetbrains-mono-nerd
)
# optional apps the binds launch: "pkg|what for"
APPS=(
  "zen-browser-bin|browser (Super+W)"
  "nautilus|files (Super+E)"
  "discord|Discord (Copilot key)"
  "spotify|Spotify (Ctrl+Copilot key)"
  "jetbrains-toolbox|IntelliJ IDEA via Toolbox (Super+I)"
)

BATTERY_ALERT=0
for a in "$@"; do
  case "$a" in
    --battery-alert) BATTERY_ALERT=1 ;;
    -h|--help)
      echo "Usage: install-i3.sh [--battery-alert]"
      echo "  --battery-alert  fullscreen blinking low-battery alert instead of a notification"
      exit 0 ;;
  esac
done

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  B=$'\033[1m'; DIM=$'\033[2m'; R=$'\033[0m'
  RED=$'\033[38;5;203m'; GRN=$'\033[38;5;114m'; YEL=$'\033[38;5;221m'; PNK=$'\033[38;5;204m'
else
  B=; DIM=; R=; RED=; GRN=; YEL=; PNK=
fi
FAILS=()
STEPS=6
step=0
say()  { step=$((step+1)); printf '\n%s[%d/%d]%s %s%s%s\n' "$DIM" "$step" "$STEPS" "$R" "$B" "$1" "$R"; }
ok()   { printf '   %s✓%s %s\n' "$GRN" "$R" "$1"; }
warn() { printf '   %s!%s %s\n' "$YEL" "$R" "$1"; }
fail() { printf '   %s✗%s %s\n' "$RED" "$R" "$1"; FAILS+=("$1"); }
need() { command -v "$1" >/dev/null 2>&1; }
have() { pacman -T "$1" >/dev/null 2>&1; }
# a real open, not `[ -r /dev/tty ]`, which passes even without a terminal under curl|bash
has_tty() { { : </dev/tty; } 2>/dev/null; }
ask() {  # ask "question" default -> sets ANSWER
  ANSWER=$2
  if has_tty; then
    printf '   %s ' "$1"
    IFS= read -r ANSWER </dev/tty || ANSWER=$2
    [ -n "$ANSWER" ] || ANSWER=$2
  fi
}

[ "$(id -u)" -ne 0 ] || { echo "Run this as your normal user, not root (it uses sudo itself)."; exit 1; }
need pacman || { echo "Arch Linux only (pacman not found)."; exit 1; }

printf '\n%s%s   Hyper Terminal i3%s\n   %sthe i3 session from OckoTajny/dotfiles%s\n' "$PNK" "$B" "$R" "$DIM" "$R"
if has_tty; then sudo -v </dev/tty || { echo "sudo is needed."; exit 1; }; else sudo -v || exit 1; fi
# keep sudo alive for long AUR builds
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &
KEEPALIVE=$!
trap 'kill "$KEEPALIVE" 2>/dev/null' EXIT

# 1. packages ---------------------------------------------------------------------
say "Packages"
sudo pacman -Syu --needed --noconfirm "${PKGS[@]}" >/dev/null 2>&1 && ok "all packages installed" || {
  # one bad package fails the whole transaction: retry one by one so the rest still land
  warn "batch install failed, retrying one by one"
  for p in "${PKGS[@]}"; do
    have "$p" || sudo pacman -S --needed --noconfirm "$p" >/dev/null 2>&1 \
      || { need yay && yay -S --needed --noconfirm "$p" >/dev/null 2>&1; } || fail "package: $p"
  done
}

# 2. optional apps ------------------------------------------------------------------
say "Apps the keybinds open (optional)"
i=1
for e in "${APPS[@]}"; do printf '     %2d) %-20s %s%s%s\n' "$i" "${e%%|*}" "$DIM" "${e#*|}" "$R"; i=$((i+1)); done
has_tty && def=a || def=n   # unattended runs skip the AUR apps
ask "Install which? (numbers like 1 3, 'a' = all, Enter = all, 'n' = none)" "$def"
chosen=()
case "$ANSWER" in
  n|N|none) ;;
  a|A|all) for e in "${APPS[@]}"; do chosen+=("${e%%|*}"); done ;;
  *) for n in $ANSWER; do
       [[ $n =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le "${#APPS[@]}" ] && chosen+=("$(echo "${APPS[$((n-1))]}" | cut -d'|' -f1)")
     done ;;
esac
if [ "${#chosen[@]}" -gt 0 ] && ! need yay; then
  # zen-browser, spotify and the toolbox live in the AUR
  sudo pacman -S --needed --noconfirm base-devel >/dev/null 2>&1
  tmp=$(mktemp -d)
  git clone --quiet https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin" \
    && (cd "$tmp/yay-bin" && makepkg -si --noconfirm >/dev/null 2>&1) && ok "yay installed" || fail "bootstrap yay"
fi
for p in "${chosen[@]}"; do
  if have "$p"; then ok "$p"
  elif sudo pacman -S --needed --noconfirm "$p" >/dev/null 2>&1 || { need yay && yay -S --needed --noconfirm "$p" >/dev/null 2>&1; }; then ok "$p"
  else fail "app: $p"; fi
done
[ "${#chosen[@]}" -gt 0 ] || ok "no apps picked"

# 3. configs + wallpaper ------------------------------------------------------------
say "Configs and wallpaper"
if [ -d "$SRC/.git" ]; then
  git -C "$SRC" fetch --quiet --depth 1 origin "$BRANCH" && git -C "$SRC" reset --quiet --hard FETCH_HEAD \
    && ok "dotfiles updated" || fail "update $SRC"
else
  git clone --quiet --depth 1 --branch "$BRANCH" "$REPO" "$SRC" && ok "dotfiles cloned" || fail "clone $REPO"
fi
existing=()
for t in "${TARGETS[@]}"; do [ -e "$HOME/$t" ] && existing+=("$t"); done
if [ "${#existing[@]}" -gt 0 ]; then
  backup="$HOME/i3-installer-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
  tar -C "$HOME" -czf "$backup" "${existing[@]}" 2>/dev/null && ok "old configs backed up: ${backup/#$HOME/\~}" \
    || warn "backup of old configs failed, continuing"
fi
mkdir -p "$HOME/.config"   # chezmoi won't create the parent of a target it applies
paths=(); for t in "${TARGETS[@]}"; do paths+=("$HOME/$t"); done
# the wallpaper ships as ~/.config/i3/wall.jpg
chezmoi apply --force --source "$SRC" "${paths[@]}" && ok "i3, kitty, LazyVim, btop, fastfetch, lazygit, touchegg, zsh" \
  || fail "apply configs (chezmoi)"

# 4. terminal extras ----------------------------------------------------------------
say "Terminal extras"
# brrtfetch: the glitchy Arch logo on Super+Return
if need brrtfetch; then ok "brrtfetch present"
else
  [ -d "$HOME/brrtfetch/.git" ] || git clone --quiet https://github.com/ferrebarrat/brrtfetch "$HOME/brrtfetch"
  (cd "$HOME/brrtfetch" && go build -o ./bin/brrtfetch ./go/main.go) >/dev/null 2>&1 \
    && sudo install -m755 "$HOME/brrtfetch/bin/brrtfetch" /usr/local/bin/brrtfetch && ok "brrtfetch built" \
    || fail "brrtfetch (go build in ~/brrtfetch)"
fi
# zsh: the .zshrc uses oh-my-zsh with two plugins
if [ -d "$HOME/.oh-my-zsh" ]; then ok "oh-my-zsh present"
else
  RUNZSH=no KEEP_ZSHRC=yes CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended --keep-zshrc >/dev/null 2>&1 && ok "oh-my-zsh installed" || fail "oh-my-zsh"
fi
for plug in zsh-autosuggestions zsh-syntax-highlighting; do
  d="$HOME/.oh-my-zsh/custom/plugins/$plug"
  [ -d "$d" ] || git clone --quiet --depth 1 "https://github.com/zsh-users/$plug" "$d" || fail "zsh plugin $plug"
done
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
  sudo chsh -s "$(command -v zsh)" "$USER" >/dev/null 2>&1 && ok "default shell: zsh" || warn "run: chsh -s $(command -v zsh)"
else ok "zsh is the default shell"; fi

# 5. system bits --------------------------------------------------------------------
say "Touchpad, gestures, GPU monitor, battery"
sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/30-libinput.conf >/dev/null <<'XORG_EOF'
# Tap to click, natural scrolling on the touchpad, no pointer acceleration anywhere
Section "InputClass"
    Identifier "touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "NaturalScrolling" "true"
    Option "AccelProfile" "flat"
EndSection

Section "InputClass"
    Identifier "pointer"
    MatchIsPointer "on"
    Driver "libinput"
    Option "AccelProfile" "flat"
EndSection
XORG_EOF
ok "touchpad: tap, natural scroll, flat acceleration"
sudo systemctl enable --now touchegg.service >/dev/null 2>&1 && ok "touchegg (3 finger swipe = workspace)" || fail "enable touchegg.service"
# the bar's GPU field reads intel_gpu_top, which needs cap_perfmon; a pacman hook keeps it across upgrades
if lspci 2>/dev/null | grep -iE 'vga|display' | grep -qi intel; then
  sudo mkdir -p /etc/pacman.d/hooks
  sudo tee /etc/pacman.d/hooks/intel-gpu-top-perfmon.hook >/dev/null <<'HOOK_EOF'
# Re-grant cap_perfmon after intel-gpu-tools upgrades, so the i3 bar can read GPU load without root
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = intel-gpu-tools

[Action]
Description = Granting cap_perfmon to intel_gpu_top
When = PostTransaction
Exec = /usr/bin/setcap cap_perfmon=+ep /usr/bin/intel_gpu_top
HOOK_EOF
  sudo setcap cap_perfmon=+ep /usr/bin/intel_gpu_top && ok "bar GPU monitor" || fail "setcap intel_gpu_top"
else
  ok "no Intel GPU, the bar just hides the GPU field"
fi
# low battery: a notification, or opt in to the fullscreen blinking alert (Super+Shift+B switches later)
if [ "$BATTERY_ALERT" -eq 0 ] && [ ! -f "$ALERT_FLAG" ]; then
  printf '   Low battery: fullscreen blinking alert instead of a notification? It flashes up to\n'
  printf '   3 times a second, skip it if flashing light bothers you. Super+Shift+B switches later.\n'
  ask "[y/N]" n
  case "$ANSWER" in y|Y|yes) BATTERY_ALERT=1 ;; esac
fi
if [ "$BATTERY_ALERT" -eq 1 ] || [ -f "$ALERT_FLAG" ]; then
  mkdir -p "${ALERT_FLAG%/*}" && touch "$ALERT_FLAG"
  sudo pacman -S --needed --noconfirm tk >/dev/null 2>&1 && ok "low battery: blinking alert" || fail "package: tk (battery alert)"
else
  ok "low battery: notification"
fi

# 6. login screen -------------------------------------------------------------------
say "Login screen"
# GDM, SDDM and LightDM all read the remembered session from AccountsService
acc="/var/lib/AccountsService/users/$USER"
sudo mkdir -p "${acc%/*}"
[ -f "$acc" ] && sudo cp "$acc" "$acc.bak-i3"
if sudo test -f "$acc" && sudo grep -q '^\[User\]' "$acc"; then
  for key in Session XSession; do
    if sudo grep -q "^$key=" "$acc"; then sudo sed -i "s/^$key=.*/$key=i3/" "$acc"
    else sudo sed -i "/^\[User\]/a $key=i3" "$acc"; fi
  done
else
  printf '[User]\nSession=i3\nXSession=i3\n' | sudo tee "$acc" >/dev/null
fi
ok "i3 is the default session at login"

# summary ---------------------------------------------------------------------------
echo
if [ "${#FAILS[@]}" -eq 0 ]; then
  printf '%s%s✓ done.%s Log out, pick %si3%s at login. %sSuper+Shift+Escape%s lists every keybind.\n\n' \
    "$GRN" "$B" "$R" "$B" "$R" "$B" "$R"
else
  printf '%s%s! finished with %d issue(s):%s\n' "$YEL" "$B" "${#FAILS[@]}" "$R"
  for f in "${FAILS[@]}"; do printf '   - %s\n' "$f"; done
  printf '   Fix them (often a mirror: sudo pacman -Syyu) and run this again, it is safe to repeat.\n\n'
fi
