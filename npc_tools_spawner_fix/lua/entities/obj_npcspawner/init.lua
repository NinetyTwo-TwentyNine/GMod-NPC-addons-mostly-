
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

numpad.Register("npctool_spawner_turnon",function(pl,ent,pID)
	if(!ent:IsValid()) then return end
	ent:SetEnabled(true)
end)
numpad.Register("npctool_spawner_turnoff",function(pl,ent,pID)
	if(!ent:IsValid()) then return end
	ent:SetEnabled(false)
end)

AccessorFunc(ENT,"m_class","NPCClass",FORCE_STRING)
AccessorFunc(ENT,"m_squad","Squad",FORCE_STRING)
AccessorFunc(ENT,"m_equipment","NPCEquipment",FORCE_STRING)
AccessorFunc(ENT,"m_keyon","KeyTurnOn",FORCE_NUMBER)
AccessorFunc(ENT,"m_keyoff","KeyTurnOff",FORCE_NUMBER)
AccessorFunc(ENT,"m_delay","SpawnDelay",FORCE_NUMBER)
AccessorFunc(ENT,"m_max","MaxNPCs",FORCE_NUMBER)
AccessorFunc(ENT,"m_total","TotalNPCs",FORCE_NUMBER)
AccessorFunc(ENT,"m_bStartOn","StartOn",FORCE_BOOL)
AccessorFunc(ENT,"m_bDeleteOnRemove","DeleteOnRemove",FORCE_BOOL)
AccessorFunc(ENT,"m_bEnabled","Enabled",FORCE_BOOL)
AccessorFunc(ENT,"m_bPatrolWalk","PatrolWalk",FORCE_BOOL)
AccessorFunc(ENT,"m_patrolType","PatrolType",FORCE_NUMBER)
AccessorFunc(ENT,"m_bStrict","StrictMovement",FORCE_BOOL)
AccessorFunc(ENT,"m_spawnflags","NPCSpawnflags",FORCE_NUMBER)
AccessorFunc(ENT,"m_bBurrowed","NPCBurrowed",FORCE_BOOL)
AccessorFunc(ENT,"m_tbKeyValues","NPCKeyValues")
AccessorFunc(ENT,"m_tbSpawnInputs","NPCSpawnInputs")
AccessorFunc(ENT,"m_proficiency","NPCProficiency",FORCE_NUMBER)
AccessorFunc(ENT,"m_soundtrack","Soundtrack",FORCE_STRING)
AccessorFunc(ENT,"m_tbNPCData","NPCData")

function ENT:Initialize()
	self:SetNotSolid(true)
	self:DrawShadow(false)
	
	numpad.OnDown(self.entOwner,self:GetKeyTurnOn(),"npctool_spawner_turnon",self)
	numpad.OnDown(self.entOwner,self:GetKeyTurnOff(),"npctool_spawner_turnoff",self)
	
	self:SetEnabled(false)
	self.m_nextSpawn = CurTime() + self:GetSpawnDelay()
	self.m_tbNPCs = {}
	self.m_tbVehicles = {}
	self.m_tbPatrolPoints = self.m_tbPatrolPoints || {}
	if self:GetTotalNPCs() == 0 then self:SetTotalNPCs(-1) end
	if self:GetStartOn() then self:SetEnabled(true) end
	if(self.m_bShowEffects == nil) then self:ShowEffects(true) end
	self.m_tbClients = {}
	self.m_tbNPCData = self.m_tbNPCData || {}
	local idx = self:EntIndex()
end

function ENT:GetNPCData() return self.m_tbNPCData end

function ENT:ShowEffects(b)
	self.m_bShowEffects = b
	if(!b) then
		if(IsValid(self.m_entEffect)) then self.m_entEffect:Remove() end
		self.m_entEffect = nil
		return
	end
	if(IsValid(self.m_entEffect)) then return end
	local e = ents.Create("env_effectscript")
	e:SetPos(self:GetPos())
	e:SetParent(self)
	e:SetModel("models/Effects/teleporttrail_Alyx.mdl")
	e:SetKeyValue("scriptfile","scripts/effects/testeffect.txt")
	e:Spawn()
	e:Activate()
	e:Fire("SetSequence","teleport",0)
	self:DeleteOnRemove(e)
	self.m_nextEffect = CurTime() +8
	self.m_entEffect = e
end

function ENT:AddPatrolPoint(vec)
	self.m_tbPatrolPoints = self.m_tbPatrolPoints || {}
	local ent = ents.Create("obj_patrolpoint")
	ent:SetPos(vec)
	ent:SetWalk(self:GetPatrolWalk())
	ent:SetType(self:GetPatrolType())
	ent:SetStrictMovement(self:GetStrictMovement())
	ent:Spawn()
	ent:Activate()
	local ptype = self:GetPatrolType()
	if ptype == 3 && self.m_tbPatrolPoints[1] then ent:SetNextPatrolPoint(self.m_tbPatrolPoints[1])
	elseif ptype == 2 && #self.m_tbPatrolPoints > 0 then ent:SetLastPatrolPoint(self.m_tbPatrolPoints[#self.m_tbPatrolPoints]) end
	if self.m_tbPatrolPoints[#self.m_tbPatrolPoints] then self.m_tbPatrolPoints[#self.m_tbPatrolPoints]:SetNextPatrolPoint(ent) end
	table.insert(self.m_tbPatrolPoints, ent)
	
	self:DeleteOnRemove(ent)
end

function ENT:SetEntityOwner(ent)
	self.entOwner = ent
end

local function finishNPCSpawn(self, npc)
	local data = self:GetNPCData()
	local keyvalues = self:GetNPCKeyValues()
	local squad = self:GetSquad()
	local burrowed = self:GetNPCBurrowed()
	local proficiency = self:GetNPCProficiency()
	local total = self:GetTotalNPCs()

	npc:Spawn()
	npc:Activate()
	if(data.Model) then if npc:GetModel() != data.Model then npc:SetModel(data.Model) end end
	if(data.Material) then npc:SetMaterial(data.Material) end
	if(data.Health) then npc:SetHealth(data.Health) if npc:GetMaxHealth() != 0 then npc:SetMaxHealth(data.Health) end end

	if(IsValid(self.entOwner)) then cleanup.Add(self.entOwner,"npcs",npc) end
	if(burrowed) then npc:Fire("unburrow","",0) end
	if(!self.m_obbMaxNPC) then
		if IsValid(npc.Vehicle) then
			self.m_obbMinNPC = npc.Vehicle:OBBMins()
			self.m_obbMaxNPC = npc.Vehicle:OBBMaxs()
		else
			self.m_obbMinNPC = npc:OBBMins()
			self.m_obbMaxNPC = npc:OBBMaxs()
		end
	end

	timer.Simple(0.1, function()
	if !IsValid(npc) then return end

	local backup_key
	local backup_value
	for k,v in pairs(npc:GetKeyValues()) do
		backup_key = string.lower(k)
		backup_value = ""
		if(data.KeyValues) then
			for k1,v1 in pairs(data.KeyValues) do
				if string.lower(k1) == backup_key then
					backup_value = v1
				end
			end
		end
		if(keyvalues) then
			for k1,v1 in pairs(keyvalues) do
				if string.lower(k1) == backup_key then
					backup_value = v1
				end
			end
		end
		if v != backup_value && backup_value != "" then
			npc:SetKeyValue(backup_key, backup_value)
		end
	end
	if(squad) && npc:GetKeyValues()["squadname"] then
	if squad != npc:GetKeyValues()["squadname"] then
		npc:Fire("setsquad",squad,0)
	end
	end

	if(proficiency == 5) then npc:SetCurrentWeaponProficiency(math.random(0,4))
	elseif(proficiency != 6) then npc:SetCurrentWeaponProficiency(proficiency) end

	for input_name,input_param in pairs(self.m_tbSpawnInputs) do
		npc:Fire(input_name,input_param)
	end
	end)

	table.insert(self.m_tbNPCs,npc)
	if table.Count(self.m_tbNPCs) >= self:GetMaxNPCs() then
		for _,ent in pairs(self.m_tbNPCs) do
			ent:CallOnRemove("NPCAmountCheck"..self:EntIndex(), function()
				if !IsValid(self) then return end
				if table.Count(self.m_tbNPCs) == self:GetMaxNPCs() then
					self.m_nextSpawn = CurTime() + self:GetSpawnDelay()
				end
				table.RemoveByValue(self.m_tbNPCs,ent)
			end)
		end
	else
		self.m_nextSpawn = CurTime() + self:GetSpawnDelay()
	end

	if(self:GetDeleteOnRemove()) then
		//self:DeleteOnRemove(npc)  // For some reason this function just crushes the game
		self:CallOnRemove("DeleteAllNPCs"..self:EntIndex(), function()
			for _,npc in ipairs(self.m_tbNPCs) do
				if IsValid(npc) then npc:Remove() end
			end
			for _,vehicle in ipairs(self.m_tbVehicles) do
				if IsValid(vehicle) then vehicle:Remove() end
			end
		end)
	end

	if(self.m_tbPatrolPoints[1]) then
		self.m_tbPatrolPoints[1]:AddNPC(npc)
	end

	if(total > 0) then
		total = total -1
		self:SetTotalNPCs(total)
		if(total == 0) then
			for _,npc in ipairs(self.m_tbNPCs) do
				npc:CallOnRemove("NPCAmountCheck_BeforeDeletion"..self:EntIndex(), function()
					if !IsValid(self) then return end
					table.RemoveByValue(self.m_tbNPCs,npc)
					if table.Count(self.m_tbNPCs) == 0 then
						self:Remove()
					end
				end)
			end
		end
	end

	/*local track = self:GetSoundtrack()
	if(track == "" || self.m_bTrackPlaying) then return end
	local bTrackPlaying
	for _,ent in ipairs(ents.GetAll()) do
		if((ent:IsNPC() && ent.HasSoundtrack) || (ent:GetClass() == "obj_npcspawner" && ent:IsSoundtrackPlaying())) then bTrackPlaying = true; break end
	end
	if(bTrackPlaying) then return end
	self.m_bTrackPlaying = true
	net.Start("slv_npctools_spawner_play")
		net.WriteEntity(self)
	net.Send(self.m_tbClients)*/
end

function ENT:SpawnNPC()
	for i = #self.m_tbNPCs,1,-1 do
		local ent = self.m_tbNPCs[i]
		if(!ent:IsValid() || ent:Health() < 0) then table.remove(self.m_tbNPCs,i) end
	end

	local data = self:GetNPCData()
	local class = self:GetNPCClass()
	local keyvalues = self:GetNPCKeyValues()
	local squad = self:GetSquad()
	local equip = self:GetNPCEquipment()
	local burrowed = self:GetNPCBurrowed()
	local spawnflags = self:GetNPCSpawnflags() || 0
	if(data.SpawnFlags) then spawnflags = bit.bor(spawnflags,data.SpawnFlags) end

	local offset = data.Offset || 25
	if(self.m_obbMaxNPC) && !IsValid(self.CurrentSimfphysVehicle) then
		for _,ent in ipairs(ents.FindInBox(self:LocalToWorld(self.m_obbMinNPC) + self:GetUp()*offset, self:LocalToWorld(self.m_obbMaxNPC) + self:GetUp()*offset)) do
			if (ent:IsValid() && (ent:GetPhysicsObject():IsValid() || ent:IsNPC() || ent:IsPlayer()) && !ent:IsWeapon()) then return end
		end
	end

	if(self.m_bShowEffects) then self:EmitSound("beams/beamstart5.wav",75,100) end
	if list.Get( "simfphys_vehicles" ) then
		if class == "npc_vehicledriver" && list.Get( "simfphys_vehicles" )[ keyvalues["vehicle"] ] && !IsValid(self.CurrentSimfphysVehicle) then
			local vehicle_pos = self:GetPos() + self:GetUp()*offset
			local vehicle_ang = Angle(0,self:GetAngles().y,0)
			local simfphys_vehicle = simfphys.SpawnVehicleSimple( keyvalues["vehicle"], vehicle_pos, vehicle_ang )
			
			local vehicle_skin
			if (data.Skin) then vehicle_skin = data.Skin end
			for key,val in pairs(keyvalues) do
				if (string.lower(key) == "skin") then vehicle_skin = val break end
			end
			if (vehicle_skin) then simfphys_vehicle:SetSkin(vehicle_skin) end

			table.insert(self.m_tbVehicles,simfphys_vehicle)

			self.CurrentSimfphysVehicle = simfphys_vehicle
			self.SpecialTimerDelay = 0.5
			return
		end
	end
	local npc = ents.Create(class)

	if(!npc:IsValid()) then ErrorNoHalt("Warning: Invalid npc class '" .. class .. "' for NPC Spawner! Removing..."); self:Remove(); return end
	npc:SetPos(self:GetPos() + self:GetUp()*offset)
	npc:SetAngles(Angle(0,self:GetAngles().y,0))

	if(burrowed) then npc:SetKeyValue("startburrowed","1") end
	if(equip) then npc:SetKeyValue("additionalequipment",equip) end
	npc:SetKeyValue("spawnflags",spawnflags)
	if(data.Model) then npc:SetKeyValue("model", data.Model) end
	if(data.Skin) then npc:SetKeyValue("skin", data.Skin) end
	if(data.KeyValues) then
		for key,val in pairs(data.KeyValues) do npc:SetKeyValue(key,val) end
	end
	if(keyvalues) then
		for key,val in pairs(keyvalues) do npc:SetKeyValue(key,val) end
	end
	if(squad) then npc:SetKeyValue("squadname", squad) end

	if class == "npc_apcdriver" && npc:GetInternalVariable("vehicle") == "" then
		local combine_apc = ents.Create( "prop_vehicle_apc" )
		combine_apc:SetName( "CombineAPC"..combine_apc:EntIndex() )
		combine_apc:SetPos(self:GetPos() + self:GetUp()*offset)
		combine_apc:SetAngles(Angle(0,self:GetAngles().y,0))
		combine_apc:SetKeyValue( "model", "models/combine_apc.mdl" )
		combine_apc:SetKeyValue( "vehiclescript", "scripts/vehicles/apc_npc.txt" )
		combine_apc:Spawn()
		table.insert(self.m_tbVehicles,combine_apc)

		combine_apc:Fire("lock")
		combine_apc:Fire("TurnOn")
		combine_apc:Activate()

		combine_apc:AddEFlags(EFL_DONTBLOCKLOS)
		combine_apc:EnableEngine(true)
		combine_apc:StartEngine(true)

		npc:SetKeyValue("vehicle",combine_apc:GetName())
		npc.Vehicle = combine_apc
	end
	if class == "npc_vehicledriver" && IsValid(self.CurrentSimfphysVehicle) then
		local simfphys_vehicle = self.CurrentSimfphysVehicle
		simfphys_vehicle.DriverSeat:SetName("simfphys["..simfphys_vehicle:EntIndex().."]driver_seat")
		if simfphys_vehicle.PassengerSeats then
			local duplicate_keys_table = {}
			for k,_ in pairs(data.KeyValues or {}) do duplicate_keys_table[k:lower()] = true end
			for k,_ in pairs(keyvalues or {}) do duplicate_keys_table[k:lower()] = true end
			duplicate_keys_table["squadname"] = true
			duplicate_keys_table["spawnflags"] = true
			duplicate_keys_table["vehicle"] = nil
			duplicate_keys_table["body"] = nil

			for i = 1,npc:GetInternalVariable("body") do
				if simfphys_vehicle.pSeat[i] then
					simfphys_vehicle.pSeat[i]:SetName("simfphys["..simfphys_vehicle:EntIndex().."]passenger_seat#"..i)
					local npc_duplicate = ents.Create(class)
					for key,val in pairs(npc:GetKeyValues()) do
						if key:lower() == "globalname" then npc_duplicate:SetKeyValue("targetname", npc:GetName()) continue end
						if !duplicate_keys_table[key:lower()] then continue end
						npc_duplicate:SetKeyValue(key, tostring(val))
					end
					npc_duplicate:SetKeyValue("vehicle",simfphys_vehicle.pSeat[i]:GetName())
					npc_duplicate.Vehicle = simfphys_vehicle

					npc_duplicate:Spawn()
					npc_duplicate:Activate()
				else
					break
				end
			end
		end

		npc:SetKeyValue("vehicle",simfphys_vehicle.DriverSeat:GetName())
		npc.Vehicle = simfphys_vehicle

		self.CurrentSimfphysVehicle = nil
	end

	finishNPCSpawn(self, npc)
end

/*
function ENT:IsSoundtrackPlaying() return self.m_bTrackPlaying end

util.AddNetworkString("slv_npctools_spawner_play")
util.AddNetworkString("slv_npctools_spawner_reqtrack")
util.AddNetworkString("slv_npctools_spawner_rectrack")
net.Receive("slv_npctools_spawner_reqtrack",function(len,pl)
	local ent = net.ReadEntity()
	if(!ent:IsValid()) then return end
	local track = ent:GetSoundtrack()
	if(track == "") then return end
	net.Start("slv_npctools_spawner_rectrack")
		net.WriteEntity(ent)
		net.WriteString(track)
	net.Send(pl)
	table.insert(self.m_tbClients,pl)
end)
*/

function ENT:Think()
	if self:GetTotalNPCs() == 0 then return end
	if(IsValid(self.m_entEffect) && CurTime() > self.m_nextEffect) then self.m_entEffect:Fire("SetSequence","teleport",0); self.m_nextEffect = CurTime() +8 end
	if(!self:GetEnabled()) then return end
	if(CurTime() >= self.m_nextSpawn) && (table.Count(self.m_tbNPCs) < self:GetMaxNPCs()) then
		self:SpawnNPC()
	end

	if self.SpecialTimerDelay then
		self:NextThink(CurTime() + self.SpecialTimerDelay)
		self.SpecialTimerDelay = nil
		return true
	end
end

function ENT:AcceptInput(cvar,activator,caller) end