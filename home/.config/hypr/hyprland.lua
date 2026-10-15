-- Hyprland config. Requires 0.55+ (hyprlang is deprecated).
-- Reference: https://wiki.hypr.land/configuring/core/advanced-configuration/lua-utilities/

-- ==============================
--  MONITORS
-- ==============================
hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "1920x0", scale = 1 })

-- 1-5 on the laptop panel, 6-10 on the external
for i = 1, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = i <= 5 and "eDP-1" or "HDMI-A-1" })
end


-- ==============================
--  WINDOW RULES
-- ==============================
-- Ignore maximize requests from apps: you decide the size.
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Small utility windows and dialogs float, centred, instead of tiling.
hl.window_rule({
    name = "float-utilities",
    match = { class = "^(pavucontrol|nm-connection-editor|blueman-manager|org\\.gnome\\.Calculator|xdg-desktop-portal-gtk|hyprpolkitagent|nwg-look|swappy)$" },
    float = true,
    center = true,
    size = "720 480",
})

-- File pickers and confirmation dialogs from any app.
hl.window_rule({
    name = "float-file-dialogs",
    match = { title = "^(Open File|Save File|Save As|Choose.*|Select.*|Open Folder|Upload.*|File Upload)$" },
    float = true,
    center = true,
    size = "900 600",
})

-- Browser picture-in-picture: small, floating, pinned over every workspace.
hl.window_rule({
    name = "picture-in-picture",
    match = { title = "^(Picture-in-Picture|Picture in picture)$" },
    float = true,
    pin = true,
    size = "480 270",
    move = "monitor_w-500 monitor_h-290",
})


-- ==============================
--  STARTUP
-- ==============================
hl.on("hyprland.start", function()
    hl.exec_cmd("quickshell")
    hl.exec_cmd("wl-paste --watch ~/.config/hypr/scripts/clip-store.sh")
    hl.exec_cmd("hypridle")
    -- GTK reads these from gsettings on Wayland, not settings.ini; the Dots
    -- colours themselves live in gtk-3.0/gtk.css and gtk-4.0/gtk.css.
    for key, value in pairs({
        ["gtk-theme"] = "adw-gtk3-dark",
        ["color-scheme"] = "prefer-dark",
        ["accent-color"] = "pink",
        ["font-name"] = "GeistMono Nerd Font 10",
        ["document-font-name"] = "Geist 11",
        ["monospace-font-name"] = "GeistMono Nerd Font 10",
    }) do
        hl.exec_cmd("gsettings set org.gnome.desktop.interface " .. key .. " '" .. value .. "'")
    end
end)

hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "phinger-cursors-light")
hl.env("HYPRCURSOR_SIZE", "24")


-- ==============================
--  LOOK & FEEL
-- ==============================
hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 2,
        col = {
            active_border = "rgb(4d4d4d)",
            -- solid, not translucent white: a window that loses focus for a moment
            -- (a Chrome hover card, a dialog closing) flashed a white edge
            inactive_border = "rgb(1f1f1f)",
        },
    },
    decoration = {
        rounding = 0,
        blur = { enabled = false },
    },
    dwindle = { preserve_split = true },
    input = { touchpad = { natural_scroll = true } },
    -- quickshell paints the wallpaper on the background layer
    misc = { force_default_wallpaper = 0 },
})

-- Animation curves and speeds, verbatim from Hyprland's shipped example config.
-- Kept explicitly: these override the compiled-in defaults, so dropping them
-- would change how the WM feels.
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

for _, a in ipairs({
    { leaf = "global",        speed = 10,   bezier = "default" },
    { leaf = "border",        speed = 5.39, bezier = "easeOutQuint" },
    { leaf = "windows",       speed = 4.79, bezier = "easeOutQuint" },
    { leaf = "windowsIn",     speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" },
    { leaf = "windowsOut",    speed = 1.49, bezier = "linear",       style = "popin 87%" },
    { leaf = "fadeIn",        speed = 1.73, bezier = "almostLinear" },
    { leaf = "fadeOut",       speed = 1.46, bezier = "almostLinear" },
    { leaf = "fade",          speed = 3.03, bezier = "quick" },
    { leaf = "layers",        speed = 3.81, bezier = "easeOutQuint" },
    { leaf = "layersIn",      speed = 4,    bezier = "easeOutQuint", style = "fade" },
    { leaf = "layersOut",     speed = 1.5,  bezier = "linear",       style = "fade" },
    { leaf = "fadeLayersIn",  speed = 1.79, bezier = "almostLinear" },
    { leaf = "fadeLayersOut", speed = 1.39, bezier = "almostLinear" },
    { leaf = "workspaces",    speed = 1.94, bezier = "almostLinear", style = "fade" },
    { leaf = "workspacesIn",  speed = 1.21, bezier = "almostLinear", style = "fade" },
    { leaf = "workspacesOut", speed = 1.94, bezier = "almostLinear", style = "fade" },
    { leaf = "zoomFactor",    speed = 7,    bezier = "quick" },
}) do
    a.enabled = true
    hl.animation(a)
end


-- ==============================
--  KEYBINDINGS
-- ==============================
local mod = "SUPER"

-- Apps
hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd("ghostty"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd("ghostty -e yazi"))
hl.bind(mod .. " + P", hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind(mod .. " + TAB", hl.dsp.exec_cmd("qs ipc call launcher windows"))
hl.bind(mod .. " + A", hl.dsp.exec_cmd("qs ipc call quickchat toggle"))
hl.bind(mod .. " + C", hl.dsp.exec_cmd("qs ipc call clipboard toggle"))
hl.bind(mod .. " + N", hl.dsp.exec_cmd("qs ipc call notifications toggle"))
hl.bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd("qs ipc call notifications dnd"))
hl.bind(mod .. " + CTRL + N", hl.dsp.exec_cmd("qs ipc call notifications clear"))
hl.bind(mod .. " + W", hl.dsp.exec_cmd("qs ipc call wallpaper toggle"))
hl.bind(mod .. " + ALT + W", hl.dsp.exec_cmd("qs ipc call panels toggle network"))
hl.bind(mod .. " + ALT + B", hl.dsp.exec_cmd("qs ipc call panels toggle bluetooth"))
hl.bind(mod .. " + Print", hl.dsp.exec_cmd("sshot"))
hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd("sshot-shift"))

-- Window / session
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + I", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mod .. " + F11", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mod .. " + End", hl.dsp.exec_cmd("qs ipc call power toggle"))
hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-theme.sh"))
-- restart the shell (live reload sometimes misses new files)
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("sh -c 'qs kill; sleep 0.5; qs -d'"))
hl.bind(mod .. " + SHIFT + End", hl.dsp.exit())

-- hjkl: focus, +SHIFT move, +CTRL resize
local dirs = { H = "left", L = "right", K = "up", J = "down" }
local steps = { H = { -40, 0 }, L = { 40, 0 }, K = { 0, -40 }, J = { 0, 40 } }
for key, dir in pairs(dirs) do
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = dir }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
    hl.bind(mod .. " + CTRL + " .. key,
        hl.dsp.window.resize({ x = steps[key][1], y = steps[key][2], relative = true }))
end

-- Workspaces
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Monitors
hl.bind(mod .. " + comma", hl.dsp.focus({ monitor = "l" }))
hl.bind(mod .. " + period", hl.dsp.focus({ monitor = "r" }))
hl.bind(mod .. " + SHIFT + comma", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind(mod .. " + SHIFT + period", hl.dsp.window.move({ workspace = "e+1" }))

-- Scratchpad
hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Mouse
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media / brightness — fire while locked, repeat on hold
for _, b in ipairs({
    { "XF86AudioRaiseVolume",  "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+", true },
    { "XF86AudioLowerVolume",  "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",        true },
    { "XF86MonBrightnessUp",   "brightnessctl set 5%+ && qs ipc call osd brightness", true },
    { "XF86MonBrightnessDown", "brightnessctl set 5%- && qs ipc call osd brightness", true },
    { "XF86AudioMute",         "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",       false },
    { "XF86AudioMicMute",      "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",     false },
    { "XF86AudioPlay",         "playerctl play-pause",                             false },
    { "XF86AudioNext",         "playerctl next",                                   false },
    { "XF86AudioPrev",         "playerctl previous",                               false },
}) do
    hl.bind(b[1], hl.dsp.exec_cmd(b[2]), { locked = true, repeating = b[3] })
end
