#!/usr/bin/env bash
# dotswap installer, niri edition: same install.sh, run with --niri.
# Usage: curl -fsSL solta.tech/install/niri | bash   (extra flags: ... | bash -s -- --update)
exec bash <(curl -fsSL https://raw.githubusercontent.com/OckoTajny/dotfiles/installer/install.sh) --niri "$@"
