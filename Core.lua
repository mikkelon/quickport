-- QuickPort: command palette for mage teleport and portal spells.
local QP = QuickPort

-- ── Event handling ──────────────────────────────────────────────────────────

local eventFrame = CreateFrame("Frame")
local initialized = false

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("SPELLS_CHANGED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

eventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        -- Gate the addon to mages only
        local _, classFileName = UnitClass("player")
        if classFileName ~= "MAGE" then
            eventFrame:UnregisterAllEvents()
            return
        end

        QP.DiscoverSpells()
        QP.UI_Build()
        initialized = true

    elseif event == "SPELLS_CHANGED" then
        if initialized then
            QP.DiscoverSpells()
        end

    elseif event == "PLAYER_REGEN_DISABLED" then
        if QuickPortFrame and QuickPortFrame:IsShown() then
            QP.Close()
        end
    end
end)

-- ── Open / Close ────────────────────────────────────────────────────────────

function QP.Open()
    if InCombatLockdown() then
        print("|cffff4444QuickPort:|r Cannot open during combat.")
        return
    end
    if not QuickPortFrame then
        print("|cffff4444QuickPort:|r Not available on this character (mages only).")
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
