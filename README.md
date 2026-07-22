# dotswap – one Hyprland machine, four rices

`dotswap` swaps whole desktop "profiles" (rices) in place using **chezmoi** with a
separate source tree per profile. One keypress cycles the entire shell, bar,
keybinds, terminal theme and Hyprland config.

| Profile     | Shell / bar                | Branch      |
|-------------|----------------------------|-------------|
| `ambxst`    | Ambxst (quickshell + axctl)| `ambxst`    |
| `illogical` | illogical-impulse (`qs -c ii`) | `main`  |
| `win11`     | illogical-impulse, Win11/waffle layout | `win11` |
| `caelestia` | Caelestia (`qs -c caelestia`) | `caelestia` |

Each profile is a branch of this repo; its files live under `dot_config/…`,
`dot_local/…` (chezmoi layout).

## Quickstart

```sh
curl -fsSL https://raw.githubusercontent.com/OckoTajny/dotfiles/installer/install.sh | bash
```

This installs base tools (`git`, `chezmoi`, `yay`), a core dependency set, the
Caelestia shell stack, clones all four profile branches into
`~/.local/share/chezmoi-<profile>/`, drops the `dotswap` tools into
`~/.local/bin/`, and applies the `ambxst` profile.

### Updating

The same script doubles as an updater. Run it with `--update` to pull in only
what's **new** – updated packages and newly added tools – while leaving your
`~/.config` (keybinds, tweaks) completely untouched:

```sh
curl -fsSL https://raw.githubusercontent.com/OckoTajny/dotfiles/installer/install.sh | bash -s -- --update
```

Without `--update` it runs a fresh install and writes the configs; with it,
configs are never re-applied.

> The three desktop shells own their full dependency trees. For a complete
> install of any one rice, also run its upstream installer:
> - **Ambxst** – https://github.com/Axenide/Ambxst
> - **illogical-impulse** – https://github.com/end-4/dots-hyprland
> - **Caelestia** – https://github.com/caelestia-dots/caelestia (`caelestia install`)

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

Cycle order: `ambxst → illogical → win11 → caelestia → …`

## How it works

- `bin/dotswap` – snapshot/apply per-profile chezmoi sources. Tracked paths are
  the `TRACKED_*` arrays at the top of the script.
- `bin/dotswap-cycle next|prev` – walks the `PROFILES` array, calls `dotswap use`
  then `dotswap-postapply`.
- `bin/dotswap-postapply <profile>` – stops the old shell, starts the new one,
  reloads Hyprland. Shell starts are `pgrep`-guarded against duplicates.

Profile name is stored in `~/.local/state/dotswap-profile`.

## Adding a machine / a profile

- **New machine:** run the quickstart, then the upstream installer for whichever
  rices you actually use.
- **New profile:** set the desktop up the way you want, `dotswap snapshot <name>`,
  add `<name>` to `PROFILES` in `bin/dotswap-cycle`, add a `start_/kill_` case in
  `bin/dotswap-postapply`, push the new branch.
