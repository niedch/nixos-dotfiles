local hostname = (function()
    local f = io.open("/etc/hostname", "r")
    if f then
        local h = f:read("*l")
        f:close()
        return h and h:gsub("%s+", "")
    end
    return os.getenv("HOSTNAME") or ""
end)()

if hostname == "desktop" then
    hl.monitor({
        output   = "desc:iiyama Corporation PL2760Q 1154112201014",
        mode     = "2560x1440@143.86Hz",
        position = "0x0",
        scale    = 1,
    })
    hl.monitor({
        output   = "desc:iiyama Corporation PL2760H 1164004201390",
        mode     = "1920x1080@143.98Hz",
        position = "auto-left",
        scale    = 1,
    })
else
    hl.monitor({
        output   = "desc:iiyama Corporation PL2760Q 1154112201014",
        mode     = "1920x1080@60Hz",
        position = "0x0",
        scale    = 1,
    })
    hl.monitor({
        output   = "desc:iiyama Corporation PL2760H 1164004201390",
        mode     = "1920x1080@60Hz",
        position = "auto-left",
        scale    = 1,
    })
end

hl.monitor({
    output   = "desc:Sharp Corporation 0x149A",
    mode     = "preferred",
    position = "auto-right",
    scale    = 1,
})

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})
