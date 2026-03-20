# Design Tokens

Base: custom dark background (#0a0a0a instead of #1e1e2e)

---

## Palette

### Base

| Token      | Hex       | Usage                     |
| ---------- | --------- | ------------------------- |
| `base`     | `#0a0a0a` | Terminal/bar background   |
| `surface0` | `#1e1e2e` | Elevated surfaces         |
| `surface1` | `#313244` | Borders, separators       |
| `overlay0` | `#45475a` | Disabled, muted           |
| `overlay1` | `#585b70` | Subtle text, inactive     |
| `subtext`  | `#a6adc8` | Secondary text            |
| `text`     | `#cdd6f4` | Primary text / foreground |

### Accent

| Token          | Hex       | Usage                        |
| -------------- | --------- | ---------------------------- |
| `red`          | `#ef688e` | Errors, critical             |
| `red-bright`   | `#f38ba8` | Urgent, critical states      |
| `peach`        | `#f6d488` | Warnings                     |
| `peach-bright` | `#f9e2af` | Warning states               |
| `green`        | `#8ada83` | Success, battery ok          |
| `green-bright` | `#a6e3a1` | Charging, connected          |
| `teal`         | `#57c1ff` | Network, links               |
| `teal-bright`  | `#7dcfff` | Active network               |
| `blue`         | `#649cf8` | Primary accent               |
| `blue-bright`  | `#89b4fa` | Bluetooth, info              |
| `mauve`        | `#cba6f7` | Misc accent                  |
| `pink`         | `#ef9cd8` | Active workspace, highlights |
| `pink-bright`  | `#f5c2e7` | Cursor, selection            |
| `flamingo`     | `#f2cdcd` | Gentle accent                |

### Border / Window Manager

| Token             | Hex       | Usage                    |
| ----------------- | --------- | ------------------------ |
| `border-active`   | `#505050` | Hyprland active border   |
| `border-inactive` | `#24262a` | Hyprland inactive border |

---

## Semantic Mappings

| Role                   | Token          | Hex       |
| ---------------------- | -------------- | --------- |
| Background             | `base`         | `#0a0a0a` |
| Foreground / text      | `text`         | `#cdd6f4` |
| Muted text             | `overlay1`     | `#585b70` |
| Dim text               | `overlay0`     | `#45475a` |
| Primary accent         | `blue`         | `#649cf8` |
| Active / selected      | `pink`         | `#ef9cd8` |
| Success / ok           | `green`        | `#8ada83` |
| Warning                | `peach`        | `#f6d488` |
| Error / critical       | `red`          | `#ef688e` |
| Network (connected)    | `text`         | `#cdd6f4` |
| Network (disconnected) | `overlay0`     | `#45475a` |
| Bluetooth (connected)  | `blue-bright`  | `#89b4fa` |
| Bluetooth (off/idle)   | `overlay0`     | `#45475a` |
| Battery ok             | `green`        | `#8ada83` |
| Battery charging       | `green-bright` | `#a6e3a1` |
| Battery warning        | `peach`        | `#f6d488` |
| Battery critical       | `red-bright`   | `#f38ba8` |

---

## Per-Config Reference

### Ghostty (`config/ghostty/config`)

Background overridden to `#0a0a0a`.

### Waybar (`config/waybar/style.css`)

Should use semantic mappings above.

### Hyprland (`config/hypr/hyprland.conf`)

- `col.active_border`: `border-active` (`#505050`)
- `col.inactive_border`: `border-inactive` (`#24262a`)

### Hyprlock (`config/hypr/hyprlock.conf`)

- `$color1`: `border-active` (`rgba(80, 106, 150, 1.0)`)
- `$foreground`: `text` (`rgba(205, 214, 244, 1.0)`)
- `$background`: `base` transparent

### Rofi (`config/rofi/colors.rasi`)

Currently uses Ayu Mirage — should be updated to match this palette.

---

## Font

- **Primary**: GeistMono Nerd Font, 12pt (terminal) / 13px (bar)
- **Size scale**: terminal 12pt → bar 13px → window title 11px

---

## Icon System (Waybar)

All right-side modules use a single fixed icon — no variable-icon arrays.

All right-side icons use `nf-md` (Material Design Nerd Font) exclusively — same grid, same stroke weight, consistent optical alignment.

| Module                  | Icon                   | Codepoint | Note                          |
| ----------------------- | ---------------------- | --------- | ----------------------------- |
| Battery 12.5%           | `󰪞` circle_slice_1    | U+F0A9E   | pie fills as level rises      |
| Battery 25%             | `󰪟` circle_slice_2    | U+F0A9F   |                               |
| Battery 37.5%           | `󰪠` circle_slice_3    | U+F0AA0   |                               |
| Battery 50%             | `󰪡` circle_slice_4    | U+F0AA1   |                               |
| Battery 62.5%           | `󰪢` circle_slice_5    | U+F0AA2   |                               |
| Battery 75%             | `󰪣` circle_slice_6    | U+F0AA3   |                               |
| Battery 87.5%           | `󰪤` circle_slice_7    | U+F0AA4   |                               |
| Battery 100% / plugged  | `󰪥` circle_slice_8    | U+F0AA5   |                               |
| Battery charging        | `󰻂` record_circle     | U+F0EC2   | pulse animation               |
| WiFi (signal-based)     | `󰪞…󰪥` slices 1,3,4,6,8| U+F0A9E…  | dim→bright by signal          |
| WiFi disconnected       | `󱃓` circle_off_outline | U+F10D3   | circle with slash             |
| WiFi ethernet           | `󰪥` circle_slice_8    | U+F0AA5   | full = stable                 |
| Bluetooth idle          | `󰧟` circle_small      | U+F09DF   | tiny dot = quiet              |
| Bluetooth connected     | `󰻂` record_circle     | U+F0EC2   | dot-in-circle = paired device |
| Notifications           | `󰵛` bell_circle_outline| U+F0D5B  | circle with bell              |

**Rule**: All icons from `nf-md` family only. Shape communicates type, CSS color communicates state. Charging battery uses pulse animation. No percentage text.
