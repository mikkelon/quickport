local QP = QuickPort

-- ── Saved Variables ──────────────────────────────────────────────────────────

function QP.InitDB()
    if not QuickPortDB then
        QuickPortDB = {}
    end
    if not QuickPortDB.hiddenDestinations then
        QuickPortDB.hiddenDestinations = {}
    end
end

function QP.IsDestinationHidden(city)
    return QuickPortDB
        and QuickPortDB.hiddenDestinations
        and QuickPortDB.hiddenDestinations[city] == true
        or false
end

-- ── Options Panel ─────────────────────────────────────────────────────────────

local PANEL_WIDTH  = 600
local PANEL_HEIGHT = 500
local ROW_HEIGHT   = 24
local PADDING      = 16

local optionsFrame
local checkboxes = {}

local function rebuildCheckboxes()
    for _, cb in ipairs(checkboxes) do
        cb:Hide()
        cb:SetParent(nil)
    end
    checkboxes = {}

    local scrollChild = optionsFrame.scrollChild
    local prevAnchor  = scrollChild

    for i, dest in ipairs(QP.AllKnownDestinations) do
        local cb = CreateFrame("CheckButton", nil, scrollChild, "UICheckButtonTemplate")
        cb:SetSize(ROW_HEIGHT, ROW_HEIGHT)

        if i == 1 then
            cb:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
        else
            cb:SetPoint("TOPLEFT", checkboxes[i - 1], "BOTTOMLEFT", 0, -4)
        end

        cb.text:SetText(dest.city)
        cb.text:SetFontObject("GameFontNormal")

        local city = dest.city
        cb:SetChecked(not QP.IsDestinationHidden(city))
        cb:SetScript("OnClick", function(self)
            if self:GetChecked() then
                QuickPortDB.hiddenDestinations[city] = nil
            else
                QuickPortDB.hiddenDestinations[city] = true
            end
            QP.DiscoverSpells()
        end)

        table.insert(checkboxes, cb)
    end

    local totalHeight = #checkboxes * (ROW_HEIGHT + 4)
    scrollChild:SetHeight(math.max(totalHeight, PANEL_HEIGHT - 80))
end

function QP.BuildOptionsPanel()
    optionsFrame = CreateFrame("Frame")
    optionsFrame:SetSize(PANEL_WIDTH, PANEL_HEIGHT)

    local title = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", PADDING, -PADDING)
    title:SetText("QuickPort")

    local subtitle = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    subtitle:SetText("Uncheck destinations to hide them from the command palette.")
    subtitle:SetTextColor(0.8, 0.8, 0.8)

    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, optionsFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT",     subtitle, "BOTTOMLEFT", 0, -12)
    scrollFrame:SetPoint("BOTTOMRIGHT", optionsFrame, "BOTTOMRIGHT", -PADDING - 20, PADDING)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(PANEL_WIDTH - PADDING * 2 - 24)
    scrollChild:SetHeight(PANEL_HEIGHT - 80)
    scrollFrame:SetScrollChild(scrollChild)

    optionsFrame.scrollChild = scrollChild

    -- Rebuild when the panel is shown so it reflects spells learned since login
    optionsFrame:SetScript("OnShow", rebuildCheckboxes)

    local category = Settings.RegisterCanvasLayoutCategory(optionsFrame, "QuickPort")
    Settings.RegisterAddOnCategory(category)
    QP.settingsCategory = category
end
