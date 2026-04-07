local QP = QuickPort

-- Two hidden SecureActionButtons — one for teleport, one for portal.
-- Spell attributes are set before the palette opens (outside combat).
-- Override bindings route ENTER -> teleport button, SHIFT-ENTER -> portal button.

local teleportBtn
local portalBtn

function QP.SecureCast_Init(parentFrame)
    teleportBtn = CreateFrame("Button", "QuickPortTeleportButton", parentFrame, "SecureActionButtonTemplate")
    teleportBtn:SetSize(1, 1)
    teleportBtn:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, 0)
    teleportBtn:SetAttribute("type", "spell")
    teleportBtn:Hide()

    portalBtn = CreateFrame("Button", "QuickPortPortalButton", parentFrame, "SecureActionButtonTemplate")
    portalBtn:SetSize(1, 1)
    portalBtn:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, 0)
    portalBtn:SetAttribute("type", "spell")
    portalBtn:Hide()
end

-- Update the spell attributes for the selected destination.
-- Must be called outside combat.
function QP.SecureCast_SetDestination(dest)
    if InCombatLockdown() then return end
    if not dest then
        teleportBtn:SetAttribute("spell", nil)
        portalBtn:SetAttribute("spell", nil)
        return
    end
    teleportBtn:SetAttribute("spell", dest.teleportKnown and dest.teleport or nil)
    portalBtn:SetAttribute("spell",   dest.portalKnown   and dest.portal   or nil)
end

-- Activate override bindings while the palette is open.
-- parentFrame is the owner — ClearOverrideBindings(parentFrame) clears them all.
function QP.SecureCast_BindKeys(parentFrame)
    if InCombatLockdown() then return end
    SetOverrideBindingClick(parentFrame, true, "ENTER",       "QuickPortTeleportButton", "LeftButton")
    SetOverrideBindingClick(parentFrame, true, "SHIFT-ENTER", "QuickPortPortalButton",   "LeftButton")
end

function QP.SecureCast_UnbindKeys(parentFrame)
    ClearOverrideBindings(parentFrame)
end
