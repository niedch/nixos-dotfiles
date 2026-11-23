hl.on("hyprland.start", function()
    -- exec_cmd() is asynchronous; keep this as ONE shell invocation so the
    -- Wayland env is imported before the session target is activated.
    hl.exec_cmd(
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE"
        .. "; systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE"
        .. "; systemctl --user restart xdg-desktop-portal-hyprland xdg-desktop-portal"
        .. "; systemctl --user start hyprland-session.target"
    )
end)
