#!/usr/bin/env bash
# update-check.sh — spustí se se startem Hyprlandu (exec-once),
# zkontroluje pacman + AUR updaty a nabídne update přes notifikaci.
# Vyžaduje: pacman-contrib (checkupdates), yay, notify-send
set -uo pipefail

# počkej na síť (max ~60 s)
for _ in $(seq 30); do
  ping -c1 -W2 archlinux.org &>/dev/null && break
  sleep 2
done

repo=$(checkupdates 2>/dev/null | wc -l)
aur=$(yay -Qua 2>/dev/null | wc -l)
total=$((repo + aur))
((total == 0)) && exit 0

# -A = tlačítko; blokuje dokud uživatel neklikne / nezavře notifikaci
action=$(notify-send -a "Updaty" -i system-software-update -t 0 \
  -A update="Aktualizovat" \
  "Dostupné aktualizace" "$repo repo + $aur AUR balíčků" 2>/dev/null || true)

# yes | yay: po zadání sudo hesla updatuje vše bez dalších dotazů (--noconfirm u yay umí crashnout)
[[ "$action" == "update" ]] && kitty --title "System update" -e bash -c 'yes | yay -Syu'
