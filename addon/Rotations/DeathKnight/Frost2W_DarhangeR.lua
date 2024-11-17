local data = ni.utils.require("DarhangeR");
local popup_shown = false;
local enemies = { };
local build = select(4, GetBuildInfo());
local level = UnitLevel("player");
local FrostStrike = IsSpellKnown(55268)
local Howling = IsSpellKnown(51411)
local function ActiveEnemies()
	table.wipe(enemies);
	enemies = ni.unit.enemiesinrange("target", 7);
	for k, v in ipairs(enemies) do
		if ni.player.threat(v.guid) == -1 then
			table.remove(enemies, k);
		end
	end
	return #enemies;
end
if build == 30300 and level == 80 and data and FrostStrike and Howling then
local items = {
	settingsfile = "DarhangeR_Frost2W.xml",
	{ type = "title", text = "Frost 2-wield DK by |c0000CED1DarhangeR" },
	{ type = "separator" },
	{ type = "title", text = "|cffFFFF00Main Settings" },
	{ type = "separator" },
	{ type = "entry", text = "\124T"..data.bossIcon()..":26:26\124t Boss Detect", tooltip = "When ON - Auto detect Bosses, when OFF - use CD bottom for Spells", enabled = true, key = "detect" },
	{ type = "entry", text = "\124T"..data.dk.deathIcon()..":26:26\124t Death Strike (Lich)", tooltip = "Use spell when player HP < %. Only in open world", enabled = true, value = 50, key = "deathstrike" },
	{ type = "entry", text = "\124T"..data.dk.raiseIcon()..":26:26\124t Raise Dead", tooltip = "Use spell on bosses or on cd active", enabled = false, key = "raisedead" },	
	{ type = "entry", text = "\124T"..data.dk.nothIcon()..":26:26\124t Noth's Special Brew", tooltip = "Enable for quick get Runic Power", enabled = false, key = "noth" },	
	{ type = "entry", text = "\124T"..data.dk.interIcon()..":26:26\124t Auto Interrupt", tooltip = "Auto check and interrupt all interruptible spells", enabled = true, key = "autointerrupt" },	
	{ type = "entry", text = "\124T"..data.debugIcon()..":26:26\124t Debug Printing", tooltip = "Enable for debug if you have problems", enabled = false, key = "Debug" },		
	{ type = "separator" },
	{ type = "title", text = "|cff00C957Defensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "\124T"..data.dk.iceboundIcon()..":26:26\124t Icebound Fortitude", tooltip = "Use spell when player HP < %", enabled = true, value = 45, key = "iceboundfort" },
	{ type = "entry", text = "\124T"..data.stoneIcon()..":26:26\124t Healthstone", tooltip = "Use Warlock Healthstone (if you have) when player HP < %", enabled = true, value = 35, key = "healthstoneuse" },
	{ type = "entry", text = "\124T"..data.hpotionIcon()..":26:26\124t Heal Potion", tooltip = "Use Heal Potions (if you have) when player HP < %", enabled = true, value = 30, key = "healpotionuse" },
	{ type = "separator" },
	{ type = "title", text = "Presence's" },
	{ type = "dropdown", menu = {
		{ selected = true, value = 48266, text = "Blood Presence" },
		{ selected = false, value = 48263, text = "Frost Presence" },
		{ selected = false, value = 48265, text = "Unholy Presence" },
	}, key = "Presence" },
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
local function OnLoad()
	ni.GUI.AddFrame("Frost2W_DarhangeR", items);
end
local function OnUnLoad()  
	ni.GUI.DestroyFrame("Frost2W_DarhangeR");
end

local queue = {
			
	"Universal pause",
	"AutoTarget",
	"Use Presence",
	"Horn of Winter",
	"Combat specific Pause",
	"Pet Attack/Follow",
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Racial Stuff",
	"Use enginer gloves",
	"Trinkets",
	"Noth's Special Brew (Use)",
	"Mind Freeze (Interrupt)",
	"Icebound Fortitude",
	"Death and Decay",
	"Unbreakable Armor",
	"Raise Dead",
	"Empower Rune Weapon",
	"Icy Touch",
	"Plague Strike",
	"Pestilence (AoE)",
	"Pestilence (Renew)",
	"Howling Blast",
	"Howling Blast (AoE)",
	"Frost Strike (Kill)",
	"Death Strike (Lich)",
	"Obliterate Dump",
	"Obliterate",
	"Frost Strike",
	"Rune Strike",
	"Blood Strike",
	"Frost Strike 2"
}
local abilities = {
-----------------------------------
	["Universal pause"] = function()
		if data.UniPause() then
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
	["Use Presence"] = function()
		local presence = GetSetting("Presence");		
		if not ni.player.buff(presence)
		 and ni.spell.available(presence) then
			ni.spell.cast(presence)
			return true
		end
	end,
-----------------------------------
	["Horn of Winter"] = function()
		if not ni.player.buff(57623)
		 and ni.spell.available(57623) then 		
			ni.spell.cast(57623)
			return true
		end
	end,
-----------------------------------
	["Combat specific Pause"] = function()
		if data.meleeStop("target")
		 or data.PlayerDebuffs("player")
		 or UnitCanAttack("player","target") == nil
		 or (UnitAffectingCombat("target") == nil 
		 and ni.unit.isdummy("target") == nil 
		 and UnitIsPlayer("target") == nil) then 
			return true
		end
	end,
-----------------------------------
	["Pet Attack/Follow"] = function()
		if ni.unit.hp("playerpet") < 20
		 and ni.unit.exists("playerpet")
		 and ni.unit.exists("target")
		 and UnitIsUnit("target", "pettarget")
		 and not UnitIsDeadOrGhost("playerpet") then
			data.petFollow()
		 else
		if UnitAffectingCombat("player")
		 and ni.unit.exists("playerpet")
		 and ni.unit.hp("playerpet") > 60
		 and ni.unit.exists("target")
		 and not UnitIsUnit("target", "pettarget")
		 and not UnitIsDeadOrGhost("playerpet") then 
			data.petAttack()
			end
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
	["Racial Stuff"] = function()
		local hracial = { 33697, 20572, 33702, 26297 }
		local bloodelf = { 25046, 28730, 50613 }
		local alracial = { 20594, 28880 }
		local _, enabled = GetSetting("detect")			
		--- Undead
		if data.forsaken("player")
		 and IsSpellKnown(7744)
		 and ni.spell.available(7744) then
				ni.spell.cast(7744)
				return true
		end
		--- Horde race
		for i = 1, #hracial do
		if data.CDorBoss("target", 5, 35, 5, enabled)
		 and IsSpellKnown(hracial[i])
		 and ni.spell.available(hracial[i])
		 and data.dk.InRange() then 
					ni.spell.cast(hracial[i])
					return true
			end
		end
		--- Blood Elf
		for i = 1, #bloodelf do
		if data.CDorBoss("target", 5, 35, 5, enabled)
		 and ni.player.power() < 60 
		 and IsSpellKnown(bloodelf[i])
		 and ni.spell.available(bloodelf[i])
		 and data.dk.InRange() then 
					ni.spell.cast(bloodelf[i])
					return true
			end
		end
		--- Ally race
		for i = 1, #alracial do
		if data.dk.InRange()
		 and ni.player.hp() < 20
		 and IsSpellKnown(alracial[i])
		 and ni.spell.available(alracial[i]) then 
					ni.spell.cast(alracial[i])
					return true
				end
			end
		end,
-----------------------------------
	["Use enginer gloves"] = function()
		local _, enabled = GetSetting("detect")			
		if ni.player.slotcastable(10)
		 and ni.player.slotcd(10) == 0 
		 and data.CDorBoss("target", 5, 35, 5, enabled)
		 and data.dk.InRange() then
			ni.player.useinventoryitem(10)
			return true
		end
	end,
-----------------------------------
	["Trinkets"] = function()
		local _, enabled = GetSetting("detect")		
		if data.CDorBoss("target", 5, 35, 5, enabled)
		 and ni.player.slotcastable(13)
		 and ni.player.slotcd(13) == 0 
		 and data.dk.InRange() then
			ni.player.useinventoryitem(13)
		else
		 if data.CDorBoss("target", 5, 35, 5, enabled)
		 and ni.player.slotcastable(14)
		 and ni.player.slotcd(14) == 0 
		 and data.dk.InRange() then
			ni.player.useinventoryitem(14)
			return true
			end
		end
	end,
-----------------------------------
	["Noth's Special Brew (Use)"] = function()
		local _, enabled1 = GetSetting("noth")
		local _, enabled = GetSetting("detect")	
		if enabled1
		 and ni.player.power() < 80
		 and data.CDorBoss("target", 5, 35, 5, enabled)
		 and ni.player.hasitem(39327)
		 and ni.player.itemcd(39327) == 0 then
			ni.player.useitem(39327)
			return true
		end
	end,
-----------------------------------
	["Mind Freeze (Interrupt)"] = function()
		local _, enabled = GetSetting("autointerrupt")
		if enabled	
		 and ni.spell.shouldinterrupt("target")
		 and ni.spell.available(47528)
		 and GetTime() - data.LastInterrupt > 9
		 and ni.spell.valid("target", 47528, true, true)  then
			ni.spell.castinterrupt("target")
			data.LastInterrupt = GetTime()
			return true
		end
	end,
-----------------------------------
	["Icebound Fortitude"] = function()
		local value, enabled = GetSetting("iceboundfort");
		if enabled
		 and ni.player.hp() < value
		 and ni.spell.available(48792) 
		 and not ni.player.buff(48792) then
			ni.spell.cast(48792)
			return true
		end
	end,
-----------------------------------
	["Death and Decay"] = function()
		if ni.vars.combat.aoe
		 and ni.spell.available(49938) then
			ni.spell.castatqueue(49938, "target")
			return true
		end
	end,
-----------------------------------
	["Unbreakable Armor"] = function()
		local _, enabled = GetSetting("detect")			
		if data.CDorBoss("target", 5, 35, 5, enabled)
		 and ni.spell.available(51271)
		 and data.dk.InRange() then
			ni.spell.cast(51271)
			return true
		end
	end,
-----------------------------------
	["Raise Dead"] = function()
		local _, enabled1 = GetSetting("raisedead")
		local _, enabled = GetSetting("detect")
		if enabled1
		 and data.CDorBoss("target", 5, 35, 5, enabled)
		 and not ni.unit.exists("playerpet")
		 and not ni.player.buff(61431)
		 and ni.spell.available(46584)
		 and IsUsableSpell(GetSpellInfo(46584))
		 and ( ni.player.hasitem(37201)
		 or	ni.player.hasglyph(60200) ) then
			ni.spell.cast(46584)
			return true
		end
	end,
-----------------------------------
	["Empower Rune Weapon"] = function()
		local _, enabled = GetSetting("detect")		
		if data.CDorBoss("target", 5, 35, 5, enabled)
		 and ni.rune.available() == 0
		 and ni.spell.available(47568) then
			ni.spell.cast(47568)
			return true
		end
	end,
-----------------------------------
	["Icy Touch"] = function()
		local icy = data.dk.icy()
		if ( not icy or ( icy < 2.5 ) )
		 and ni.spell.available(49909)		
		 and ni.spell.valid("target", 49909, true, true) then
			ni.spell.cast(49909, "target")
			return true
		end
	end,
-----------------------------------
	["Plague Strike"] = function()
		local plague = data.dk.plague()
		if ( not plague or ( plague < 2.5 ) )
		 and ni.spell.available(49921)
		 and ni.spell.valid("target", 49921, true, true) then
			ni.spell.cast(49921, "target")
			return true
		end
	end,
-----------------------------------
	["Pestilence (AoE)"] = function()
		local icy = data.dk.icy()
		local plague = data.dk.plague()
		local enemies = ni.unit.enemiesinrange("target", 7)
		local _, BR = ni.rune.bloodrunecd()
		local _, DR = ni.rune.deathrunecd()
		if ( BR >= 1 or DR >= 1 )
		 and icy
		 and plague
		 and ni.spell.valid("target", 50842, true, true) then
		 if ActiveEnemies() >= 1 then
		  for i = 1, #enemies do
		   if ni.unit.creaturetype(enemies[i].guid) ~= 8
		    and ni.unit.creaturetype(enemies[i].guid) ~= 11
		    and (not ni.unit.debuff(enemies[i].guid, 55078, "player")
		    or not ni.unit.debuff(enemies[i].guid, 55095, "player")) then
				ni.spell.cast(50842, "target")
						return true
					end
				end
			end
		end
	end,
-----------------------------------
	["Pestilence (Renew)"] = function()
		local icy = data.dk.icy()
		local plague = data.dk.plague()
		local _, BR = ni.rune.bloodrunecd()
		local _, DR = ni.rune.deathrunecd()
		 if ni.player.hasglyph(63334)
		 and ni.spell.valid("target", 50842, true, true)
		 and ( ( icy ~= nil and icy < 4.5 )
		 or ( plague ~= nil and plague < 4.5 ) ) then
			if BR == 0 and DR == 0
			and ni.spell.cd(45529) == 0 then  
				ni.spell.cast(45529)
				ni.spell.cast(50842, "target")
			return true
		else
				ni.spell.cast(50842, "target")
			return true
			end
		end
	end,
-----------------------------------
	["Howling Blast"] = function()
		if ni.player.buff(59052)
		 and ni.player.power() < 90		
		 and ni.spell.available(51411)
		 and ni.spell.valid("target", 51411, true, true) then
			ni.spell.cast(51411, "target")
			return true
		end
	end,
-----------------------------------
	["Howling Blast (AoE)"] = function()
		if ni.player.buff(51124)
		 and ActiveEnemies() >= 2
		 and ni.player.power() < 90
		 and ni.spell.available(51411)
		 and ni.spell.valid("target", 51411, true, true) then
			ni.spell.cast(51411, "target")
			return true
		end
	end,
-----------------------------------
	["Death Strike (Lich)"] = function()
		local value, enabled = GetSetting("deathstrike"); 
		local _, FR = ni.rune.frostrunecd()
		local _, UR = ni.rune.unholyrunecd()
		local _, DR = ni.rune.deathrunecd()
		local icy = data.dk.icy()
		local plague = data.dk.plague()
		if enabled
		 and (not data.youInInstance()
		 and not data.youInRaid())
		 and ni.player.hp() < value
		 and ((FR >= 1 and UR >= 1)
		 or (FR >= 1 and DR >= 1)
		 or (DR >= 1 and UR >= 1)
		 or (DR == 2))
		 and plague
		 and icy
		 and ni.spell.available(49924)
		 and ni.spell.valid("target", 49924, true, true) then
			ni.spell.cast(49924, "target")
			return true
		end
	end,
-----------------------------------
	["Obliterate Dump"] = function()
		local _, FR = ni.rune.frostrunecd()
		local _, UR = ni.rune.unholyrunecd()
		local _, DR = ni.rune.deathrunecd()
		local icy = data.dk.icy()
		local plague = data.dk.plague()
		if ActiveEnemies() >= 2
		 and ((FR >= 1 and UR >= 1)
		 or (FR >= 1 and DR >= 1)
		 or (DR >= 1 and UR >= 1)
		 or (DR == 2))			 
		 and plague
		 and icy
		 and ni.player.power() < 90
		 and not ni.player.buff(51124)
		 and ni.spell.available(51425)
		 and ni.spell.valid("target", 51425, true, true) then
			ni.spell.cast(51425, "target")
			return true
		end
	end,
-----------------------------------
	["Obliterate"] = function()
		local _, FR = ni.rune.frostrunecd()
		local _, UR = ni.rune.unholyrunecd()
		local _, DR = ni.rune.deathrunecd()
		local icy = data.dk.icy()
		local plague = data.dk.plague()
		if ( ActiveEnemies() < 1 or ActiveEnemies() == 1 )
		 and ((FR >= 1 and UR >= 1)
		 or (FR >= 1 and DR >= 1)
		 or (DR >= 1 and UR >= 1)
		 or (DR == 2))			 
		 and plague
		 and icy
		 and ni.player.power() < 90
		 and ni.spell.available(51425)
		 and ni.spell.valid("target", 51425, true, true) then
			ni.spell.cast(51425, "target")
			return true
		end
	end,
-----------------------------------
	["Rune Strike"] = function()
		if IsUsableSpell(GetSpellInfo(56815))
		 and ni.spell.available(56815, true)
		 and not IsCurrentSpell(56815)
		 and ni.spell.valid("target", 56815, true, true) then
			ni.spell.cast(56815, "target")
			return true
		end
	end,
-----------------------------------
	["Frost Strike (Kill)"] = function()
		local icy = data.dk.icy()
		local plague = data.dk.plague()
		if ni.player.buff(51124)
		and plague
		and icy
		and ni.spell.available(55268)
		and ni.spell.valid("target", 55268, true, true) then
			ni.spell.cast(55268, "target")
			return true
		end
	end,
-----------------------------------
	["Frost Strike"] = function()
		local icy = data.dk.icy()
		local plague = data.dk.plague()
		if ni.player.power() > 96
		and plague
		and icy
		and ni.spell.available(55268)
		and ni.spell.valid("target", 55268, true, true) then
			ni.spell.cast(55268, "target")
			return true
		end
	end,
-----------------------------------
	["Frost Strike 2"] = function()
		local icy = data.dk.icy()
		local plague = data.dk.plague()
		if ni.player.power() >= 32
		and plague
		and icy
		and ni.spell.available(55268)
		and ni.spell.valid("target", 55268, true, true) then
			ni.spell.cast(55268, "target")
			return true
		end
	end,
-----------------------------------
	["Blood Strike"] = function()
		local _, BR = ni.rune.bloodrunecd()
		local icy = data.dk.icy()
		local plague = data.dk.plague()
		if BR >= 1
		 and plague
		 and icy
		 and ni.player.power() < 80
		 and ni.spell.available(49930)
		 and ni.spell.valid("target", 49930, true, true) then
			ni.spell.cast(49930, "target")
			return true
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Frost Dual Wield DPS Death Knight by DarhangeR for 3.3.5a", 
		 "Welcome to Frost Dual Wield DPS Death Knight Profile! Support and more in Discord > https://discord.gg/TEQEJYS.\n\n--Profile Function--\n-For use Death and Decay configure AoE Toggle key.")
		popup_shown = true;
		end 
	end,
}

	ni.bootstrap.profile("Frost2W_DarhangeR", queue, abilities, OnLoad, OnUnLoad);
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
            elseif not FrostStrike and not Howling then
              ni.frames.floatingtext:message("Go and learn all spells from trainer!");			
            end
        end,
    }
    ni.bootstrap.profile("Frost2W_DarhangeR", queue, abilities);
end	