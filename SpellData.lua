-- Key binding display name for the WoW Key Bindings UI.
BINDING_NAME_QUICKPORT_TOGGLE = "Open QuickPort"

QuickPort = {}
local QP = QuickPort

-- Master list of all mage teleport/portal destinations.
-- teleportID / portalID are spell IDs; nil when the spell doesn't exist for
-- that faction or destination. Using IDs ensures the addon works on all
-- locales — spell names are looked up at runtime via C_Spell.GetSpellInfo.
QP.Destinations = {
	-- Alliance
	{ city = "Stormwind", teleportID = 3561, portalID = 10059 },
	{ city = "Ironforge", teleportID = 3562, portalID = 11416 },
	{ city = "Darnassus", teleportID = 3565, portalID = 11419 },
	{ city = "Exodar", teleportID = 32271, portalID = 32266 },
	{ city = "Theramore", teleportID = 49359, portalID = 49360 },
	{ city = "Boralus", teleportID = 281403, portalID = 267877 },
	{ city = "Stormshield", teleportID = 176248, portalID = 176246 },

	-- Horde
	{ city = "Orgrimmar", teleportID = 3567, portalID = 11417 },
	{ city = "Undercity", teleportID = 3563, portalID = 11418 },
	{ city = "Thunder Bluff", teleportID = 3566, portalID = 11420 },
	{ city = "Silvermoon City", teleportID = 32272, portalID = 32267 },
	{ city = "Stonard", teleportID = 49358, portalID = 49361 },
	{ city = "Dazar'alor", teleportID = 281404, portalID = 281402 },
	{ city = "Warspear", teleportID = 176242, portalID = 176244 },

	-- Neutral / Expansion hubs
	{ city = "Shattrath", teleportID = 33690, portalID = 33691 },
	{ city = "Dalaran (Northrend)", teleportID = 53140, portalID = 53142 },
	{ city = "Dalaran (Broken Isles)", teleportID = 224869, portalID = 224871 },
	-- Tol Barad has faction-specific teleport spells; only the player's faction
	-- version will be known, so both entries are listed and DiscoverSpells
	-- filters to whichever (if any) the player knows.
	{ city = "Tol Barad", teleportID = 88342, portalID = 88345 }, -- Alliance
	{ city = "Tol Barad", teleportID = 88344, portalID = 88345 }, -- Horde
	{ city = "Vale of Eternal Blossoms", teleportID = 132627, portalID = 132620 },
	{ city = "Oribos", teleportID = 344587, portalID = 344597 },
	{ city = "Valdrakken", teleportID = 395277, portalID = 395289 },
	{ city = "Dornogal", teleportID = 446540, portalID = 446534 },
	{ city = "Silvermoon City", teleportID = 1259190, portalID = 1259194 }, -- Midnight hub

	-- Special: teleport only
	{ city = "Hall of the Guardian", teleportID = 193759, portalID = nil },

	-- Special: non-standard (Ancient Tome of Teleport/Portal: Dalaran)
	{ city = "Dalaran (Ancient)", teleportID = 120145, portalID = 120146 },
}

-- Populated at runtime: only entries where the player knows at least one spell.
QP.KnownDestinations = {}

function QP.DiscoverSpells()
	QP.KnownDestinations = {}
	for _, dest in ipairs(QP.Destinations) do
		local teleportKnown = dest.teleportID and IsSpellKnown(dest.teleportID) or false
		local portalKnown = dest.portalID and IsSpellKnown(dest.portalID) or false
		if teleportKnown or portalKnown then
			-- If a portal-only entry shares a city name with an already-added entry
			-- that has a known teleport (e.g. faction-specific Tol Barad teleports
			-- sharing the same portal spell), skip the redundant portal-only entry.
			local redundant = false
			if not teleportKnown then
				for _, known in ipairs(QP.KnownDestinations) do
					if known.city == dest.city and known.teleportKnown then
						redundant = true
						break
					end
				end
			end
			if not redundant then
				table.insert(QP.KnownDestinations, {
					city = dest.city,
					teleportID = dest.teleportID,
					portalID = dest.portalID,
					teleportKnown = teleportKnown,
					portalKnown = portalKnown,
				})
			end
		end
	end
end
