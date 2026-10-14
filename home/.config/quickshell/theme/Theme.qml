pragma Singleton

import QtQuick
import Quickshell.Io

// Single source of truth for shell colours and typography.
//
// Values follow the Dots design system v9 (tokens.css). Dark is canonical;
// light is the same roles on the light ramp. Property names are historical and
// kept so the panels don't change; Design.md maps each one to its token.
//
// mode: "system" follows org.gnome.desktop.interface color-scheme
// (prefer-light = light, anything else = dark); "dark" / "light" pin it.
// Switch with `qs ipc call theme set light|dark|system`.
QtObject {
    id: theme

    property string mode: "system"
    property bool systemLight: false
    readonly property bool light: mode === "light" || (mode === "system" && systemLight)

    readonly property var darkPalette: ({
        base:          "#080808",                   // bg-base
        surface:       "#111111",                   // bg-surface
        raised:        "#181818",                   // bg-raised
        raisedHover:   "#262626",                   // bg-raised + bg-hover
        overlay:       "#1f1f1f",                   // bg-overlay
        hover:         Qt.rgba(1, 1, 1, 0.06),      // bg-hover
        field:         Qt.rgba(1, 1, 1, 0.035),     // bg-field
        empty:         "#292929",                   // neutral-4
        occupied:      "#383838",                   // neutral-5
        line:          "#4d4d4d",                   // neutral-6
        borderSubtle:  Qt.rgba(1, 1, 1, 0.07),      // border-subtle
        borderDefault: Qt.rgba(1, 1, 1, 0.13),      // border-default
        borderStrong:  "#707070",                   // border-strong
        borderFocus:   "#ececec",                   // border-focus
        disabled:      "#5c5c5c",                   // text-disabled
        textSubtle:    "#8a8a8a",                   // text-subtle
        secondary:     "#9e9e9e",                   // text-secondary
        primary:       "#b8b8b8",                   // text-primary
        strong:        "#dcdcdc",                   // text-strong
        max:           "#ececec",                   // text-max
        scrim:         Qt.rgba(0, 0, 0, 0.72),      // scrim
        selection:     Qt.rgba(1, 1, 1, 0.2),       // selection
        accent:        "#f0a0dc",                   // accent-primary
        accentSubtle:  Qt.rgba(240 / 255, 160 / 255, 220 / 255, 0.14),
        danger:        "#f2553f",                   // accent-danger
        warning:       "#f0b14a",                   // accent-warning
        success:       "#5fcf7f",                   // accent-success
        info:          "#6aa8ff",                   // accent-info
        onAccent:      "#0a0a0a"                    // on-accent-*
    })

    readonly property var lightPalette: ({
        base:          "#f2f2f2",
        surface:       "#f9f9f9",
        raised:        "#ffffff",
        raisedHover:   "#f4f4f4",
        overlay:       "#ffffff",
        hover:         Qt.rgba(0, 0, 0, 0.045),
        field:         "#ffffff",
        empty:         "#c4c4c4",
        occupied:      "#a8a8a8",
        line:          "#8a8a8a",
        borderSubtle:  Qt.rgba(0, 0, 0, 0.08),
        borderDefault: Qt.rgba(0, 0, 0, 0.14),
        borderStrong:  "#8a8a8a",
        borderFocus:   "#141414",
        disabled:      "#a3a3a3",
        textSubtle:    "#6b6b6b",
        secondary:     "#555555",
        primary:       "#3a3a3a",
        strong:        "#222222",
        max:           "#141414",
        scrim:         Qt.rgba(10 / 255, 10 / 255, 10 / 255, 0.4),
        selection:     Qt.rgba(0, 0, 0, 0.14),
        accent:        "#9a1c78",
        accentSubtle:  Qt.rgba(154 / 255, 28 / 255, 120 / 255, 0.1),
        danger:        "#c43a12",
        warning:       "#8a4a00",
        success:       "#1d7a3a",
        info:          "#1a5dcc",
        onAccent:      "#ffffff"
    })

    readonly property var p: light ? lightPalette : darkPalette

    // ---- Layers: forward is lighter ------------------------------------
    readonly property color base: p.base          // bar, drawer (bg-base)
    readonly property color surface: p.surface    // resting cards (bg-surface)
    readonly property color raised: p.raised      // menus, toasts, tooltips, osd (bg-raised)
    readonly property color raisedHover: p.raisedHover // a hovered toast
    readonly property color overlay: p.overlay    // launcher, clipboard, power, quick chat (bg-overlay)
    readonly property color hover: p.hover        // hover fill, a tint over any layer
    readonly property color well: p.field         // where you type (bg-field)
    readonly property color scrim: p.scrim
    readonly property color selection: p.selection // selected text

    // ---- Lines: a quiet line decorates, a control edge is 3:1 ----------
    readonly property color border: p.borderSubtle         // dividers inside a component
    readonly property color borderRaised: p.borderDefault  // edge of a floating layer
    readonly property color borderOverlay: p.borderDefault
    readonly property color borderControl: p.borderStrong  // fields, switches, checkboxes
    readonly property color focusRing: p.borderFocus       // 2px, max ink

    // ---- Neutral marks: structure, never state -------------------------
    readonly property color empty: p.empty        // empty workspace dot, osd track
    readonly property color occupied: p.occupied  // occupied workspace dot
    readonly property color line: p.line          // drawer edge, = Hyprland active border
    readonly property color dim: p.line           // inactive glyph, dot hover

    // ---- Text ----------------------------------------------------------
    readonly property color ghost: p.disabled     // text-disabled
    readonly property color muted: p.textSubtle   // text-subtle: paused media, menu 2nd text
    readonly property color subtle: p.secondary   // text-secondary: timestamps, hints
    readonly property color textDim: p.secondary  // window title, playing media
    readonly property color overlay1: p.secondary // placeholder text
    readonly property color text: p.primary       // text-primary: clock, body
    readonly property color textHi: p.strong      // text-strong: values, menu text
    readonly property color fg: p.strong          // drawer body text
    readonly property color textMax: p.max        // text-max: current item only

    // ---- Semantic accents: state, never structure ----------------------
    readonly property color red: p.danger         // urgent / critical
    readonly property color peach: p.warning      // warning (bar)
    readonly property color yellow: p.warning     // warning (notifications)
    readonly property color green: p.success      // success / charging
    readonly property color blue: p.info          // info / active (external)
    readonly property color pink: p.accent        // accent-primary: selection, current, dnd on
    readonly property color pinkSubtle: p.accentSubtle
    readonly property color onAccent: p.onAccent

    // ---- Typography ----------------------------------------------------
    readonly property string font: "GeistMono Nerd Font"  // the interface
    readonly property string fontSans: "Geist"            // paragraphs a person reads
    readonly property int fontSize: 13            // bar text (font-size-sm)
    readonly property int iconSize: 16            // bar status glyphs (icon-size)

    // ---- Geometry ------------------------------------------------------
    readonly property int barHeight: 32
    readonly property int radiusSm: 3
    readonly property int radiusMd: 5
    readonly property int radiusLg: 8
    readonly property int focusWidth: 2
    readonly property int dur: 150            // dur-base
    readonly property int durSlow: 300        // dur-slow
    readonly property int durPulse: 800       // dur-pulse

    // ---- Follow the OS colour scheme -----------------------------------
    function readScheme(line) {
        theme.systemLight = line.indexOf("prefer-light") >= 0
    }

    property Process schemeNow: Process {
        running: true
        command: ["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"]
        stdout: SplitParser { onRead: data => theme.readScheme(data) }
    }

    property Process schemeWatch: Process {
        running: true
        command: ["gsettings", "monitor", "org.gnome.desktop.interface", "color-scheme"]
        stdout: SplitParser { onRead: data => theme.readScheme(data) }
    }
}
