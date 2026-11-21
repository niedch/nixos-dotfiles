--!nonstrict
local common = require("./common.luau")

local function render(active: boolean)
    shortcut.setLabel(if active then noctalia.tr("active") else noctalia.tr("inactive"))
    shortcut.setIcon("presentation", "presentation-off")
    shortcut.setActive(active == true)
    shortcut.setEnabled(true)
end

noctalia.state.watch(common.STATE_KEY, function(value)
    if type(value) == "table" and value.active ~= nil then
        render(value.active == true)
    end
end)

function onClick()
    common.toggle()
end

-- Initial render
render(common.isActive())
