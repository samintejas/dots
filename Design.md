# Design

These configs implement the **Dots** design system, v9.1 (the "Dots Design System"
artifact is the source of truth for every value here; `tokens.css` there holds them all).
Grey carries structure; colour appears only to say something is selected, in progress
or wrong. Layers get lighter going forward: base, surface, raised, overlay.

## Tokens used (dark, canonical)

| token | value | where |
| --- | --- | --- |
| `bg-base` | `#080808` | bar, terminal, lock screen, wallpaper fallback, gtk window, notification drawer |
| `bg-surface` | `#111111` | resting cards, gtk views, nvim cursor line |
| `bg-raised` | `#181818` | popups, tray menu, tooltips, osd, wifi and bluetooth panels, gtk popovers, nvim pmenu, fzf current line, imv overlay |
| `bg-overlay` | `#1f1f1f` | launcher, clipboard, power menu, quick chat, gtk dialogs (on a 72% `scrim`) |
| `bg-hover` | white at 6% | hover fill, a tint over any layer |
| `bg-field` | white at 3.5% | where you type: launcher, clipboard, quick chat, wi-fi password, gtk entries, lock screen |
| `border-subtle` | white at 7% | dividers inside a component, gtk separators |
| `border-default` | white at 13% | edges of floating layers; Hyprland inactive window border |
| `border-strong` | `#707070` | field, switch and checkbox edges (3:1 on every layer) |
| `border-focus` | `#ececec` | focus: 2px, max ink |
| `neutral-4` / `-5` / `-6` | `#292929` / `#383838` / `#4d4d4d` | empty / occupied workspace dot; Hyprland active border and drawer edge |
| `text-secondary` / `primary` / `strong` / `max` | `#9e9e9e` / `#b8b8b8` / `#dcdcdc` / `#ececec` | hints; body; values; current item only |
| `selection` | white at 20% | selected text |
| `accent-primary` | `#f0a0dc` | selection marks, current workspace, dnd on |
| `accent-danger` / `warning` / `success` / `info` | `#f2553f` / `#f0b14a` / `#5fcf7f` / `#6aa8ff` | state only |

`text-subtle` (`#8a8a8a`) and `text-disabled` (`#5c5c5c`) are never used for text a
person has to read. The terminal palette (`term-0`..`term-15`, `code-*`) is unchanged
from v8 and stays inside the terminal.

## Light, dark and system

Light is the same roles on the light ramp (`bg-base` `#f2f2f2`, raised and overlay
white, `accent-primary` `#9a1c78`, see `tokens.css`).

| tool | follows the OS | how |
| --- | --- | --- |
| quickshell | yes | `Theme.mode` is `system` by default: it watches `org.gnome.desktop.interface color-scheme` (`prefer-light` = light). Pin with `qs ipc call theme set light`, `dark` or back to `system` |
| GTK 4 / libadwaita | yes (GTK 4.16+) | `gtk-4.0/gtk.css` keeps every colour in `--dots-*` variables, with a `prefers-color-scheme: light` block |
| GTK 3, ghostty, nvim, yazi, fzf, imv, hyprlock, Hyprland borders | dark only | GTK 3 has no media query; the design system defines the terminal palette for dark only |

`super+shift+t` (`hypr/scripts/toggle-theme.sh`) flips the OS colour scheme.
Hyprland sets it to `prefer-dark` at start.

## Where each thing lives

- `quickshell/theme/Theme.qml`: the one place for shell colours, radii, timing, with a
  dark and a light palette. Property names are historical (`textHi` = text-strong,
  `subtle` = text-secondary, `well` = bg-field, `border` = border-subtle,
  `borderRaised` = border-default, `borderControl` = border-strong, `focusRing` = border-focus).
- Type: the interface is Geist Mono (Nerd Font build) on the scale 12, 13, 14, 16, 20, 24,
  32, 48, 96: 13px bar, 12px lists, menus and meta (nothing below 12). Paragraphs a person
  reads set in **Geist**: notification bodies (13px), quick chat answers (14px), and
  GTK's document font.
- Shape: bars and layout tiles square; `radius-sm` 3px controls, `radius-md` 5px
  rows and cards, `radius-lg` 8px floating layers; pills only for indicators.
- `hypr/hyprland.lua`: square layout, 2px border (`neutral-6` active, `border-default` inactive), no blur.
- `hypr/hyprlock.conf`, `ghostty`, `gtk-3.0`/`gtk-4.0`, `nvim` highlight overrides,
  `yazi/flavors/dots.yazi`, `imv`, fzf (`.zshrc`), tuigreet (`misc/config.toml`, named ANSI colours).

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
| theme | `super+shift+t` flips light and dark; `qs ipc call theme set system\|dark\|light` |
| keys | `super+n` drawer, `super+shift+n` dnd, `super+ctrl+n` clear notifications, `super+shift+r` restart the shell |
| bar | middle-click clock toggles dnd (`dnd` shown while on) |

## Deliberate deviations

- Severity glyphs and bar icons are Nerd Font (Material) outlines, not Lucide: shapes
  still differ per state (circle, check, triangle, octagon, bell), but the icon set is not Lucide.
- The desktop bar is 32px, not `bar-h` (44px, an app's top bar); it is a status line.
- Inner spacing in the shell panels predates v9's 8 / 16 / 32 gaps and 36px rows and
  has not been re-laid out yet.
- The quickshell wallpaper drawer keeps its own image grid styling beyond colours.
