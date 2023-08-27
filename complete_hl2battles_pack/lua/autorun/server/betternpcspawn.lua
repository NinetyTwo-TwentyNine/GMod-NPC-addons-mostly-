include('HL2 Fixes/ai_ignoreplayers_fix.lua')
include('HL2 Fixes/gunship_cannon_fix.lua')
include('HL2 Fixes/helicopter_damage_fix.lua')
include('HL2 Fixes/metropolice_manhack_fix.lua')
include('HL2 Fixes/working_apcdriver.lua')


CreateConVar("bns_npc_check_complete", 1, bit.bor(FCVAR_NOT_CONNECTED, FCVAR_UNREGISTERED), "", 0, 1)

local UnnecessaryKeyValues = {"additionalequipment", "avelocity", "basevelocity", "body", "cycle", "dontusespeechsemaphore", "effects", "expressionoverride", "fademaxdist", "fademindist", "fadescale", "friction", "globalname", "gravity", "hitboxset", "lightingorigin", "lightingoriginhack", "ltime", "modelindex", "playbackrate", "sequence", "shadowcastdist", "skin", "spawnflags", "speed", "texframeindex", "velocity", "view_ofs", "waterlevel"}
cvars.AddChangeCallback("bns_npc_check_complete", function()
  if GetConVarNumber("bns_npc_check_complete") == 0 then
    list.Add("BNS_AllNPCTemplates")
    list.Add("BNS_NPCKeyValues")

    for k,v in pairs(list.Get("NPC")) do
      if !list.Get("BNS_NPCKeyValues")[v.Class] then
        list.GetForEdit("BNS_NPCKeyValues")[v.Class] = {}
        local keyvaluessponge = ents.Create(v.Class)
        if keyvaluessponge:IsNPC() then
          for k1,v1 in pairs(keyvaluessponge:GetKeyValues()) do
            if !table.HasValue(UnnecessaryKeyValues, string.lower(k1)) then
              list.GetForEdit("BNS_NPCKeyValues")[v.Class][string.lower(k1)] = v1
            elseif string.lower(k1) == "globalname" then
              list.GetForEdit("BNS_NPCKeyValues")[v.Class]["targetname"] = v1
            end
          end
        end
        keyvaluessponge:Remove()
      end

      if !table.IsEmpty(list.Get("BNS_NPCKeyValues")[v.Class]) then
        list.GetForEdit("BNS_AllNPCTemplates")[k] = v
      end
    end
    GetConVar("bns_npc_check_complete"):SetFloat(1)
  end
end)

hook.Add("InitPostEntity", "BNS_GetAllNPCTemplates&KeyValues", function()
	timer.Simple(FrameTime(), function()
		GetConVar("bns_npc_check_complete"):SetFloat(0)
	end)
end)


list.Add("BNS_PlayerNPCTemplates")
local NPCMenuType = ""

hook.Add("PlayerSpawnNPC", "BNSServerMenuChanges", function(ply, npc_type, toolgun_spawn)
  if list.Get("BNS_AllNPCTemplates")[npc_type] then
    NPCMenuType = npc_type

    if toolgun_spawn != true then
      if list.Get("BNS_PlayerNPCTemplates")[ply:AccountID()] then
        if list.Get("BNS_PlayerNPCTemplates")[ply:AccountID()][NPCMenuType] then
          list.Set("NPC", NPCMenuType, list.Get("BNS_PlayerNPCTemplates")[ply:AccountID()][NPCMenuType])
        end
      end
    end
  end
end)

hook.Add("PlayerSpawnedNPC", "BNSAdditionalNPCSetupHook", function(ply, npc)
  if npc:IsNPC() then
    if list.Get("NPC")[NPCMenuType].Weapons then
      if ply:GetInfo("gmod_npcweapon") != "" && npc:GetKeyValues()["additionalequipment"] == "" then
        npc:Give(ply:GetInfo("gmod_npcweapon"))
      end
    end
    if list.Get("NPC")[NPCMenuType].Health then
      if npc:GetMaxHealth() != 0 && npc:Health() != npc:GetMaxHealth() then
        npc:SetMaxHealth(list.Get("NPC")[NPCMenuType].Health)
      end
    end
    list.Set("NPC", NPCMenuType, list.Get("BNS_AllNPCTemplates")[NPCMenuType])

    if bit.band(npc:GetKeyValues()["spawnflags"], 16) != 0 then
      if npc:GetClass() == "npc_metropolice" then
	npc:CapabilitiesAdd(CAP_AIM_GUN)
        npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
        npc:SetMaxHealth(0)
      end
      npc:SetKeyValue( "spawnflags", bit.band(npc:GetKeyValues()["spawnflags"], bit.bnot(16)) )
    end
  end
end)

hook.Add("PlayerSpawnedVehicle", "BNSAdditionalVehicleSetupHook", function(ply, vehicle)
  if vehicle:GetClass() == "prop_vehicle_apc" then
    vehicle:Fire("Lock")
    //vehicle:Fire("TurnOn")
    vehicle:AddEFlags(EFL_DONTBLOCKLOS)
  end
end)

hook.Add("PlayerDisconnected", "BNSClientNPCTemplatesDelete", function(ply)
  list.GetForEdit("BNS_AllNPCTemplates")[ply:AccountID()] = nil
end)