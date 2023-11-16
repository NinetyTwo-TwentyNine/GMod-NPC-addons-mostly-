hook.Add("OnEntityCreated", "Combine APC Driver AI", function(ent)
	if ent:GetClass() == "npc_apcdriver" then
		timer.Simple(FrameTime(), function()
		if !IsValid(ent) then return end
		if ent:MapCreationID() != -1 then return end

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
				return ( ent.Vehicle:WaterLevel() > 2 )
			end
			func_table[BNS_DFT_CHECK_VEHICLE_NOGROUND] = function()
				return ( ent.Vehicle:GetOperatingParams().wheelsInContact <= 1 )
			end
			func_table[BNS_DFT_CHECK_VEHICLE_STOPPED] = function()
				return ( ent.Vehicle:GetSpeed() == 0 )
			end
			func_table[BNS_DFT_CHECK_NPC_HASTARGET] = function()
				return ( IsValid(ent:GetEnemy()) )
			end
			func_table[BNS_DFT_CHECK_NPC_TARGET_LASTKNOWN_SIGHT] = function()
				if !func_table[BNS_DFT_CHECK_NPC_HASTARGET]() then return false end
				local enemy = ent:GetEnemy()
				local enemy_assumed_pos = ent:GetEnemyLastKnownPos() + enemy:BodyTarget(ent:EyePos()) - enemy:GetPos()
				return ( ent:Visible(enemy) || ent:VisibleVec(enemy_assumed_pos) )
			end
			func_table[BNS_DFT_CHECK_NPC_MOVEMENT] = function()
				return ( ent:IsMoving() )
			end
			func_table[BNS_DFT_CHECK_NPC_BMOVEMENT] = function()
				return ( ent.Vehicle:GetThrottle() < 0 )
			end
			func_table[BNS_DFT_GET_VEHICLE_FLENGTH] = function()
				return ( ent.Vehicle:OBBMaxs().y )
			end
			func_table[BNS_DFT_GET_VEHICLE_BLENGTH] = function()
				return ( ent.Vehicle:OBBMins().y )
			end
			func_table[BNS_DFT_GET_VEHICLE_SIZEQUOTA] = function()
				return ( {width = ent.Vehicle:OBBMaxs().x - ent.Vehicle:OBBMins().x, length = ent.Vehicle:OBBMaxs().y - ent.Vehicle:OBBMins().y} )
			end

			BNS_AddVehicleDrivingAI(ent, func_table)
		end
		end)
	end
end)