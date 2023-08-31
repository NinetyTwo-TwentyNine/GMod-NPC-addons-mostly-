hook.Add("OnEntityCreated", "Combine APC Driver AI", function(ent)
	if ent:GetClass() == "npc_apcdriver" then
		timer.Simple(FrameTime(), function()
		if IsValid(ent) && ent:MapCreationID() == -1 then
			if !table.IsEmpty(ents.FindByName(ent:GetKeyValues()["vehicle"])) then
				for k,v in pairs(ents.FindByName(ent:GetKeyValues()["vehicle"])) do
					if !v:IsVehicle() then continue end

					if v:GetDriver() == ent then
						ent.Vehicle = v
						break
					end
				end
				if !ent.Vehicle then return end


				local func_table = {}
				func_table[BNS_DFT_CHECK_VEHICLE_INWATER] = function()
					return (ent.Vehicle:WaterLevel() > 2)
				end
				func_table[BNS_DFT_CHECK_VEHICLE_NOGROUND] = function()
					return (ent.Vehicle:GetOperatingParams().wheelsInContact <= 1)
				end
				func_table[BNS_DFT_CHECK_VEHICLE_STOPPED] = function()
					return (ent.Vehicle:GetSpeed() == 0)
				end
				func_table[BNS_DFT_CHECK_NPC_HASTARGET] = function()
					return (IsValid(ent:GetEnemy()))
				end
				func_table[BNS_DFT_CHECK_NPC_TARGETSIGHT] = function()
					return (ent.HasTarget && ent:Visible(ent:GetEnemy()))
				end
				func_table[BNS_DFT_CHECK_NPC_MOVEMENT] = function()
					return (ent:IsMoving())
				end
				func_table[BNS_DFT_CHECK_NPC_BMOVEMENT] = function()
					return ((ent.Vehicle:GetPos() + ent.Vehicle:GetForward()*ent.Vehicle:OBBMins().y):Distance(ent:GetCurWaypointPos()) < (ent.Vehicle:GetPos() + ent.Vehicle:GetForward()*ent.Vehicle:OBBMaxs().y):Distance(ent:GetCurWaypointPos()))
				end
				func_table[BNS_DFT_GET_VEHICLE_FLENGTH] = function()
					return (ent.Vehicle:OBBMaxs().y)
				end
				func_table[BNS_DFT_GET_VEHICLE_BLENGTH] = function()
					return (ent.Vehicle:OBBMins().y)
				end
				func_table[BNS_DFT_GET_VEHICLE_WIDTH] = function()
					return (math.abs(ent.Vehicle:OBBMaxs().x - ent.Vehicle:OBBMins().x))
				end

				BNS_AddVehicleDrivingAI(ent, func_table)
			end
		end
		end)
	end
end)