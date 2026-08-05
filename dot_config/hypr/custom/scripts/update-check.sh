#!/usr/bin/env bash
# update-check.sh — runs on Hyprland start (exec-once), checks pacman + AUR
# updates and offers to update via a notification.
# Requires: pacman-contrib (checkupdates), yay, notify-send
set -uo pipefail

# wait for the network (max ~60 s)
for _ in $(seq 30); do
  ping -c1 -W2 archlinux.org &>/dev/null && break
  sleep 2
done

repo=$(checkupdates 2>/dev/null | wc -l)
aur=$(yay -Qua 2>/dev/null | wc -l)
total=$((repo + aur))
((total == 0)) && exit 0

# -A = button; blocks until the user clicks / dismisses the notification
action=$(notify-send -a "Updates" -i system-software-update -t 0 \
  -A update="Update" \
  "Updates available" "$repo repo + $aur AUR packages" 2>/dev/null || true)

# --answerdiff/-clean/-edit=None: skip PKGBUILD diff/clean/edit prompts explicitly (avoids
# hang on `less` pager) instead of blindly piping "y" into everything with `yes`.
[[ "$action" == "update" ]] && kitty --title "System update" -e yay -Syu --noconfirm \
  --answerdiff None --answerclean None --answeredit None
