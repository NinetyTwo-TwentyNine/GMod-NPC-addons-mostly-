BNS_DFT_CHECK_VEHICLE_INWATER = 1
BNS_DFT_CHECK_VEHICLE_NOGROUND = 2
BNS_DFT_CHECK_VEHICLE_STOPPED = 3
BNS_DFT_CHECK_NPC_HASTARGET = 4
BNS_DFT_CHECK_NPC_TARGETSIGHT = 5
BNS_DFT_CHECK_NPC_MOVEMENT = 6
BNS_DFT_CHECK_NPC_BMOVEMENT = 7
BNS_DFT_GET_VEHICLE_FLENGTH = 8
BNS_DFT_GET_VEHICLE_BLENGTH = 9
BNS_DFT_GET_VEHICLE_WIDTH = 10

function BNS_AddVehicleDrivingAI(ent, driving_func_table)
	if !(ent:GetClass() == "npc_apcdriver" || ent:GetClass() == "npc_vehicledriver") then return end
	if !IsValid(ent.Vehicle) then return end
	if !ent.Vehicle:IsVehicle() then return end


	if navmesh.GetNavAreaCount() > 0 && tonumber(ent:GetKeyValues()["drivermaxspeed"]) > 0 then
		ent:Fire("HandBrakeOff")
		ent.AvoidAreas = {}
		ent.StuckCount = {}
	else
		ent.VehiclePath = BNS_VP_STATUS_NEVER
	end

	timer.Create("DrivingVehicleAI"..ent:EntIndex(), 0.1, 0, function()
	if IsValid(ent) && IsValid(ent.Vehicle) && GetConVarNumber("ai_disabled") == 0 then
//==============================================================================================================================================================================
		ent.IsInWater = driving_func_table[BNS_DFT_CHECK_VEHICLE_INWATER]()
		ent.NoGroundConnection = driving_func_table[BNS_DFT_CHECK_VEHICLE_NOGROUND]()
		ent.HasTarget = driving_func_table[BNS_DFT_CHECK_NPC_HASTARGET]()
		ent.TargetInSight = driving_func_table[BNS_DFT_CHECK_NPC_TARGETSIGHT]()
//==============================================================================================================================================================================
		if ent.Driving then
			if !driving_func_table[BNS_DFT_CHECK_NPC_MOVEMENT]() then
				if ent.IsStuck then
					ent.IsStuck = false
					ent.StuckTimer = nil
					ent.StuckDistance = nil

					if !ent.AvoidAreas[ent.BackupPath[ent.BackupArea + 1]:GetID()] then
						ent.VehiclePath = table.Copy(ent.BackupPath)
						ent.CurrentArea = ent.BackupArea
					else
						ent.VehiclePath = nil
						ent.CurrentArea = 1
					end
					ent.BackupPath = nil
					ent.BackupArea = nil
				else
					ent.CurrentArea = ent.CurrentArea + 1
				end
				ent.Driving = false
			elseif driving_func_table[BNS_DFT_CHECK_VEHICLE_STOPPED]() then
				if !ent.StuckTimer then
					ent.StuckTimer = 0
				else
					ent.StuckTimer = ent.StuckTimer + 0.1
				end

				if ent.StuckTimer >= 1.6 then
					if !ent.IsStuck then
						ent.IsStuck = true

						if !ent.StuckCount[ent.VehiclePath[ent.CurrentArea + 1]:GetID()] then
							ent.StuckCount[ent.VehiclePath[ent.CurrentArea + 1]:GetID()] = 0
						end
						ent.BackupPath = table.Copy(ent.VehiclePath)
						table.Empty(ent.VehiclePath)

						if driving_func_table[BNS_DFT_CHECK_NPC_BMOVEMENT]() then
							ent.StuckDistance = driving_func_table[BNS_DFT_GET_VEHICLE_FLENGTH]()
						else
							ent.StuckDistance = driving_func_table[BNS_DFT_GET_VEHICLE_BLENGTH]()
						end
						table.insert( ent.VehiclePath, navmesh.GetNearestNavArea(ent.Vehicle:GetPos() + ent:GetForward()*ent.StuckDistance) )

						if table.IsEmpty(ent.VehiclePath) then
							ent.Driving = false
							ent.VehiclePath = table.Copy(ent.BackupPath)
							ent.BackupPath = nil

							ent.IsStuck = false
							ent.StuckDistance = nil
						else
							table.Add( ent.VehiclePath, ent.VehiclePath[1]:GetAdjacentAreas() )
							ent.BackupArea = ent.CurrentArea
							ent.CurrentArea = 0
						end
					else
						ent.CurrentArea = ent.CurrentArea + 1

						if ent.StuckCount[ent.BackupPath[ent.BackupArea + 1]:GetID()] then
							ent.StuckCount[ent.BackupPath[ent.BackupArea + 1]:GetID()] = ent.StuckCount[ent.BackupPath[ent.BackupArea + 1]:GetID()] + 1
							if ent.StuckCount[ent.BackupPath[ent.BackupArea + 1]:GetID()] >= 3 then
								table.insert(ent.AvoidAreas, ent.BackupPath[ent.BackupArea + 1]:GetID())
								for k,v in pairs(ent.BackupPath[ent.BackupArea + 1]:GetAdjacentAreas()) do
									table.insert(ent.AvoidAreas, v:GetID())
								end
								ent.StuckCount[ent.BackupPath[ent.BackupArea + 1]:GetID()] = nil
							end
						end

						if ent.CurrentArea >= table.Count(ent.VehiclePath) then
							ent.Driving = false
							ent.VehiclePath = BNS_VP_STATUS_NEVER
							ent.CurrentArea = nil
							ent.BackupPath = nil
							ent.BackupArea = nil

							ent.IsStuck = true
							ent.StuckTimer = nil
							ent.StuckDistance = nil
							ent.AvoidAreas = nil
							ent.StuckCount = nil

							ent.PathOutOfRange = false
							ent.BreakTimer = nil

							ent:Fire("Stop")
							print(tostring(ent)..": This vehicle is totally stuck... Welp, now I'm stationary!")
						end
					end

 					if istable(ent.VehiclePath) then
						if IsValid(ent.DrivePoint) then
							ent.DrivePoint:Remove()
						end
						ent.DrivePoint = ents.Create( "path_corner" )
						ent.DrivePoint:SetName( "Driving_Point"..ent.DrivePoint:EntIndex() )
						ent.DrivePoint:SetPos( ent.VehiclePath[ent.CurrentArea + 1]:GetCenter() + Vector(0, 0, 10) )

						if ent.DrivePoint:IsInWorld() && (ent.DrivePoint:WaterLevel() <= 2 || ent.IsInWater) then
							ent.DrivePoint:Spawn()
							ent.DrivePoint:Activate()
							ent.DrivePoint:DropToFloor()
							ent:Fire("GotoPathCorner", ent.DrivePoint:GetName())
							ent.StuckTimer = 0.8
						end
					end
				end
			else
				ent.CheckTable = {}
				if !ent.IsStuck then
					table.insert( ent.CheckTable, navmesh.GetNearestNavArea(ent.Vehicle:GetPos()) )
				else
					table.insert( ent.CheckTable, navmesh.GetNearestNavArea(ent.Vehicle:GetPos() + ent.Vehicle:GetForward()*ent.StuckDistance) )
				end

				if !table.IsEmpty(ent.CheckTable) then
					table.Add( ent.CheckTable, ent.CheckTable[1]:GetAdjacentAreas() )
					for k,v in pairs( ent.CheckTable[1]:GetAdjacentAreas() ) do
						table.Add( ent.CheckTable, v:GetAdjacentAreas() )
					end

					if !table.HasValue(ent.CheckTable, ent.VehiclePath[ent.CurrentArea + 1]) && !table.HasValue(ent.CheckTable, ent.VehiclePath[ent.CurrentArea]) then
						if !ent.PathOutOfRange then
							ent.PathOutOfRange = true
							ent.BreakTimer = 0
						else
							ent.BreakTimer = ent.BreakTimer + 0.1
							if ent.BreakTimer >= 0.8 then
								ent.Driving = false
								if table.HasValue(ent.VehiclePath, ent.CheckTable[1]) && !ent.IsStuck then
									ent.CurrentArea = table.KeyFromValue(ent.VehiclePath, ent.CheckTable[1])
								else
									ent.VehiclePath = nil
									ent.IsStuck = false
									ent.StuckDistance = nil
								end

								ent.PathOutOfRange = false
								ent.BreakTimer = nil

								ent:Fire("Stop")
							end
						end
					else
						if ent.PathOutOfRange then
							ent.PathOutOfRange = false
							ent.BreakTimer = nil
						end
						if ent.HasTarget && !ent.TargetInSight && !ent.IsStuck then
							if ent.Vehicle:GetPos():Distance(ent.VehiclePath[ent.CurrentArea + 1]:GetCenter()) < ent.Vehicle:GetPos():Distance(ent.VehiclePath[ent.CurrentArea]:GetCenter()) then
								ent.CurrentArea = ent.CurrentArea + 1
								ent.Driving = false
							end
						end
					end
				end
				ent.CheckTable = nil
			end
		end
//==============================================================================================================================================================================
		if ent.HasTarget then
			if !ent.Driving and !ent.TargetInSight then
				if !ent.VehiclePath then
					ent.VehiclePath = Astar( navmesh.GetNearestNavArea(ent.Vehicle:GetPos()), navmesh.GetNearestNavArea(ent:GetEnemyLastKnownPos()), driving_func_table[BNS_DFT_GET_VEHICLE_WIDTH](), ent.AvoidAreas )
					ent.CurrentArea = 1
				elseif istable(ent.VehiclePath) then
					if table.GetLastValue(ent.VehiclePath) != navmesh.GetNearestNavArea(ent:GetEnemyLastKnownPos()) then
						if table.HasValue( ent.VehiclePath, navmesh.GetNearestNavArea(ent:GetEnemyLastKnownPos()) ) then
							if table.KeyFromValue( ent.VehiclePath, navmesh.GetNearestNavArea(ent:GetEnemyLastKnownPos()) ) < ent.CurrentArea then
								ent.VehiclePath = table.Reverse(ent.VehiclePath)
								ent.CurrentArea = table.Count(ent.VehiclePath) - ent.CurrentArea + 1
							end
							while( table.KeyFromValue( ent.VehiclePath, navmesh.GetNearestNavArea(ent:GetEnemyLastKnownPos()) ) != table.Count(ent.VehiclePath) ) do
								table.remove( ent.VehiclePath, table.Count(ent.VehiclePath) )
							end
						else
							ent.CheckTable = {}
							table.insert( ent.CheckTable, table.GetLastValue(ent.VehiclePath) )
							table.Add( ent.CheckTable, ent.CheckTable[1]:GetAdjacentAreas() )
							for k,v in pairs( ent.CheckTable[1]:GetAdjacentAreas() ) do
								table.Add( ent.CheckTable, v:GetAdjacentAreas() )
							end

							if table.HasValue( ent.CheckTable, navmesh.GetNearestNavArea(ent:GetEnemyLastKnownPos()) ) then
								ent.PathBuildup = Astar( ent.VehiclePath[table.Count(ent.VehiclePath)], navmesh.GetNearestNavArea(ent:GetEnemyLastKnownPos()), driving_func_table[BNS_DFT_GET_VEHICLE_WIDTH](), ent.AvoidAreas )
								if istable(ent.PathBuildup) then
									table.remove( ent.VehiclePath, table.Count(ent.VehiclePath) )
									for k,v in pairs(ent.PathBuildup) do
										table.insert(ent.VehiclePath, v)
									end
								elseif ent.PathBuildup == BNS_VP_STATUS_FAILED then
									ent.VehiclePath = BNS_VP_STATUS_FAILED
								end
								ent.PathBuildup = nil
							else
								ent.VehiclePath = Astar( navmesh.GetNearestNavArea(ent.Vehicle:GetPos()), navmesh.GetNearestNavArea(ent:GetEnemyLastKnownPos()), driving_func_table[BNS_DFT_GET_VEHICLE_WIDTH](), ent.AvoidAreas )
								ent.CurrentArea = 1
							end
							ent.CheckTable = nil
						end
					end
				end

				if istable(ent.VehiclePath) then
					if ent.VehiclePath[ent.CurrentArea + 1] then
						if IsValid(ent.DrivePoint) then
							ent.DrivePoint:Remove()
						end
						ent.DrivePoint = ents.Create( "path_corner" )
						ent.DrivePoint:SetName( "Driving_Point"..ent.DrivePoint:EntIndex() )
						ent.DrivePoint:SetPos( ent.VehiclePath[ent.CurrentArea + 1]:GetCenter() + Vector(0, 0, 10) )

						if ent.DrivePoint:IsInWorld() && (ent.DrivePoint:WaterLevel() <= 2 || ent.IsInWater) then
							ent.DrivePoint:Spawn()
							ent.DrivePoint:Activate()
							ent.DrivePoint:DropToFloor()
							ent:Fire("GotoPathCorner", ent.DrivePoint:GetName())
							ent.Driving = true
						end
					else
						ent.VehiclePath = nil
					end
				elseif ent.VehiclePath == BNS_VP_STATUS_FAILED then
					ent.Driving = false
					ent.VehiclePath = BNS_VP_STATUS_DELAY
					ent.PathOutOfRange = false
					ent.BreakTimer = nil

					print(tostring(ent)..": The path isn't valid. Awaiting...")
					ent.Path_EnemyLastPosTable = {navmesh.GetNearestNavArea(ent:GetEnemyLastKnownPos())}
					table.Add(ent.Path_EnemyLastPosTable, ent.Path_EnemyLastPosTable[1]:GetAdjacentAreas())
					ent.Path_VehicleLastPosTable = {navmesh.GetNearestNavArea(ent.Vehicle:GetPos())}
					table.Add(ent.Path_VehicleLastPosTable, ent.Path_VehicleLastPosTable[1]:GetAdjacentAreas())
				elseif ent.VehiclePath == BNS_VP_STATUS_DELAY then
					if !table.HasValue(ent.Path_VehicleLastPosTable, navmesh.GetNearestNavArea(ent.Vehicle:GetPos())) || !table.HasValue(ent.Path_EnemyLastPosTable, navmesh.GetNearestNavArea(ent:GetEnemyLastKnownPos())) then
						ent.Path_EnemyLastPosTable = nil
						ent.Path_VehicleLastPosTable = nil
						ent.VehiclePath = nil
					end
				end
			end
		end
//==============================================================================================================================================================================
		if ent.IsInWater || ent.NoGroundConnection then
			if !ent.IsAboutToDie then
				ent.IsAboutToDie = true
				ent.DeathTimer = 0
				ent:Fire("StopFiring")
			else
				ent.DeathTimer = ent.DeathTimer + 0.1

				if ent.DeathTimer >= 15 then
					ent.Vehicle:Fire("TurnOff")
					ent:Remove()
					return
				end
			end
		elseif ent.IsAboutToDie then
			ent.IsAboutToDie = false
			ent.DeathTimer = nil
			ent:Fire("StartFiring")
		end
//==============================================================================================================================================================================
	end
	end)

	ent:CallOnRemove("DestroyTheTimer", function()
		timer.Remove("DrivingVehicleAI"..ent:EntIndex())
		if IsValid(ent.DrivePoint) then
			ent.DrivePoint:Remove()
		end
	end)
end