QuickPort = {}
local QP = QuickPort

-- Master list of all mage teleport/portal destinations.
-- Spell names follow the stable "Teleport: City" / "Portal: City" convention.
-- teleport and/or portal may be nil when the spell doesn't exist for that category.
QP.Destinations = {
    -- Alliance
    { city = "Stormwind",           teleport = "Teleport: Stormwind",           portal = "Portal: Stormwind" },
    { city = "Ironforge",           teleport = "Teleport: Ironforge",           portal = "Portal: Ironforge" },
    { city = "Darnassus",           teleport = "Teleport: Darnassus",           portal = "Portal: Darnassus" },
    { city = "Exodar",              teleport = "Teleport: Exodar",              portal = "Portal: Exodar" },
    { city = "Theramore",           teleport = "Teleport: Theramore",           portal = "Portal: Theramore" },
    { city = "Boralus",             teleport = "Teleport: Boralus",             portal = "Portal: Boralus" },
    { city = "Stormshield",         teleport = "Teleport: Stormshield",         portal = "Portal: Stormshield" },

    -- Horde
    { city = "Orgrimmar",           teleport = "Teleport: Orgrimmar",           portal = "Portal: Orgrimmar" },
    { city = "Undercity",           teleport = "Teleport: Undercity",           portal = "Portal: Undercity" },
    { city = "Thunder Bluff",       teleport = "Teleport: Thunder Bluff",       portal = "Portal: Thunder Bluff" },
    { city = "Silvermoon City",     teleport = "Teleport: Silvermoon City",     portal = "Portal: Silvermoon City" },
    { city = "Stonard",             teleport = "Teleport: Stonard",             portal = "Portal: Stonard" },
    { city = "Dazar'alor",          teleport = "Teleport: Dazar'alor",          portal = "Portal: Dazar'alor" },
    { city = "Warspear",            teleport = "Teleport: Warspear",            portal = "Portal: Warspear" },

    -- Neutral / Expansion hubs
    { city = "Shattrath",           teleport = "Teleport: Shattrath",           portal = "Portal: Shattrath" },
    { city = "Dalaran (Northrend)", teleport = "Teleport: Dalaran",             portal = "Portal: Dalaran" },
    { city = "Dalaran (Broken Isles)", teleport = "Teleport: Dalaran - Broken Isles", portal = "Portal: Dalaran - Broken Isles" },
    { city = "Tol Barad",           teleport = "Teleport: Tol Barad",           portal = "Portal: Tol Barad" },
    { city = "Vale of Eternal Blossoms", teleport = "Teleport: Vale of Eternal Blossoms", portal = "Portal: Vale of Eternal Blossoms" },
    { city = "Oribos",              teleport = "Teleport: Oribos",              portal = "Portal: Oribos" },
    { city = "Valdrakken",          teleport = "Teleport: Valdrakken",          portal = "Portal: Valdrakken" },
    { city = "Dornogal",            teleport = "Teleport: Dornogal",            portal = "Portal: Dornogal" },

    -- Special: teleport only
    { city = "Hall of the Guardian", teleport = "Teleport: Hall of the Guardian", portal = nil },

    -- Special: non-standard spell names
    { city = "Dalaran (Ancient)",   teleport = "Ancient Teleport: Dalaran",     portal = "Ancient Portal: Dalaran" },
}

-- Populated at runtime: only entries where the player knows at least one spell.
QP.KnownDestinations = {}

local function spellIsKnown(spellName)
    if not spellName then return false end
    -- C_Spell.GetSpellInfo returns nil if the spell doesn't exist or isn't known
    local info = C_Spell.GetSpellInfo(spellName)
    return info ~= nil
end

function QP.DiscoverSpells()
    QP.KnownDestinations = {}
    for _, dest in ipairs(QP.Destinations) do
        local teleportInfo = dest.teleport and C_Spell.GetSpellInfo(dest.teleport)
        local portalInfo   = dest.portal   and C_Spell.GetSpellInfo(dest.portal)
        local teleportKnown = teleportInfo ~= nil
        local portalKnown   = portalInfo   ~= nil
        if teleportKnown or portalKnown then
            table.insert(QP.KnownDestinations, {
                city          = dest.city,
                teleport      = dest.teleport,
                portal        = dest.portal,
                teleportKnown = teleportKnown,
                portalKnown   = portalKnown,
                teleportID    = teleportInfo and teleportInfo.spellID,
                portalID      = portalInfo   and portalInfo.spellID,
            })
        end
    end
end
