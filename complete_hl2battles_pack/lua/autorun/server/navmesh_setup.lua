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

local function AreaSizeCheck(current, nav_direction)
	local newcurrent = current
	local deltaZ, deltaXY, elevationAngle
	local area_size = 0

	for _,neighbor in pairs( current:GetAdjacentAreasAtSide(nav_direction) ) do
		deltaZ = current:ComputeAdjacentConnectionHeightChange(neighbor)
		if math.abs(deltaZ) > 25 then
			CreateAreaDisconnection(current, neighbor)
			break
		end

		deltaZ = current:GetClosestPointOnArea(neighbor:GetCenter()).z - current:GetCenter().z
		if nav_direction % 2 > 0 then
			elevationAngle = math.atan2( math.abs(deltaZ), current:GetSizeX()/2 )
		else
			elevationAngle = math.atan2( math.abs(deltaZ), current:GetSizeY()/2 )
		end
		if math.abs(elevationAngle) > (math.pi / 6) then
			CreateAreaDisconnection(current, neighbor)
			break
		end

		deltaZ = neighbor:GetClosestPointOnArea(current:GetCenter()).z - neighbor:GetCenter().z
		if nav_direction % 2 > 0 then
			elevationAngle = math.atan2( math.abs(deltaZ), neighbor:GetSizeX()/2 )
		else
			elevationAngle = math.atan2( math.abs(deltaZ), neighbor:GetSizeY()/2 )
		end
		if math.abs(elevationAngle) > (math.pi / 6) then
			CreateAreaDisconnection(current, neighbor)
			break
		end

		deltaZ = current:GetCenter().z - neighbor:GetCenter().z
		if nav_direction % 2 > 0 then
			elevationAngle = math.atan2( math.abs(deltaZ), (current:GetSizeX() + neighbor:GetSizeX())/2 )
		else
			elevationAngle = math.atan2( math.abs(deltaZ), (current:GetSizeY() + neighbor:GetSizeY())/2 )
		end
		if math.abs(elevationAngle) > (math.pi / 6) then
			CreateAreaDisconnection(current, neighbor)
			break
		end

		if nav_direction % 2 > 0 then
			deltaXY = math.abs(current:GetCenter().x - neighbor:GetCenter().x)
		else
			deltaXY = math.abs(current:GetCenter().y - neighbor:GetCenter().y)
		end
		if deltaXY > area_size then
			area_size = deltaXY
			newcurrent = neighbor
		end
	end

	if nav_direction % 2 > 0 then
		return (area_size + newcurrent:GetSizeX()/2)
	else
		return (area_size + newcurrent:GetSizeY()/2)
	end
end


cvars.AddChangeCallback("nav_area_size_check_complete", function()
	if GetConVarNumber("nav_area_size_check_complete") == 0 then
		table.Empty(BNS_Server_NavAreaSizes)
		for k,current in pairs(navmesh.GetAllNavAreas()) do
			BNS_Server_NavAreaSizes[current:GetID()] = {}

			BNS_Server_NavAreaSizes[current:GetID()]["X"] = {}
			BNS_Server_NavAreaSizes[current:GetID()]["X"][1] = AreaSizeCheck(current, 1)
			BNS_Server_NavAreaSizes[current:GetID()]["X"][2] = AreaSizeCheck(current, 3)

			BNS_Server_NavAreaSizes[current:GetID()]["Y"] = {}
			BNS_Server_NavAreaSizes[current:GetID()]["Y"][1] = AreaSizeCheck(current, 0)
			BNS_Server_NavAreaSizes[current:GetID()]["Y"][2] = AreaSizeCheck(current, 2)
		end
		GetConVar("nav_area_size_check_complete"):SetFloat(1)
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


	local indexCheckTable = {}
	for _,v in pairs( table.Add({start}, start:GetAdjacentAreas()) ) do table.insert(indexCheckTable, v:GetID()) end
	for _,v in pairs( table.Add({goal}, goal:GetAdjacentAreas()) ) do table.insert(indexCheckTable, v:GetID()) end

	while ( !start:IsOpenListEmpty() ) do
		local current = start:PopOpenList() // Remove the area with lowest cost in the open list and return it
		if ( current == goal ) then // That's it!
			local total_path = { current }

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