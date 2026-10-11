# Design

These configs implement the **Dots** design system (published as the "Dots"
artifact, source of truth for every value here). Grey carries structure; colour
appears only to say something is selected, in progress or wrong.

## Tokens used (dark)

| token | value | where |
| --- | --- | --- |
| `bg-base` | `#0b0b0b` | bar, terminal, lock screen, wallpaper fallback, gtk window |
| `bg-surface` | `#121212` | resting cards, gtk views |
| `bg-hover` | `#1a1a1a` | hover fill |
| `bg-inset` | `#212121` | input wells, empty workspace dot |
| `bg-raised` | `#171717` | popups, tray menu, tooltips, osd |
| `bg-overlay` | `#1c1c1c` | notification drawer, clipboard, rofi |
| `border-default` / `-strong` / `-overlay` | `#262626` / `#383838` / `#4e4e4e` | hairlines; floating layers; sheets |
| `text-secondary` / `primary` / `strong` / `max` | `#9c9c9c` / `#b4b4b4` / `#e2e2e2` / `#f5f5f5` | hints; body; values; current item only |
| `accent-primary` | `#ef9cd8` | selection, current workspace, focus, dnd on |
| `accent-danger` / `warning` / `success` / `info` | `#f38ba8` / `#fab387` / `#a6e3a1` / `#89b4fa` | state only |

`text-subtle` (`#6a6a6a`) and `text-disabled` (`#4a4a4a`) are never used for
text a person has to read. Terminal ANSI colours stay inside the terminal.

## Where each thing lives

- `quickshell/theme/Theme.qml` — the one place for colours, radii, timing.
  Property names are historical (`textHi` = text-strong, `subtle` = text-secondary).
- Type: Geist Mono Nerd Font everywhere, 13px bar, 12px lists and menus, 11px meta.
- Shape: bars square; 3px controls, 4px rows/cards, 6px floating layers; pills only for indicators.
- `hypr/hyprland.lua` — square layout, 2px border (`#4e4e4e` active, `#262626` inactive), no blur.
- `hypr/hyprlock.conf`, `ghostty`, `rofi`, `gtk-3.0`/`gtk-4.0`, `nvim` highlight overrides,
  `btop/themes/dots.theme`, `yazi/flavors/dots.yazi`, `imv`, fzf (`.zshrc`), tuigreet (`misc/config.toml`).

## Shell features

| what | how |
| --- | --- |
| workspace dots | fixed 20px slots, one sliding pill; circle occupied, square empty, diamond urgent; scroll to step |
| hover hints | battery (with time left), network, bluetooth devices, volume, date |
| volume | bar glyph (hollow = muted); scroll ±5%, click mute, right-click mixer |
| osd | volume (any source, via PipeWire) and brightness (`qs ipc call osd brightness`) |
| notifications | toast cards with severity bar + glyph shape; hover pauses; max 3 popups; `+n more`; clear all; dnd |
| clipboard | `super+c`: filter, enter copies, del removes, clear all (cliphist) |
| keys | `super+n` drawer, `super+shift+n` dnd, `super+ctrl+n` clear notifications |
| bar | middle-click clock toggles dnd (`dnd` shown while on); click network = nmtui |

## Deliberate deviations

- Severity glyphs and bar icons are Nerd Font (Material) outlines, not Lucide: shapes
  still differ per state (circle, check, triangle, octagon, bell), but the icon set is not Lucide.
- The quickshell wallpaper drawer keeps its own image grid styling beyond colours.
