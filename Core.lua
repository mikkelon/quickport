-- QuickPort: command palette for mage teleport and portal spells.
QuickPort = {}
local QP = QuickPort

-- Saved variables are initialised in PLAYER_LOGIN so they are available
-- before we touch them (WoW populates SavedVariables before PLAYER_LOGIN).
-- QuickPortDB = {}  -- declared in .toc SavedVariables

local inCombat = false

-- ── Event handling ──────────────────────────────────────────────────────────

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("SPELLS_CHANGED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

eventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        -- Gate the addon to mages only
        local _, classID = UnitClassBase("player")
        if classID ~= "MAGE" then
            eventFrame:UnregisterAllEvents()
            return
        end

        -- Initialise saved variables
        QuickPortDB = QuickPortDB or {}

        -- Set default keybinding on first ever load
        if not QuickPortDB.bindingSet then
            SetBinding("CTRL-P", "QUICKPORT_TOGGLE")
            SaveBindings(GetCurrentBindingSet())
            QuickPortDB.bindingSet = true
        end

        QP.DiscoverSpells()
        QP.UI_Build()

    elseif event == "SPELLS_CHANGED" then
        QP.DiscoverSpells()

    elseif event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
        if QuickPortFrame and QuickPortFrame:IsShown() then
            QP.Close()
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
    end
end)

-- ── Open / Close ────────────────────────────────────────────────────────────

function QP.Open()
    if inCombat then
        print("|cffff4444QuickPort:|r Cannot open during combat.")
        return
    end
    QP.UI_Open()
end

function QP.Close()
    QP.UI_Close()
end

function QP.Toggle()
    if QuickPortFrame and QuickPortFrame:IsShown() then
        QP.Close()
    else
        QP.Open()
    end
end

-- ── Slash commands ───────────────────────────────────────────────────────────

SLASH_QUICKPORT1 = "/quickport"
SLASH_QUICKPORT2 = "/qp"
SlashCmdList["QUICKPORT"] = function() QP.Toggle() end
