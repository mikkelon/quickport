local QP = QuickPort

local castBtn

function QP.SecureCast_Init(parentFrame)
    castBtn = CreateFrame("Button", "QuickPortCastButton", parentFrame,
        "SecureActionButtonTemplate")
    castBtn:SetSize(1, 1)
    castBtn:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, 0)
    -- Register for both down and up so override bindings (which fire on key down)
    -- trigger the secure action. Default "LeftButtonUp" misses key-down clicks.
    castBtn:RegisterForClicks("AnyDown", "AnyUp")
    castBtn:SetAttribute("*type1", "macro")

    castBtn:SetScript("PostClick", function() QP.Close() end)

    -- Override bindings deliver hardware clicks, which SecureActionButtonTemplate
    -- needs to execute its macro action. ENTER propagation in OnKeyDown is also
    -- required so the EditBox doesn't swallow the key before the binding sees it.
    parentFrame:HookScript("OnShow", function()
        if InCombatLockdown() then return end
        SetOverrideBindingClick(parentFrame, true, "ENTER",       "QuickPortCastButton")
        SetOverrideBindingClick(parentFrame, true, "SHIFT-ENTER", "QuickPortCastButton")
    end)

    parentFrame:HookScript("OnHide", function()
        if InCombatLockdown() then return end
        ClearOverrideBindings(parentFrame)
    end)
end

-- Update macro text for the selected destination. Outside combat only.
-- Looks up localized spell names at runtime so /cast works on all locales.
function QP.SecureCast_SetDestination(dest)
    if InCombatLockdown() then return end
    local teleportName = dest and dest.teleportKnown
        and C_Spell.GetSpellInfo(dest.teleportID)
        and C_Spell.GetSpellInfo(dest.teleportID).name
    local portalName = dest and dest.portalKnown
        and C_Spell.GetSpellInfo(dest.portalID)
        and C_Spell.GetSpellInfo(dest.portalID).name
    castBtn:SetAttribute("macrotext1",      teleportName and ("/cast " .. teleportName) or nil)
    castBtn:SetAttribute("shift-macrotext1", portalName   and ("/cast " .. portalName)  or nil)
end
