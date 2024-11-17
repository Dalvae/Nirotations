local data = ni.utils.require("DarhangeR");
local build = select(4, GetBuildInfo());
local level = UnitLevel("player");

if build == 30300 and level == 80 and data then
	local enemies = {};
	local items = {
		settingsfile = "Arms_PVP_Dalvae.xml",
		{ type = "title",    text = "Arms Warrior PVP by |c0000CED1Dalvae" },
		{ type = "separator" },
		{ type = "title",    text = "|cffFFFF00Main Settings" },
		{ type = "separator" },
		{ type = "entry",    text = "\124T" .. data.bossIcon() .. ":26:26\124t Boss Detect",                                                                          tooltip = "When ON - Auto detect Bosses, when OFF - use CD bottom for Spells", enabled = true,      key = "detect" },
		{ type = "entry",    text = "Auto Stence",                                                                                                                    tooltip = "Auto use proper stence",                                            enabled = false,     key = "stence" },
		{ type = "entry",    text = "\124T" .. data.warrior.batIcon() .. ":26:26\124t Battle Shout",                                                                  enabled = true,                                                                key = "battleshout" },
		{ type = "entry",    text = "\124T" .. data.warrior.comIcon() .. ":26:26\124t Commanding Shout",                                                              enabled = false,                                                               key = "commandshout" },
		{ type = "entry",    text = "\124T" .. data.debugIcon() .. ":26:26\124t Debug Printing",                                                                      tooltip = "Enable for debug if you have problems",                             enabled = false,     key = "Debug" },
		{ type = "entry",    text = "\124T" .. select(3, GetSpellInfo(6603)) .. ":26:26\124t Two handed Weapon ID",                                                   tooltip = "Write the id of your two handed weapon",                            value = "",          key = "TwoArm" },

		{ type = "separator" },
		{ type = "page",     number = 1,                                                                                                                              text = "|cff00C957Defensive Settings" },
		{ type = "separator" },
		{ type = "entry",    text = "\124T" .. data.warrior.enraIcon() .. ":26:26\124t Enraged Regeneration",                                                         tooltip = "Use spell when player HP < %",                                      enabled = true,      value = 37,          key = "regen" },
		{ type = "entry",    text = "\124T" .. data.warrior.bersIcon() .. ":26:26\124t Berserker Rage (Anti-Contol)",                                                 enabled = true,                                                                key = "bersrage" },
		{ type = "entry",    text = "\124T" .. data.stoneIcon() .. ":26:26\124t Healthstone",                                                                         tooltip = "Use Warlock Healthstone (if you have) when player HP < %",          enabled = true,      value = 35,          key = "healthstoneuse" },
		{ type = "entry",    text = "\124T" .. data.hpotionIcon() .. ":26:26\124t Heal Potion",                                                                       tooltip = "Use Heal Potions (if you have) when player HP < %",                 enabled = true,      value = 30,          key = "healpotionuse" },
		{ type = "separator" },
		{ type = "page",     number = 2,                                                                                                                              text = "|cffEE4000Rotation Settings" },
		{ type = "separator" },
		{ type = "entry",    text = "\124T" .. data.warrior.shatIcon() .. ":26:26\124t Shattering Throw",                                                             enabled = true,                                                                key = "shattering" },
		{ type = "entry",    text = "\124T" .. data.warrior.sweepIcon() .. ":26:26\124t Sweeping Strikes (AoE)",                                                      enabled = true,                                                                key = "sweeping" },
		{ type = "entry",    text = "\124T" .. data.warrior.thundIcon() .. ":26:26\124t Thunder Clap (AoE)",                                                          enabled = true,                                                                key = "thunder" },
		{ type = "entry",    text = "\124T" .. data.warrior.hamIcon() .. ":26:26\124t Hamstring (Player only)",                                                       enabled = true,                                                                key = "hams" },
		{ type = "entry",    text = "\124T" .. data.warrior.heroIcon() .. ":26:26\124t  /  \124T" .. data.warrior.cleaveIcon() .. ":26:26\124t Heroic Strike/Cleave", tooltip = "Minimal rage threshold for use spells",                             value = 35,          key = "heroiccleave" },
		{ type = "entry",    text = "\124T" .. select(3, GetSpellInfo(7386)) .. ":26:26\124t Sunders Armor",                                                          tooltip = "stack sunders armor",                                               enabled = true,      key = "sunders" },


	};
	local function GetSetting(name)
		for k, v in ipairs(items) do
			if v.type == "entry"
					and v.key ~= nil
					and v.key == name then
				return v.value, v.enabled
			end
			if v.type == "dropdown"
					and v.key ~= nil
					and v.key == name then
				for k2, v2 in pairs(v.menu) do
					if v2.selected then
						return v2.value
					end
				end
			end
			if v.type == "input"
					and v.key ~= nil
					and v.key == name then
				return v.value
			end
		end
	end;

	local function ActiveEnemies()
		table.wipe(enemies);
		enemies = ni.unit.enemiesinrange("target", 7);
		if ni.vars.combat.aoe then
			for k, v in ipairs(enemies) do
				if ni.player.threat(v.guid) == -1 then
					table.remove(enemies, k);
				end
			end
			return #enemies;
		end
	end
	-- Lista de hechizos que queremos reflejar
	local spellsToReflect = {
		47610, -- Frostfire Bolt
		47809, -- Shadow Bolt
		48127, -- Mind Blast
		48461, -- Wrath
		12826, -- Polymorph
		12824, -- Polymorph
		12825, -- Polymorph
		118, -- Polymorph
		61305, -- Polymorph: Black Cat
		28272, -- Polymorph: Pig
		61721, -- Polymorph: Rabbit
		61780, -- Polymorph: Turkey
		28271, -- Polymorph: Turtle
		59172, --Chaos Bolt
		51514, --Hex
		60043, --Lava burst
		33786, --Cyclone
		48160, --Vampiric Touch
		47843, --Unstable Affliction
		53308, --roots
		48465, --starfire
		48463, --Moonfire
	}

	local function CombatEventCatcher(event, ...)
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...

			local playerGUID = UnitGUID("player")


			-- Priorizar hechizos instantáneos
			if subevent == "SPELL_CAST_SUCCESS" and destGUID == playerGUID then
				for i = 1, #spellsToReflect do
					if spellId == spellsToReflect[i] then
						print("Hechizo instantáneo reflectable detectado: " .. spellName)
						return true, sourceGUID, "instant"
					end
				end
				-- Verificar hechizos con tiempo de lanzamiento
			elseif (subevent == "SPELL_CAST_START" or subevent == "SPELL_CAST_SUCCESS") and UnitGUID(sourceName .. "target") == playerGUID then
				for i = 1, #spellsToReflect do
					if spellId == spellsToReflect[i] then
						print("Hechizo con tiempo de lanzamiento reflectable detectado: " .. spellName)
						return true, sourceGUID, "cast"
					end
				end
			end
		end
		return false, nil, nil
	end

	local function OnLoad()
		ni.combatlog.registerhandler("Arms_PVP_Dalvae", CombatEventCatcher)
		ni.GUI.AddFrame("Arms_PVP_Dalvae", items)
	end

	local function OnUnLoad()
		ni.combatlog.unregisterhandler("Arms_PVP_Dalvae", CombatEventCatcher)
		ni.GUI.DestroyFrame("Arms_PVP_Dalvae")
	end

	local function IsReflectableSpellIncoming()
		local enemies = ni.unit.enemiesinrange("player", 30)
		for i = 1, #enemies do
			local unit = enemies[i].guid
			if UnitExists(unit) and UnitIsEnemy("player", unit) then
				local castName, _, _, _, startTime, endTime, _, _, spellId = UnitCastingInfo(unit)
				if castName then
					for j = 1, #spellsToReflect do
						if spellId == spellsToReflect[j] then
							local castPercent = ni.unit.castingpercent(unit)
							if castPercent >= 80 then
								print("Hechizo reflectable detectado por IsReflectableSpellIncoming: " .. castName)
								return true, unit
							end
						end
					end
				end
			end
		end
		return false, nil
	end

	local spells                = {
		heroicStrike = { id = 47450, name = "Heroic Strike" },
		cleave = { id = 47520, name = "Cleave" },
		sunderArmor = { id = 7386, name = "Sunder Armor" },
		shatteringThrow = { id = 64382, name = "Shattering Throw" },
		rend = { id = 47465, name = "Rend" },
		sweepingStrikes = { id = 12328, name = "Sweeping Strikes" },
		thunderClap = { id = 47502, name = "Thunder Clap" },
		overpower = { id = 7384, name = "Overpower" },
		execute = { id = 47471, name = "Execute" },
		hamstring = { id = 1715, name = "Hamstring" },
		mortalStrike = { id = 47486, name = "Mortal Strike" },
		slam = { id = 1464, name = "Slam" },
		berserkRage = { id = 18499, name = "Berserker Rage" },
		victoryRush = { id = 34428, name = "Victory Rush" },
		bladestorm = { id = 46924, name = "Bladestorm" },
		battleShout = { id = 47436, name = "Battle Shout" },
		commandingShout = { id = 47440, name = "Commanding Shout" },
		enragedRegeneration = { id = 55694, name = "Enraged Regeneration" },
		bloodFury = { id = 20572, name = "Blood Fury" },
		strCard = { id = 60229, name = "Blood Fury" },
		juggernaut = { id = 65156, name = "Juggernaut" },
		recklessness = { id = 1719, name = "Recklessness" },
		charge = { id = 11578, name = "Charge" },
		intercept = { id = 20252, name = "Intercept" },
		intervene = { id = 3411, name = "Intercept" },
		whirlwind = { id = 1680, name = "Whirlwind" },
		heroicthrow = { id = 57755, name = "Heroic Throw" },
		pummel = { id = 6552, name = "Pummel" },
		shieldBash = { id = 72, name = "Shield Bash" },
		revenge = { id = 57823, name = "Revenge" },
		spellReflect = { id = 23920, name = "Spell Reflect" },

		--Stances
		berserkStance = { id = 2458, name = "Berserk Stance" },
		battleStance = { id = 2457, name = "Battle Stance" },
		defensiveStance = { id = 71, name = "Defensive Stance" },

		2458
	}
	--Macros

	SLASH_STOPGASTING1          = "/stopgasting"
	SlashCmdList["STOPGASTING"] = function()
		ni.rotation.delay(1)
	end


	SLASH_CHARGEAR1          = "/chargear"
	SlashCmdList["CHARGEAR"] = function()
		local currentStance = GetShapeshiftForm()
		local mouseoverUnit = UnitGUID("mouseover")
		local targetUnit = UnitGUID("target")

		if UnitExists(mouseoverUnit) and mouseoverUnit ~= targetUnit then
			ni.player.runtext("/target [@mouseover]")
		end
		if UnitExists("target")
				and ni.unit.distance("player", "target") > 7
				and ni.unit.distance("target", "target") < 26 then
			if UnitCanAttack("player", "target") then
				if ni.spell.cd(spells.charge.id) == 0 then
					ni.player.lookat("target")
					ni.C_Timer.After(0.1, function()
						if currentStance == 1 then
							ni.spell.cast(spells.charge.id)
						else
							ni.spell.cast(spells.battleStance.id)
							ni.C_Timer.After(0.2, function()
								ni.player.runtext("/cast Charge ")
							end)
						end
					end)
				elseif ni.spell.cd(spells.intercept.id) == 0 then
					ni.player.lookat("target")
					ni.C_Timer.After(0.1, function()
						if currentStance == 3 then
							ni.spell.cast(spells.intercept.id)
						else
							ni.spell.cast(spells.berserkStance.id)
							ni.C_Timer.After(0.2, function()
								ni.player.runtext("/cast Heroic Throw /cast Intercept ")
							end)
						end
					end)
				end
			else
				if ni.spell.cd(spells.intervene.id) == 0
						and ni.player.power() > 10 then
					ni.player.lookat("target")
					ni.C_Timer.After(0.1, function()
						if currentStance == 2 then
							ni.spell.cast(spells.intervene.id)
						else
							ni.spell.cast(spells.defensiveStance.id)
							ni.C_Timer.After(0.4, function()
								ni.spell.cast(spells.intervene.id)
							end)
						end
					end)
				end
			end
		end
	end

	local function castBattle(spellID, target)
		local currentStance = GetShapeshiftForm()
		if currentStance ~= 1 then -- Not in battle stance
			ni.spell.cast(spells.battleStance.id)
			ni.spell.cast(spellID, target)
		end
		ni.spell.cast(spellID, target)
	end

	local function castBerserker(spellID, target)
		local currentStance = GetShapeshiftForm()
		if currentStance ~= 3 then -- Not in berserker stance
			ni.spell.cast(spells.berserkStance.id)
			ni.spell.cast(spellID, target)
		end
		ni.spell.cast(spellID, target)
	end

	local function castDefensive(spellID, target)
		local currentStance = GetShapeshiftForm()
		if UnitExists(target) then -- No need to check UnitCanAttack for defensive
			if currentStance ~= 2 then -- Not in defensive stance
				ni.spell.cast(spells.defensiveStance.id)
				ni.spell.cast(spellID, target)
			end
			ni.spell.cast(spellID, target)
		end
	end


	local queueofensive  = {
		-- "enemies",
		"Battle Stance",
		"Battle Shout",
		"Universal pause",
		"StartAttack",
		"AutoTarget",
		"Commanding Shout",
		"Enraged Regeneration",
		"Berserker Rage",
		"Combat specific Pause",
		"Healthstone (Use)",
		-- "Heal Potions (Use)",
		-- "Racial Stuff",
		"Use enginer gloves",
		"Bloodrage",
		"Pummel",
		"Spell Reflection",
		"Victory Rush",
		"Shattering Throw",
		"Rend",
		"MortalJuggernaut",
		"SunderArmor",
		"Overpowerprio",
		"HeroicThrow",
		"Execute",
		"MortalGlyph",
		"Sweeping Strikes (AoE)",
		"Thunder Clap (AoE)",
		"Heroic Strike + Cleave (Filler)",
		"Hamstring (Player only)",
		"Overpower",
		"Mortal Strike",
	}
	local queuedefensive = {
		"Defensive Stance",
		-- "Shield Wall",
		-- "Shield Block",
		"StartAttack",
		"AutoTarget",
		"Enraged Regeneration",
		"Shield Bash",
		"Spell Reflection",
		"Shield Slam",
		"Revenge",
		"Hamstring",
		"RendDefensive",
		"Thunder Clap (AoE)",
		"Heroic Strike + Cleave (Filler)",
	}
	local abilities      = {
		-- ["enemies"] = function()
		-- 	if ActiveEnemies() > 1 then
		-- 		print("mas de 1 enemy")
		-- 	end
		-- end,
		-----------------------------------

		["Universal pause"] = function()
			if IsMounted()
					-- or UnitInVehicle("player")
					or UnitIsDeadOrGhost("target")
					or UnitIsDeadOrGhost("player")
					or UnitChannelInfo("player") ~= nil
					or UnitCastingInfo("player") ~= nil
					or ni.vars.combat.casting == true
					or ni.player.islooting()
					or data.PlayerBuffs("player")
					or not UnitAffectingCombat("player")
			then
				return true
			end
			ni.vars.debug = select(2, GetSetting("Debug"));
		end,
		-----------------------------------
		["AutoTarget"] = function()
			if UnitAffectingCombat("player")
					and ((ni.unit.exists("target")
							and UnitIsDeadOrGhost("target")
							and not UnitCanAttack("player", "target"))
						or not ni.unit.exists("target")) then
				ni.player.runtext("/targetenemy")
			end
		end,
		-----------------------------------
		["StartAttack"] = function()
			if UnitExists("target")
					and UnitCanAttack("player", "target")
					and not UnitIsDeadOrGhost("target")
					and UnitAffectingCombat("player")
					and not IsCurrentSpell(6603)
					and data.warrior.InRange()
			then
				ni.spell.cast(6603);
			end
		end,
		-----------------------------------

		["Battle Stance"] = function()
			local _, enabled = GetSetting("stence")
			local currentStance = GetShapeshiftForm()

			if enabled
					and currentStance ~= 1
					and ni.spell.available(spells.battleStance.id)
			then
				ni.spell.cast(spells.battleStance.id)

				return true
			end
		end,
		-----------------------------------
		["Defensive Stance"] = function()
			local currentStance = GetShapeshiftForm()

			if currentStance ~= 2 --
					and ni.spell.available(spells.defensiveStance.id)
			then
				ni.spell.cast(spells.defensiveStance.id)
				return true
			end
		end,
		-----------------------------------
		["Battle Shout"] = function()
			local _, enabled = GetSetting("battleshout")
			if ni.player.buffs("47436||48932||48934") then
				return false
			end
			if enabled
					and ni.spell.available(47436) then
				ni.spell.cast(47436)
				return true
			end
		end,
		-----------------------------------
		["Commanding Shout"] = function()
			local _, enabled = GetSetting("commandshout")
			if ni.player.buffs("47440||47440") then
				return false
			end
			if enabled
					and ni.spell.available(47440) then
				ni.spell.cast(47440)
				return true
			end
		end,
		-----------------------------------
		["Enraged Regeneration"] = function()
			local value, enabled = GetSetting("regen");
			local enrage = { 18499, 12292, 29131, 14204, 57522 }
			if enabled
					and ni.spell.available(55694)
					and ni.player.hp() < value then
				for i = 1, #enrage do
					if ni.player.buff(enrage[i]) then
						ni.spell.cast(55694)
					else
						if not ni.player.buff(enrage[i])
								and ni.spell.cd(2687) == 0 then
							ni.spell.castspells("2687|55694")
							return true
						end
					end
				end
			end
		end,
		-----------------------------------
		["Spell Reflection"] = function()
			if ni.spell.cd(spells.spellReflect.id) == 0
					and ni.player.power() >= 15 -- Verifica si tienes al menos 15 de rage
			then
				local shouldReflect, targetUnit = IsReflectableSpellIncoming()
				if shouldReflect then
					print("hay que reflejar")
					ni.spell.cast(spells.defensiveStance.id)
					ni.spell.cast(spells.spellReflect.id)
					return true
				end

				-- Verificar hechizos instantáneos
				local instantReflect, instantTargetGUID = CombatEventCatcher("COMBAT_LOG_EVENT_UNFILTERED", GetTime(),
					"SPELL_CAST_SUCCESS", UnitGUID("player"), UnitName("player"), 0, UnitGUID("player"), UnitName("player"), 0, 0,
					"")
				if instantReflect then
					print("hay que reflejar")
					ni.spell.cast(spells.defensiveStance.id)
					ni.spell.cast(spells.spellReflect.id)
					return true
				end
			end
		end,
		-----------------------------------
		["Berserker Rage"] = function()
			local _, enabled = GetSetting("bersrage")
			if enabled
					and data.warrior.Berserk()
					and ni.spell.available(18499)
					and not ni.player.buff(18499) then
				ni.spell.cast(18499)
				return true
			end
		end,
		-----------------------------------
		["Combat specific Pause"] = function()
			local buff = { 33786, 21892, 40733, 69051 }
			local debuffs = nil
			for i, v in ipairs(buff) do
				if ni.unit.buff("target", v) then debuffs = 1 end
			end
			if debuffs
					or data.PlayerDebuffs("player")
					or UnitCanAttack("player", "target") == nil
					or (UnitAffectingCombat("target") == nil
						and ni.unit.isdummy("target") == nil
						and UnitIsPlayer("target") == nil) then
				return true
			end
		end,
		-----------------------------------
		["Healthstone (Use)"] = function()
			local value, enabled = GetSetting("healthstoneuse");
			local hstones = { 36892, 36893, 36894 }
			for i = 1, #hstones do
				if enabled
						and ni.player.hp() < value
						and ni.player.hasitem(hstones[i])
						and ni.player.itemcd(hstones[i]) == 0 then
					ni.player.useitem(hstones[i])
					return true
				end
			end
		end,
		-----------------------------------
		["Heal Potions (Use)"] = function()
			local value, enabled = GetSetting("healpotionuse");
			local hpot = { 33447, 43569, 40087, 41166, 40067 }
			for i = 1, #hpot do
				if enabled
						and ni.player.hp() < value
						and ni.player.hasitem(hpot[i])
						and ni.player.itemcd(hpot[i]) == 0 then
					ni.player.useitem(hpot[i])
					return true
				end
			end
		end,

		-----------------------------------
		["Use enginer gloves"] = function()
			if ni.player.incombat()
					and ni.player.slotcastable(10)
					and ni.player.slotcd(10) == 0
					and ni.unit.hp("target") > 20
			then
				ni.player.useinventoryitem(10)
				return true
			end
		end,

		-----------------------------------	
		["Bloodrage"] = function()
			local _, enabled = GetSetting("detect")
			if ni.unit.isboss("target")
					and ni.player.power() < 65
					-- and ni.player.hasglyph(58096)
					and ni.spell.available(2687)
					and data.warrior.InRange() then
				ni.spell.cast(2687)
				return true
			end
		end,

		["Recklessness"] = function()
			local rend = data.warrior.rend()
			local _, enabled = GetSetting("detect")
			if data.CDorBoss("target", 5, 35, 5, enabled)
					and rend
					and ni.unit.debuffstacks("target", spells.sunderArmor.id) == 5
					and ni.spell.cd(spells.recklessness.id) == 0
					and data.warrior.InRange() then
				--Berserk Stance
				castBerserker(spells.recklessness.id) -- Recklessness
				ni.spell.cast(spells.bloodFury.id)
				return true
			end
		end,
		-----------------------------------
		["Bladestorm"] = function()
			local rend = data.warrior.rend()
			local _, enabled = GetSetting("detect")
			if data.CDorBoss("target", 5, 35, 5, enabled)
					and rend
					and ni.unit.debuffstacks("target", 7386) == 5
					and not ni.player.buff(65156)
					and ni.spell.available(spells.bladestorm.id)
					and ni.spell.valid("target", 47465, true, true)
			then
				if ni.unit.debuffremaining("target", 7386) > 8
				then
					if ni.spell.cd(spells.shatteringThrow.id) == 0
					then
						ni.spell.cast(spells.shatteringThrow.id, "target") --Shattering
						ni.spell.cast(46924)
					else
						ni.spell.cast(spells.bloodFury.id)
						ni.spell.cast(spells.bladestorm.id)
					end
				else
					ni.spell.cast(7386)

					return true
				end
			end
		end,
		-----------------------------------
		["Victory Rush"] = function()
			if IsUsableSpell(GetSpellInfo(34428))
					and ni.spell.valid("target", 34428, true, true) then
				ni.spell.cast(34428, "target")
				return true
			end
		end,
		-----------------------------------
		["Shattering Throw"] = function()
			local _, enabled = GetSetting("shattering")
			local buff = { 642, 1022, 45438 }
			-- poner Hero
			if enabled then
				for i, v in ipairs(buff) do
					local _, _, _, _, _, _, _, _, isRemovable = ni.unit.buff("target", v)
					if isRemovable
							and not ni.player.ismoving()
							and ni.spell.available(64382) then
						castBattle(64382, "target")

						return true
					end
				end
			end
		end,
		-----------------------------------
		["Pummel"] = function()
			if not ni.player.isdisarmed() then
				if ni.spell.shouldinterrupt("target", 80)
						or ni.unit.ischanneling("target") then
					if ni.spell.cd(spells.pummel.id) == 0
							and ni.player.power() >= 10
							and data.warrior.InRange() then
						ni.spell.cast(spells.berserkStance.id)
						ni.spell.cast(spells.pummel.id)
						return true
					end
				end
			end
		end,
		-----------------------------------

		["Shield Bash"] = function()
			if not ni.player.isdisarmed() then
				if ni.spell.shouldinterrupt("target", 80)
						or ni.unit.ischanneling("target") then
					if ni.spell.cd(spells.shieldBash.id) == 0
							and ni.player.power() >= 10
							and data.warrior.InRange() then
						ni.spell.cast(spells.defensiveStance.id)
						ni.spell.cast(spells.shieldBash.id, "target")
						return true
					end
				end
			end
		end,
		-----------------------------------
		["Shield Slam"] = function()
			if ni.spell.available(47488, true)
					and ni.spell.valid("target", 47488, true, true) then
				ni.spell.cast(47488)
				return true
			end
		end,
		-----------------------------------
		["HeroicThrow"] = function()
			if
					ni.spell.available(spells.heroicthrow.id)
					and not data.warrior.InRange()
					and ni.spell.valid("target", spells.heroicthrow.id, true, true, false)
			then
				ni.spell.cast(spells.heroicthrow.id, "target")
			end
		end,
		-----------------------------------
		["Execute"] = function()
			if ni.vars.combat.aoe
					and (ActiveEnemies() < 2 or ni.player.buff(spells.sweepingStrikes.id))
			then
				if ni.player.power() > 25
						and (ni.unit.hp("target") <= 20
							or ni.player.buff(52437) --this bufff
						)
						-- and ni.spell.cd(47486) ~= 0 -- No sé porque prefiere tirar mortal
						and ni.spell.valid("target", 47471, true, true)
				then
					ni.spell.cast(47471, "target")

					return true
				end
			else
				if not ni.vars.combat.aoe
						and ni.player.power() > 25
						and (ni.unit.hp("target") <= 20
							or ni.player.buff(52437) --this bufff
						)
						-- and ni.spell.cd(47486) ~= 0 -- No sé porque prefiere tirar mortal
						and ni.spell.valid("target", 47471, true, true) then
					ni.spell.cast(47471)
				end
			end
		end,
		-----------------------------------
		["Sweeping Strikes (AoE)"] = function()
			local _, enabled = GetSetting("sweeping")
			if enabled
					and ni.vars.combat.aoe
					and ActiveEnemies() >= 1
					and ni.spell.available(12328)
					and ni.spell.valid("target", 47465, true, true) then
				ni.spell.cast(12328)

				return true
			end
		end,
		-----------------------------------
		["Thunder Clap (AoE)"] = function()
			local _, enabled = GetSetting("thunder")
			if enabled
					and ni.player.power() > 80
					and ni.spell.available(47502, true)
					and ni.spell.valid("target", 47465, true, true) then
				castBattle(47502)
				return true
			end
		end,

		-----------------------------------
		["Revenge"] = function()
			if IsUsableSpell(GetSpellInfo(57823))
					and ni.spell.available(57823, true)
					and ni.spell.valid("target", 57823, true, true) then
				ni.spell.cast(57823, "target")
				return true
			end
		end,
		-----------------------------------
		["Whirlwind"] = function()
			if ni.vars.combat.aoe
					and ActiveEnemies() > 3
					and ni.player.power() > 26
					and not ni.player.debuff(spells.sweepingStrikes.id)
					and ni.spell.cd(spells.whirlwind.id) == 0
			then
				ni.player.runtext("/cast Berserker Stance")
				ni.spell.cast(spells.whirlwind.id)
			end
		end,
		-----------------------------------
		["Hamstring (Player only)"] = function()
			local _, enabled = GetSetting("hams")
			local hams = data.warrior.hams()
			if enabled
					and ni.unit.isplayer("target")
					and (not hams or (hams <= 2))
					and not ni.unit.isboss("target")
					and ni.spell.available(1715, true)
					and not ni.unit.buff("target", 66115) -- hand of fredom
					and ni.spell.valid("target", 1715, true, true) then
				ni.spell.cast(1715, "target")
				return true
			end
		end,
		-----------------------------------
		["Rend"] = function()
			if not ni.unit.debuff("target", 47465, "player")
					and ni.spell.available(47465, true)
					and ni.spell.valid("target", 47465, true, true)
			then
				castBattle(47465, "target")

				return true
			end
		end,
		-----------------------------------
		["RendDefensive"] = function()
			if not ni.unit.debuff("target", 47465, "player")
					and ni.spell.available(47465, true)
					and ni.spell.valid("target", 47465, true, true)
			then
				local currentStance = GetShapeshiftForm()
				if currentStance ~= 2 then
					if ni.spell.available(spells.defensiveStance.id) then
						ni.spell.cast(spells.defensiveStance.id)
					end
					currentStance = GetShapeshiftForm()
					if currentStance == 2 then
						ni.spell.cast(47465, "target")
						return true
					end
				end
			end
		end,
		["SunderArmor"] = function()
			local _, enabled = GetSetting("sunders")
			if enabled then
				if ni.spell.available(7386, true) then
					if
							(ni.unit.debuffstacks("target", 7386) < 5 or
								ni.unit.debuffremaining("target", 7386) <= 5) and
							ni.unit.isboss("target") and
							ni.spell.valid("target", 7386, true, true)
					then
						ni.spell.cast(7386, "target")
					end
				end
			end
		end,
		-----------------------------------

		["Overpower"] = function()
			if IsUsableSpell(GetSpellInfo(7384))
					-- and ActiveEnemies() <= 3
					and ni.spell.available(7384, true)
					and ni.spell.valid("target", 7384, true, true) then
				castBattle(7384, "target")
				return true
			end
		end,
		-----------------------------------
		["Overpowerprio"] = function()
			if IsUsableSpell(GetSpellInfo(7384))
					and ni.player.buffremaining(60503) <= 4
					and ni.spell.available(7384, true)
					and ni.spell.valid("target", 7384, true, true) then
				castBattle(7384, "target")
				return true
			end
		end,

		["MortalJuggernaut"] = function()
			if ni.spell.available(spells.mortalStrike.id, true)
					and (ni.player.buff(spells.juggernaut.id)
						or ni.player.power() > 80)
			then
				castBattle(spells.mortalStrike.id, "target")
			end
		end,

		["MortalGlyph"] = function()
			if ni.player.hasglyph(58368)
			then
				if ni.spell.available(spells.mortalStrike.id, true)
				then
					castBattle(spells.mortalStrike.id, "target")
				end
			end
		end,

		["Mortal Strike"] = function()
			if ni.vars.combat.aoe
					and (ActiveEnemies() < 2 or ni.player.buff(spells.sweepingStrikes.id))
			then
				if ni.spell.available(47486, true)
						and (ni.player.ismoving()
							or ni.player.power() > 77)
						and ni.spell.valid("target", 47486, true, true) then
					castBattle(47486)
					return true
				end
			else
				if not ni.vars.combat.aoe
						and ni.spell.available(47486, true)
						and (ni.player.ismoving()
							or ni.player.power() > 77)
						and ni.spell.valid("target", 47486, true, true) then
					castBattle(47486)
					return true
				end
			end
		end,
		-----------------------------------
		["Heroic Strike + Cleave (Filler)"] = function()
			local value = GetSetting("heroiccleave");
			if ni.spell.valid("target", 47475)
			-- and ni.spell.cd(47486) ~= 0
			then
				if (ni.vars.combat.aoe
							and ActiveEnemies() > 0)
				then
					if ni.player.power() > (value)
							and not IsCurrentSpell(47520)
					then
						ni.spell.cast(47520)
						return true
					end
				else
					if not IsCurrentSpell(47450)
							and ni.player.power() > value then
						ni.spell.cast(47450)
						return true
					end
				end
			end
		end,
		-----------------------------------

	}

	local dynamicqueue   = function()
		local value = GetSetting("TwoArm");

		if ni.player.hasitemequipped(value) then
			return queueofensive
		end

		return queuedefensive
	end;

	ni.bootstrap.profile("Arms_PVP_Dalvae", dynamicqueue, abilities, OnLoad, OnUnLoad);
else
	local queue = {
		"Error",
	}
	local abilities = {
		["Error"] = function()
			ni.vars.profiles.enabled = false;
			if build > 30300 then
				ni.frames.floatingtext:message("This profile is meant for WotLK 3.3.5a! Sorry!")
			elseif level < 80 then
				ni.frames.floatingtext:message("This profile is meant for level 80! Sorry!")
			elseif data == nil then
				ni.frames.floatingtext:message("Data file is missing or corrupted!");
			end
		end,
	}
	ni.bootstrap.profile("Arms_PVP_Dalvae", queue, abilities);
end
