local QP = QuickPort

local MAX_ROWS    = 8
local FRAME_WIDTH = 360
local ROW_HEIGHT  = 22
local PADDING     = 12

-- Colors
local COLOR_BG          = { 0.08, 0.08, 0.10, 0.92 }
local COLOR_BORDER      = { 0.25, 0.25, 0.30, 1.0  }
local COLOR_SELECTED    = { 0.20, 0.45, 0.80, 0.35 }
local COLOR_TEXT        = { 0.95, 0.95, 0.95, 1.0  }
local COLOR_HINT        = { 0.55, 0.55, 0.60, 1.0  }
local COLOR_SEARCH_BG   = { 0.04, 0.04, 0.06, 1.0  }

local paletteFrame
local searchBox
local resultRows = {}
local hintLine

local currentResults  = {}
local selectedIndex   = 1

local function setBackdrop(frame, bgColor, borderColor)
    frame:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
    frame:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
end

local function updateRows()
    for i = 1, MAX_ROWS do
        local row = resultRows[i]
        local dest = currentResults[i]
        if dest then
            row.label:SetText(dest.city)
            if i == selectedIndex then
                row.highlight:Show()
                row.label:SetTextColor(COLOR_TEXT[1], COLOR_TEXT[2], COLOR_TEXT[3], COLOR_TEXT[4])
            else
                row.highlight:Hide()
                row.label:SetTextColor(COLOR_TEXT[1], COLOR_TEXT[2], COLOR_TEXT[3], 0.75)
            end
            row:Show()
        else
            row:Hide()
        end
    end

    -- Update hint to reflect availability of the selected destination
    local dest = currentResults[selectedIndex]
    if dest then
        local teleportPart = dest.teleportKnown and "|cffadd8e6Enter|r = Teleport" or "|cff666666Enter|r = (no teleport)"
        local portalPart   = dest.portalKnown   and "|cffadd8e6Shift+Enter|r = Portal" or "|cff666666Shift+Enter|r = (no portal)"
        hintLine:SetText(teleportPart .. "   " .. portalPart)
    else
        hintLine:SetText("|cff666666No matching destinations|r")
    end
end

local function selectIndex(idx)
    if #currentResults == 0 then return end
    selectedIndex = math.max(1, math.min(idx, math.min(#currentResults, MAX_ROWS)))
    QP.SecureCast_SetDestination(currentResults[selectedIndex])
    updateRows()
end

local function runSearch()
    if not resultRows[1] then return end  -- guard: rows not yet built
    local query = searchBox:GetText()
    if query == searchBox.placeholder then query = "" end
    currentResults = QP.FilterDestinations(query)
    selectedIndex  = 1
    QP.SecureCast_SetDestination(currentResults[1])
    updateRows()
end

local function createResultRow(parent, index)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("LEFT",  parent, "LEFT",  PADDING, 0)
    row:SetPoint("RIGHT", parent, "RIGHT", -PADDING, 0)

    if index == 1 then
        row:SetPoint("TOP", parent, "TOP", 0, 0)
    else
        row:SetPoint("TOP", resultRows[index - 1], "BOTTOM", 0, -2)
    end

    local hl = row:CreateTexture(nil, "BACKGROUND")
    hl:SetAllPoints()
    hl:SetColorTexture(COLOR_SELECTED[1], COLOR_SELECTED[2], COLOR_SELECTED[3], COLOR_SELECTED[4])
    hl:Hide()
    row.highlight = hl

    local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", row, "LEFT", 6, 0)
    label:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    label:SetJustifyH("LEFT")
    label:SetTextColor(COLOR_TEXT[1], COLOR_TEXT[2], COLOR_TEXT[3], 1)
    row.label = label

    return row
end

function QP.UI_Build()
    -- Main palette frame
    paletteFrame = CreateFrame("Frame", "QuickPortFrame", UIParent, "BackdropTemplate")
    paletteFrame:SetFrameStrata("DIALOG")
    paletteFrame:SetWidth(FRAME_WIDTH)
    paletteFrame:SetPoint("TOP", UIParent, "TOP", 0, -180)
    paletteFrame:SetClampedToScreen(true)

    -- Search box container
    local searchContainer = CreateFrame("Frame", nil, paletteFrame, "BackdropTemplate")
    searchContainer:SetHeight(34)
    searchContainer:SetPoint("TOP",   paletteFrame, "TOP",   0, -PADDING)
    searchContainer:SetPoint("LEFT",  paletteFrame, "LEFT",  PADDING, 0)
    searchContainer:SetPoint("RIGHT", paletteFrame, "RIGHT", -PADDING, 0)
    setBackdrop(searchContainer, COLOR_SEARCH_BG, COLOR_BORDER)

    searchBox = CreateFrame("EditBox", "QuickPortSearchBox", searchContainer)
    searchBox:SetAllPoints(searchContainer)
    searchBox:SetFontObject("GameFontNormal")
    searchBox:SetTextColor(COLOR_TEXT[1], COLOR_TEXT[2], COLOR_TEXT[3], 1)
    searchBox:SetTextInsets(8, 8, 0, 0)
    searchBox:SetAutoFocus(false)
    searchBox:SetMaxLetters(64)

    searchBox.placeholder = "Search destination..."

    local function showPlaceholder()
        if searchBox:GetText() == "" then
            searchBox:SetText(searchBox.placeholder)
            searchBox:SetTextColor(COLOR_HINT[1], COLOR_HINT[2], COLOR_HINT[3], 1)
        end
    end

    local function hidePlaceholder()
        if searchBox:GetText() == searchBox.placeholder then
            searchBox:SetText("")
            searchBox:SetTextColor(COLOR_TEXT[1], COLOR_TEXT[2], COLOR_TEXT[3], 1)
        end
    end

    searchBox:SetScript("OnEditFocusGained", hidePlaceholder)
    searchBox:SetScript("OnEditFocusLost",   showPlaceholder)
    searchBox:SetScript("OnTextChanged",     function() runSearch() end)

    -- Secure cast hooks: must be set up after searchBox exists
    QP.SecureCast_Init(paletteFrame)

    -- Route navigation keys; ESC propagates to close via UISpecialFrames.
    -- ENTER is handled by the override binding in SecureCast (SetOverrideBindingClick).
    searchBox:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput(true)
        elseif key == "UP" then
            self:SetPropagateKeyboardInput(false)
            selectIndex(selectedIndex - 1)
        elseif key == "DOWN" then
            self:SetPropagateKeyboardInput(false)
            selectIndex(selectedIndex + 1)
        elseif key == "ENTER" then
            self:SetPropagateKeyboardInput(true)  -- let override binding handle cast
        else
            self:SetPropagateKeyboardInput(false)
        end
    end)

    -- Results area
    local resultsFrame = CreateFrame("Frame", nil, paletteFrame)
    resultsFrame:SetPoint("TOP",   searchContainer, "BOTTOM", 0, -6)
    resultsFrame:SetPoint("LEFT",  paletteFrame, "LEFT",  0, 0)
    resultsFrame:SetPoint("RIGHT", paletteFrame, "RIGHT", 0, 0)
    resultsFrame:SetHeight(MAX_ROWS * (ROW_HEIGHT + 2))

    for i = 1, MAX_ROWS do
        resultRows[i] = createResultRow(resultsFrame, i)
    end

    -- Hint line
    local hintContainer = CreateFrame("Frame", nil, paletteFrame)
    hintContainer:SetHeight(22)
    hintContainer:SetPoint("TOP",   resultsFrame, "BOTTOM", 0, -4)
    hintContainer:SetPoint("LEFT",  paletteFrame, "LEFT",   0, 0)
    hintContainer:SetPoint("RIGHT", paletteFrame, "RIGHT",  0, 0)

    hintLine = hintContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hintLine:SetPoint("CENTER", hintContainer, "CENTER")
    hintLine:SetTextColor(COLOR_HINT[1], COLOR_HINT[2], COLOR_HINT[3], 1)

    -- Size the palette to fit its content
    local totalHeight = PADDING          -- top padding
                      + 34              -- search box
                      + 6               -- gap
                      + MAX_ROWS * (ROW_HEIGHT + 2)  -- rows
                      + 4               -- gap
                      + 22              -- hint
                      + PADDING         -- bottom padding
    paletteFrame:SetHeight(totalHeight)
    setBackdrop(paletteFrame, COLOR_BG, COLOR_BORDER)

    paletteFrame:Hide()

    -- Close on Escape via standard UISpecialFrames mechanism
    tinsert(UISpecialFrames, "QuickPortFrame")
end

function QP.UI_Open()
    if InCombatLockdown() then return end
    runSearch()
    paletteFrame:Show()
    searchBox:SetText("")
    searchBox:SetTextColor(COLOR_TEXT[1], COLOR_TEXT[2], COLOR_TEXT[3], 1)
    searchBox:SetFocus()
end

function QP.UI_Close()
    paletteFrame:Hide()
    searchBox:ClearFocus()
end
