local addonName, ns = ...

--[[
The frame rate check: measure for a few seconds, then say in a window what the number
suggests, with a button that does it. Chat lines get missed, so the answer is a window.

It runs by itself the first time RenderTuner is used and each time the settings arrive at
the client's defaults (after "Client defaults", or a fresh install), a while after login so
the world has loaded; /tuner check and More... run it whenever asked. Not in combat. The
window has a box to stop the automatic check for good.

What the number means is decided in Model.Advise; this file reads the frame rate, shows the
window, and hands the button's choice to the actions in Core.lua.
]]

local W = LibStub("LibICWidgets-1.0")

local Catalog = ns.Catalog
local Model = ns.Model

local Check = {}
ns.Check = Check

local SETTLE = 10       -- seconds after login before measuring
local SAMPLES = 12      -- readings, half a second apart
local EVERY = 0.5
local POPUP_W, POPUP_H = 440, 170

local popup
local running = false

-- What the window's button does: the step the advice names.
local function Take(advice)
    if advice and advice.axis == "scale" then ns.ApplyPreset(advice.preset)
    elseif advice and advice.axis == "level" then ns.ApplyLevel(advice.preset) end
end

local function Hide()
    if not popup then return end
    -- The box says "never again" for the automatic check; it is read as the window closes.
    ns.db.settings.check = popup.skip:GetChecked() and "off" or nil
    popup:Hide()
end

local function Build()
    local p = W.Panel(UIParent, { name = "RenderTunerCheck", width = POPUP_W, height = POPUP_H, strata = "DIALOG" })
    p:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
    p:EnableMouse(true)

    p.title = W.Label(p, "", { font = "title", color = "accent" })
    p.title:SetPoint("TOPLEFT", p, "TOPLEFT", 14, -12)

    p.body = W.Label(p, "", { wrap = true })
    p.body:SetPoint("TOPLEFT", p, "TOPLEFT", 14, -38)
    p.body:SetWidth(POPUP_W - 28)
    p.body:SetJustifyV("TOP")

    p.skip = W.CheckBox(p, { size = 16 })
    p.skip:SetPoint("BOTTOMLEFT", p, "BOTTOMLEFT", 14, 14)
    local skipText = W.Label(p, "Do not check at login", { color = "textDim" })
    skipText:SetPoint("LEFT", p.skip, "RIGHT", 8, 0)

    p.close = W.Button(p, "Close", 70, 24, { onClick = Hide })
    p.close:SetPoint("BOTTOMRIGHT", p, "BOTTOMRIGHT", -14, 40)

    p.open = W.Button(p, "Open RenderTuner", 130, 24, {
        onClick = function()
            Hide()
            if not ns.Panel.IsShown() then ns.Panel.Toggle() end
        end,
    })
    p.open:SetPoint("RIGHT", p.close, "LEFT", -6, 0)

    p.use = W.Button(p, "", 130, 24, {
        kind = "accent",
        onClick = function(self)
            local advice = self.advice
            Hide()
            Take(advice)
        end,
    })
    p.use:SetPoint("RIGHT", p.open, "LEFT", -6, 0)
    return p
end

-- The window for a measured frame rate. `auto` takes the step the number suggests without
-- asking, and shows the window only when there is nothing to take.
function Check.Show(fps, auto)
    local live = ns.Apply.Live()
    local limits = ns.Apply.Limits()
    local level = Model.LevelOf(live.graphicsQuality, Catalog.LEVELS, live, ns.Excused)
    if level and level.also then level = nil end
    local advice = Model.Advise(fps, live.RenderScale or 1, level, Catalog.PRESETS, Catalog.LEVELS, limits,
        (tonumber(live.vsync) or 0) > 0)
    local head, body, button = Model.AdviseText(advice, limits)

    if auto and button then
        -- What it replaces, named before the step is taken.
        local was
        if advice.axis == "scale" then
            local now = Model.PresetOf(live.RenderScale or 1, Catalog.PRESETS, limits)
            was = now and now.label or string.format("%d%%", math.floor((live.RenderScale or 1) * 100 + 0.5))
        else
            was = level and level.label
        end
        local line = Model.AutoLine(advice, was, limits)
        ns.Print(head .. " " .. line .. ".")
        Take(advice)
        if ns.Panel then ns.Panel.Flash(line) end
        return advice
    end

    popup = popup or Build()
    popup.title:SetText(head)
    popup.body:SetText(body)
    popup.skip:SetChecked(ns.db.settings.check == "off")
    popup.use.advice = advice
    popup.use:SetLabel(button or "")
    popup.use:SetShown(button ~= nil)
    popup:Show()
    return advice
end

-- Measures for about six seconds, then shows the window. `manual` says so in chat first, and
-- says why when it cannot; it also means the player is in the game, so the reading stands.
-- Run by itself, a reading at the background frame rate limit is not believed: the game was
-- behind another window. It looks again twice, half a minute apart, and then lets the next
-- login try.
function Check.Start(manual, attempt, auto)
    if running then
        if manual then ns.Print("already measuring: the answer comes in a few seconds.") end
        return
    end
    if InCombatLockdown() then
        if manual then ns.Print("not in combat: try again once it is over.") end
        return
    end
    running = true
    -- The panel's Auto-set button counts the seconds down while this runs.
    local function Tell(left) if ns.Panel then ns.Panel.Measuring(left) end end
    Tell(math.ceil(SAMPLES * EVERY))
    if manual then ns.Print("measuring the frame rate for a few seconds. Stay where you are.") end
    local readings, ticks = {}, 0
    C_Timer.NewTicker(EVERY, function()
        ticks = ticks + 1
        local fps = ns.Apply.Framerate()
        if fps > 0 then readings[#readings + 1] = fps end
        if ticks < SAMPLES then
            Tell(math.ceil((SAMPLES - ticks) * EVERY))
            return
        end
        running = false
        Tell(nil)
        local median = Model.Median(readings)
        if median and not manual and Model.BackgroundCapped(median, ns.Apply.Live()) then
            if (attempt or 1) < 3 then
                C_Timer.After(30, function() Check.Start(false, (attempt or 1) + 1) end)
            else
                ns.db.settings.checked, ns.db.settings.checkedAtDefaults = nil, false
            end
        elseif median then
            Check.Show(median, auto)
        elseif manual then
            ns.Print("the client gave no frame rate reading.")
        end
    end, SAMPLES)
end

-- At login: runs the check later, if it is due.
function Check.Login()
    local live, defaults = ns.Apply.Live(), ns.Apply.Defaults()
    local atDefaults = live.RenderScale ~= nil and live.graphicsQuality ~= nil
        and Model.Same(live.RenderScale, defaults.RenderScale)
        and Model.Same(live.graphicsQuality, defaults.graphicsQuality)
    local settings = ns.db.settings
    local due, kept = Model.CheckDue(settings, atDefaults)
    settings.checkedAtDefaults = kept
    if not due then return end
    settings.checked = true
    C_Timer.After(SETTLE, function() Check.Start(false) end)
end

function Check.IsRunning()
    return running
end

function Check.IsShown()
    return popup ~= nil and popup:IsShown()
end

-- For the cases.
function Check.Popup()
    return popup
end
