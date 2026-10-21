#!/usr/bin/env bash
# Hyper Terminal i3 installer: just the i3 (X11) session from OckoTajny/dotfiles.
# No Hyprland, no niri, no dotswap. Arch Linux (and Arch based, e.g. CachyOS).
#
#   curl -fsSL solta.tech/install/i3 | bash                    (asks what to do)
#   curl -fsSL solta.tech/install/i3 | bash -s -- --update     (or --install, --doctor, --uninstall)
#
# Safe to re-run. A failing step is reported and skipped, the summary at the end
# lists what went wrong, and the full output of every command is in $LOG.
set -uo pipefail   # no -e on purpose: one failure must not abort the rest

REPO="https://github.com/OckoTajny/dotfiles.git"
BRANCH=niri   # every profile branch carries the i3 session; niri is the one kept current
SRC="$HOME/.local/share/i3-dotfiles"
ALERT_FLAG="$HOME/.local/state/i3-battery-alert"
STATE="$HOME/.local/state/i3-installer"
LOG="${XDG_CACHE_HOME:-$HOME/.cache}/i3-installer.log"
XORG_CONF=/etc/X11/xorg.conf.d/30-libinput.conf
GPU_HOOK=/etc/pacman.d/hooks/intel-gpu-top-perfmon.hook
ACC="/var/lib/AccountsService/users/$USER"
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

MODE=
BATTERY_ALERT=0
for a in "$@"; do
  case "$a" in
    --install|install) MODE=install ;;
    --update|update|-u) MODE=update ;;
    --doctor|doctor) MODE=doctor ;;
    --uninstall|uninstall) MODE=uninstall ;;
    --battery-alert) BATTERY_ALERT=1 ;;
    -h|--help)
      echo "Usage: install-i3.sh [--install|--update|--doctor|--uninstall] [--battery-alert]"
      echo "  (no mode)        asks, showing what is installed and when it last ran"
      echo "  --install        everything: packages, apps, configs (old ones backed up), extras"
      echo "  --update         upgrade packages, add new ones, show changed configs and ask to apply"
      echo "  --doctor         check what is missing or broken, changes nothing"
      echo "  --uninstall      remove what this installer set up (not packages, configs restorable)"
      echo "  --battery-alert  fullscreen blinking low-battery alert instead of a notification"
      exit 0 ;;
  esac
done

# --- output ------------------------------------------------------------------------
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

# run "label" cmd...: runs cmd with its output in $LOG and a live status line showing
# the label, elapsed time and the command's latest output line, so nothing looks frozen.
run() {
  local label=$1; shift
  printf '\n$ %s\n' "$*" >>"$LOG"
  "$@" >>"$LOG" 2>&1 </dev/null &
  local pid=$! i=0 start=$SECONDS frames='|/-\' last width
  while kill -0 "$pid" 2>/dev/null; do
    if [ -t 1 ]; then
      width=$(( $(tput cols 2>/dev/null || echo 80) - ${#label} - 16 ))
      # pacman redraws progress bars with \r: keep only the newest piece
      last=$(tail -c 400 "$LOG" | tr '\r' '\n' | grep -v '^[[:space:]]*$' | tail -n1)
      [ "$width" -gt 10 ] && last=${last:0:$width} || last=
      printf '\r\033[K   %s %s %s(%ds) %s%s' "${frames:i++%4:1}" "$label" "$DIM" $((SECONDS - start)) "$last" "$R"
    fi
    sleep 0.2
  done
  wait "$pid"; local rc=$?
  [ -t 1 ] && printf '\r\033[K'
  return $rc
}

# --- state -------------------------------------------------------------------------
save_state() { mkdir -p "${STATE%/*}"; printf 'mode=%s\ndate=%s\ncommit=%s\n' "$MODE" "$(date '+%Y-%m-%d %H:%M')" \
  "$(git -C "$SRC" rev-parse --short HEAD 2>/dev/null || echo none)" >"$STATE"; }
state() { sed -n "s/^$1=//p" "$STATE" 2>/dev/null; }
status_line() {
  if [ ! -f "$STATE" ] && [ ! -d "$SRC/.git" ]; then
    printf '   %sstatus:%s not installed on this machine\n' "$DIM" "$R"; return
  fi
  local remote local_c behind=""
  local_c=$(git -C "$SRC" rev-parse --short HEAD 2>/dev/null)
  remote=$(timeout 5 git ls-remote "$REPO" "refs/heads/$BRANCH" 2>/dev/null | cut -c1-7)
  if [ -n "$remote" ] && [ -n "$local_c" ]; then
    [ "$remote" = "$local_c" ] && behind=", configs up to date" || behind=", ${YEL}newer configs available${R}"
  fi
  printf '   %sstatus:%s installed, last run: %s %s (dotfiles %s%s)\n' "$DIM" "$R" \
    "$(state mode)" "$(state date)" "${local_c:-?}" "$behind"
  printf '   %slog of every command: %s%s\n' "$DIM" "${LOG/#$HOME/\~}" "$R"
}

# --- steps -------------------------------------------------------------------------
do_packages() {
  say "Packages"
  if [ "$MODE" = update ]; then
    run "upgrading the system" sudo pacman -Syu --noconfirm && ok "system upgraded" || fail "pacman -Syu"
  fi
  local missing=()
  for p in "${PKGS[@]}"; do have "$p" || missing+=("$p"); done
  if [ "${#missing[@]}" -eq 0 ]; then ok "all ${#PKGS[@]} packages present"; return; fi
  run "installing ${#missing[@]} packages" sudo pacman -Syu --needed --noconfirm "${missing[@]}" \
    && { ok "installed: ${missing[*]}"; return; }
  # one bad package fails the whole transaction: retry one by one so the rest still land
  warn "batch install failed, retrying one by one"
  for p in "${missing[@]}"; do
    run "$p" sudo pacman -S --needed --noconfirm "$p" \
      || { need yay && run "$p (AUR)" yay -S --needed --noconfirm "$p"; } && ok "$p" || fail "package: $p"
  done
}

do_apps() {
  say "Apps the keybinds open (optional)"
  local i=1 e def chosen=()
  for e in "${APPS[@]}"; do
    have "${e%%|*}" && e="$e, installed"
    printf '     %2d) %-20s %s%s%s\n' "$i" "${e%%|*}" "$DIM" "${e#*|}" "$R"; i=$((i+1))
  done
  has_tty && def=a || def=n   # unattended runs skip the AUR apps
  ask "Install which? (numbers like 1 3, 'a' = all, Enter = all, 'n' = none)" "$def"
  case "$ANSWER" in
    n|N|none) ;;
    a|A|all) for e in "${APPS[@]}"; do chosen+=("${e%%|*}"); done ;;
    *) for n in $ANSWER; do
         [[ $n =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le "${#APPS[@]}" ] && chosen+=("$(echo "${APPS[$((n-1))]}" | cut -d'|' -f1)")
       done ;;
  esac
  if [ "${#chosen[@]}" -gt 0 ] && ! need yay; then
    # zen-browser, spotify and the toolbox live in the AUR
    local tmp; tmp=$(mktemp -d)
    run "base-devel" sudo pacman -S --needed --noconfirm base-devel
    run "cloning yay" git clone --quiet https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin" \
      && (cd "$tmp/yay-bin" && run "building yay" makepkg -si --noconfirm) && ok "yay installed" || fail "bootstrap yay"
  fi
  for p in "${chosen[@]}"; do
    if have "$p"; then ok "$p (already installed)"
    elif run "$p" sudo pacman -S --needed --noconfirm "$p" || { need yay && run "$p (AUR)" yay -S --needed --noconfirm "$p"; }; then ok "$p"
    else fail "app: $p"; fi
  done
  [ "${#chosen[@]}" -gt 0 ] || ok "no apps picked"
}

apply_configs() {
  local existing=() paths=() t backup
  for t in "${TARGETS[@]}"; do [ -e "$HOME/$t" ] && existing+=("$t"); done
  if [ "${#existing[@]}" -gt 0 ]; then
    backup="$HOME/i3-installer-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    tar -C "$HOME" -czf "$backup" "${existing[@]}" 2>/dev/null && ok "old configs backed up: ${backup/#$HOME/\~}" \
      || warn "backup of old configs failed, continuing"
  fi
  mkdir -p "$HOME/.config"   # chezmoi won't create the parent of a target it applies
  for t in "${TARGETS[@]}"; do paths+=("$HOME/$t"); done
  # the wallpaper ships as ~/.config/i3/wall.jpg
  run "applying configs" chezmoi apply --force --source "$SRC" "${paths[@]}" \
    && ok "i3, kitty, LazyVim, btop, fastfetch, lazygit, touchegg, zsh, wallpaper" || fail "apply configs (chezmoi)"
}

do_configs() {
  say "Configs and wallpaper"
  if [ -d "$SRC/.git" ]; then
    run "fetching dotfiles" git -C "$SRC" fetch --depth 1 origin "$BRANCH" \
      && run "updating dotfiles" git -C "$SRC" reset --hard FETCH_HEAD && ok "dotfiles updated" || fail "update $SRC"
  else
    run "cloning dotfiles" git clone --depth 1 --branch "$BRANCH" "$REPO" "$SRC" && ok "dotfiles cloned" || fail "clone $REPO"
  fi
  if [ "$MODE" = update ]; then
    # update never overwrites silently: list what differs and ask
    local paths=() t changes
    for t in "${TARGETS[@]}"; do paths+=("$HOME/$t"); done
    changes=$(chezmoi status --source "$SRC" "${paths[@]}" 2>/dev/null)
    if [ -z "$changes" ]; then ok "your configs match the dotfiles"; return; fi
    printf '   %sdiffers from the dotfiles (yours vs new):%s\n' "$DIM" "$R"
    printf '%s\n' "$changes" | sed 's/^/     /'
    ask "Apply the new versions? Yours get backed up first. [y/N]" n
    case "$ANSWER" in y|Y|yes) apply_configs ;; *) ok "configs left as they are" ;; esac
  else
    apply_configs
  fi
}

do_extras() {
  say "Terminal extras"
  # brrtfetch: the glitchy Arch logo on Super+Return
  if need brrtfetch; then ok "brrtfetch present"
  else
    [ -d "$HOME/brrtfetch/.git" ] || run "cloning brrtfetch" git clone https://github.com/ferrebarrat/brrtfetch "$HOME/brrtfetch"
    (cd "$HOME/brrtfetch" && run "building brrtfetch" go build -o ./bin/brrtfetch ./go/main.go) \
      && sudo install -m755 "$HOME/brrtfetch/bin/brrtfetch" /usr/local/bin/brrtfetch && ok "brrtfetch built" \
      || fail "brrtfetch (go build in ~/brrtfetch)"
  fi
  # zsh: the .zshrc uses oh-my-zsh with two plugins
  if [ -d "$HOME/.oh-my-zsh" ]; then ok "oh-my-zsh present"
  else
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /tmp/omz-install.sh \
      && run "installing oh-my-zsh" env RUNZSH=no KEEP_ZSHRC=yes CHSH=no sh /tmp/omz-install.sh --unattended --keep-zshrc \
      && ok "oh-my-zsh installed" || fail "oh-my-zsh"
  fi
  for plug in zsh-autosuggestions zsh-syntax-highlighting; do
    local d="$HOME/.oh-my-zsh/custom/plugins/$plug"
    if [ -d "$d" ]; then ok "$plug"
    else run "cloning $plug" git clone --depth 1 "https://github.com/zsh-users/$plug" "$d" && ok "$plug" || fail "zsh plugin $plug"; fi
  done
  if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
    run "setting zsh as default shell" sudo chsh -s "$(command -v zsh)" "$USER" && ok "default shell: zsh" \
      || warn "run: chsh -s $(command -v zsh)"
  else ok "zsh is the default shell"; fi
}

do_system() {
  say "Touchpad, gestures, GPU monitor, battery"
  sudo mkdir -p "${XORG_CONF%/*}"
  sudo tee "$XORG_CONF" >/dev/null <<'XORG_EOF'
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
  run "enabling touchegg" sudo systemctl enable --now touchegg.service && ok "touchegg (3 finger swipe = workspace)" \
    || fail "enable touchegg.service"
  # the bar's GPU field reads intel_gpu_top, which needs cap_perfmon; a pacman hook keeps it across upgrades
  if lspci 2>/dev/null | grep -iE 'vga|display' | grep -qi intel; then
    sudo mkdir -p "${GPU_HOOK%/*}"
    sudo tee "$GPU_HOOK" >/dev/null <<'HOOK_EOF'
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
  if [ "$BATTERY_ALERT" -eq 0 ] && [ ! -f "$ALERT_FLAG" ] && [ "$MODE" = install ]; then
    printf '   Low battery: fullscreen blinking alert instead of a notification? It flashes up to\n'
    printf '   3 times a second, skip it if flashing light bothers you. Super+Shift+B switches later.\n'
    ask "[y/N]" n
    case "$ANSWER" in y|Y|yes) BATTERY_ALERT=1 ;; esac
  fi
  if [ "$BATTERY_ALERT" -eq 1 ] || [ -f "$ALERT_FLAG" ]; then
    mkdir -p "${ALERT_FLAG%/*}" && touch "$ALERT_FLAG"
    { have tk || run "installing tk" sudo pacman -S --needed --noconfirm tk; } && ok "low battery: blinking alert" \
      || fail "package: tk (battery alert)"
  else
    ok "low battery: notification"
  fi
}

do_login() {
  say "Login screen"
  # GDM, SDDM and LightDM all read the remembered session from AccountsService
  sudo mkdir -p "${ACC%/*}"
  sudo test -f "$ACC" && sudo cp -n "$ACC" "$ACC.bak-i3"
  if sudo test -f "$ACC" && sudo grep -q '^\[User\]' "$ACC"; then
    for key in Session XSession; do
      if sudo grep -q "^$key=" "$ACC"; then sudo sed -i "s/^$key=.*/$key=i3/" "$ACC"
      else sudo sed -i "/^\[User\]/a $key=i3" "$ACC"; fi
    done
  else
    printf '[User]\nSession=i3\nXSession=i3\n' | sudo tee "$ACC" >/dev/null
  fi
  ok "i3 is the default session at login"
}

# doctor: read-only, prints what is fine and what is not
check() { if eval "$2" >/dev/null 2>&1; then ok "$1"; else fail "$1: ${3:-missing}"; fi; }
do_doctor() {
  say "Packages"
  local missing=() p t
  for p in "${PKGS[@]}"; do have "$p" || missing+=("$p"); done
  [ "${#missing[@]}" -eq 0 ] && ok "all ${#PKGS[@]} packages installed" || fail "missing packages: ${missing[*]}"
  say "Configs"
  check "dotfiles clone in ${SRC/#$HOME/\~}" "[ -d '$SRC/.git' ]"
  for t in "${TARGETS[@]}"; do check "~/$t" "[ -e '$HOME/$t' ]"; done
  if [ -d "$SRC/.git" ]; then
    local changes; changes=$(chezmoi status --source "$SRC" "${TARGETS[@]/#/$HOME/}" 2>/dev/null | wc -l)
    [ "$changes" -eq 0 ] && ok "configs match the dotfiles" || warn "$changes config file(s) differ from the dotfiles (your edits, or run --update)"
  fi
  check "i3 config is valid" "i3 -C -c '$HOME/.config/i3/config'" "i3 -C reports errors"
  say "Session"
  check "AccountsService default session is i3" "sudo -n grep -qE '^X?Session=i3' '$ACC'" "not set (or no sudo), run --install"
  if [ "${XDG_CURRENT_DESKTOP:-}" = i3 ]; then
    ok "running inside i3"
    for p in dunst picom xcape nm-applet; do check "$p running" "pgrep -x $p"; done
    check "battery watcher running" "pgrep -f 'i3/battery\$'"
  else
    warn "not inside i3 right now (${XDG_CURRENT_DESKTOP:-no desktop}), skipping process checks"
  fi
  say "Extras"
  check "brrtfetch" "need brrtfetch"
  check "oh-my-zsh" "[ -d '$HOME/.oh-my-zsh' ]"
  check "zsh is the default shell" "[ \"\$(getent passwd '$USER' | cut -d: -f7)\" = '$(command -v zsh)' ]"
  say "System"
  check "touchpad config ${XORG_CONF}" "[ -f '$XORG_CONF' ]"
  check "touchegg service" "systemctl is-active touchegg.service" "inactive"
  if lspci 2>/dev/null | grep -iE 'vga|display' | grep -qi intel; then
    check "intel_gpu_top can read the GPU" "getcap /usr/bin/intel_gpu_top | grep -q cap_perfmon" "no cap_perfmon"
  fi
  if [ -f "$ALERT_FLAG" ]; then
    ok "low battery: blinking alert"
    check "tk for the blinking alert" "python3 -c 'import tkinter'"
  else ok "low battery: notification"; fi
  say "Network"
  check "GitHub reachable" "timeout 5 git ls-remote '$REPO' HEAD" "no connection"
}

do_uninstall() {
  say "Uninstall"
  printf '   Removes: %s, the touchpad config, the GPU hook, the battery alert flag, and\n' "${SRC/#$HOME/\~}"
  printf '   restores the login screen session. Packages and your configs stay.\n'
  ask "Continue? [y/N]" n
  case "$ANSWER" in y|Y|yes) ;; *) ok "nothing removed"; return ;; esac
  rm -rf "$SRC" "$ALERT_FLAG" "$STATE" && ok "dotfiles clone, battery flag, state removed"
  sudo rm -f "$XORG_CONF" "$GPU_HOOK" && ok "touchpad config and GPU hook removed"
  if sudo test -f "$ACC.bak-i3"; then sudo mv "$ACC.bak-i3" "$ACC" && ok "login session restored"
  else warn "no AccountsService backup, pick your session at login"; fi
  local last; last=$(ls -t "$HOME"/i3-installer-backup-*.tar.gz 2>/dev/null | head -n1)
  if [ -n "$last" ]; then
    ask "Restore your configs from ${last/#$HOME/\~} (from before the install)? [y/N]" n
    case "$ANSWER" in
      y|Y|yes) tar -C "$HOME" -xzf "$last" && ok "configs restored" || fail "restore $last" ;;
      *) ok "configs kept, backups stay in ~/i3-installer-backup-*.tar.gz" ;;
    esac
  fi
}

# --- main --------------------------------------------------------------------------
[ "$(id -u)" -ne 0 ] || { echo "Run this as your normal user, not root (it uses sudo itself)."; exit 1; }
need pacman || { echo "Arch Linux only (pacman not found)."; exit 1; }
mkdir -p "${LOG%/*}"
printf '\n===== %s %s\n' "$(date '+%Y-%m-%d %H:%M')" "$*" >>"$LOG"

printf '\n%s%s   Hyper Terminal i3%s\n   %sthe i3 session from OckoTajny/dotfiles%s\n' "$PNK" "$B" "$R" "$DIM" "$R"
status_line
if [ -z "$MODE" ]; then
  default=1; [ -d "$SRC/.git" ] && default=2
  printf '\n   1) install    everything, configs replaced (old ones backed up)\n'
  printf '   2) update     upgrade packages, add new ones, ask before touching configs\n'
  printf '   3) doctor     check what is missing or broken, changes nothing\n'
  printf '   4) uninstall  remove what this installer set up\n'
  ask "What now? [$default]" "$default"
  case "$ANSWER" in 2) MODE=update ;; 3) MODE=doctor ;; 4) MODE=uninstall ;; *) MODE=install ;; esac
fi

if [ "$MODE" = doctor ]; then
  STEPS=6
  if has_tty; then sudo -v </dev/tty 2>/dev/null; fi   # optional, only to read the AccountsService file
  do_doctor
  echo
  [ "${#FAILS[@]}" -eq 0 ] && printf '%s%s✓ all good.%s\n\n' "$GRN" "$B" "$R" \
    || printf '%s%s! %d problem(s).%s Run with --update or --install to fix.\n\n' "$YEL" "$B" "${#FAILS[@]}" "$R"
  exit 0
fi

if has_tty; then sudo -v </dev/tty || { echo "sudo is needed."; exit 1; }; else sudo -v || exit 1; fi
# keep sudo alive for long AUR builds
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &
KEEPALIVE=$!
trap 'kill "$KEEPALIVE" 2>/dev/null' EXIT

case "$MODE" in
  uninstall) STEPS=1; do_uninstall ;;
  update) STEPS=5; do_packages; do_configs; do_extras; do_system; save_state; say "Done" ;;
  *) do_packages; do_apps; do_configs; do_extras; do_system; do_login; save_state ;;
esac

# summary ---------------------------------------------------------------------------
echo
if [ "${#FAILS[@]}" -eq 0 ]; then
  case "$MODE" in
    install) printf '%s%s✓ done.%s Log out, pick %si3%s at login. %sSuper+Shift+Escape%s lists every keybind.\n' \
      "$GRN" "$B" "$R" "$B" "$R" "$B" "$R" ;;
    update) printf '%s%s✓ updated.%s Reload i3 with %sSuper+Shift+R%s (or log out) to pick up changes.\n' \
      "$GRN" "$B" "$R" "$B" "$R" ;;
    *) printf '%s%s✓ done.%s\n' "$GRN" "$B" "$R" ;;
  esac
else
  printf '%s%s! finished with %d issue(s):%s\n' "$YEL" "$B" "${#FAILS[@]}" "$R"
  for f in "${FAILS[@]}"; do printf '   - %s\n' "$f"; done
  printf '   Details in %s. Fix them (often a mirror: sudo pacman -Syyu) and run again, it is safe to repeat.\n' "${LOG/#$HOME/\~}"
fi
printf '   %sfull log: %s%s\n\n' "$DIM" "${LOG/#$HOME/\~}" "$R"
