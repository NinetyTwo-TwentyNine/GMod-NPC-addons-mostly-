simfphys.weapon.MGClipsize = 100

local function mg_fire(ply,vehicle,shootOrigin,shootDirection)

	vehicle:EmitSound("sherman_fire_mg", 120)

	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 6000, shootOrigin )

	local projectile = {}
		projectile.filter = vehicle.VehicleData["filter"]
		projectile.shootOrigin = shootOrigin
		projectile.shootDirection = shootDirection
		projectile.attacker = ply
		projectile.Tracer	= 1
		projectile.Spread = Vector(0.006,0.006,0)
		projectile.HullSize = 1
		projectile.attackingent = vehicle
		projectile.Damage = 26
		projectile.ArmourPiercing = true
		projectile.Force = 12
	simfphys.FireHitScan( projectile )
end

function simfphys.weapon:ValidClasses()

	local classes = {
		"avx_hmmwv"
	}

	return classes
end

function simfphys.weapon:Initialize( vehicle )
	self.MGClip = self.MGClipsize

	local data = {}
	data.Attachment = "mg_muzzle"
	data.Direction = Vector(0,0,-1)
	data.Attach_Start = "mg_muzzle"

	simfphys.RegisterCrosshair( vehicle:GetDriverSeat(), data )
	simfphys.RegisterCamera( vehicle:GetDriverSeat(), Vector(4, 0, 8), Vector(28, 4, 64), true )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end
end

function simfphys.weapon:AimWeapon( ply, vehicle, pod )
	local reloading = (not self:CanPrimaryAttack(vehicle)) and self.MGClip == self.MGClipsize
	local Aimang = pod:WorldToLocalAngles( ply:EyeAngles() )
	local AimRate = 250

	local Angles = vehicle:WorldToLocalAngles( Aimang ) + Angle(-15, 180, 0)
	if reloading then
		Angles.p = -75
	end
	
	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw and math.ApproachAngle( vehicle.sm_pp_yaw, Angles.y, AimRate * FrameTime() ) or 0
	vehicle.sm_pp_pitch = vehicle.sm_pp_pitch and math.ApproachAngle( vehicle.sm_pp_pitch, Angles.p, AimRate * FrameTime() ) or 0
	
	local TargetAng = Angle(vehicle.sm_pp_pitch,vehicle.sm_pp_yaw,0)
	TargetAng:Normalize()
	
	vehicle:SetPoseParameter("turret_yaw", TargetAng.y )
	vehicle:SetPoseParameter("turret_pitch", TargetAng.p )
end

function simfphys.weapon:Think( vehicle )
	local pod = vehicle:GetDriverSeat()
	if not IsValid( pod ) then return end

	local ply = pod:GetDriver()

	if not IsValid( ply ) then
		if vehicle.wpn then
			vehicle.wpn:Stop()
			vehicle.wpn = nil
		end

		return
	end

	self:AimWeapon( ply, vehicle, pod )

	local fire = ply:KeyDown( IN_ATTACK )

	if fire then
		self:PrimaryAttack( vehicle, ply, shootOrigin )
	end

	if ply:KeyDown( IN_RELOAD ) and self.MGClip < self.MGClipsize and self:CanPrimaryAttack(vehicle) then
		self.MGClip = self.MGClipsize
		vehicle:EmitSound("MG_RELOAD")
		self:SetNextPrimaryFire( vehicle, CurTime() + 9 )
	end
end

function simfphys.weapon:CanPrimaryAttack( vehicle )
	vehicle.NextShoot = vehicle.NextShoot or 0
	return vehicle.NextShoot < CurTime()
end

function simfphys.weapon:SetNextPrimaryFire( vehicle, time )
	vehicle.NextShoot = time
end

function simfphys.weapon:PrimaryAttack( vehicle, ply )
	if not self:CanPrimaryAttack( vehicle ) then return end

	if self.MGClip <= 0 then
		self.MGClip = self.MGClipsize
		vehicle:EmitSound("MG_RELOAD")
		self:SetNextPrimaryFire( vehicle, CurTime() + 9 )
		return
	end

	self.MGClip = self.MGClip - 1
	
	vehicle.wOldPos = vehicle.wOldPos or vehicle:GetPos()
	local deltapos = vehicle:GetPos() - vehicle.wOldPos
	vehicle.wOldPos = vehicle:GetPos()
	
	local AttachmentID = vehicle:LookupAttachment( "mg_muzzle" )
	local Attachment = vehicle:GetAttachment( AttachmentID )
	local ang = Attachment.Ang
	
	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()
	local shootDirection = -ang:Up()
	
	local effectdata = EffectData()
		effectdata:SetOrigin( shootOrigin )
		effectdata:SetAngles( ang )
		effectdata:SetEntity( vehicle )
		effectdata:SetAttachment( AttachmentID )
		effectdata:SetScale( 2 )
	util.Effect( "CS_MuzzleFlash_X", effectdata, true, true )
	
	mg_fire( ply, vehicle, shootOrigin, shootDirection )
	
	self:SetNextPrimaryFire( vehicle, CurTime() + (60 / 600) )
end