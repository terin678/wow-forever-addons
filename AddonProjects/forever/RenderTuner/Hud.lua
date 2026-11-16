local addonName, ns = ...

--[[
The icon on the screen: a small square that stays where it is dragged, for the things worth
a click without opening the panel. Today that is the goggles.

A click opens a ring of options around it, one per pair of goggles, which spiral out of the
icon; a click on one puts that pair on or takes it off, and the ring stays open until the
icon is clicked again, when they spiral back into it. A right-click is
the menu, a drag moves the icon, and while a pair is on the icon wears that pair's picture.

Where an option is at each moment is Model.RingSpot, which is pure. The ring is animated
by an OnUpdate that is set only while it is opening or closing. Nothing here is particular
to RenderTuner but the options; it moves to Keel when a second addon wants a ring.

/tuner hud shows or hides the icon. Where it sits, and whether it is shown, are per character.
]]

local W = LibStub("LibKeelWidgets-1.0")
local Util = LibStub("LibKeelUtil-1.0")

local Hud = {}
ns.Hud = Hud

local SIZE = 36            -- pixels, at the interface's own scale
local OPTION = 32          -- an option in the ring
local OPEN, CLOSE = 0.45, 0.28    -- seconds for the ring to open and to close
local DEFAULT_X, DEFAULT_Y = 0.02, 0.45    -- fractions of the screen: the left edge, halfway down

local frame
local downX, downY
-- t: how far open the ring is, 0 to 1. dir: 1 opening, -1 closing.
local ring = { options = {}, t = 0, dir = -1, facing = 0 }

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
    tip:AddLine(ring.dir > 0 and "Click to put the goggles away" or "Click for the goggles", 0.7, 0.7, 0.7)
    tip:AddLine("Right-click for the menu", 0.7, 0.7, 0.7)
    tip:AddLine("Drag to move", 0.7, 0.7, 0.7)
end

--------------------------------------------------------------------------------
-- The ring
--------------------------------------------------------------------------------

local function PlaceRing()
    local count = #ring.options
    for index, option in ipairs(ring.options) do
        local x, y, scale, alpha = ns.Model.RingSpot(index, count, ns.Model.RingProgress(index, count, ring.t), ring.facing)
        option:SetScale(scale)
        option:ClearAllPoints()
        -- An offset is measured in the option's own scale.
        option:SetPoint("CENTER", frame, "CENTER", x / scale, y / scale)
        option:SetAlpha(alpha)
        option:SetShown(ring.t > 0)
    end
end

local function Tick(_, elapsed)
    ring.t = Util.Clamp(ring.t + ring.dir * elapsed / (ring.dir > 0 and OPEN or CLOSE), 0, 1)
    PlaceRing()
    if ring.t == 0 or ring.t == 1 then frame:SetScript("OnUpdate", nil) end
end

local SetOpen

local function BuildRing()
    for _, mode in ipairs(ns.Catalog.GOGGLES) do
        local option = W.Panel(frame, { width = OPTION, height = OPTION })
        option.mode = mode
        option.icon = option:CreateTexture(nil, "ARTWORK")
        option.icon:SetPoint("TOPLEFT", 2, -2)
        option.icon:SetPoint("BOTTOMRIGHT", -2, 2)
        option.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        option.icon:SetTexture(mode.icon)
        -- The glow an action button wears when it is checked: this pair is the one that is on.
        option.mark = option:CreateTexture(nil, "OVERLAY")
        option.mark:SetAllPoints()
        option.mark:SetTexture("Interface\\Buttons\\CheckButtonHilight")
        option.mark:SetBlendMode("ADD")
        option:EnableMouse(true)
        option:SetScript("OnMouseUp", function(self, button)
            if button ~= "LeftButton" then return end
            -- The ring stays open: pairs can be tried one after another, and the icon puts it away.
            ns.SetGoggles(ns.Goggles() ~= self.mode and self.mode or nil)
        end)
        W.Tooltip(option, function(tip, self)
            tip:AddLine(self.mode.label)
            tip:AddLine(self.mode.note, 1, 1, 1, true)
            tip:AddLine(ns.Goggles() == self.mode and "Click to take them off" or "Click to put them on", 0.7, 0.7, 0.7)
        end, "ANCHOR_RIGHT")
        option:Hide()
        ring.options[#ring.options + 1] = option
    end
end

function SetOpen(on)
    if on and #ring.options == 0 then BuildRing() end
    if #ring.options == 0 then return end
    if on then
        -- Fan out toward the middle of the screen, so an icon at an edge opens inward.
        local x, y = frame:GetCenter()
        local cx, cy = UIParent:GetCenter()
        ring.facing = (x and cx) and math.atan2(cy - y, cx - x) or 0
        Hud.Refresh()
    end
    ring.dir = on and 1 or -1
    frame:SetScript("OnUpdate", Tick)
end

--------------------------------------------------------------------------------
-- The icon
--------------------------------------------------------------------------------

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
    frame:HookScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            Menu()
        elseif button == "LeftButton" then
            local x, y = W.GetPlace(self)
            if x == downX and y == downY then SetOpen(ring.dir < 0) end
        end
    end)
    -- Hidden with the ring open: shut at once, so it is not found half open when shown.
    frame:HookScript("OnHide", function(self)
        ring.t, ring.dir = 0, -1
        self:SetScript("OnUpdate", nil)
        PlaceRing()
    end)
    W.Tooltip(frame, Tip, "ANCHOR_RIGHT")
    W.SetPlace(frame, hud.x or DEFAULT_X, hud.y or DEFAULT_Y)
    Hud.Refresh()
end

function Hud.Refresh()
    if not frame then return end
    local mode = ns.Goggles()
    frame.icon:SetTexture(mode and mode.icon or ns.Launcher.ICON)
    for _, option in ipairs(ring.options) do option.mark:SetShown(option.mode == mode) end
    frame:SetShown(ns.cdb.hud.shown)
end

function Hud.SetShown(on)
    ns.cdb.hud.shown = on and true or false
    Hud.Create()
    Hud.Refresh()
    if not on then ns.Print("the icon is hidden. /tuner hud brings it back.") end
end
