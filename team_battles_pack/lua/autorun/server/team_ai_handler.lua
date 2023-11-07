local function SetRelationshipProperly(npc, ent, rel)
	if ent:IsFlagSet(FL_NOTARGET) then rel = D_NU end

	//if npc:Disposition(ent) != rel then  -- would prioritize entities which this NPC previously had a different relationship with
		if (npc:Disposition(ent) == D_HT || npc:Disposition(ent) == D_FR) && (rel != D_HT && rel != D_FR) then
			npc:ClearEnemyMemory(ent)
		end
		npc:AddEntityRelationship(ent, rel, GetTeamBasedRelationshipPriority(npc, ent))
	//end
end

function GetTeamBasedRelationshipPriority(ent1, ent2)
	local team1 = ent1:GetInternalVariable("TeamNum")
	local team2 = ent2:GetInternalVariable("TeamNum")
	return ( ( (team1 != 0 && team2 != 0) && 99 ) || 0 )
end

function AddTeamBasedRelations(ent)
	if !IsValid(ent) then return end
	if !ent:IsNPC() && !ent:IsPlayer() then return end

	local ent_team = ent:GetInternalVariable("TeamNum")
	for _,team_member in pairs(ents.GetAll()) do
		if team_member == self then continue end
		if !team_member:IsNPC() && !team_member:IsPlayer() then continue end

		local tmember_team = team_member:GetInternalVariable("TeamNum")

		if team_member:IsPlayer() && (tmember_team == 1001 || tmember_team == 1002) then tmember_team = 0 end
		if ent_team == 0 && tmember_team == 0 then continue end

		if (ent_team == 0 || tmember_team == 0) && ent_team != tmember_team then
			if ent:IsNPC() then
				SetRelationshipProperly(ent, team_member, D_NU)
			end
			if team_member:IsNPC() then
				SetRelationshipProperly(team_member, ent, D_NU)
			end
		elseif ent_team != tmember_team then
			if ent:IsNPC() then
				SetRelationshipProperly(ent, team_member, D_HT)
			end
			if team_member:IsNPC() then
				SetRelationshipProperly(team_member, ent, D_HT)
			end
		else
			if ent:IsNPC() then
				SetRelationshipProperly(ent, team_member, D_LI)
			end
			if team_member:IsNPC() then
				SetRelationshipProperly(team_member, ent, D_LI)
			end
		end	
	end
end

hook.Add("OnEntityCreated", "Team AI handling", function(npc)
	if !npc:IsNPC() then return end

	timer.Simple(0.1, function()
		if !IsValid(npc) then return end

		AddTeamBasedRelations(npc)
		Simfphys_AddVehicleBasedRelations(npc)
		LFS_AddVehicleBasedRelations(npc)
	end)
end)

hook.Add( "AcceptInput", "Team AI handling: If the team gets changed", function( ent, input, activator, caller, value )
	if !ent:IsNPC() && !ent:IsPlayer() then return end
		
	if string.lower(input) == "setteam" then
		ent:SetKeyValue("TeamNum", value)
	end

	if string.lower(input) == "addoutput" then
		local prev_team = ent:GetInternalVariable("TeamNum")
		timer.Simple(FrameTime(), function()
			if !IsValid(ent) then return end
				
			local cur_team = ent:GetInternalVariable("TeamNum")
			if prev_team != cur_team then
				AddTeamBasedRelations(ent)
				Simfphys_AddVehicleBasedRelations(ent)
				LFS_AddVehicleBasedRelations(ent)
			end
		end)
	end
end)

hook.Add( "EntityKeyValue", "Team AI handling: If the team gets changed", function( ent, key, value )
	if !ent:IsNPC() && !ent:IsPlayer() then return end
		
	if string.lower(key) == "teamnum" then
		local prev_team = ent:GetInternalVariable("TeamNum")
		local cur_team = tonumber(value)

		if prev_team != cur_team then
			timer.Simple(FrameTime(), function()
				if !IsValid(ent) then return end
			
				AddTeamBasedRelations(ent)
				Simfphys_AddVehicleBasedRelations(ent)
				LFS_AddVehicleBasedRelations(ent)
			end)
		end
	end
end)