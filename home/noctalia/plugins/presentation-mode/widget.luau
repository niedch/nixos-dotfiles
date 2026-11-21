--!nonstrict
local common = require("./common.luau")

local function render(active: boolean)
    if active then
        barWidget.setGlyph("presentation")
        barWidget.setGlyphColor("primary")
        barWidget.setText("")
        barWidget.setTooltip(noctalia.tr("tooltip.active"))
    else
        barWidget.setGlyph("presentation-off")
        barWidget.setGlyphColor("on_surface_variant")
        barWidget.setText("")
        barWidget.setTooltip(noctalia.tr("tooltip.inactive"))
    end
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
