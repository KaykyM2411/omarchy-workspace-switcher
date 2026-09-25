# Omarchy Workspace Switcher

A theme-aware workspace overview for the Omarchy Shell. Open it with a keyboard shortcut, see numbered workspaces and window previews, then select one with the mouse or keyboard.

## Features

- Shows occupied, numbered workspaces across connected monitors.
- Shows up to four window previews per workspace.
- Centers cards in incomplete rows.
- Uses the current Omarchy Shell colors, typography, spacing, and corners.
- Opens on demand; previews stop capturing when the panel closes.
- Supports arrow keys or Tab to navigate, Enter to select, and Escape to close.

## Requirements

- Omarchy Shell with `omarchy plugin` support (tested with Omarchy 4.0.4).
- Quickshell with `ScreencopyView` and Hyprland toplevel capture support (tested with Quickshell 0.3.1 and Hyprland 0.56.2).

## Install

```bash
omarchy plugin add https://github.com/KaykyM2411/omarchy-workspace-switcher.git --enable
```

Add a shortcut to `~/.config/hypr/bindings.lua`:

```lua
o.bind("SUPER + ALT + W", "Workspace switcher", "omarchy-shell shell toggle kaykym.workspace-switcher")
```

Check `omarchy menu keybindings --print` first if you choose a different shortcut. Hyprland reloads the binding when the file is saved. Open the switcher with the shortcut, or run:

```bash
omarchy-shell shell toggle kaykym.workspace-switcher
```

To update a Git-installed copy, run `omarchy plugin update kaykym.workspace-switcher`.

## Como usar

O painel mostra os workspaces numerados que têm janelas abertas, inclusive em outros monitores. Clique numa miniatura para ir ao workspace. Também é possível navegar com as setas ou Tab, confirmar com Enter e fechar com Esc.

## Notes

- Previews show application windows, not the wallpaper or the complete monitor image.
- Special and empty workspaces are omitted. A workspace with more than four windows shows previews of the first four.
- Window capture depends on the compositor exposing the Hyprland toplevel export protocol. A window without an available capture handle has an empty preview until the handle appears.
- This plugin runs inside the Omarchy Shell process. Review the source before installing a plugin from any repository.

## Development

The repository root is the Omarchy plugin folder: `manifest.json` declares the `panel` entry point, and `Panel.qml` contains the UI. Validate changes with:

```bash
omarchy plugin validate .
```

For local development, copy these files to `~/.config/omarchy/plugins/kaykym.workspace-switcher/` and run `omarchy-shell shell rescanPlugins` if the shell does not detect a change.
