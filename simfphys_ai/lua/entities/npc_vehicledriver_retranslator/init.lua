AddCSLuaFile( "shared.lua" )
include("shared.lua")

local VehicleKeysArray = {}
VehicleKeysArray[IN_FORWARD] = "W"
VehicleKeysArray[IN_BACK] = "S"
VehicleKeysArray[IN_LEFT] = "A"
VehicleKeysArray[IN_RIGHT] = "D"
VehicleKeysArray[IN_JUMP] = "Space"
VehicleKeysArray[IN_RUN] = "Shift"


function ENT:Initialize()
	self:SetModel("models/props_c17/doll01.mdl")
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self:SetNotSolid( true )
	self:SetMoveType( MOVETYPE_NONE )
	
	if !IsValid(self.VehicleDriver) then
		self:RemoveByError("No vehicle driver NPC was provided.")
		return
	elseif self.VehicleDriver:GetClass() != "npc_vehicledriver" then
		self:RemoveByError("Vehicle driver NPC has an invalid class ("..self.VehicleDriver:GetClass()..").")
		return
	end

	if !IsValid(self.Seat) then
		self:RemoveByError("No vehicle was provided.")
		return
	end
	if !IsValid(self.Seat.base) then
		self:RemoveByError("No simfphys vehicle was provided.")
		return
	end
	self.Vehicle = self.Seat.base

	self.VehicleDriver:DeleteOnRemove(self)

	self:EstablishVehicleConnection()
	self:SetupDriverFunctions()

	self:DeleteOnRemove(self.VehicleDriver)
end

function ENT:EstablishVehicleConnection()
	self:SetPos(self.Seat:GetPos())
	self:SetParent(self.Seat)

	if self.Vehicle.DriverSeat == self.Seat then
		self.SeatPos = 0
	elseif self.Vehicle.PassengerSeats then
		for i = 1, table.Count( self.Vehicle.PassengerSeats ) do
			if self.Vehicle.pSeat[i] == self.Seat then
				self.SeatPos = i
				break
			end
		end
	end

	if !self.SeatPos then
		self:RemoveByError("Failed attempt at establishing connection to the vehicle.")
		return
	end


	if self.SeatPos == 0 then
		if !(self:SetVehicleParameters()) then
			self:RemoveByError("Failed to identify vehicle parameters.")
			return
		end
	end
	
	self.Vehicle:GetPassengerSeats() -- Updating vehicle's pSeat table before changing seat parameters
	if self.SeatPos == 0 then
		self.Vehicle.DriverSeat = self
	else
		self.Vehicle.pSeat[self.SeatPos] = self
	end
	self.Seat:Fire("Lock")


	self.TraceFilter = {self.Vehicle}
	table.Add(self.TraceFilter, self.Vehicle:GetChildren())
	table.Add(self.TraceFilter, self.Vehicle.Wheels)

	if self.Seat:GetNWBool("HasCrosshair", false) then
		self.GunnerSeat = true

		if self.Seat:GetNWBool("CalcCenterPos", false) then
			local muzzleStringId1 = self.Seat:GetNWString("Start_Left", null)
			local muzzleStringId2 = self.Seat:GetNWString("Start_Right", null)
			self.MuzzleAttachmentLeft = self.Vehicle:LookupAttachment( muzzleStringId1 )
			self.MuzzleAttachmentRight = self.Vehicle:LookupAttachment( muzzleStringId2 )
		else
			local muzzleStringId = self.Seat:GetNWString("Attachment", null)
			self.MuzzleAttachment = self.Vehicle:LookupAttachment( muzzleStringId )
		end
	else
		self.GunnerSeat = false
	end

	if self.Seat:GetNWString( "SpecialCam_Attachment", false ) then
		local seatStringId = self.Seat:GetNWString( "SpecialCam_Attachment", null )
		self.SeatAttachment = self.Vehicle:LookupAttachment(seatStringId)
	end

	self.TurretHasStopped_Counter = 0
	self.PitchEditCounter = 0
	self.YawEditCounter = 0


	local seat_pos = self.Seat:GetPos()
	local seat_ang = self.Seat:GetAngles()
	self.Seat:SetParent(NULL)
	self.Seat:SetPos(seat_pos)
	self.Seat:SetAngles(seat_ang)
	constraint.Weld(self.Seat, self.Vehicle, 0, 0, 0, false, false)
	self.Seat:GetPhysicsObject():EnableMotion(true)

	local vehicle = self.Vehicle
	vehicle.GetDriverSeat = function()
		return vehicle.DriverSeat
	end
	vehicle.GetPassengerSeats = function()
		return vehicle.pSeat
	end
end

function ENT:SetVehicleParameters()
	if Vector(math.Round(self.Vehicle:GetForward().x), math.Round(self.Vehicle:GetForward().y), math.Round(self.Vehicle:GetForward().z)) == Vector(math.Round(self.Seat:GetForward().x), math.Round(self.Seat:GetForward().y), math.Round(self.Seat:GetForward().z)) || 
	Vector(math.Round(self.Vehicle:GetForward().x), math.Round(self.Vehicle:GetForward().y), math.Round(self.Vehicle:GetForward().z)) == -Vector(math.Round(self.Seat:GetForward().x), math.Round(self.Seat:GetForward().y), math.Round(self.Seat:GetForward().z)) then
		self.Vehicle.Width = math.abs(self.Vehicle:OBBMaxs().y)*2
		if Vector(math.Round(self.Vehicle:GetForward().x), math.Round(self.Vehicle:GetForward().y), math.Round(self.Vehicle:GetForward().z)) == Vector(math.Round(self.Seat:GetForward().x), math.Round(self.Seat:GetForward().y), math.Round(self.Seat:GetForward().z)) then
			self.Vehicle.FLength = math.abs(self.Vehicle:OBBMaxs().x)
			self.Vehicle.BLength = -math.abs(self.Vehicle:OBBMins().x)
		else
			self.Vehicle.FLength = math.abs(self.Vehicle:OBBMins().x)
			self.Vehicle.BLength = -math.abs(self.Vehicle:OBBMaxs().x)
		end
	elseif Vector(math.Round(self.Vehicle:GetRight().x), math.Round(self.Vehicle:GetRight().y), math.Round(self.Vehicle:GetRight().z)) == Vector(math.Round(self.Seat:GetForward().x), math.Round(self.Seat:GetForward().y), math.Round(self.Seat:GetForward().z)) ||
	Vector(math.Round(self.Vehicle:GetRight().x), math.Round(self.Vehicle:GetRight().y), math.Round(self.Vehicle:GetRight().z)) == -Vector(math.Round(self.Seat:GetForward().x), math.Round(self.Seat:GetForward().y), math.Round(self.Seat:GetForward().z)) then
		self.Vehicle.Width = math.abs(self.Vehicle:OBBMaxs().x)*2
		if Vector(math.Round(self.Vehicle:GetRight().x), math.Round(self.Vehicle:GetRight().y), math.Round(self.Vehicle:GetRight().z)) == Vector(math.Round(self.Seat:GetForward().x), math.Round(self.Seat:GetForward().y), math.Round(self.Seat:GetForward().z)) then
			self.Vehicle.FLength = math.abs(self.Vehicle:OBBMaxs().y)
			self.Vehicle.BLength = -math.abs(self.Vehicle:OBBMins().y)
		else
			self.Vehicle.FLength = math.abs(self.Vehicle:OBBMins().y)
			self.Vehicle.BLength = -math.abs(self.Vehicle:OBBMaxs().y)
		end
	else
		return false
	end

	print("Width = "..self.Vehicle.Width)
	print("FLength = "..self.Vehicle.FLength)
	print("BLength = "..self.Vehicle.BLength)

	return true
end

function ENT:Think()
	if !IsValid(self.Seat) || !IsValid(self.Vehicle) || !IsValid(self.VehicleDriver) then return end

	self.VehicleDriver:ResetKeysArray()

	if GetConVarNumber("ai_disabled") == 1 then return end


	if self.SeatPos == 0 then
		self:DriveTheVehicle()
	end

	if self.GunnerSeat then
		self:UpdateAngleDifference()
		self:ControlTheGun()
	end

	self:NextThink(CurTime() + FrameTime())
	return true
end

function ENT:DriveTheVehicle()
	local target_pos
	local target_table = ents.FindByName(self.VehicleDriver:GetKeyValues()["target"])
	if table.IsEmpty(target_table) || self.VehicleDriver:GetInternalVariable("drivermaxspeed") <= 0 then
		self.VehicleDriver:SetKeyValue("target", "")
		self.VehicleDriver:SetKeyDown(IN_JUMP, true)
		return
	else
		target_pos = target_table[1]:GetPos()
	end

	local relative_pos,_ = WorldToLocal(target_pos, Angle(0,0,0), self.Vehicle:GetPos(), self.Seat:GetAngles())
	if relative_pos:Length2D() <= 100 then
		self.VehicleDriver:SetKeyValue("target", "")
		self.VehicleDriver:SetKeyDown(IN_JUMP, true)
		return
	end


	if relative_pos.y > 0 then
		self.VehicleDriver:SetKeyDown(IN_FORWARD, true)
	elseif relative_pos.y < -0 then
		self.VehicleDriver:SetKeyDown(IN_BACK, true)
	end
	self.GoingBackwards = self.VehicleDriver:KeyDown(IN_BACK)

	local deltaZ = target_pos.z - self.Vehicle:GetPos().z
	if deltaZ > 0 && !self.GoingBackwards then
		self.VehicleDriver:SetKeyDown(IN_RUN, math.atan2( deltaZ, relative_pos:Length2D() ) > (math.pi / 18))
	end

	relative_pos,_ = WorldToLocal(target_pos, Angle(0,0,0), self.Vehicle:GetPos() + self.Seat:GetForward() * self.Vehicle:GetPos():Distance(target_pos), self.Seat:GetAngles())

	if !self.GoingBackwards then
		if relative_pos.x > 75 then
			self.VehicleDriver:SetKeyDown(IN_RIGHT, true)
		elseif relative_pos.x < -75 then
			self.VehicleDriver:SetKeyDown(IN_LEFT, true)
		end
	else
		if relative_pos.x > 0 then
			self.VehicleDriver:SetKeyDown(IN_LEFT, true)
		elseif relative_pos.x < -0 then
			self.VehicleDriver:SetKeyDown(IN_RIGHT, true)
		end
	end
end

function ENT:UpdateAngleDifference()
	if self.PrevMuzzlePos then
		self.CurMuzzlePos = self.Vehicle:WorldToLocal(self:GetGunPos())
		if math.Round((self.CurMuzzlePos - self.PrevMuzzlePos).x) == 0 && math.Round((self.CurMuzzlePos - self.PrevMuzzlePos).y) == 0 && math.Round((self.CurMuzzlePos - self.PrevMuzzlePos).z) == 0 then
			self.TurretHasStopped_Counter = self.TurretHasStopped_Counter + 1
		else
			self.TurretHasStopped_Counter = 0
		end
	end
	if self.TurretHasStopped_Counter >= 6 then
		self.TurretHasStopped = true
	else
		self.TurretHasStopped = false
	end

	if self.TurretHasStopped && math.Round(CurTime() - self.VehicleDriver:GetEnemyLastTimeSeen(), 1) <= 0.1 then
		if self.AngleDifference then
			local next_angle_diff = (self.VehicleDriver:EyeAngles() - self:GetGunDir():Angle())
			if math.Round((next_angle_diff - self.AngleDifference).x) != 0 && math.Round((next_angle_diff - self.AngleDifference).y) == 0 then
				self.YawEditCounter = self.YawEditCounter + 1
			else
				self.YawEditCounter = 0
			end
			if math.Round((next_angle_diff - self.AngleDifference).x) == 0 && math.Round((next_angle_diff - self.AngleDifference).y) != 0 then
				self.PitchEditCounter = self.PitchEditCounter + 1
			else
				self.PitchEditCounter = 0
			end
		end
		
		if self.YawEditCounter >= 6 || self.PitchEditCounter >= 6 || ( self.PrevEnemyString && tostring(self.VehicleDriver:GetEnemy() || self.VehicleDriver) != self.PrevEnemyString ) then
			self.AngleDifference = nil
			self.TurretHasStopped_Counter = 0
			self.YawEditCounter = 0
			self.PitchEditCounter = 0
		else
			self.AngleDifference = self.VehicleDriver:EyeAngles() - self:GetGunDir():Angle()
			self.AngleDifference:Normalize()
			if math.abs((self.AngleDifference).x) > 15 || math.abs((self.AngleDifference).y) > 15 then
				self.AngleDifference = nil
			else
				self.TurretHasStopped_Counter = 0
			end
		end
	end

	if self.MuzzleAttachment || (self.MuzzleAttachmentLeft && self.MuzzleAttachmentRight) then
		self.PrevMuzzlePos = self.Vehicle:WorldToLocal(self:GetGunPos())
	end
	if IsValid(self.VehicleDriver:GetEnemy()) then
		self.PrevEnemyString = tostring(self.VehicleDriver:GetEnemy())
	end
end

function ENT:ControlTheGun()
	self.Attacking = false

	if self.Vehicle:GetNWBool( "TurretSafeMode", true ) && self.SeatPos == 0 then
		self.VehicleDriver:SetKeyDown(IN_WALK, true)
	end

	local gun_los = self:SetEyesDirection()

	if IsValid(self.VehicleDriver:GetEnemy()) && (self.Vehicle:IsDriveWheelsOnGround() && self.Vehicle:WaterLevel() <= 2) then
		local enemy = self.VehicleDriver:GetEnemy()

		if IsValid(gun_los.Entity) then
			local target = gun_los.Entity
			if target != enemy then
				target = simfphys.IdentifyVehicleTarget(self.VehicleDriver, target)
			end

			if (self.VehicleDriver:Disposition(target) == D_HT || self.VehicleDriver:Disposition(target) == D_FR) && !(target:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 1) then
				self.Attacking = true
			end
		end

		if !self.Attacking && (CurTime() - self.VehicleDriver:GetEnemyLastTimeSeen()) < 3 then
			local target_dist = gun_los.StartPos:Distance(enemy:BodyTarget(gun_los.StartPos))
			local secondary_check_pos = gun_los.StartPos + (gun_los.HitPos-gun_los.StartPos):Angle():Forward()*target_dist

			local support_check = util.TraceLine({
				start = gun_los.StartPos,
				endpos = secondary_check_pos,
				//mask = MASK_BLOCKLOS_AND_NPCS,
				filter = self.TraceFilter
			})
			secondary_check_pos = support_check.HitPos or secondary_check_pos

			local secondary_check = util.TraceLine({
				start = secondary_check_pos,
				endpos = secondary_check_pos + (enemy:BodyTarget(secondary_check_pos) - secondary_check_pos) * 32768,
				mask = MASK_BLOCKLOS_AND_NPCS,
				filter = self.TraceFilter
			})

			if secondary_check.Entity == enemy then
				if secondary_check.StartPos:Distance(secondary_check.HitPos) <= 100 then
					self.Attacking = true
				end
			end
		end
	end

	if self.Attacking then
		self:StartAttacking()
	elseif self.SeatPos == 0 then
		self:CheckIfMovementRequired()
	end
end

function ENT:SetEyesDirection()
	self:SetAngles(Angle(0,0,0))

	local driver = self.VehicleDriver
	local seat_camera_pos = self:GetCameraPos()
	driver:SetSaveValue("m_vDefaultEyeOffset", self.Seat:WorldToLocal(seat_camera_pos))

	local gun_pos = self:GetGunPos() or seat_camera_pos
	local gun_direction = self:GetGunDir() or self.VehicleDriver:EyeAngles():Forward()
	local gun_los = util.TraceLine({
		start = gun_pos,
		endpos = gun_pos + gun_direction * 32768,
		//mask = MASK_BLOCKLOS_AND_NPCS,
		filter = self.TraceFilter
	})

	if IsValid(driver:GetEnemy()) then
		local enemy = driver:GetEnemy()
		local enemy_pos = driver:GetEnemyLastKnownPos()
		if (CurTime() - self.VehicleDriver:GetEnemyLastTimeSeen()) < 3 then
			enemy_pos = enemy_pos + ( enemy:HeadTarget(seat_camera_pos) or enemy:BodyTarget(seat_camera_pos) ) - enemy:GetPos()
		end

		local los = util.TraceLine({
			start = seat_camera_pos,
			endpos = seat_camera_pos + (enemy_pos - seat_camera_pos):Angle():Forward() * 32768,
			mask = MASK_BLOCKLOS_AND_NPCS,
			filter = self.TraceFilter
		})
		if simfphys.IdentifyVehicleTarget(self.VehicleDriver, los.Entity) == enemy then
			self.VehicleDriver:UpdateEnemyMemory(enemy, enemy:GetPos())
		end

		//local tr0vis1=constraint.Rope(Entity(0), Entity(0), 0, 0, seat_camera_pos, los.HitPos, 5, 0, 5, 1, "cable/cable", false )
		//local tr0vis2=constraint.Rope(Entity(0), Entity(0), 0, 0, gun_pos, los.HitPos, 5, 0, 5, 1, "cable/cable", false )
		//local tr0vis3=constraint.Rope(Entity(0), Entity(0), 0, 0, gun_pos, gun_los.HitPos, 5, 0, 5, 1, "cable/cable", false )
		//timer.Simple(FrameTime(), function() if IsValid(tr0vis1) then tr0vis1:Remove() end end)
		//timer.Simple(FrameTime(), function() if IsValid(tr0vis2) then tr0vis2:Remove() end end)
		//timer.Simple(FrameTime(), function() if IsValid(tr0vis3) then tr0vis3:Remove() end end)

		local aim_angle = (los.HitPos - gun_pos):Angle()
		aim_angle = aim_angle + (self.AngleDifference or Angle(0,0,0))
		self.VehicleDriver:SetEyeAngles(aim_angle)
	end

	//print("Cur angle = "..tostring(self.VehicleDriver:EyeAngles()))
	//print("Actual angle = "..tostring(self:WorldToLocalAngles(self.VehicleDriver:EyeAngles())))

	return gun_los
end

function ENT:GetCameraPos()
	local seat_camera_pos

	if self.SeatAttachment then
		seat_camera_pos,_ = LocalToWorld(self.Seat:GetNWVector("SpecialCam_Firstperson", Vector(0,0,0)), self.Seat:GetAngles(), self.Vehicle:GetAttachment( self.SeatAttachment ).Pos, self.Vehicle:GetAttachment( self.SeatAttachment ).Ang)
	else
		seat_camera_pos = self.Seat:LocalToWorld(self.Seat:GetNWVector("SpecialCam_Firstperson", Vector(0,0,0)))
	end

	return seat_camera_pos
end

function ENT:GetGunPos()
	local gun_pos

	if self.MuzzleAttachment then
		gun_pos = self.Vehicle:GetAttachment( self.MuzzleAttachment ).Pos
	elseif self.MuzzleAttachmentLeft && self.MuzzleAttachmentRight then
		gun_pos = ( self.Vehicle:GetAttachment( self.MuzzleAttachmentLeft ).Pos + self.Vehicle:GetAttachment( self.MuzzleAttachmentRight ).Pos ) / 2
	else
		return null
	end

	return gun_pos
end

function ENT:GetGunDir()
	local gun_ang

	if self.MuzzleAttachment then
		gun_ang = self.Vehicle:GetAttachment( self.MuzzleAttachment ).Ang
	elseif self.MuzzleAttachmentLeft && self.MuzzleAttachmentRight then
		gun_ang = self.Vehicle:GetAttachment( self.MuzzleAttachmentLeft ).Ang
	elseif self.SeatAttachment then
		gun_ang = self.Vehicle:GetAttachment( self.SeatAttachment ).Ang
	else
		return null
	end

	if self.Seat:GetNWVector( "Direction", Vector(1,0,0) ) == Vector(0,0,1) then
		return gun_ang:Up()
	elseif self.Seat:GetNWVector( "Direction", Vector(1,0,0) ) == Vector(0,0,-1) then
		return -gun_ang:Up()
	else
		return gun_ang:Forward()
	end
end

function ENT:StartAttacking()
	self.VehicleDriver:SetKeyDown(IN_ATTACK, true)
	self.VehicleDriver:SetKeyDown(IN_ATTACK2, true)

	if self.SeatPos != 0 then return end
	self.AdditionalMovementCounter = 0
	self.AdditionalMovementRequired = false
end

function ENT:CheckIfMovementRequired()
	if self.AdditionalMovementRequired then return end

	if (math.Round(CurTime() - self.VehicleDriver:GetEnemyLastTimeSeen(), 1) <= 0.1) && (self.VehicleDriver:GetKeyValues()["target"] == "") then
		self.AdditionalMovementCounter = self.AdditionalMovementCounter or 0
		self.AdditionalMovementCounter = self.AdditionalMovementCounter + FrameTime() / ((self.TurretHasStopped and 2) or 1)
		if self.AdditionalMovementCounter > 2.0 then
			self.AdditionalMovementCounter = nil
			self.AdditionalMovementRequired = true
		end
	end
end

function ENT:OnRemove()
	local vehicle = self.Vehicle
	local seat = self.Seat
	local seatpos = self.SeatPos

	timer.Simple(FrameTime(), function()
		if IsValid(vehicle) && IsValid(seat) && isnumber(seatpos) then
			seat:Fire("Unlock")
			constraint.RemoveConstraints(seat, "Weld")
			seat:SetParent(vehicle)

			if seatpos == 0 then
				vehicle.DriverSeat = seat

				for _,key in pairs(VehicleKeysArray) do
					vehicle.PressedKeys[key] = false
				end
				vehicle:StopEngine()
				vehicle:SetActive( false )
			else
				vehicle.pSeat[seatpos] = seat
			end
		end
	end)
end

function ENT:RemoveByError(message)
	print(tostring(self)..": Error! "..message.." Removing...")
	self:Remove()
end



//========================================================================================
// Fake functions
//========================================================================================

function ENT:GetDriver()
	return self.VehicleDriver
end

function ENT:SetupDriverFunctions()
	local DRIVER = self.VehicleDriver
	table.insert(SIMFPHYS_AI_NpcIds, DRIVER:EntIndex())
	DRIVER:CallOnRemove("RemoveFromAITable"..DRIVER:EntIndex(), function()
		if table.HasValue(SIMFPHYS_AI_NpcIds, DRIVER:EntIndex()) then
			table.RemoveByValue(SIMFPHYS_AI_NpcIds, DRIVER:EntIndex())
		end
	end)

	DRIVER.Retranslator = self
	DRIVER.Vehicle = self.Vehicle
	DRIVER.Seat = self.Seat

	DRIVER.mCurAngle = DRIVER.Seat:WorldToLocalAngles(DRIVER.Seat:GetForward():Angle())

	function DRIVER:EyeAngles()
		return DRIVER.Seat:LocalToWorldAngles(DRIVER.mCurAngle)
	end

	function DRIVER:SetEyeAngles(angle)
		DRIVER.mCurAngle = DRIVER.Seat:WorldToLocalAngles(angle)
	end

	DRIVER.mKeysArray = {}
	DRIVER.mKeysArray[IN_ATTACK] = false
	DRIVER.mKeysArray[IN_ATTACK2] = false
	DRIVER.mKeysArray[IN_WALK] = false
	DRIVER.mKeysArray[IN_RELOAD] = false
	if DRIVER.Retranslator.SeatPos == 0 then
		DRIVER.mKeysArray[IN_FORWARD] = false
		DRIVER.mKeysArray[IN_BACK] = false
		DRIVER.mKeysArray[IN_LEFT] = false
		DRIVER.mKeysArray[IN_RIGHT] = false
		DRIVER.mKeysArray[IN_JUMP] = false
		DRIVER.mKeysArray[IN_RUN] = false
	end

	function DRIVER:ResetKeysArray()
		for k,_ in pairs(DRIVER.mKeysArray) do
			DRIVER:SetKeyDown(k, false)
		end
	end

	function DRIVER:SetKeyDown(key, down)
		DRIVER.mKeysArray[key] = down
		if VehicleKeysArray[key] then
			if down then
				DRIVER.Vehicle.PressedKeys[VehicleKeysArray[key]] = 0
			else
				DRIVER.Vehicle.PressedKeys[VehicleKeysArray[key]] = false
			end
		end
	end

	function DRIVER:KeyDown(key)
		return DRIVER.mKeysArray[key]
	end

	function DRIVER:Armor()
		return 0
	end

	function DRIVER:GetInfo(cVarName)
		return GetConvar(cVarName):GetDefault()
	end

	function DRIVER:GetInfoNum(cVarName, default)
		return default
	end

	function DRIVER:Team()
		return DRIVER:GetInternalVariable("teamnum")
	end

	function DRIVER:SteamID64()
		return -1
	end

	function DRIVER:ExitVehicle()
		DRIVER:Remove()
	end
end


hook.Add( "AcceptInput", "Simfphys npc_vehicledriver inputs compatibility", function( ent, input, activator, caller, value )
	if !IsValid(ent) then return end

	if ent:GetClass() == "npc_vehicledriver" && IsValid(ent.Retranslator) then
		if string.lower(input) == "gotopathcorner" then
			ent:SetKeyValue("target", tostring(value))
		end
		if string.lower(input) == "stop" then
			ent:SetKeyValue("target", "")
		end
	end
end)