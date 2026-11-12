-- Hyprland configuration (Lua).
-- Hyprland 0.57 removed the legacy hyprlang hyprland.conf; this is its port.
-- Reference: https://wiki.hypr.land/configuring/
-- API stubs: /run/current-system/sw/share/hypr/stubs/hl.meta.lua

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/configuring/core/environment-variables/
hl.env("XCURSOR_THEME", "rose-pine")
hl.env("GTK_CURSOR_THEME", "rose-pine")
hl.env("HYPRCURSOR_THEME", "rose-pine")
hl.env("HYPRCURSOR_SIZE", "36")

-----------------
---- IMPORTS ----
-----------------

-- Each require() is its own scope: an error in one file does not stop the rest.
require("looknfeel")
require("keybinds")

-- monitors.lua is written by hyprdynamicmonitors for whichever displays are
-- attached, so it is gitignored and may not exist yet (desktop/bootstrap.sh
-- seeds it). A missing module would otherwise abort this whole file.
if not pcall(require, "monitors") then
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
end

-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/configuring/core/autostart/
-- Not started here because systemd user units already start them with the
-- session, and a second copy just fails:
--   hyprdynamicmonitors (services.hyprdynamicmonitors in the NixOS config)
--   swaync (swaync.service, shipped with the package)
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprlock")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("waybar")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("hyprctl setcursor rose-pine 36")
end)

---------------
---- INPUT ----
---------------

-- See https://wiki.hypr.land/configuring/core/config-options/
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        scroll_method = "on_button_down",
        scroll_button = 274,

        touchpad = {
            natural_scroll       = true,
            clickfinger_behavior = true,
        },
    },

    -- Disable all Hyprland nags
    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },
})

-- Per-device config, see https://wiki.hypr.land/configuring/core/devices/
hl.device({
    name        = "kingsis-corporation-zowie-gaming-mouse",
    sensitivity = -0.5,
})

-- Keep automated pointer coordinates accurate across logins.
hl.device({
    name          = "ydotoold-virtual-device-1",
    accel_profile = "flat",
    sensitivity   = 0,
})

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/configuring/core/rules/

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})
