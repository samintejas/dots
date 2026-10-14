pragma Singleton

import QtQuick

// Single source of truth for shell colours and typography.
//
// Values follow the Dots design system (bg-base #060606 … text-strong #e2e2e2,
// one accent-warning). Property names are kept; see Design.md.
QtObject {
    // ---- Neutral ramp: structure, never state -------------------------
    readonly property color base: "#060606"       // root background
    readonly property color surface: "#111111"    // resting cards (bg-surface)
    readonly property color hover: Qt.rgba(1, 1, 1, 0.05)      // hover fill
    readonly property color empty: "#1c1c1c"      // empty workspace dot
    readonly property color border: "#232323"     // card / menu borders
    readonly property color occupied: "#383838"   // occupied workspace dot
    readonly property color ghost: "#4a4a4a"      // disabled, low-urgency
    readonly property color line: "#4e4e4e"       // dividers
    readonly property color dim: "#4e4e4e"        // inactive glyph, dot hover
    readonly property color muted: "#808080"      // paused media, menu 2nd text
    readonly property color subtle: "#9c9c9c"     // timestamps, muted body
    readonly property color textDim: "#9c9c9c"    // window title, playing media
    readonly property color text: "#b4b4b4"       // clock
    readonly property color textHi: "#e2e2e2"     // values, menu text, nominal status
    readonly property color textMax: "#f5f5f5"    // current item only (text-max)

    readonly property color raised: "#0f0f0f"     // menus, toasts, tooltips (bg-raised)
    readonly property color overlay: "#060606"    // dialogs, sheets, palette (bg-overlay)
    readonly property color borderRaised: "#232323"   // border-raised, border-strong
    readonly property color borderOverlay: "#232323"  // border-overlay
    readonly property color scrim: Qt.rgba(0, 0, 0, 0.8)
    readonly property color well: "#000000"       // where you type (bg-well)
    readonly property color borderControl: "#6a6a6a"  // switch, checkbox edge
    readonly property color overlay1: "#9c9c9c"   // placeholder text (text-secondary)
    readonly property color fg: "#e2e2e2"         // drawer body text

    // ---- Semantic accents: state, never structure ---------------------
    readonly property color red: "#f38ba8"        // urgent / critical
    readonly property color peach: "#fab387"      // warning (bar)
    readonly property color yellow: "#fab387"     // warning (notifications)
    readonly property color green: "#a6e3a1"      // success / charging
    readonly property color blue: "#89b4fa"       // info / active (external)
    readonly property color pink: "#ef9cd8"       // active (laptop panel)
    readonly property color pinkSubtle: Qt.rgba(239 / 255, 156 / 255, 216 / 255, 0.12)  // accent-primary-subtle
    readonly property color focusRing: Qt.rgba(239 / 255, 156 / 255, 216 / 255, 0.55)   // focus-ring, mark

    // ---- Typography ---------------------------------------------------
    readonly property string font: "GeistMono Nerd Font"
    readonly property int fontSize: 13            // bar text
    readonly property int iconSize: 16            // bar status glyphs

    // ---- Geometry -----------------------------------------------------
    readonly property int barHeight: 32
    readonly property int radiusSm: 3
    readonly property int radiusMd: 4
    readonly property int radiusLg: 6
    readonly property int dur: 150            // dur-base
    readonly property int durSlow: 300        // dur-slow
    readonly property int durPulse: 800       // dur-pulse
}
