local QP = QuickPort

-- Subsequence fuzzy match with scoring.
-- Returns a numeric score (higher = better match), or nil if query doesn't match.
-- Empty query matches everything with score 0.
function QP.FuzzyScore(query, text)
    if query == "" then return 0 end

    local lowerQuery = query:lower()
    local lowerText  = text:lower()

    local score     = 0
    local textLen   = #lowerText
    local qi        = 1  -- index into query
    local lastMatch = 0  -- last matched position in text (1-based)

    for ti = 1, textLen do
        local tc = lowerText:sub(ti, ti)
        local qc = lowerQuery:sub(qi, qi)

        if tc == qc then
            -- Base score for a match
            score = score + 1

            -- Consecutive bonus: reward characters matched back-to-back
            if lastMatch == ti - 1 then
                score = score + 4
            end

            -- Word-start bonus: reward matching the first char of a word
            if ti == 1 then
                score = score + 8
            elseif lowerText:sub(ti - 1, ti - 1):match("[%s%-_%(]") then
                score = score + 6
            end

            -- Position penalty: earlier matches are slightly better
            score = score - (ti * 0.01)

            lastMatch = ti
            qi = qi + 1
            if qi > #lowerQuery then break end
        end
    end

    -- All query characters must be matched
    if qi <= #lowerQuery then return nil end

    return score
end

-- Filter and sort destinations by fuzzy match against query.
-- Returns an array of matched destination entries (references to KnownDestinations).
function QP.FilterDestinations(query)
    local results = {}
    for _, dest in ipairs(QP.KnownDestinations) do
        local score = QP.FuzzyScore(query, dest.city)
        if score then
            table.insert(results, { dest = dest, score = score })
        end
    end
    table.sort(results, function(a, b) return a.score > b.score end)

    local sorted = {}
    for _, entry in ipairs(results) do
        table.insert(sorted, entry.dest)
    end
    return sorted
end
