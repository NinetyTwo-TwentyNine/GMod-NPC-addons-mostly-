simfphys.weapon.MGClipsize = 100

local lavc2_susdata = {}
local Maxs = Vector(10,10,0)

for i = 1,4 do
	lavc2_susdata[i] = { 
		Attachment = "sus_left_attach_"..i,
		PoseParameter = "suspension_left_"..i,
		PoseParameterMultiplier = 1,
		-- ReversePoseParam = true,
		Height = 25,
		GroundHeight = -55,
		Mins = -Maxs,
		Maxs = Maxs,
	}
	
	lavc2_susdata	[i + 4] = { 
		Attachment = "sus_right_attach_"..i,
		PoseParameter = "suspension_right_"..i,
		PoseParameterMultiplier = 1,
		-- ReversePoseParam = true,
		Height = 25,
		GroundHeight = -55,
		Mins = -Maxs,
		Maxs = Maxs,
	}
end

local function mg_fire(ply,vehicle,shootOrigin,shootDirection)

	vehicle:ResetSequence("fire")
	vehicle:EmitSound("M240_LAST")
	
	local projectile = {}
		projectile.filter = vehicle.VehicleData["filter"]
		projectile.shootOrigin = shootOrigin
		projectile.shootDirection = shootDirection
		projectile.attacker = ply
		projectile.Tracer	= 1
		projectile.HullSize = 6
		projectile.attackingent = vehicle
		projectile.Spread = Vector(0.01,0.01,0.01)
		projectile.Damage = 12
		projectile.Force = 12
	
	simfphys.FireHitScan( projectile )
end

function simfphys.weapon:ValidClasses()
	
	local classes = {
		"sim_fphys_lav-c2_armed"
	}
	
	return classes
end

function simfphys.weapon:Initialize( vehicle )
	self.MGClip = self.MGClipsize

	local data = {}
	data.Attachment = "muzzle"
	data.Direction = Vector(1,0,0)
	data.Attach_Start = "muzzle"
	
	simfphys.RegisterCrosshair( vehicle:GetDriverSeat(), data )
	simfphys.RegisterCamera( vehicle:GetDriverSeat(), Vector(0,30,55), Vector(13,85,120), true )
	
	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end
	
	for i = 2, table.Count( vehicle.pSeat ) do
		simfphys.RegisterCamera( vehicle.pSeat[ i ], Vector(0,0,60), Vector(0,0,60) )
	end
end

function simfphys.weapon:AimWeapon( ply, vehicle, pod )	
	local reloading = (not self:CanPrimaryAttack(vehicle)) and self.MGClip == self.MGClipsize
	local Aimang = pod:WorldToLocalAngles( ply:EyeAngles() )
	local AimRate = 250
	
	local Angles = vehicle:WorldToLocalAngles( Aimang ) 
	if reloading then
		Angles.p = -75
	end
	
	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw and math.ApproachAngle( vehicle.sm_pp_yaw, Angles.y, AimRate * FrameTime() ) or 0
	vehicle.sm_pp_pitch = vehicle.sm_pp_pitch and math.ApproachAngle( vehicle.sm_pp_pitch, Angles.p, AimRate * FrameTime() ) or 0
	
	local TargetAng = Angle(vehicle.sm_pp_pitch,vehicle.sm_pp_yaw,0)
	TargetAng:Normalize() 
	
	vehicle:SetPoseParameter("cannon_aim_yaw", TargetAng.y )
	vehicle:SetPoseParameter("cannon_aim_pitch", -TargetAng.p )
end

function simfphys.weapon:Think( vehicle )
	local pod = vehicle:GetDriverSeat()
	if not IsValid( pod ) then return end
	
	local ply = pod:GetDriver()
	
	local curtime = CurTime()
	
	if not IsValid( ply ) then 
		if vehicle.wpn then
			vehicle.wpn:Stop()
			vehicle.wpn = nil
		end
		
		return
	end

	local AttachmentID = vehicle:LookupAttachment( "muzzle" )
	local Attachment = vehicle:GetAttachment( AttachmentID )

	vehicle.wOldPos = vehicle.wOldPos or vehicle:GetPos()
	local deltapos = vehicle:GetPos() - vehicle.wOldPos
	vehicle.wOldPos = vehicle:GetPos()
	local DeltaP = deltapos * engine.TickInterval()
	
	self:UpdateSuspension( vehicle )
	self:DoWheelSpin( vehicle )
	self:AimWeapon( ply, vehicle, pod )
	
	local fire = ply:KeyDown( IN_ATTACK )
	
	if fire then
		self:PrimaryAttack( vehicle, ply, DeltaP, Attachment.Pos, Attachment.Ang )
	end

	if ply:KeyDown( IN_RELOAD ) and self.MGClip < self.MGClipsize and self:CanPrimaryAttack(vehicle) then
		self.MGClip = self.MGClipsize
		vehicle:EmitSound("MG_RELOAD", 75, 75)
		self:SetNextPrimaryFire( vehicle, CurTime() + 7 )
	end
end

function simfphys.weapon:CanPrimaryAttack( vehicle )
	vehicle.NextShoot = vehicle.NextShoot or 0
	return vehicle.NextShoot < CurTime()
end

function simfphys.weapon:SetNextPrimaryFire( vehicle, time )
	vehicle.NextShoot = time
end

function simfphys.weapon:PrimaryAttack( vehicle, ply, deltapos, cPos, cAng )
	if not self:CanPrimaryAttack( vehicle ) then return end

	if self.MGClip <= 0 then
		self.MGClip = self.MGClipsize
		vehicle:EmitSound("MG_RELOAD", 75, 75)
		self:SetNextPrimaryFire( vehicle, CurTime() + 7 )
		return
	end

	self.MGClip = self.MGClip - 1
	
	local AttachmentID = vehicle:LookupAttachment( "muzzle" )
	local Attachment = vehicle:GetAttachment( AttachmentID )
	
	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()
	local shootDirection = Attachment.Ang:Forward()

	local trace = util.TraceLine( {
		start = cPos,
		endpos = cPos + cAng:Forward() * 50000,
		filter = vehicle.VehicleData["filter"]
	} )
	
	local effectdata = EffectData()
		effectdata:SetOrigin( shootOrigin )
		effectdata:SetAngles( Attachment.Ang )
		effectdata:SetEntity( vehicle )
		effectdata:SetAttachment( AttachmentID )
		effectdata:SetScale( 3 )
	util.Effect( "CS_MuzzleFlash", effectdata, true, true )
	
	mg_fire( ply, vehicle, Attachment.Pos, (trace.HitPos - Attachment.Pos):GetNormalized() )
	
	self:SetNextPrimaryFire( vehicle, CurTime() + 0.08 )
end


function simfphys.weapon:UpdateSuspension( vehicle )
	if not vehicle.filterEntities then
		vehicle.filterEntities = player.GetAll()
		table.insert(vehicle.filterEntities, vehicle)
		
		for i, wheel in pairs( ents.FindByClass( "gmod_sent_vehicle_fphysics_wheel" ) ) do
			table.insert(vehicle.filterEntities, wheel)
		end
	end
	
	vehicle.oldDist = istable( vehicle.oldDist ) and vehicle.oldDist or {}
	
	vehicle.susOnGround = false
	local Up = vehicle:GetUp()
	
	for i,v in pairs( lavc2_susdata ) do
		local pos = vehicle:GetAttachment( vehicle:LookupAttachment( lavc2_susdata[i].Attachment ) ).Pos + Up * 10
		
		local trace = util.TraceHull( {
			start = pos,
			endpos = pos + Up * - 100,
			maxs = Vector(10,10,0),
			mins = -Vector(10,10,0),
			filter = vehicle.filterEntities,
		} )
		local Dist = (pos - trace.HitPos):Length() - 30
		
		if trace.Hit then
			vehicle.susOnGround = true
		end
		
		vehicle.oldDist[i] = vehicle.oldDist[i] and (vehicle.oldDist[i] + math.Clamp(Dist - vehicle.oldDist[i],-5,1)) or 0
		
		vehicle:SetPoseParameter(lavc2_susdata[i].PoseParameter, vehicle.oldDist[i] )
	end
end


function simfphys.weapon:DoWheelSpin( vehicle )
	local spin_r = (vehicle.VehicleData[ "spin_4" ] + vehicle.VehicleData[ "spin_6" ]) * 1.25
	local spin_l = (vehicle.VehicleData[ "spin_3" ] + vehicle.VehicleData[ "spin_5" ]) * 1.25
	
	net.Start( "simfphys_update_tracks", true )
		net.WriteEntity( vehicle )
		net.WriteFloat( spin_r ) 
		net.WriteFloat( spin_l ) 
	net.Broadcast()
	
	vehicle:SetPoseParameter("spin_wheels_right", spin_r)
	vehicle:SetPoseParameter("spin_wheels_left", spin_l )
end