# Design

These configs implement the **Dots** design system (published as the "Dots"
artifact, source of truth for every value here). Grey carries structure; colour
appears only to say something is selected, in progress or wrong.

## Tokens used (dark)

| token | value | where |
| --- | --- | --- |
| `bg-base` | `#060606` | bar, terminal, lock screen, wallpaper fallback, gtk window, notification drawer |
| `bg-surface` | `#0a0a0a` | resting cards, gtk views |
| `bg-hover` | white at 5% | hover fill (a tint over any layer) |
| `bg-inset` | `#1c1c1c` | empty workspace dot |
| `bg-well` | `#000000` | where you type: launcher, clipboard and password fields |
| `bg-raised` | `#0f0f0f` | popups, tray menu, tooltips, osd, wifi and bluetooth panels, gtk popovers |
| `bg-overlay` | `#060606` | launcher, clipboard, power menu (as deep as the ground, on an 80% scrim) |
| `border-default` / `-raised` / `-overlay` | `#232323` | hairlines and the borders of floating layers; the shadow does the lifting |
| `border-strong` / window border | `#383838` / `#4e4e4e` active | occupied marks; Hyprland active window and the drawer edge |
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
- `hypr/hyprland.lua` — square layout, 2px border (`#4e4e4e` active, `#232323` inactive), no blur.
- `hypr/hyprlock.conf`, `ghostty`, `gtk-3.0`/`gtk-4.0`, `nvim` highlight overrides,
  `btop/themes/dots.theme`, `yazi/flavors/dots.yazi`, `imv`, fzf (`.zshrc`), tuigreet (`misc/config.toml`).

## Shell features

| what | how |
| --- | --- |
| workspace dots | fixed 20px slots, one sliding pill; circle occupied, square empty, diamond urgent; scroll to step |
| hover hints | battery (with time left), network, bluetooth devices, volume, date |
| volume | bar glyph (hollow = muted); scroll ±5%, click mute, right-click mixer |
| osd | volume (any source, via PipeWire) and brightness (`qs ipc call osd brightness`) |
| notifications | toast cards, borderless, full-height severity bar; hover pauses; max 3 popups, `+n more`; repeats collapse; critical popups leave after 20s (they stay in the drawer); clear all |
| system notices | battery (charging, low, critical, full), wi-fi connect/disconnect and Spotify track changes, raised by `notifier/Notifier.qml` from state the shell already watches |
| launcher | `super+p`: apps ranked by use, `= 2+2` calculator, `> cmd` shell command; `super+tab` switches windows |
| quick chat | `super+a`: ask Claude without a session; follow-ups keep context; `^y` copy, `^l` new chat, `^m` haiku/sonnet/opus; `qs ipc call quickchat ask "…"` from scripts. Uses `claude -p` (your login); with `~/.config/anthropic/key` it calls the API directly, which is faster |
| power menu | `super+end`: lock, sleep, log out, restart, shut down; `l s o r p` pick directly |
| wi-fi / bluetooth | click the bar icon, or `super+alt+w` / `super+alt+b`, for a popover: switch, list, join or connect |
| clipboard | `super+c`: filter, enter copies, del removes, clear all (cliphist); copies marked by password managers are not stored |
| keys | `super+n` drawer, `super+shift+n` dnd, `super+ctrl+n` clear notifications, `super+shift+r` restart the shell |
| bar | middle-click clock toggles dnd (`dnd` shown while on) |

## Deliberate deviations

- Severity glyphs and bar icons are Nerd Font (Material) outlines, not Lucide: shapes
  still differ per state (circle, check, triangle, octagon, bell), but the icon set is not Lucide.
- The quickshell wallpaper drawer keeps its own image grid styling beyond colours.
