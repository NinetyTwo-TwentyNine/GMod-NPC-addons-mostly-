hook.Add("PlayerEnteredVehicle", "Simfphys AI handling", function(ply, seat)
	local vehicle = seat:GetOwner()
	if !IsValid(vehicle) then return end
	if vehicle:GetClass() != "gmod_sent_vehicle_fphysics_base" then return end
	if !IsValid(vehicle:GetDriverSeat()) then return end

	if vehicle:GetDriverSeat() == seat then
		for _,npc in pairs(ents.GetAll()) do
			if !npc:IsNPC() then continue end

			local disposition = npc:Disposition(ply)
			if disposition == D_HT then
				npc:AddEntityRelationship(ply, D_FR, GetTeamBasedRelationshipPriority(npc, ply))
			end
		end
	end
end)

hook.Add("PlayerLeaveVehicle", "Simfphys AI handling", function(ply, seat)
	local vehicle = seat:GetOwner()
	if !IsValid(vehicle) then return end
	if vehicle:GetClass() != "gmod_sent_vehicle_fphysics_base" then return end
	if !IsValid(vehicle:GetDriverSeat()) then return end

	if vehicle:GetDriverSeat() == seat then
		for _,npc in pairs(ents.GetAll()) do
			if !npc:IsNPC() then continue end

			local disposition = npc:Disposition(ply)
			if disposition == D_FR then
				npc:AddEntityRelationship(ply, D_HT, GetTeamBasedRelationshipPriority(npc, ply))
			end
		end
	end
end)

function Simfphys_AddVehicleBasedRelations(ent)
	if !IsValid(ent) then return end
	if !ent:IsNPC() && !ent:IsPlayer() then return end

	if ent:GetClass() == "npc_vehicledriver" || ent:IsPlayer() then
		local vehicle
		if ent:IsPlayer() then
			vehicle = ent:GetVehicle()
			if IsValid(vehicle) then vehicle = vehicle.base end
		else
			vehicle = ent.Vehicle
		end

		if !IsValid(vehicle) then return end
		if vehicle:GetClass() != "gmod_sent_vehicle_fphysics_base" then return end

		for _,npc in pairs(ents.GetAll()) do
			if !npc:IsNPC() then continue end

			local disposition = npc:Disposition(ent)
			if disposition == D_HT then
				npc:AddEntityRelationship(ent, D_FR, GetTeamBasedRelationshipPriority(npc, ent))
			end
		end
	end

	if ent:IsNPC() then
		for _,vehicle in pairs(ents.FindByClass("gmod_sent_vehicle_fphysics_base")) do
			if !IsValid(vehicle:GetDriverSeat()) then continue end

			local driver = vehicle:GetDriverSeat():GetDriver()
			if !IsValid(driver) then continue end

			local disposition = ent:Disposition(driver)
			if disposition == D_HT then
				ent:AddEntityRelationship(driver, D_FR, GetTeamBasedRelationshipPriority(ent, driver))
			end
		end
	end
end