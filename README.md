# dotswap – one Hyprland machine, four rices

`dotswap` swaps whole desktop "profiles" (rices) in place using **chezmoi** with a
separate source tree per profile. One keypress cycles the entire shell, bar,
keybinds, terminal theme and Hyprland config.

| Profile     | Shell / bar                | Branch      |
|-------------|----------------------------|-------------|
| `ambxst`    | Ambxst (quickshell + axctl)| `ambxst`    |
| `illogical` | illogical-impulse (`qs -c ii`) | `main`  |
| `win11`     | illogical-impulse, Win11/waffle layout | `win11` |
| `43pr`      | Waybar + Rofi + Quickshell ([43PR/dotfiles](https://github.com/43PR/dotfiles) monochrome) | `43pr` |
| `niri`      | Ambxst on [niri](https://github.com/niri-wm/niri) (same rice as `ambxst`, `~/.config/niri` mirrors the Hyprland binds) | `niri` |

Each profile is a branch of this repo; its files live under `dot_config/…`,
`dot_local/…` (chezmoi layout).

## Quickstart

```sh
curl -fsSL solta.tech/install | bash
```

(`solta.tech/install` redirects to
`raw.githubusercontent.com/OckoTajny/dotfiles/installer/install.sh`.)

This installs base tools (`git`, `chezmoi`, `yay`), a core dependency set
(incl. quickshell, waybar, rofi, awww … for every rice), clones all four
profile branches into `~/.local/share/chezmoi-<profile>/`, drops the `dotswap`
tools into `~/.local/bin/`, and applies the `ambxst` profile.

### Just i3 or just niri

```sh
curl -fsSL solta.tech/install/i3 | bash     # only the i3 (X11) session
curl -fsSL solta.tech/install/niri | bash   # only niri + the Ambxst shell
```

**i3** has its own standalone installer, `install-i3.sh`: no Hyprland, niri
or dotswap. It installs the session's packages (asks which apps the binds open:
Zen, Nautilus, Discord, Spotify, IntelliJ), clones the dotfiles to
`~/.local/share/i3-dotfiles` and applies only what the session uses
(`~/.config/{i3,kitty,nvim,btop,fastfetch,lazygit,touchegg}`, `~/.zshrc`,
wallpaper included) after backing up the old ones to `~/i3-installer-backup-*.tar.gz`.
Then brrtfetch, oh-my-zsh, touchpad and gestures, the bar's GPU monitor, and
i3 as the default login session. Safe to re-run.

Run without flags it shows the status (installed or not, last run, whether newer
configs are available) and asks what to do: **install**, **update** (upgrade
packages, add new ones, list changed configs and ask before applying),
**doctor** (read-only check of packages, configs, session, services) or
**uninstall** (removes what it set up, offers to restore your old configs).
Skip the menu with `--install`, `--update`, `--doctor` or `--uninstall`:

```sh
curl -fsSL solta.tech/install/i3 | bash -s -- --doctor
```

While it works, a live line shows the current step, elapsed time and the
command's latest output; everything goes to `~/.cache/i3-installer.log`.

Low battery in i3 shows a notification. The installer asks whether you want a
fullscreen blinking alert instead (or pass `--battery-alert`); it flashes up to
3 times a second, so skip it if flashing light bothers you. Super+Shift+B
switches between the two any time.

**niri** is `install.sh --niri` (`install-niri.sh`): the full installer minus
the Hyprland rices and i3.

### Updating

The same script doubles as an updater. Run it with `--update` to pull in only
what's **new** – updated packages and newly added tools – while leaving your
`~/.config` (keybinds, tweaks) completely untouched:

```sh
curl -fsSL solta.tech/install | bash -s -- --update
```

Without `--update` it runs a fresh install and writes the configs; with it,
configs are never re-applied.

> The desktop shells own their full dependency trees. For a complete install
> of any one rice, also run its upstream installer:
> - **Ambxst** – https://github.com/Axenide/Ambxst
> - **illogical-impulse** – https://github.com/end-4/dots-hyprland
> - **43PR** – https://github.com/43PR/dotfiles (`./install.sh`; the `43pr`
>   branch here is that setup with my keybinds/tools mapped onto it)

## Usage

```sh
dotswap status            # current profile
dotswap list              # available profiles
dotswap use <profile>     # save current, switch to <profile>
dotswap save              # re-snapshot current desktop into its profile branch
dotswap diff <profile>    # preview what applying <profile> would change
dotswap snapshot <name>   # create a new profile from the current desktop
```

`dotswap use` auto-saves the current desktop into its own branch before
switching, so live tweaks are never lost.

### Keybinds (in every profile)

| Keys                          | Action                       |
|-------------------------------|------------------------------|
| `Ctrl+Shift+Super+Right`      | cycle to next profile        |
| `Ctrl+Shift+Super+Left`       | cycle to previous profile    |
| `Ctrl+Super+P`                | jump straight to `win11`     |

Cycle order: `ambxst → illogical → win11 → 43pr → niri → …`
In a niri session only `niri ↔ ambxst` cycle (the other shells are Hyprland-only).

## How it works

- `bin/dotswap` – snapshot/apply per-profile chezmoi sources. Tracked paths are
  the `TRACKED_*` arrays at the top of the script.
- `bin/dotswap-cycle next|prev` – walks the `PROFILES` array, calls `dotswap use`
  then `dotswap-postapply`.
- `bin/dotswap-postapply <profile>` – stops the old shell, starts the new one,
  reloads Hyprland. Shell starts are `pgrep`-guarded against duplicates.
  `ambxst`/`43pr` are Lua Hyprland configs, `illogical`/`win11` are `.conf`;
  Hyprland picks the format at startup, so a switch across formats finishes
  on the next login (postapply notifies you).

Profile name is stored in `~/.local/state/dotswap-profile`.

## Adding a machine / a profile

- **New machine:** run the quickstart, then the upstream installer for whichever
  rices you actually use.
- **New profile:** set the desktop up the way you want, `dotswap snapshot <name>`,
  add `<name>` to `PROFILES` in `bin/dotswap-cycle`, add a `start_/kill_` case in
  `bin/dotswap-postapply`, push the new branch.
