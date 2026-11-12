-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/configuring/core/config-options/

-- Matugen colors. colors.lua is generated from the current wallpaper (see
-- desktop/matugen/templates/hyprland-colors.lua) and is gitignored, so fall
-- back to a fixed palette until desktop/bootstrap.sh has produced it.
local ok, c = pcall(require, "colors")
if not ok or type(c) ~= "table" then
    c = {
        primary_container   = "rgba(00504dff)",
        secondary_container = "rgba(324b4aff)",
        surface             = "rgba(0e1514ff)",
        error               = "rgba(ffb4abff)",
    }
end

hl.config({
    general = {
        col = {
            active_border   = { colors = { c.primary_container, c.secondary_container }, angle = 45 },
            inactive_border = c.surface,
        },
        border_size = 1,
        gaps_in     = 2,
        gaps_out    = 4,

        -- Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/configuring/extra/tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding = 10,

        shadow = {
            enabled      = true,
            range        = 15,
            render_power = 4, -- was 5; Hyprland 0.57 caps this at 4
            offset       = { 0, 0 },
        },

        blur = {
            enabled           = true,
            size              = 1,
            passes            = 4,
            contrast          = 1.1,
            brightness        = 1.1,
            vibrancy          = 0.2,
            vibrancy_darkness = 0.2,
            noise             = 0.03,
            ignore_opacity    = true,
            new_optimizations = true,
        },

        active_opacity     = 0.93,
        inactive_opacity   = 0.92,
        fullscreen_opacity = 1.0,
    },

    animations = {
        enabled = true,
    },

    -- See https://wiki.hypr.land/configuring/layouts/dwindle-layout/ for more
    dwindle = {
        -- Pseudotiling is per-window only: toggle it with mainMod + P.
        preserve_split = true, -- You probably want this
    },

    -- See https://wiki.hypr.land/configuring/layouts/master-layout/ for more
    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper  = -1,   -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo    = true, -- If true disables the random hyprland logo / anime girl background. :(
        disable_splash_rendering = true,
    },

    cursor = {
        hide_on_key_press = true,
        inactive_timeout  = 3,
    },
})

-- See https://wiki.hypr.land/configuring/core/animations/
hl.curve("calm", { type = "bezier", points = { { 0.25, 0.9 }, { 0.35, 1 } } })

hl.animation({ leaf = "windows",     enabled = true, speed = 4, bezier = "calm" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 4, bezier = "calm" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "calm" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "calm" })

hl.animation({ leaf = "fade",        enabled = true, speed = 3, bezier = "calm" })
hl.animation({ leaf = "fadeIn",      enabled = true, speed = 3, bezier = "calm" })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 2, bezier = "calm" })

hl.animation({ leaf = "layers",      enabled = true, speed = 3, bezier = "calm" })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 3, bezier = "calm" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 2, bezier = "calm" })

hl.animation({ leaf = "workspaces",  enabled = true, speed = 4, bezier = "calm" })

-- Ref https://wiki.hypr.land/configuring/core/rules/workspace-rules/
-- "Smart gaps" / "No gaps when only"
local smart_gaps = { top = 4, right = 0, bottom = 0, left = 0 }
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = smart_gaps, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = smart_gaps, gaps_in = 0 })

hl.window_rule({
    name  = "no-gaps-wtv1",
    match = { float = false, workspace = "w[tv1]" },

    border_size = 0,
    rounding    = 10,
})

hl.window_rule({
    name  = "no-gaps-f1",
    match = { float = false, workspace = "f[1]" },

    border_size = 0,
    rounding    = 10,
})

-- WINDOW RULE
hl.window_rule({ border_color = c.error })

-- LAYER RULES
hl.layer_rule({
    name  = "layer-notifications",
    match = { namespace = "swaync-notification-window|swaync-control-center" },

    animation    = "fade",
    blur         = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name  = "layer-overlays-fade",
    match = { namespace = "swayosd|selection|hyprlock" },

    animation = "fade",
})

hl.layer_rule({
    name  = "layer-hyprpicker",
    match = { namespace = "hyprpicker" },

    no_anim = true,
})

hl.layer_rule({
    name  = "layer-waybar",
    match = { namespace = "waybar" },

    blur         = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name  = "layer-rofi",
    match = { namespace = "rofi" },

    animation    = "slidein 800%",
    blur         = true,
    ignore_alpha = 0.5,
})
