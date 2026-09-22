# Design Tokens

Audited against the configs on 2026-09-22. This describes what the configs
**actually do**, not an aspiration — where a value disagrees with the system it
is called out under [Known inconsistencies](#known-inconsistencies).

There are two colour layers, and conflating them is what caused the previous
drift:

1. **A neutral grey ramp** — all shell chrome (bar, drawers, menus, surfaces,
   body text). No hue. Roughly `#0a0a0a → #ffffff`.
2. **A small semantic accent set** — state only (urgent, ok, warning, active,
   info). Borrowed from Catppuccin Mocha.

Rule of thumb: **shape and grey communicate structure, accent communicates
state.** If a colour isn't signalling a state, it should come from the grey ramp.

---

## Layer 1 — Neutral ramp

| Token       | Hex       | Used for                                        |
| ----------- | --------- | ----------------------------------------------- |
| `base`      | `#0a0a0a` | Root background: bar, drawers, wallpaper fallback, terminal, lock screen |
| `surface`   | `#111111` | Raised cards: notification card, drawer panel, tray menu |
| `hover`     | `#1a1a1a` | Hover fill on cards and menu rows                |
| `empty`     | `#222222` | Empty workspace dot                              |
| `border`    | `#252525` | Card and menu borders                            |
| `occupied`  | `#3a3a3a` | Occupied workspace dot                           |
| `ghost`     | `#484848` | Disabled text, low-urgency accent bar, separators |
| `line`      | `#505050` | Drawer dividers; Hyprland active window border   |
| `dim`       | `#555555` | Inactive glyph (network/bluetooth off), dot hover |
| `muted`     | `#606060` | Paused media text, secondary menu text           |
| `subtle`    | `#686868` | Notification timestamp and body-muted text       |
| `text-dim`  | `#9a9a9a` | Window title, playing media text                 |
| `text`      | `#b0b0b0` | Clock                                            |
| `text-hi`   | `#e0e0e0` | Notification body, tray menu text                |
| `text-max`  | `#ffffff` | Battery/network nominal state                    |

Two ramp values sit outside the greys and are used as neutrals anyway:

| Token      | Hex       | Used for                                    |
| ---------- | --------- | ------------------------------------------- |
| `overlay1` | `#585b70` | Wallpaper drawer placeholder; terminal selection bg |
| `fg`       | `#cdd6f4` | Terminal foreground; wallpaper drawer text  |

---

## Layer 2 — Semantic accents

| Role                 | Token     | Hex       | Used in                                        |
| -------------------- | --------- | --------- | ---------------------------------------------- |
| Urgent / critical    | `red`     | `#f38ba8` | Battery ≤20%, wifi signal <40, urgent workspace, critical notification |
| Warning              | `peach`   | `#fab387` | Battery ≤50%, wifi signal 40–69                |
| Warning (notif)      | `yellow`  | `#f9e2af` | Notification "disconnected/failed" accent bar  |
| Success / connected  | `green`   | `#a6e3a1` | Battery charging, notification "connected" accent bar |
| Info / active        | `blue`    | `#89b4fa` | Bluetooth connected, notification default accent, active workspace on `HDMI-A-1` |
| Active (primary)     | `pink`    | `#ef9cd8` | Active workspace on `eDP-1`, wallpaper drawer selection, rofi selection |

The two active-workspace colours are deliberate: **pink marks the laptop panel,
blue marks the external monitor**, so the bar tells you which screen has focus.

---

## Terminal / launcher palette

Ghostty's ANSI palette and Rofi's theme share a separate Catppuccin-derived set.
These are *not* used by the shell chrome.

| Slot | Normal    | Bright    |
| ---- | --------- | --------- |
| 0/8  | `#45475a` | `#585b70` |
| 1/9  | `#ef688e` | `#f38ba8` |
| 2/10 | `#8ada83` | `#a6e3a1` |
| 3/11 | `#f6d488` | `#f9e2af` |
| 4/12 | `#649cf8` | `#89b4fa` |
| 5/13 | `#ef9cd8` | `#f5c2e7` |
| 6/14 | `#57c1ff` | `#7dcfff` |
| 7/15 | `#e4e4e7` | `#f4f4f5` |

Ghostty also sets `foreground #cdd6f4`, `background #0a0a0a`,
`cursor-color #f5e0dc`, `selection-background #585b70`.

Rofi (`rofi/colors.rasi`) maps: `bg=#0a0a0a`, `fg=#cdd6f4`, `muted=#45475a`,
`border=#313244`, `accent=#649cf8`, `selected=#ef9cd8`.

---

## Typography

**One family everywhere: `GeistMono Nerd Font`.** No exceptions.

| Surface                | Size   |
| ---------------------- | ------ |
| Ghostty                | 12 pt  |
| Rofi list              | 12     |
| Rofi prompt            | 14     |
| Bar — clock, title, media | 13 px |
| Bar — status glyphs    | 16 px  |
| Drawers / notifications | 10–14 px |
| Hyprlock clock         | 96     |
| Hyprlock date          | 13     |

---

## Per-component reference

### Ghostty (`ghostty/config`)
Background `base`, foreground `fg`, palette above. Padding 12×4, balanced.

### Rofi (`rofi/config.rasi`, `rofi/colors.rasi`)
480 px centred, 1 px `#313244` border, 4 px radius, 5 rows. Selection uses `pink`.

### Quickshell bar (`quickshell/bar/`)
32 px tall, `base` background, `Top` layer, exclusive zone 32.
Left: workspaces, window title. Right: media, tray, bluetooth, network, battery, clock.

### Quickshell notifications (`quickshell/notifications/`)
`NotificationItem.qml` is the only file with **named** colour properties —
`bgColor`, `borderColor`, `textColor`, `mutedColor`, `ghostColor`, `accentColor`,
`urgentColor`, `successColor`, `warnColor`, `hoverColor`. Every other QML file
uses inline literals. Popups are bottom-right, 360 px wide.

### Quickshell wallpaper (`quickshell/wallpaper/`)
`Background` layer, `base` fallback. Drawer uses `pink` selection, `fg` text.

### Hyprland (`hypr/hyprland.lua`)
`col.active_border = rgb(505050)` (`line`), `col.inactive_border = rgb(24262A)`.
Gaps 0, rounding 0, border 2, blur size 3 / vibrancy 0.2.

### Hyprlock (`hypr/hyprlock.conf`)
`$base = rgba(10,10,10,1.0)`, `$foreground = rgba(255,255,255,1.0)`,
`$muted = rgba(88,91,112,1.0)` (= `overlay1`), `$background = rgba(0,0,0,0)`.
Clock colon blinks at 1 Hz via `scripts/lock-clock.sh` as a liveness signal.

### Neovim
`oxocarbon` colorscheme with transparent `Normal`/`NormalFloat`/`NormalNC`/`FloatBorder`.
Independent of the above — it inherits the terminal palette for ANSI only.

---

## Icons

All status glyphs come from the `nf-md` (Material Design) Nerd Font range, so
they share a grid and stroke weight.

| Module    | State        | Glyph | Codepoint |
| --------- | ------------ | ----- | --------- |
| Battery   | any          | `󰪥`   | U+F0AA5   |
| Network   | connected    | `󰪥`   | U+F0AA5   |
| Network   | disconnected | `○`   | U+25CB    |
| Bluetooth | connected    | `󰪥`   | U+F0AA5   |
| Bluetooth | idle         | `○`   | U+25CB    |

**Colour carries all state; the glyph never changes** (beyond present/absent).
Battery pulses at 0.3↔1.0 opacity over 800 ms while charging — and only while
charging, not when full.

Workspace dots are `Rectangle`s, not glyphs: active 18×6 pill (r3), occupied
8×8 (r4), empty 6×6 (r1.5), animated over 150 ms `OutQuint`.

---

## Known inconsistencies

Real divergences, left as-is pending a decision:

1. **Two warning oranges.** The bar uses `#fab387` (Catppuccin peach) for
   battery ≤50% and mid wifi signal; notifications use `#f9e2af`; the terminal
   palette uses `#f6d488`/`#f9e2af`. Three warm tones for one concept.
2. **`#ffffff` for nominal battery/network.** Pure white is brighter than every
   other bar element (clock is `#b0b0b0`), so idle status glyphs are the loudest
   thing on the bar. `text` or `text-hi` would sit better.
3. **Colours are inline literals** in every QML file except `NotificationItem.qml`.
   There is no shared token singleton, which is the mechanical reason this
   document drifted from the code in the first place. A `Theme.qml` singleton
   imported by the bar, drawers and notifications would make drift impossible.
4. **The grey ramp is finely subdivided** — `#484848`, `#505050`, `#555555`,
   `#606060`, `#686868` are five steps within ~15% lightness, used across
   different files for broadly similar jobs. Probably collapsible to three.

---

## Removed from this document

Prior versions described a **Waybar** icon system with 8-step `circle_slice`
battery pies and signal-scaled wifi glyphs. Waybar was replaced by Quickshell and
none of that was ever implemented — the code has always used single fixed glyphs.
It also carried a note that Rofi "should be updated" from Ayu Mirage; that was
done, and `rofi/colors.rasi` now matches the palette.
