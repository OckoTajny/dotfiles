#!/usr/bin/env bash
# dotswap installer, i3 edition: same install.sh, run with --i3.
# Usage: curl -fsSL solta.tech/install/i3 | bash   (extra flags: ... | bash -s -- --update)
exec bash <(curl -fsSL https://raw.githubusercontent.com/OckoTajny/dotfiles/installer/install.sh) --i3 "$@"
