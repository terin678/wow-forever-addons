local addonName, ns = ...

--[[
The icon on the screen: a small square that stays where it is dragged, for the things worth
a click without opening the panel. Today that is the goggles. A click opens the menu, a
drag moves it, and while a pair of goggles is on it wears that pair's icon.

/tuner hud shows or hides it. Where it sits, and whether it is shown, are per character.
]]

local W = LibStub("LibKeelWidgets-1.0")

local Hud = {}
ns.Hud = Hud

local SIZE = 36    -- pixels, at the interface's own scale
local DEFAULT_X, DEFAULT_Y = 0.02, 0.45    -- fractions of the screen: the left edge, halfway down

local frame
local downX, downY

-- The goggles as menu rows; the Addon Compartment's menu shows the same ones.
function Hud.GogglesItems()
    local items = { { title = "Goggles" } }
    for _, mode in ipairs(ns.Catalog.GOGGLES) do
        items[#items + 1] = {
            text = mode.label,
            checked = function() return ns.Goggles() == mode end,
            onClick = function() ns.SetGoggles(ns.Goggles() ~= mode and mode or nil) end,
        }
    end
    return items
end

local function Menu()
    local items = Hud.GogglesItems()
    items[#items + 1] = { divider = true }
    items[#items + 1] = { text = "Open RenderTuner", onClick = function() ns.Panel.Toggle() end }
    items[#items + 1] = { text = "Hide this icon", onClick = function() Hud.SetShown(false) end }
    W.Menu(frame, items)
end

local function Tip(tip)
    local mode = ns.Goggles()
    tip:AddLine("RenderTuner")
    tip:AddLine(mode and (mode.label .. " are on") or "No goggles on", 1, 1, 1)
    tip:AddLine("Click for the goggles", 0.7, 0.7, 0.7)
    tip:AddLine("Drag to move", 0.7, 0.7, 0.7)
end

-- Called once, at login, when the saved settings are in hand.
function Hud.Create()
    if frame then return end
    local hud = ns.cdb.hud
    frame = W.Panel(UIParent, {
        name = "RenderTunerHud", width = SIZE, height = SIZE, movable = true, strata = "MEDIUM",
        onMoved = function(self) hud.x, hud.y = W.GetPlace(self) end,
    })
    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetPoint("TOPLEFT", 2, -2)
    frame.icon:SetPoint("BOTTOMRIGHT", -2, 2)
    frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    -- The panel's own scripts do the dragging. These run after them and tell a click from
    -- a drag by whether the icon ended up where it started.
    frame:HookScript("OnMouseDown", function(self) downX, downY = W.GetPlace(self) end)
    frame:HookScript("OnMouseUp", function(self)
        local x, y = W.GetPlace(self)
        if x == downX and y == downY then Menu() end
    end)
    W.Tooltip(frame, Tip, "ANCHOR_RIGHT")
    W.SetPlace(frame, hud.x or DEFAULT_X, hud.y or DEFAULT_Y)
    Hud.Refresh()
end

function Hud.Refresh()
    if not frame then return end
    local mode = ns.Goggles()
    frame.icon:SetTexture(mode and mode.icon or ns.Launcher.ICON)
    frame:SetShown(ns.cdb.hud.shown)
end

function Hud.SetShown(on)
    ns.cdb.hud.shown = on and true or false
    Hud.Create()
    Hud.Refresh()
    if not on then ns.Print("the icon is hidden. /tuner hud brings it back.") end
end
