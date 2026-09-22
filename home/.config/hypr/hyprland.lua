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
--  STARTUP
-- ==============================
hl.on("hyprland.start", function()
    hl.exec_cmd("quickshell")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("~/.config/hypr/scripts/notify-spotify.sh")
    hl.exec_cmd("~/.config/hypr/scripts/notify-battery.sh")
    hl.exec_cmd("~/.config/hypr/scripts/notify-network.sh")
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
            active_border = "rgb(505050)",
            inactive_border = "rgb(24262A)",
        },
    },
    decoration = {
        rounding = 0,
        blur = { size = 3, vibrancy = 0.2 },
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
hl.bind(mod .. " + P", hl.dsp.exec_cmd("rofi -show combi"))
hl.bind(mod .. " + C", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -p clipboard | cliphist decode | wl-copy"))
hl.bind(mod .. " + W", hl.dsp.exec_cmd("qs ipc call wallpaper toggle"))
hl.bind(mod .. " + Print", hl.dsp.exec_cmd("sshot"))
hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd("sshot-shift"))

-- Window / session
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + I", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mod .. " + F11", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mod .. " + End", hl.dsp.exec_cmd("powerctl"))
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
    { "XF86AudioRaiseVolume",   "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+", true },
    { "XF86AudioLowerVolume",   "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",        true },
    { "XF86MonBrightnessUp",    "brightnessctl set 5%+",                            true },
    { "XF86MonBrightnessDown",  "brightnessctl set 5%-",                            true },
    { "XF86AudioMute",          "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",       false },
    { "XF86AudioMicMute",       "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",     false },
    { "XF86AudioPlay",          "playerctl play-pause",                             false },
    { "XF86AudioNext",          "playerctl next",                                   false },
    { "XF86AudioPrev",          "playerctl previous",                               false },
}) do
    hl.bind(b[1], hl.dsp.exec_cmd(b[2]), { locked = true, repeating = b[3] })
end
