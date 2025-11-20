# NimLaunch (SDL2)

NimLaunch is a lightweight, keyboard-first launcher with fuzzy search, themes, shortcuts, power actions, and Vim mode. This build uses SDL2 for native Wayland/X11 support (no Xlib/Xft), with GPU-backed compositing for rendering.

## Features
- Fuzzy app search with typo tolerance; MRU bias for empty query.
- Prefix commands: `:t` themes, `:c` config files, `:s` file search, `:p` power actions, `:r` shell run, `!` shorthand, custom shortcuts.
- Vim mode (optional): hjkl navigation, `/ : !` command bar, `gg/G`, `:q`, etc.
- Themes with live preview; clock overlay; status/toast messages.
- Icons from `.desktop` files (PNG/SVG) with a fallback alias map; icons can be toggled off in config.

## Build (Arch examples)
Deps: `nim >= 2.0`, `sdl2`, `sdl2_ttf`, `sdl2_image`, `fontconfig` (fc-match), `librsvg` (`rsvg-convert`), plus a font (default `ttf-dejavu`).
```bash
cd NimLaunch2
nim c -d:release --opt:speed --nimcache=/tmp/nl2cache -o:./bin/nimlaunch src/main.nim
./bin/nimlaunch
```

## Config
Stored at `~/.config/nimlaunch/nimlaunch.toml` (auto-created). Key sections:
- `[window]` width/max_visible_items/center/position.
- `[font]` `fontname` (e.g., `DejaVu Sans:size=12`); resolved via fc-match.
- `[input]` prompt, cursor, `vim_mode` (true/false).
- `[icons]` `enabled` (true/false) to toggle icons.
- `[terminal]` program used for `:r/!`.
- `[border]` width.
- `[[shortcuts]]`, `[power]` + `[[power_actions]]`, `[[themes]]`.

Icons: uses the `.desktop` Icon, lowercased variants, and an alias map (e.g., `code`→`visual-studio-code`, `steam`, `discord`, `firefox`, etc.). SVGs are rasterized via `rsvg-convert`; otherwise a fallback box is shown (or icons can be disabled).

## Vim Mode Notes
- Top prompt hidden; bottom command bar appears when pressing `/ : !`.
- Clock moves to top-right in Vim mode (bottom-right otherwise).
- Standard bindings: `h/j/k/l`, `gg/G`, `Ctrl+H`, `Ctrl+U`, `:q`, Enter to launch.

## Wayland/X11
Runs natively on both via SDL2 (no XWayland required on Wayland). Borderless window like the original. GPU compositing handles fills/icons/text blits; SDL_ttf still rasterizes glyphs in software.
