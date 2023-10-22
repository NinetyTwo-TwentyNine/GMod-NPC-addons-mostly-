hook.Add("OnEntityCreated", "Simfphys Vehicle Driver Retranslator", function(ent)
	if ent:GetClass() == "npc_vehicledriver" then
		timer.Simple(FrameTime(), function()
		if !IsValid(ent) then return end
		if ent:MapCreationID() != -1 then return end

		if !table.IsEmpty(ents.FindByName(ent:GetKeyValues()["vehicle"])) then
			for k,v in pairs(ents.FindByName(ent:GetKeyValues()["vehicle"])) do
				if !v.fphysSeat || !v:IsVehicle() then
					continue
				end

				if IsValid(v:GetDriver()) then
					continue
				end

				ent.Seat = v
				break
			end
			if !ent.Seat then return end

			ent.Retranslator = ents.Create("npc_vehicledriver_retranslator")
			ent.Retranslator.Seat = ent.Seat
			ent.Retranslator.VehicleDriver = ent
			ent.Retranslator:Spawn()
			ent.Retranslator:Activate()

			timer.Simple(FrameTime(), function()
			if !IsValid(ent) then return end
			if !IsValid(ent.Retranslator) then return end
			if !IsValid(ent.Vehicle) then return end

			if ent.Retranslator.SeatPos != 0 then
				ent:SetKeyValue("drivermaxspeed", 0)
			end

			local func_table = {}
			func_table[BNS_DFT_CHECK_VEHICLE_INWATER] = function()
				return ( ent.Vehicle:WaterLevel() > 2 )
			end
			func_table[BNS_DFT_CHECK_VEHICLE_NOGROUND] = function()
				return ( !ent.Vehicle:IsDriveWheelsOnGround() )
			end
			func_table[BNS_DFT_CHECK_VEHICLE_STOPPED] = function()
				return ( math.abs(ent.Vehicle.ForwardSpeed) < 5 )
			end
			func_table[BNS_DFT_CHECK_NPC_HASTARGET] = function()
				return ( IsValid(ent:GetEnemy()) )
			end
			func_table[BNS_DFT_CHECK_NPC_TARGETSIGHT] = function()
				return ( ent.HasTarget && !ent.Retranslator.AdditionalMovementRequired && math.Round(CurTime() - ent:GetEnemyLastTimeSeen(), 1) <= 0.1 )
			end
			func_table[BNS_DFT_CHECK_NPC_MOVEMENT] = function()
				return ( ent:GetKeyValues()["target"] != "" )
			end
			func_table[BNS_DFT_CHECK_NPC_BMOVEMENT] = function()
				return ( ent.Retranslator.GoingBackwards )
			end
			func_table[BNS_DFT_GET_VEHICLE_FLENGTH] = function()
				return ( ent.Vehicle.FLength )
			end
			func_table[BNS_DFT_GET_VEHICLE_BLENGTH] = function()
				return ( ent.Vehicle.BLength )
			end
			func_table[BNS_DFT_GET_VEHICLE_SIZEQUOTA] = function()
				return ( {width = ent.Vehicle.Width, length = ent.Vehicle.FLength - ent.Vehicle.BLength} )
			end

			BNS_AddVehicleDrivingAI(ent, func_table)
			end)
		end
		end)
	end
end)