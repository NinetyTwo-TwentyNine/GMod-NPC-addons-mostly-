-- Blixibon

-- In a squad, only two soldiers may attack at a time.
-- This mod splits up the squads automatically.
ESBOXNPCS_RandomCombineSquad = { "overwatch", "novaprospekt", "overwatch2", "overwatch3", "" } -- "" was a squad in order to have a 25% chance of clearing

ESBOXNPCS_Aircraft = { ["npc_combinegunship"] = true, ["npc_helicopter"] = true, ["npc_combinedropship"] = true }

ESBOXNPCS_StriderNodes = {}

util.AddNetworkString( "ESBOXNPCS_EnhancementDenied" )
util.AddNetworkString( "ESBOXNPCS_PlaySoundOnClient" )

local esboxnpcs_fixups_admin_only = CreateConVar("esboxnpcs_fixups_admin_only", "0", FCVAR_NONE, "Makes major fixups like strider node placement and map helicopter data loading only available to admins, so NPCs spawned by regular players will not be able to use any behavior that requires the fixups. After an admin triggers the fixup, regular players will be able to use the behavior without consequence.")
local esboxnpcs_strider_path_max = CreateConVar("esboxnpcs_strider_path_max", "16", FCVAR_ARCHIVE)
local esboxnpcs_strider_path_random = CreateConVar("esboxnpcs_strider_path_random", "1", FCVAR_ARCHIVE, "Place paths randomly or in order of BSP register?")
local esboxnpcs_all_npcs = CreateConVar("esboxnpcs_all_npcs", "0", FCVAR_ARCHIVE)
local esboxnpcs_heli_path_file_override = CreateConVar("esboxnpcs_heli_path_file_override", "", FCVAR_NONE)
local esboxnpcs_npc_friendlytospawner_admin_only = CreateConVar("esboxnpcs_npc_friendlytospawner_admin_only", "0", FCVAR_NONE, "Makes the \"NPCs Friendly To Spawner\" setting admin-only.")

concommand.Add("esboxnpcs_strider_fixup", function(ply) ESBOXNPCS_CreateStriderPath(ply) end)
concommand.Add("esboxnpcs_aircraft_fixup", function(ply) ESBOXNPCS_CreateHeliPaths(ply) end)
concommand.Add("esboxnpcs_draw_heli_paths", function(ply, cmd, args) ESBOXNPCS_DrawHeliPaths(tonumber(args[1])) end)
concommand.Add("esboxnpcs_reverse_heli_paths", function(ply) ESBOXNPCS_ReverseTracks(ply) end)

local function TableIsValid(tab)

	for _, v in pairs(tab) do
		if IsValid(v) then
			return true
		end
	end
	
	return false

end

local function GetPlayerConVar(ply, cvar) return ply:GetInfo(cvar) end
local function IsPlayerConVarEnabled(ply, cvar) return ply:GetInfoNum(cvar, 0) > 0 end

local function GetKeyValue(ent, key)
	for k, v in pairs(ent:GetKeyValues()) do
		if k == key then
			return v
		end
	end
	return ""
end

local function AddSpawnFlag(ent, flag)
	if !ent:HasSpawnFlags(flag) then
		ent:SetKeyValue("spawnflags", ent:GetSpawnFlags() + flag)
	end
end

function ESBOXNPCS_InDebugMode(ply) return IsPlayerConVarEnabled(ply, "esboxnpcs_debug") end
function ESBOXNPCS_DebugPrint(ply, msg) ply:PrintMessage(HUD_PRINTCONSOLE, msg) end
function ESBOXNPCS_DebugCheckPrint(ply, msg)
	if IsPlayerConVarEnabled(ply, "esboxnpcs_debug") then ply:PrintMessage(HUD_PRINTCONSOLE, msg) end 
end

-- Node entities only exist when the map first starts, so this hacky method records strider node locations right when the map loads.
-- This broke every time I made live Lua changes since it reloads the addon, but I don't know if anything could go wrong in regular gameplay.
local stridernodes_lastpos
hook.Add("EntityKeyValue", "Enhanced Sandbox NPC Node Storing", function(ent, key, val)

	if (key == "hinttype" && val == "904") then -- ent:GetClass() == "info_node_air_hint"
		local pos = ent:GetPos()
		
		-- Make sure it's not a duplicate
		if !stridernodes_lastpos || !pos:IsEqualTol(stridernodes_lastpos, 1.0) then
			table.insert(ESBOXNPCS_StriderNodes, pos)
			stridernodes_lastpos = pos
			--print("Adding strider node ", pos)
		end
	end
    
end)

ESBOXNPCS_StriderPathName = "esboxnpcs_striderpath"
local FirstStriderPath
function ESBOXNPCS_CreateStriderPath(ply)

	if IsValid(FirstStriderPath) then
		return
	end
	
	-- gm_construct has unused strider corners, a few other maps copy them for some reason
	-- Use them instead
	--if game.GetMap() == "gm_construct" then
		local stridercorner1 = ents.FindByName("stridercorner1")[1]
		if IsValid(stridercorner1) then
			print("gm_construct-style strider corners detected, aborting path_track generation and using existing corners")
			ESBOXNPCS_StriderPathName = "stridercorner"
			FirstStriderPath = stridercorner1
			return
		else
			ESBOXNPCS_StriderPathName = "esboxnpcs_striderpath"
		end
	--end
	
	if --[[!game.SinglePlayer() &&]] IsValid(ply) && (esboxnpcs_fixups_admin_only:GetBool() == true && !ply:IsAdmin()) then
		net.Start("ESBOXNPCS_EnhancementDenied")
		net.WriteString("Strider paths cannot be created! Let an admin do it.")
		net.Send(ply)
		return
	end
	
	local cullvalue = esboxnpcs_strider_path_max:GetInt()
	local shouldcull = cullvalue > 0
	
	if ESBOXNPCS_StriderNodes[1] != nil then
		print("Creating strider path")
	else
		return
	end
		
	local currentpath
	local pathname = ESBOXNPCS_StriderPathName
	local nextnum = 1
	local indebug = ESBOXNPCS_InDebugMode(ply)
	if esboxnpcs_strider_path_random:GetBool() then
		local tablecount = table.Count(ESBOXNPCS_StriderNodes)
		local v
		for i = 1,(shouldcull and cullvalue or 256),1 do -- 256 is limit, that many strider nodes would be absurd
		
			v = ESBOXNPCS_StriderNodes[math.random(tablecount)]
			
			if (indebug) then
				ESBOXNPCS_DebugPrint(ply, string.format("Creating strider track at %s", tostring(v)))
			end
			
			currentpath = ents.Create("path_track")
			if (IsValid(currentpath)) then
				currentpath:SetName(pathname .. nextnum)
				currentpath:SetPos(v)
				
				nextnum = nextnum + 1
				currentpath:SetKeyValue("target", pathname .. nextnum)
				currentpath:Spawn()
			end
			
		end
	else
		for _, v in pairs(ESBOXNPCS_StriderNodes) do
			if (shouldcull && nextnum > cullvalue) then break end
			
			if (indebug) then
				ESBOXNPCS_DebugPrint(ply, string.format("Creating strider track at %s", tostring(v)))
			end
		
			currentpath = ents.Create("path_track")
			if (IsValid(currentpath)) then
				currentpath:SetName(pathname .. nextnum)
				currentpath:SetPos(v)
				
				nextnum = nextnum + 1
				currentpath:SetKeyValue("target", pathname .. nextnum)
				currentpath:Spawn()
			end
		end
	end
	
	if (IsValid(currentpath)) then
		-- Make it a circle
		currentpath:SetKeyValue("target", pathname .. 1)
	end
		
	FirstStriderPath = currentpath

end

function ESBOXNPCS_UnpauseStriderCannonAI(repeater, bullseye)

	timer.UnPause(repeater)

end

function ESBOXNPCS_RunStriderCannonAI(strider, repeater)

	if !IsValid(strider) then
		print("Removing timer " .. repeater)
		timer.Remove(repeater)
		return
	end
	
	print("Running cannon AI")
	
	local firetarget = nil
	local followtarget = false
	
	local cannondelay = (strider:Health() / 12)

	local enemy = strider:GetEnemy()
	if IsValid(enemy) then
	
		--print("Enemy valid")
		
		local groundentity = enemy:GetGroundEntity()
		
		if IsValid(groundentity) &&
				(groundentity:GetClass() == "prop_physics" --||
				--groundentity:GetClass() == "func_physbox" ||
				--groundentity:GetClass() == "func_breakable"
				) then
			print("Enemy is standing on " .. groundentity:GetClass())
			firetarget = enemy:GetPos()
			cannondelay = (cannondelay / 2)
		elseif strider:Health() <= 300 then
			--print("Our health is ", strider:Health(), ", valid")
			firetarget = enemy:GetPos()
		elseif enemy:Health() >= 175 then -- enemy:GetHullType() >= HULL_LARGE
			--print("Enemy health is ", enemy:Health(), ", valid")
			firetarget = enemy:GetPos()
		end
		
	end
	
	if firetarget != nil then
	
		if followtarget == false then
			local bullseye = ents.Create("npc_bullseye")
			if IsValid(bullseye) then
			
				-- Strider will destroy whatever is in its way.
				local trace = util.TraceLine( {start = strider:GetShootPos(), endpos = firetarget, mask = MASK_SHOT} )
				if (trace.Fraction != 1) then
					
					if trace.HitNonWorld && IsValid(trace.Entity) then
						print("Strider cannon trace hit entity, setting strider cannon target to entity")
						firetarget = trace.HitPos
					else
						print("Moving strider cannon target up because it can't see target")
						firetarget:Add(Vector(0, 0, 64))
					end
					
				end
			
				AddSpawnFlag(bullseye, 65536) -- 262144
				bullseye:SetPos(firetarget)
				bullseye:SetName("esboxtemp" .. bullseye:EntIndex())
				print("Creating bullseye, " .. bullseye:GetName())
				bullseye:Spawn()
				strider:Fire("SetCannonTarget", bullseye:GetName())
				
				timer.Pause(repeater)
				timer.Simple(cannondelay, function() ESBOXNPCS_UnpauseStriderCannonAI(repeater, bullseye) end)
				
				-- Remove bullseyes after 20 seconds, in case we're reassigned or we take too long
				timer.Simple(20, function() if IsValid(bullseye) then bullseye:Remove() end end)
			end
		else
			local targetname = firetarget:GetName()
			if targetname == "" then
				targetname = "stridertarget" .. firetarget:EntIndex()
				firetarget:SetName(targetname)
			end
			
			strider:Fire("SetCannonTarget", targetname)
				
			timer.Pause(repeater)
			timer.Simple(cannondelay, function() ESBOXNPCS_UnpauseStriderCannonAI(repeater, nil) end)
		end
	end

end

-- 
ESBOXNPCS_HeliPathFile = nil
ESBOXNPCS_HeliPaths = {}
ESBOXNPCS_NonAutoPaths = {}
ESBOXNPCS_TracksReversed = false
local UsingOverride = false
function ESBOXNPCS_CreateHeliPaths(ply)

	-- Our way of checking whether we've already done this or not
	if TableIsValid(ESBOXNPCS_HeliPaths) then
		return
	end
	
	if !game.SinglePlayer() && IsValid(ply) && (esboxnpcs_fixups_admin_only:GetBool() == true && !ply:IsAdmin()) then
		net.Start("ESBOXNPCS_EnhancementDenied")
		net.WriteString("Heli paths cannot be created! Let an admin do it.")
		net.Send(ply)
		return
	end
	
	if esboxnpcs_heli_path_file_override:GetString() != "" then
		if file.Exists(esboxnpcs_heli_path_file_override:GetString(), "LUA") then
			ESBOXNPCS_HeliPathFile = esboxnpcs_heli_path_file_override:GetString()
			UsingOverride = true
		end
	elseif UsingOverride == true then
		ESBOXNPCS_HeliPathFile = nil
		UsingOverride = false
	end

	if !ESBOXNPCS_HeliPathFile then
		ESBOXNPCS_HeliPathFile = "maps/" .. game.GetMap() .. "_helinodes.lua"
	end

	if file.Exists(ESBOXNPCS_HeliPathFile, "LUA") then
		-- Get the file
		include(ESBOXNPCS_HeliPathFile)
		
		ESBOXNPCS_DebugPrint(ply, "Have file")
		
		local tablecount = table.Count(ESBOXNPCS_MapHeliNodes)
		if (ents.GetEdictCount() + tablecount) > 8192 then
			net.Start("ESBOXNPCS_EnhancementDenied")
			net.WriteString("There are too many entities in the level to create the heli paths. Try cleaning up the map.")
			net.Send(ply)
			return
		end
		print("ESBOXNPCS: Aircraft node table count is " .. tablecount - 1)
		
		ESBOXNPCS_TracksReversed = false
		
		-- Place all of the tracks
		local ent
		for _, data in pairs(ESBOXNPCS_MapHeliNodes) do
			-- I feel like someone could take advantage of this.
			--if (data.Class == "path_track") then
				ent = ents.Create(data.Class)
				for k, v in pairs (data) do
					ent:SetKeyValue(k, v)
				end
				if (data.Class == "path_track") then
					print("Creating " .. ent:GetName()) -- .. " with target " .. data.Target
					table.insert(ESBOXNPCS_HeliPaths, ent)
					
					if GetKeyValue(ent, "ResponseContext") == "esboxnpcs_no_auto" then
						ESBOXNPCS_NonAutoPaths[ent] = true
					end
				end
			--end
		end
			
		-- Make all of the tracks spawn here
		for _, v in pairs(ESBOXNPCS_HeliPaths) do
			if IsValid(v) then
				v:Activate()
				--print("Activated " .. v:GetName())
				ESBOXNPCS_HandleTrack(v:GetName(), GetKeyValue(v, "target"))
			else
				table.RemoveByValue(ESBOXNPCS_HeliPaths, v)
			end
		end
	end

end

function ESBOXNPCS_ReverseTracks(ply)

	if !game.SinglePlayer() && IsValid(ply) && (esboxnpcs_fixups_admin_only:GetBool() == true && !ply:IsAdmin()) then
		net.Start("ESBOXNPCS_EnhancementDenied")
		net.WriteString("You can't reverse tracks! Let an admin do it.")
		net.Send(ply)
		return
	end
	
	ESBOXNPCS_CreateHeliPaths(ply)

	local count = 0
	local pathtable = {}
	for _, path in pairs(ESBOXNPCS_HeliPaths) do
		
		if IsValid(path) then
			nextpath = ents.FindByName(ESBOXNPCS_GetNextPath(path))[1]
			table.insert(pathtable, {Path = path, Target = nextpath})
			count = count + 1
		end
		
	end
	
	if count == 0 && IsValid(ply) then
		net.Start("ESBOXNPCS_PlaySoundOnClient")
		net.WriteString("physics/wood/wood_crate_impact_hard4.wav")
		net.Send(ply)
		ply:PrintMessage(HUD_PRINTTALK, "No tracks to reverse!")
		return
	end
	
	for _, v in pairs(pathtable) do
	
		if IsValid(v.Target) then
			v.Target:SetKeyValue("target", v.Path:GetName())
			v.Target:Activate()
			print("Set target of " .. v.Target:GetName() .. " to " .. v.Path:GetName())
		end
	
	end
	
	-- Notify the player
	if IsValid(ply) then
		net.Start("ESBOXNPCS_PlaySoundOnClient")
		if (ESBOXNPCS_TracksReversed) then
			print("Tracks reverted to original by " .. ply:GetName())
			net.WriteString("physics/metal/metal_grenade_impact_hard3.wav")
			ply:PrintMessage(HUD_PRINTTALK, string.format("%i tracks reverted to original direction!", count))
		else
			print("Tracks reversed by " .. ply:GetName())
			net.WriteString("physics/metal/metal_grenade_impact_hard2.wav")
			ply:PrintMessage(HUD_PRINTTALK, string.format("%i tracks reversed!", count))
		end
		net.Send(ply)
	else
		print("Track reverse culprit not found")
	end
	
	ESBOXNPCS_TracksReversed = !ESBOXNPCS_TracksReversed

end

ESBOXNPCS_HeliTracks = {}
function ESBOXNPCS_HandleTrack(path, target)

	local track = nil
	local pathintrack = false
	local targetintrack = false
	local count = 1
	for _, v in pairs(ESBOXNPCS_HeliTracks) do
		if (v[path]) then
			pathintrack = true
		end
		if (v[target]) then
			targetintrack = true
		end
		
		if (targetintrack || pathintrack) then
			track = v
			break
		end
		
		count = count + 1
	end

	if track == nil then
		ESBOXNPCS_HeliTracks[count] = { [path] = true }
		track = ESBOXNPCS_HeliTracks[count]
		pathintrack = true
	end
	
	if (!pathintrack) then
		track[path] = true
	end
	
	--print("Adding " .. path .. " to track ", count)
	
	if (!targetintrack && target != "") then
		track[target] = true
		--print("Adding " .. target .. " to track ", count)
	end

end

function ESBOXNPCS_ChooseRandomTrack(origin)

	local track = nil
	for _, v in pairs(ESBOXNPCS_HeliTracks) do
		if (v[origin]) then
			track = v
			break
		end
	end
	
	if track != nil then
		local _, result = table.Random(track)
		if (table.Count(track) > 1) then
			while result == origin do
				_, result = table.Random(track)
			end
		end
		
		--print("Track Length: ", table.Count(track), " Result: " .. result)
		return result
	end
	
	return nil

end

function ESBOXNPCS_GetNextPath(ent)

	-- Always choose the internal target (borrows ResponseContext), but if there is none, choose the regular target
	for k, v in pairs(ent:GetKeyValues()) do
		key = string.lower(k)
		if key == "target" then
			return v
		end
	end

end

-- Designed to be called by lua_run within the map that runs every time a path_track is passed.
-- Derivative functions (e.g. ESBOXNPCS_InternalPathHandler_NextPath) can be called directly as well, but you'll have to make sure the activator and caller are valid first.
-- 
-- Old code fired directly from lua_run:
-- Code = "if IsValid(ACTIVATOR) && (!IsValid(ACTIVATOR:GetEnemy()) && ACTIVATOR:GetNPCState() == NPC_STATE_IDLE) then ESBOXNPCS_InternalPathHandler_NextPath(ACTIVATOR, CALLER) end"
function ESBOXNPCS_InternalPathHandler(activator, caller)

	if !IsValid(activator) || !IsValid(caller) then
		return
	end
	
	if GetKeyValue(activator, "target") != caller:GetName() then
		return
	end
	
	local usesbehavior = GetKeyValue(activator, "hintgroup") == "esbox_behavior"
	if (usesbehavior) then
		-- Only if we don't have an enemy
		if !IsValid(ACTIVATOR:GetEnemy()) && ACTIVATOR:GetNPCState() == NPC_STATE_IDLE then
			ESBOXNPCS_InternalPathHandler_RandomPath(activator, caller)
		end
	else
		-- Always
		ESBOXNPCS_InternalPathHandler_RandomPath(activator, caller)
	end

end

function ESBOXNPCS_InternalPathHandler_NextPath(activator, caller)

	if caller:GetClass() == "path_track" then
		local nextpath = ESBOXNPCS_GetNextPath(caller)
		activator:SetKeyValue("target", nextpath)
		activator:Fire("FlyToSpecificTrackViaPath", nextpath)
	end

end

function ESBOXNPCS_InternalPathHandler_RandomPath(activator, caller)

	if caller:GetClass() == "path_track" then
		local nextpath = ESBOXNPCS_ChooseRandomTrack(caller:GetName())
		activator:SetKeyValue("target", nextpath)
		activator:Fire("FlyToSpecificTrackViaPath", nextpath)
	end

end

function ESBOXNPCS_DrawHeliPaths(lifetime)

	local color = Color(100, 200, 255)
	for _, path in pairs(ESBOXNPCS_HeliPaths) do
		if IsValid(path) then
			debugoverlay.Box( path:GetPos(), Vector(-16, -16, -16), Vector(16, 16, 16), lifetime, color )
			nextpath = ents.FindByName(ESBOXNPCS_GetNextPath(path))[1]
			if IsValid(nextpath) then
				debugoverlay.Line( path:GetPos(), nextpath:GetPos(), lifetime, color, true )
			end
		end
	end

end

function ESBOXNPCS_HandleNPC(ent, ply)

	if (ent:IsNPC() == false) then
		return
	end

	if !IsValid(ply) then
		-- Try to get the host
		local players = player.GetAll()
		for _, v in pairs(players) do
			if v:IsListenServerHost() then
				ply = v
				break
			end
		end
		
		-- If it's still not valid, don't do fixup
		if !ply then print("Cannot handle NPC, invalid player") return end
	end
	
	local class = ent:GetClass():lower()
	local classify = ent:Classify()
	
	if IsPlayerConVarEnabled(ply, "esboxnpcs_npc_fixup") then
		ESBOXNPCS_FixupNPC(ent, ply)
	end
	
	if IsPlayerConVarEnabled(ply, "esboxnpcs_npc_patrol") then
		ent:Fire("StartPatrolling")
	end
	
	-- Turrets have problems with some features
	local isturret = string.sub(class, 1, 10) == "npc_turret"
	
	--if !isturret && IsPlayerConVarEnabled(ply, "esboxnpcs_npc_longvis") then
	--	AddSpawnFlag(ent, 256)
	--end
	
	if !ent:IsScripted() && !isturret && IsPlayerConVarEnabled(ply, "esboxnpcs_npc_squadcap") then
		local capabilities = ent:CapabilitiesGet()
		if bit.band(capabilities, CAP_SQUAD) == 0 then
			local dontshow = false
			ent:CapabilitiesAdd(CAP_SQUAD)
			
			-- Well, we know it was incapable of squads before, so giving it a squad now probably wouldn't hurt anything.	
			-- Squadnames are ignored on spawn when the NPC is incapable, but they don't clear the keyvalue, so the "if squadname is empty" thing is not reliable.
			if (classify == CLASS_PLAYER_ALLY ||
				classify == CLASS_PLAYER_ALLY_VITAL) then
				ent:Fire("SetSquad", "resistance")
			elseif (classify == CLASS_COMBINE ||
					classify == CLASS_COMBINEGUNSHIP) then
				ent:Fire("SetSquad", "overwatch")
			--[[elseif IsMounted("hl1") then
				print("HL1, ", classify)
				-- Don't try HL1 classes if HL1 is not mounted
				if (classify == 27) then -- CLASS_HUMAN_PASSIVE
					print("sintist")
					ent:Fire("SetSquad", "resistance")
				elseif (classify == 28) then -- CLASS_HUMAN_MILITARY
					-- Might as well put assassins in a different squad.
					-- It makes sense and the user might have a mod that makes them and the HECU enemies.
					print("what")
					if class == "monster_human_assassin" then
						print("a")
						ent:Fire("SetSquad", "blackops")
					else
						print("b")
						ent:Fire("SetSquad", "hecu")
					end
				elseif (classify == 29) then -- CLASS_ALIEN_MILITARY
					print("aliens")
					ent:Fire("SetSquad", "alien_military")
				end]]
			else
				dontshow = true
			end
			
			if dontshow != true then
				print("Adding squad capabilities to " .. class .. "...")
			end
		end
	end
	
	if IsPlayerConVarEnabled(ply, "esboxnpcs_npc_friendlytospawner") then
		if (esboxnpcs_fixups_admin_only:GetBool() == true && !ply:IsAdmin()) then
			net.Start("ESBOXNPCS_EnhancementDenied")
			net.WriteString("The \"NPCs friendly to spawner\" setting has been disabled by admins. This NPC's relationship has not been changed.")
			net.Send(ply)
		else
			ent:AddEntityRelationship( ply, D_LI, 99 )
		end
	end

	-- Helicopters
	if (ESBOXNPCS_Aircraft[class]) then
		if IsPlayerConVarEnabled(ply, "esboxnpcs_npc_squadcap") then
			ent:Fire("SetSquad", "overwatch")
		end
		if IsPlayerConVarEnabled(ply, "esboxnpcs_aircraft_nodes") then
			
			ESBOXNPCS_CreateHeliPaths(ply)
			
			if TableIsValid(ESBOXNPCS_HeliPaths) then
				local nearestpath = ESBOXNPCS_HeliPaths[1]
				local nearestpathdist = (32768 * 32768)
				for _, path in pairs(ESBOXNPCS_HeliPaths) do
					if IsValid(path) && !ESBOXNPCS_NonAutoPaths[path] then
						local dist = ent:GetPos():DistToSqr(path:GetPos())
						if (dist < nearestpathdist) then
							nearestpath = path
							nearestpathdist = dist
						end
					end
				end
				
				if IsPlayerConVarEnabled(ply, "esboxnpcs_debug") then
					ply:PrintMessage(HUD_PRINTCENTER, "Flying to " .. nearestpath:GetName())
				end
				ply:PrintMessage(HUD_PRINTCONSOLE, "Flying to " .. nearestpath:GetName())
				ent:Fire("FlyToSpecificTrackViaPath", nearestpath:GetName())
				ent:SetKeyValue("target", nearestpath:GetName())
			end
			
			if IsPlayerConVarEnabled(ply, "esboxnpcs_aircraft_behavior") then
				ent:Fire("StartBreakableMovement")
				ent:Fire("ChooseNearestPathPoint")
				ent:SetKeyValue("hintgroup", "esbox_behavior") -- Using hintgroup as data storage. They don't use hintgroups, so it's fine
			end
			
			if IsPlayerConVarEnabled(ply, "esboxnpcs_gunship_omniscient") then
				ent:Fire("OmniscientOn")
			end
			
			if class == "npc_helicopter" then
				if IsPlayerConVarEnabled(ply, "esboxnpcs_chopper_bombing_vehicle") then
					local attackmode = GetPlayerConVar(ply, "esboxnpcs_chopper_bombing_vehicle")
					local chosenbehavior = "StartDefaultBehavior"
					if 		(attackmode == "1") then chosenbehavior = "StartBombingVehicle"
					elseif	(attackmode == "2") then chosenbehavior = "StartAlwaysLeadingVehicle"
					elseif	(attackmode == "3") then chosenbehavior = "StartTrailingVehicle"
					elseif	(attackmode == "4") then chosenbehavior = "StartBullrushBehavior"
					end
					ent:Fire(chosenbehavior)
					ent:SetKeyValue("hintgroup", "esbox_behavior") -- Same here, since this is incompatible with FlyToSpecificTrackViaPath.
				end
				if IsPlayerConVarEnabled(ply, "esboxnpcs_chopper_long_cycle") then
					ent:Fire("StartLongCycleShooting")
				end
			end
		end
		
	-- Strider
	elseif (class == "npc_strider") then
		if IsPlayerConVarEnabled(ply, "esboxnpcs_strider_follows_paths") then
			-- Create our strider paths
			ESBOXNPCS_CreateStriderPath(ply)
			
			local paths = ents.FindByName(ESBOXNPCS_StriderPathName .. "*")
			local nearestpath
			local nearestpathdist = (32768 * 32768)
			for _, path in pairs(paths) do
				local dist = ent:GetPos():DistToSqr(path:GetPos())
				if (dist < nearestpathdist) then
					nearestpath = path
					nearestpathdist = dist
				end
			end
			
			if IsValid(nearestpath) then
				ent:Fire("SetTargetPath", nearestpath:GetName())
			end
		end
		if IsPlayerConVarEnabled(ply, "esboxnpcs_strider_stomps_player") then
			AddSpawnFlag(ent, 65536)
		end
		if IsPlayerConVarEnabled(ply, "esboxnpcs_strider_cannon") then
			local timername = "esboxnpcs_stridercannontimer" .. ent:EntIndex()
			timer.Create(timername, math.random(9, 14), 0, function() ESBOXNPCS_RunStriderCannonAI(ent, timername) end)
		end
		
	-- Hunter
	elseif (class == "npc_hunter") then
		if IsPlayerConVarEnabled(ply, "esboxnpcs_hunter_follows_striders") then
			-- Select the nearest strider and follow it.
			local striders = ents.FindByClass( "npc_strider" )
			local neareststrider
			local neareststriderdist = (4096 * 4096) -- Don't go for striders this far away
			
			for _, strider in pairs(striders) do
				local dist = ent:GetPos():DistToSqr(strider:GetPos())
				if (dist < neareststriderdist) then
					neareststrider = strider
					neareststriderdist = dist
				end
			end
			
			-- Hooray for messy, easily breakable hacks...
			-- ...yeah...
			if IsValid(neareststrider) then
			
				local stridername = neareststrider:GetName()
				if stridername == "" then
					stridername = "esbox_strider" .. neareststrider:EntIndex()
					neareststrider:SetName(stridername)
				end
				
				ent:Fire("FollowStrider", stridername)
				
			end
		end
		
	-- Combine Soldier
	elseif (class == "npc_combine_s") then
		if IsPlayerConVarEnabled(ply, "esboxnpcs_soldier_squad_mixup") then
			if IsPlayerConVarEnabled(ply, "esboxnpcs_soldier_squad_mixup_models") then
				local chosen = math.random(5)
				if (chosen == 5) then
					ent:Fire("SetSquad", "")
				else
					ent:Fire("SetSquad", string.format("%s_%i", ent:GetModel(), chosen))
				end
			else
				local count = 0
				for _ in pairs(ESBOXNPCS_RandomCombineSquad) do count = count + 1 end
				ent:Fire("SetSquad", ESBOXNPCS_RandomCombineSquad[math.random(count)])
			end
		end
		if IsPlayerConVarEnabled(ply, "esboxnpcs_soldier_add_hintgroup") then
			ent:SetKeyValue("hintgroup", "overwatch")
		end
		if (IsPlayerConVarEnabled(ply, "esboxnpcs_soldier_elite_proficiency") && string.sub(ent:GetModel(), -17) == "super_soldier.mdl") ||
			(IsPlayerConVarEnabled(ply, "esboxnpcs_soldier_ar2_proficiency") && IsValid(ent:GetActiveWeapon()) && ent:GetActiveWeapon():GetClass() == "weapon_ar2") then
			ent:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_VERY_GOOD )
		end
		if IsPlayerConVarEnabled(ply, "esboxnpcs_soldier_tactical_variant") then
			ent:SetKeyValue("tacticalvariant", GetPlayerConVar(ply, "esboxnpcs_soldier_tactical_variant"))
		end
		local grenoverride = GetPlayerConVar(ply, "esboxnpcs_soldier_grenade_override")
		if grenoverride != "-1" then
			ent:SetKeyValue("numgrenades", grenoverride) -- tonumber(grenoverride)
		end
		
	-- Metro Police
	elseif (class == "npc_metropolice") then
		if math.random() < tonumber(GetPlayerConVar(ply, "esboxnpcs_metrocop_manhack_chance")) then
			ent:SetKeyValue("manhacks", "1")
			ent:SetBodygroup(1, 1)
		end
		if IsPlayerConVarEnabled(ply, "esboxnpcs_metrocop_pistol_drawn") && IsValid(ent:GetActiveWeapon()) then
			ent:SetKeyValue("weapondrawn", "1")
			if ent:GetActiveWeapon():GetClass() == "weapon_pistol" then ent:GetActiveWeapon():RemoveEffects(EF_NODRAW) end
		end
		if IsPlayerConVarEnabled(ply, "esboxnpcs_metrocop_arrest_behavior") then
			AddSpawnFlag(ent, 2097152)
		end
		
	-- Scanners
	elseif (class == "npc_cscanner" ||
			class == "npc_clawscanner") then
		if IsPlayerConVarEnabled(ply, "esboxnpcs_scanners_update_directly") then
			ent:SetKeyValue("OnPhotographNPC", "npc_combine*,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnPhotographNPC", "npc_metropolice,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnPhotographNPC", "npc_apcdriver,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnPhotographNPC", "npc_vehicledriver,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnPhotographNPC", "npc_strider,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnPhotographNPC", "npc_helicopter,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnPhotographNPC", "npc_hunter,UpdateEnemyMemory,!activator,0.5,-1")
			
			ent:SetKeyValue("OnPhotographPlayer", "npc_combine*,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnPhotographPlayer", "npc_metropolice,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnPhotographPlayer", "npc_apcdriver,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnPhotographPlayer", "npc_vehicledriver,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnPhotographPlayer", "npc_strider,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnPhotographPlayer", "npc_helicopter,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnPhotographPlayer", "npc_hunter,UpdateEnemyMemory,!activator,0.5,-1")
		end
		
		-- Make sure we have the CloseUp sequence
		-- (allows all claw scanners to use, including both spawned shield scanners as well as d3_c17 scanners or custom models)
		if ent:LookupSequence("CloseUp") != -1 && IsPlayerConVarEnabled(ply, "esboxnpcs_scanners_carry_mines") then
			ent:Fire("EquipMine")
			
			ent:SetKeyValue("OnFoundEnemy", "!self,DeployMine,,4,-1")
			ent:SetKeyValue("OnFoundEnemy", "!self,SetRelationship,* D_NU 0,4.5,-1")
		end
		
	-- Cameras
	elseif (class == "npc_combine_camera") then
		if IsPlayerConVarEnabled(ply, "esboxnpcs_scanners_update_directly") then
			AddSpawnFlag(ent, 32)
			
			ent:SetKeyValue("OnFoundEnemy", "npc_combine*,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnFoundEnemy", "npc_metropolice,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnFoundEnemy", "npc_apcdriver,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnFoundEnemy", "npc_vehicledriver,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnFoundEnemy", "npc_strider,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnFoundEnemy", "npc_helicopter,UpdateEnemyMemory,!activator,0.5,-1")
			ent:SetKeyValue("OnFoundEnemy", "npc_hunter,UpdateEnemyMemory,!activator,0.5,-1")
		end
		
	-- Alyx
	elseif (class == "npc_alyx") then
		if IsPlayerConVarEnabled(ply, "esboxnpcs_alyx_gets_in_jalopy") then
			-- Select the nearest jalopy and get in it when needed.
			local jalopies = ents.FindByClass( "prop_vehicle_jeep" )
			local nearestjalopy
			local nearestjalopydist = (2048 * 2048) -- Should be relatively close
			
			for _, jalopy in pairs(jalopies) do
				local dist = ent:GetPos():DistToSqr(jalopy:GetPos())
				if (dist < nearestjalopydist) then
					nearestjalopy = jalopy
					nearestjalopydist = dist
				end
			end
			
			-- Hooray for messy, easily breakable hacks...
			-- ...yeah...
			if IsValid(nearestjalopy) then
			
				local name = ent:GetName()
				if name == "" then
					name = "esbox_alyx" .. ent:EntIndex()
					ent:SetName(name)
				end
				
				local jalopyname = nearestjalopy:GetName()
				if jalopyname == "" then
					jalopyname = "esbox_jalopy" .. ent:EntIndex()
					nearestjalopy:SetName(jalopyname)
				end
				
				nearestjalopy:SetKeyValue("PlayerOn", string.format("%s,EnterVehicle,%s,0.25,-1", name, jalopyname))
				nearestjalopy:SetKeyValue("PlayerOff", string.format("%s,ExitVehicle,,0.25,-1", name))
				
			end
		end
		
	-- Dog
	elseif (class == "npc_dog") then
		if IsPlayerConVarEnabled(ply, "esboxnpcs_dog_playing_fetch") then
			ent:Fire("StartCatchThrowBehavior")
		end
	--elseif () then
    end
	
	-- Operations involving classify classes must be handled separately from classnames
	if	(classify == CLASS_PLAYER_ALLY ||
			classify == CLASS_PLAYER_ALLY_VITAL ||
			classify == CLASS_VORTIGAUNT) then
		if IsPlayerConVarEnabled(ply, "esboxnpcs_gunship_cithate") then
			ent:AddRelationship( "npc_combinegunship D_HT 0" )
		end
	end
end

function ESBOXNPCS_FixupNPC(ent, ply, force)

	local class = ent:GetClass():lower()
	
	-- Just check for lack of squadname
	-- Most NPC creators who add squads usually know what they're doing...
	local squadname = GetKeyValue(ent, "squadname")
	if (!force && squadname != "") then
		return
	end
	
	-- GetKeyValue(ent, "citizentype") == CT_UNIQUE
	-- ent:GetModel() != "models/police.mdl"
	
	-- Checks for unique type, which indicates a custom model (I know Odessa is checked, but who cares)
	-- Sets squad and makes medics drop health vials when they die
	if (class == "npc_citizen") then
		ent:Fire("SetSquad", "resistance")
		if ent:HasSpawnFlags(131072) && !ent:HasSpawnFlags(8) then
			ent:SetKeyValue("spawnflags", ent:GetSpawnFlags() + 8)
		end
		
	-- This one just makes sure it doesn't have a squad name
	-- Then it sets the squad to "overwatch" and gives 5 grenades (other soldier settings, like mixup or grenade override, can change this)
	elseif (class == "npc_combine_s" ||
			class == "npc_metropolice") then
		ent:Fire("SetSquad", "overwatch")
		//ent:SetKeyValue("numgrenades", "5")
		
	-- If any zombie or antlion reskins that don't already use squads come to light, let me know.
	-- I disabled this for performance reasons. (don't forget this gets called every time a NPC is spawned)
	--[[
	elseif (class == "npc_zombie" ||
			class == "npc_zombie_torso" ||
			class == "npc_fastzombie" ||
			class == "npc_fastzombie_torso" ||
			class == "npc_zombine") then
		if (force || squadname == "") then
			ent:Fire("SetSquad", "zombies")
		end
		
	elseif (class == "npc_headcrab" ||
			class == "npc_headcrab_fast") then
		if (force || squadname == "")
			ent:Fire("SetSquad", "zombies")
		end
		
	elseif (class == "npc_poisonzombie" ||
			class == "npc_headcrab_poison") then
		if (force || squadname == "")
			ent:Fire("SetSquad", "poison")
		end
		
	elseif (class == "npc_antlion" ||
			class == "npc_antlion_worker" ||
			class == "npc_antlionguard") && (force || squadname == "") then
		if (force || squadname == "")
			ent:Fire("SetSquad", "antlions")
		end]]
		
	elseif (class == "npc_vortigaunt") then
		ent:Fire("SetSquad", "resistance")
		
	end

end

hook.Add("PlayerSpawnedNPC", "Enhanced Sbox NPC Handling", function(ply, ent) -- OnEntityCreated

    if !esboxnpcs_all_npcs:GetBool() then
		ESBOXNPCS_HandleNPC(ent, ply)
	end
	
end)

hook.Add("OnEntityCreated", "Enhanced Sbox NPC Handling", function(ent)

    if esboxnpcs_all_npcs:GetBool() then
		timer.Simple(0.01, function() if IsValid(ent) then ESBOXNPCS_HandleNPC(ent, nil) end end)
	end
	
end)

hook.Add("AcceptInput", "Enhanced Sbox NPCs Input Handling", function(ent, input, activator, caller, value)

    -- Internally, UpdateEnemyMemory only accepts targetnames, so nothing like !activator works.
	-- Why? I don't know. Valve's lack of planning, I guess.
	-- This is needed to get scanner-updates-all-Combine to work.
	if (input == "UpdateEnemyMemory") && ent:IsNPC() then
		if value == "!activator" && IsValid(activator) then
			ent:UpdateEnemyMemory(activator, activator:GetPos())
			return true
		end
	end
	
end)

