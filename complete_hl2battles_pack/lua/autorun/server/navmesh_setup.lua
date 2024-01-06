CreateConVar("nav_area_size_check_complete", 1, bit.bor(FCVAR_UNREGISTERED), "", 0, 1)

BNS_Server_NavAreaSizes = {}
BNS_Server_NavAreaDisconnections = {}

local function CreateAreaDisconnection(current, neighbor)
	if BNS_Server_NavAreaDisconnections[neighbor:GetID()] then
		if table.HasValue(BNS_Server_NavAreaDisconnections[neighbor:GetID()], current:GetID()) then return end
	end

	if !BNS_Server_NavAreaDisconnections[current:GetID()] then
		BNS_Server_NavAreaDisconnections[current:GetID()] = {}
	end
	if !table.HasValue(BNS_Server_NavAreaDisconnections[current:GetID()], neighbor:GetID()) then
		table.insert(BNS_Server_NavAreaDisconnections[current:GetID()], neighbor:GetID())
	end
end

local function AreaDisconnectionCheck(current, nav_direction)
	local deltaZ, elevationAngle
	for _,neighbor in pairs( current:GetAdjacentAreasAtSide(nav_direction) ) do
		if BNS_Server_NavAreaDisconnections[neighbor:GetID()] then
			if table.HasValue(BNS_Server_NavAreaDisconnections[neighbor:GetID()], current:GetID()) then continue end
		end
		if BNS_Server_NavAreaDisconnections[current:GetID()] then
			if table.HasValue(BNS_Server_NavAreaDisconnections[current:GetID()], neighbor:GetID()) then continue end
		end


		deltaZ = current:ComputeAdjacentConnectionHeightChange(neighbor)
		if math.abs(deltaZ) > 12.5 then
			CreateAreaDisconnection(current, neighbor)
			continue
		end

		deltaZ = current:GetClosestPointOnArea(neighbor:GetCenter()).z - current:GetCenter().z
		if nav_direction % 2 > 0 then
			elevationAngle = math.atan2( math.abs(deltaZ), current:GetSizeX()/2 )
		else
			elevationAngle = math.atan2( math.abs(deltaZ), current:GetSizeY()/2 )
		end
		if math.abs(elevationAngle) > (math.pi / 6) then
			CreateAreaDisconnection(current, neighbor)
			continue
		end

		deltaZ = neighbor:GetClosestPointOnArea(current:GetCenter()).z - neighbor:GetCenter().z
		if nav_direction % 2 > 0 then
			elevationAngle = math.atan2( math.abs(deltaZ), neighbor:GetSizeX()/2 )
		else
			elevationAngle = math.atan2( math.abs(deltaZ), neighbor:GetSizeY()/2 )
		end
		if math.abs(elevationAngle) > (math.pi / 6) then
			CreateAreaDisconnection(current, neighbor)
			continue
		end

		deltaZ = current:GetCenter().z - neighbor:GetCenter().z
		if nav_direction % 2 > 0 then
			elevationAngle = math.atan2( math.abs(deltaZ), (current:GetSizeX() + neighbor:GetSizeX())/2 )
		else
			elevationAngle = math.atan2( math.abs(deltaZ), (current:GetSizeY() + neighbor:GetSizeY())/2 )
		end
		if math.abs(elevationAngle) > (math.pi / 6) then
			CreateAreaDisconnection(current, neighbor)
			continue
		end
	end
end


local function SaveAreaSize(current, nav_direction, area_size)
	if !BNS_Server_NavAreaSizes[current:GetID()] then
		BNS_Server_NavAreaSizes[current:GetID()] = {}
	end
	if nav_direction % 2 == 1 then
		if !BNS_Server_NavAreaSizes[current:GetID()]["X"] then
			BNS_Server_NavAreaSizes[current:GetID()]["X"] = {}
		end

		if nav_direction == 1 then 
			BNS_Server_NavAreaSizes[current:GetID()]["X"][1] = area_size
		else
			BNS_Server_NavAreaSizes[current:GetID()]["X"][2] = area_size
		end
	end
	if nav_direction % 2 == 0 then
		if !BNS_Server_NavAreaSizes[current:GetID()]["Y"] then
			BNS_Server_NavAreaSizes[current:GetID()]["Y"] = {}
		end

		if nav_direction == 0 then 
			BNS_Server_NavAreaSizes[current:GetID()]["Y"][1] = area_size
		else
			BNS_Server_NavAreaSizes[current:GetID()]["Y"][2] = area_size
		end
	end
end

local function AreaSizeCheck(current, nav_direction)
	local area_size = 0

	local newcurrent_table = {}
	for _,neighbor in pairs( current:GetAdjacentAreasAtSide(nav_direction) ) do
		if BNS_Server_NavAreaDisconnections[neighbor:GetID()] then
			if table.HasValue(BNS_Server_NavAreaDisconnections[neighbor:GetID()], current:GetID()) then continue end
		end
		if BNS_Server_NavAreaDisconnections[current:GetID()] then
			if table.HasValue(BNS_Server_NavAreaDisconnections[current:GetID()], neighbor:GetID()) then continue end
		end


		if nav_direction % 2 > 0 then
			if math.abs( current:GetCenter().y - neighbor:GetCenter().y ) < ( neighbor:GetSizeY() + current:GetSizeY() ) / 4 then
				newcurrent_table[neighbor:GetID()] = math.abs(current:GetCenter().x - neighbor:GetCenter().x)
			end
		else
			if math.abs( current:GetCenter().x - neighbor:GetCenter().x ) < ( neighbor:GetSizeX() + current:GetSizeX() ) / 4 then
				newcurrent_table[neighbor:GetID()] = math.abs(current:GetCenter().y - neighbor:GetCenter().y)
			end
		end
	end

	for _,k in pairs(table.GetKeys(newcurrent_table)) do
		local newcurrent_areasize
		if BNS_Server_NavAreaSizes[k] then
			if nav_direction % 2 == 1 && BNS_Server_NavAreaSizes[k]["X"] then
				if nav_direction == 1 then 
					newcurrent_areasize = BNS_Server_NavAreaSizes[k]["X"][1]
				else
					newcurrent_areasize = BNS_Server_NavAreaSizes[k]["X"][2]
				end
			end
			if nav_direction % 2 == 0 && BNS_Server_NavAreaSizes[k]["Y"] then
				if nav_direction == 0 then 
					newcurrent_areasize = BNS_Server_NavAreaSizes[k]["Y"][1]
				else
					newcurrent_areasize = BNS_Server_NavAreaSizes[k]["Y"][2]
				end
			end
		end

		if !isnumber(newcurrent_areasize) then
			newcurrent_areasize = AreaSizeCheck(navmesh.GetNavAreaByID(k), nav_direction)
		end
		newcurrent_table[k] = newcurrent_table[k] + newcurrent_areasize
	end

	if !table.IsEmpty(newcurrent_table) then
		for k,v in pairs(newcurrent_table) do
			if area_size < v then
				area_size = v
			end
		end
	else
		if nav_direction % 2 > 0 then
			area_size = (current:GetSizeX()/2)
		else
			area_size = (current:GetSizeY()/2)
		end
	end

	SaveAreaSize(current, nav_direction, area_size)
	return area_size
end


cvars.AddChangeCallback("nav_area_size_check_complete", function()
	if GetConVarNumber("nav_area_size_check_complete") == 0 then
		table.Empty(BNS_Server_NavAreaDisconnections)
		for k,current in pairs(navmesh.GetAllNavAreas()) do
			AreaDisconnectionCheck(current, 0)
			AreaDisconnectionCheck(current, 1)
			AreaDisconnectionCheck(current, 2)
			AreaDisconnectionCheck(current, 3)
		end

		table.Empty(BNS_Server_NavAreaSizes)
		for k,current in pairs(navmesh.GetAllNavAreas()) do
			local nav_dir_table = {0,1,2,3}

			if BNS_Server_NavAreaSizes[current:GetID()] then
				if BNS_Server_NavAreaSizes[current:GetID()]["X"] then
					if BNS_Server_NavAreaSizes[current:GetID()]["X"][1] then
						table.RemoveByValue(nav_dir_table, 1)
					end
					if BNS_Server_NavAreaSizes[current:GetID()]["X"][2] then
						table.RemoveByValue(nav_dir_table, 3)
					end
				end
				if BNS_Server_NavAreaSizes[current:GetID()]["Y"] then
					if BNS_Server_NavAreaSizes[current:GetID()]["Y"][1] then
						table.RemoveByValue(nav_dir_table, 0)
					end
					if BNS_Server_NavAreaSizes[current:GetID()]["Y"][2] then
						table.RemoveByValue(nav_dir_table, 2)
					end
				end
			end

			for _,nav_direction in pairs(nav_dir_table) do
				AreaSizeCheck(current, nav_direction)
			end
		end

		GetConVar("nav_area_size_check_complete"):SetFloat(1)
	else
		print("Done figuring out the navmesh data! ("..navmesh.GetNavAreaCount().." navigation areas in total)")
	end
end)

hook.Add("InitPostEntity", "BNS_NavAreaSizeCheck", function()
	timer.Simple(FrameTime(), function()
		GetConVar("nav_area_size_check_complete"):SetFloat(0)
	end)
end)


--========================================================================================================
--The (vehicle) path determining function
--========================================================================================================


BNS_VP_STATUS_FAILED = "Failed!"
BNS_VP_STATUS_DELAY = "Delay before rebuilding..."
BNS_VP_STATUS_NEVER = "Never driving anywhere again."

function Astar( start, goal, sizequota, avoidthose )
	if ( !IsValid( start ) || !IsValid( goal ) ) then return false end

	start:ClearSearchLists()

	start:AddToOpenList()

	local cameFrom = {}

	start:SetCostSoFar( 0 )

	start:SetTotalCost( start:GetCenter():Distance( goal:GetCenter() ) )
	start:UpdateOnOpenList()


	local goalCheckTable = {}
	for _,v in pairs( table.Add({goal}, goal:GetAdjacentAreas()) ) do
		local deltaZ = v:ComputeAdjacentConnectionHeightChange(goal)
		if math.abs(deltaZ) > 12.5 then continue end

		table.insert(goalCheckTable, v:GetID())
	end

	local indexCheckTable = {}
	for _,v in pairs( table.Add({start}, start:GetAdjacentAreas()) ) do table.insert(indexCheckTable, v:GetID()) end
	for _,v in pairs( table.Add({goal}, goal:GetAdjacentAreas()) ) do table.insert(indexCheckTable, v:GetID()) end

	while ( !start:IsOpenListEmpty() ) do
		local current = start:PopOpenList() // Remove the area with lowest cost in the open list and return it
		if ( table.HasValue(goalCheckTable, current:GetID()) ) then // That's it!
			local total_path = { current }
			if (current != goal) then
				local canAddGoal = true
				if BNS_Server_NavAreaDisconnections[current:GetID()] then
					if table.HasValue(BNS_Server_NavAreaDisconnections[current:GetID()], goal:GetID()) then
						canAddGoal = false
					end
				end
				if BNS_Server_NavAreaDisconnections[goal:GetID()] then
					if table.HasValue(BNS_Server_NavAreaDisconnections[goal:GetID()], current:GetID()) then
						canAddGoal = false
					end
				end

				if canAddGoal == true then
					table.insert(total_path, 1, goal)
				end
			end

			current = current:GetID()
			while ( cameFrom[ current ] ) do
				current = cameFrom[ current ]
				table.insert( total_path, navmesh.GetNavAreaByID( current ) )
			end
			total_path = table.Reverse(total_path)
			return total_path
		end

		current:AddToClosedList()

		for k, neighbor in pairs( current:GetAdjacentAreas() ) do
			local newCostSoFar = current:GetCostSoFar() + current:GetCenter():Distance( neighbor:GetCenter() )

			if BNS_Server_NavAreaDisconnections[current:GetID()] then
				if table.HasValue(BNS_Server_NavAreaDisconnections[current:GetID()], neighbor:GetID()) then
					continue
				end
			end
			if BNS_Server_NavAreaDisconnections[neighbor:GetID()] then
				if table.HasValue(BNS_Server_NavAreaDisconnections[neighbor:GetID()], current:GetID()) then
					continue
				end
			end

			if !table.HasValue(indexCheckTable, neighbor:GetID()) then
				if table.HasValue(avoidthose, neighbor:GetID()) || neighbor:IsBlocked() then
					continue
				end

				local deltaXY = math.abs(neighbor:GetCenter().x - current:GetCenter().x) - math.abs(neighbor:GetCenter().y - current:GetCenter().y)

				local area_size_width, area_size_length
				if math.Round(deltaXY) != 0 then
					if deltaXY < 0 then  // We need to choose perpendicular direction to ours (for width)
						area_size_width = BNS_Server_NavAreaSizes[neighbor:GetID()]["X"]
						area_size_length = BNS_Server_NavAreaSizes[neighbor:GetID()]["Y"]
					else
						area_size_width = BNS_Server_NavAreaSizes[neighbor:GetID()]["Y"]
						area_size_length = BNS_Server_NavAreaSizes[neighbor:GetID()]["X"]
					end

					if area_size_width[1] < (sizequota.width / 2) || area_size_width[2] < (sizequota.width / 2) || area_size_length[1] < (sizequota.length / 2) || area_size_length[2] < (sizequota.length / 2) then
						continue
					end
				else
					area_size_width = BNS_Server_NavAreaSizes[neighbor:GetID()]["X"]
					area_size_length = BNS_Server_NavAreaSizes[neighbor:GetID()]["Y"]

					if area_size_width[1] < ((sizequota.width + sizequota.length) / 4) || area_size_width[2] < ((sizequota.width + sizequota.length) / 4) || area_size_length[1] < ((sizequota.width + sizequota.length) / 4) || area_size_length[2] < ((sizequota.width + sizequota.length) / 4) then
						continue
					end
				end
			end
			
			if ( ( neighbor:IsOpen() || neighbor:IsClosed() ) && neighbor:GetCostSoFar() <= newCostSoFar ) then
				continue
			else
				neighbor:SetCostSoFar( newCostSoFar );
				neighbor:SetTotalCost( newCostSoFar + neighbor:GetCenter():Distance( goal:GetCenter() ) )

				if ( neighbor:IsClosed() ) then
				
					neighbor:RemoveFromClosedList()
				end

				if ( neighbor:IsOpen() ) then
					// This area is already on the open list, update its position in the list to keep costs sorted
					neighbor:UpdateOnOpenList()
				else
					neighbor:AddToOpenList()
				end

				cameFrom[ neighbor:GetID() ] = current:GetID()
			end
		end
	end

	return BNS_VP_STATUS_FAILED
end