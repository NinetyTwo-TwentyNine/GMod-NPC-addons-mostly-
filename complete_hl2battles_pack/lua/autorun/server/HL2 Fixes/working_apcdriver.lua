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
				func_table["check_vehicle_water"] = function()
					return (ent.Vehicle:WaterLevel() > 2)
				end
				func_table["check_vehicle_noground"] = function()
					return (ent.Vehicle:GetOperatingParams().wheelsInContact <= 1)
				end
				func_table["check_vehicle_stopped"] = function()
					return (ent.Vehicle:GetSpeed() == 0)
				end
				func_table["check_npc_target"] = function()
					return (IsValid(ent:GetEnemy()))
				end
				func_table["check_npc_targetsight"] = function()
					return (ent.HasTarget && ent:Visible(ent:GetEnemy()))
				end
				func_table["check_npc_movement"] = function()
					return (ent:IsMoving())
				end
				func_table["check_npc_bmovement"] = function()
					return ((ent.Vehicle:GetPos() + ent.Vehicle:GetForward()*ent.Vehicle:OBBMins().y):Distance(ent:GetCurWaypointPos()) > (ent.Vehicle:GetPos() + ent.Vehicle:GetForward()*ent.Vehicle:OBBMaxs().y):Distance(ent:GetCurWaypointPos()))
				end
				func_table["get_vehicle_flength"] = function()
					return (ent.Vehicle:OBBMaxs().y)
				end
				func_table["get_vehicle_blength"] = function()
					return (ent.Vehicle:OBBMins().y)
				end

				BNS_AddVehicleDrivingAI(ent, func_table)
			end
		end
		end)
	end
end)