simfphys.weapon.M240Clipsize = 150
simfphys.weapon.M2Clipsize = 100

local m1a1_susdata = {}
for i = 1,7 do
	m1a1_susdata[i] = {
		attachment = "sus_left_attach_" .. i,
		poseparameter = "suspension_left_" .. i,
	}

	local ir = i + 7

	m1a1_susdata[ir] = {
		attachment = "sus_right_attach_" .. i,
		poseparameter = "suspension_right_" .. i,
	}
end

local function m2_fire(ply,vehicle,shootOrigin,shootDirection)

	vehicle:EmitSound("sherman_fire_mg", 120)

	local projectile = {}
		projectile.filter = vehicle.VehicleData["filter"]
		projectile.shootOrigin = shootOrigin
		projectile.shootDirection = shootDirection
		projectile.attacker = ply
		projectile.Tracer	= 1
		projectile.Spread = Vector(0.006,0.006,0.006)
		projectile.HullSize = 1
		projectile.attackingent = vehicle
		projectile.Damage = 26
		projectile.ArmourPiercing = true
		projectile.Force = 12

	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 3000, shootOrigin )

	simfphys.FireHitScan( projectile )

end

local function m240_fire(ply,vehicle,shootOrigin,shootDirection)

	vehicle:EmitSound("tiger_fire_mg", 115)

	local projectile = {}
		projectile.filter = vehicle.VehicleData["filter"]
		projectile.shootOrigin = shootOrigin
		projectile.shootDirection = shootDirection
		projectile.attacker = ply
		projectile.Tracer	= 1
		projectile.Spread = Vector(0.01, 0.01, 0)
		projectile.HullSize = 1
		projectile.attackingent = vehicle
		projectile.Damage = 12
		projectile.Force = 12

	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 1000, shootOrigin )

	simfphys.FireHitScan( projectile )
end

local function cannon_fire(ply,vehicle,shootOrigin,shootDirection)
	vehicle:EmitSound("t90ms_fire", 150)
	vehicle:EmitSound("sherman_reload")

	timer.Simple( 4, function()
		if IsValid( vehicle ) then
			vehicle:EmitSound("simulated_vehicles/weapons/leopard_ready.wav")
		end
	end)

	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 1500000, shootOrigin )

	local projectile = {}
		projectile.filter = vehicle.VehicleData["filter"]
		projectile.shootOrigin = shootOrigin - (shootDirection * 200)
		projectile.shootDirection = shootDirection
		projectile.attacker = ply
		projectile.attackingent = vehicle
		projectile.ArmourPiercing = true
		projectile.Damage = 460
		projectile.Force = 9000
		projectile.Size = 15
		projectile.BlastRadius = 200
		projectile.BlastDamage = 200
		projectile.BlastEffect = "simfphys_tankweapon_explosion"

	simfphys.FirePhysProjectile( projectile )
end

function simfphys.weapon:ValidClasses()
	return { "avx_m1a1" }
end

function simfphys.weapon:Initialize( vehicle )
	net.Start( "avx_ins1_register_tank" )
		net.WriteEntity( vehicle )
		net.WriteString( "m1a1" )
	net.Broadcast()

	self.M2Clip = self.M2Clipsize
	self.M240Clip = self.M240Clipsize

	vehicle:SetNWBool( "SpecialCam_Loader", true )
	vehicle:SetNWFloat( "SpecialCam_LoaderTime", 4.5 )

	simfphys.RegisterCrosshair( vehicle:GetDriverSeat(), { Attachment = "muzzle_cannon", Type = 4 } )
	simfphys.RegisterCamera( vehicle:GetDriverSeat(), Vector(24,0,0), Vector(0,40,140), true, "gunner_view" )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end

	simfphys.RegisterCrosshair( vehicle.pSeat[1] , { Attachment = "muzzle_m240", Type = 5 } )
	simfphys.RegisterCamera( vehicle.pSeat[1], Vector(0,-8,0), Vector(0,40,140), true, "m240_view" )

	simfphys.RegisterCrosshair( vehicle.pSeat[2] , { Attachment = "muzzle_m2", Type = 5 } )
	simfphys.RegisterCamera( vehicle.pSeat[2], Vector(0,-8,0), Vector(0,40,140), true, "m2_view" )

	timer.Simple( 1, function()
		if not IsValid( vehicle ) then return end
		if not vehicle.VehicleData["filter"] then print("[simfphys Armed Vehicle Pack] ERROR:TRACE FILTER IS INVALID. PLEASE UPDATE SIMFPHYS BASE") return end

		vehicle.WheelOnGround = function( ent )
			ent.FrontWheelPowered = ent:GetPowerDistribution() ~= 1
			ent.RearWheelPowered = ent:GetPowerDistribution() ~= -1

			for i = 1, table.Count( ent.Wheels ) do
				local Wheel = ent.Wheels[i]
				if IsValid( Wheel ) then
					local dmgMul = Wheel:GetDamaged() and 0.5 or 1
					local surfacemul = simfphys.TractionData[Wheel:GetSurfaceMaterial():lower()]

					ent.VehicleData[ "SurfaceMul_" .. i ] = (surfacemul and math.max(surfacemul,0.001) or 1) * dmgMul

					local WheelPos = ent:LogicWheelPos( i )

					local WheelRadius = WheelPos.IsFrontWheel and ent.FrontWheelRadius or ent.RearWheelRadius
					local startpos = Wheel:GetPos()
					local dir = -ent.Up
					local len = WheelRadius + math.Clamp(-ent.Vel.z / 50,2.5,6)
					local HullSize = Vector(WheelRadius,WheelRadius,0)
					local tr = util.TraceHull( {
						start = startpos,
						endpos = startpos + dir * len,
						maxs = HullSize,
						mins = -HullSize,
						filter = ent.VehicleData["filter"]
					} )

					local onground = self:IsOnGround( vehicle ) and 1 or 0
					ent.VehicleData[ "onGround_" .. i ] = onground

					if vehicle:GetActive() then
						Wheel:SetOnGround( onground )
						if tr.Hit then
							Wheel:SetSpeed( Wheel.FX )
							Wheel:SetSkidSound( Wheel.skid )
							Wheel:SetSurfaceMaterial( util.GetSurfacePropName( tr.SurfaceProps ) )
						end
					end
				end
			end

			local FrontOnGround = math.max(ent.VehicleData[ "onGround_1" ],ent.VehicleData[ "onGround_2" ])
			local RearOnGround = math.max(ent.VehicleData[ "onGround_3" ],ent.VehicleData[ "onGround_4" ])

			ent.DriveWheelsOnGround = math.max(ent.FrontWheelPowered and FrontOnGround or 0,ent.RearWheelPowered and RearOnGround or 0)
		end
	end)
end

function simfphys.weapon:GetForwardSpeed( vehicle )
	return vehicle.ForwardSpeed
end

function simfphys.weapon:IsOnGround( vehicle )
	return vehicle.susOnGround == true
end

function simfphys.weapon:AimM2( ply, vehicle, pod )
	if not IsValid( pod ) then return end

	local reloading = (not self:CanAttackM2(vehicle)) and self.M2Clip == self.M2Clipsize
	local Aimang = pod:WorldToLocalAngles( ply:EyeAngles() )
	local AimRate = 150

	local Angles = vehicle:WorldToLocalAngles( Aimang )
	if reloading then
		Angles.p = -75
	end

	vehicle.sm_ppm2_yaw = vehicle.sm_ppm2_yaw and math.ApproachAngle( vehicle.sm_ppm2_yaw, Angles.y, AimRate * FrameTime() ) or 180
	vehicle.sm_ppm2_pitch = vehicle.sm_ppm2_pitch and math.ApproachAngle( vehicle.sm_ppm2_pitch, -Angles.p - 65, AimRate * FrameTime() ) or 0

	local TargetAng = Angle(vehicle.sm_ppm2_pitch,vehicle.sm_ppm2_yaw,0)
	TargetAng:Normalize()

	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw or 180

	vehicle:SetPoseParameter("m2_aim_yaw", TargetAng.y - vehicle.sm_pp_yaw )
	vehicle:SetPoseParameter("m2_aim_pitch", -TargetAng.p )
end

function simfphys.weapon:AimM240( ply, vehicle, pod )
	if not IsValid( pod ) then return end

	local reloading = (not self:CanAttackM240(vehicle)) and self.M240Clip == self.M240Clipsize
	local Aimang = pod:WorldToLocalAngles( ply:EyeAngles() ) + Angle(35, 180 - 3, 0)
	local AimRate = 150

	local Angles = vehicle:WorldToLocalAngles( Aimang )
	if reloading then
		Angles.p = -75
	end

	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw or 180

	vehicle.sm_ppmg_yaw = vehicle.sm_ppmg_yaw and math.ApproachAngle( vehicle.sm_ppmg_yaw, Angles.y, 150 * FrameTime() ) or 180
	vehicle.sm_ppmg_pitch = vehicle.sm_ppmg_pitch and math.ApproachAngle( vehicle.sm_ppmg_pitch, -Angles.p, AimRate * FrameTime() ) or 0
	vehicle.sm_ppmg_pivot = vehicle.sm_ppmg_pivot and math.Clamp(math.ApproachAngle( vehicle.sm_ppmg_pivot, Angles.y - 55 - vehicle.sm_pp_yaw + 180, 150 * FrameTime() ), -100, 100) or 0

	local TargetAng = Angle(vehicle.sm_ppmg_pitch,vehicle.sm_ppmg_yaw,0)
	TargetAng:Normalize()

	vehicle:SetPoseParameter("m240_aim_pivot", vehicle.sm_ppmg_pivot )
	vehicle:SetPoseParameter("m240_aim_yaw", TargetAng.y - vehicle.sm_ppmg_pivot - vehicle.sm_pp_yaw + 180 )
	vehicle:SetPoseParameter("m240_aim_pitch", -TargetAng.p )
end

function simfphys.weapon:AimCannon( ply, vehicle, pod, Attachment )
	if not IsValid( pod ) then return end

	local Aimang = pod:WorldToLocalAngles( ply:EyeAngles() )
	Aimang:Normalize()

	local AimRate = 60

	local Angles = vehicle:WorldToLocalAngles( Aimang )

	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw and math.ApproachAngle( vehicle.sm_pp_yaw, Angles.y, AimRate * FrameTime() ) or 180
	vehicle.sm_pp_pitch = vehicle.sm_pp_pitch and math.ApproachAngle( vehicle.sm_pp_pitch, -Angles.p, AimRate * FrameTime() ) or 0

	local TargetAng = Angle(vehicle.sm_pp_pitch,vehicle.sm_pp_yaw,0)
	TargetAng:Normalize()

	vehicle:SetPoseParameter("turret_yaw", TargetAng.y - 180 )
	vehicle:SetPoseParameter("cannon_aim_yaw", TargetAng.y - 180 )

	local pclamp = math.Clamp( (math.cos( math.rad(TargetAng.y) ) - 0.7) * 6,0,1) ^ 2 * 15
	vehicle:SetPoseParameter("cannon_aim_pitch", math.Clamp(-TargetAng.p,-20,15 - pclamp) )
end

function simfphys.weapon:ControlTurret( vehicle, deltapos )
	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end

	local pod = vehicle:GetDriverSeat()

	if not IsValid( pod ) then return end

	local ply = pod:GetDriver()

	if not IsValid( ply ) then return end

	local safemode = ply:KeyDown( IN_WALK )

	if vehicle.ButtonSafeMode ~= safemode then
		vehicle.ButtonSafeMode = safemode
		
		if safemode then
			vehicle:SetNWBool( "TurretSafeMode", not vehicle:GetNWBool( "TurretSafeMode", true ) )
			
			if vehicle:GetNWBool( "TurretSafeMode" ) then
				vehicle:EmitSound( "vehicles/tank_turret_stop1.wav")
			else
				vehicle:EmitSound( "vehicles/tank_readyfire1.wav")
			end
		end
	end
	
	if vehicle:GetNWBool( "TurretSafeMode", true ) then return end

	local ID = vehicle:LookupAttachment( "muzzle_cannon" )
	local Attachment = vehicle:GetAttachment( ID )

	self:AimCannon( ply, vehicle, pod, Attachment )

	local DeltaP = deltapos * engine.TickInterval()

	local fire = ply:KeyDown( IN_ATTACK )
	local fire2 = ply:KeyDown( IN_ATTACK2 )

	if fire then
		self:PrimaryAttack( vehicle, ply, Attachment.Pos + DeltaP, Attachment )
	end

	if fire2 then
		self:SecondaryAttack( vehicle, ply, DeltaP, Attachment.Pos, Attachment.Ang )
	end
end

function simfphys.weapon:ControlM2( vehicle, deltapos )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end

	local pod = vehicle.pSeat[2]

	if not IsValid( pod ) then return end

	local ply = pod:GetDriver()

	if not IsValid( ply ) then return end

	self:AimM2( ply, vehicle, pod )

	local ID = vehicle:LookupAttachment( "muzzle_m2" )
	local Attachment = vehicle:GetAttachment( ID )

	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()

	local fire = ply:KeyDown( IN_ATTACK )

	if fire then
		self:AttackM2( vehicle, ply, shootOrigin, Attachment, ID )
	end

	if ply:KeyDown(IN_RELOAD) and self:CanAttackM2( vehicle ) and self.M2Clip < self.M2Clipsize then
		self.M2Clip = self.M2Clipsize
		vehicle:EmitSound("MG_RELOAD")
		self:SetNextM2Fire( vehicle, CurTime() + 9 )
	end
end

function simfphys.weapon:AttackM2( vehicle, ply, shootOrigin, Attachment, ID )

	if not self:CanAttackM2( vehicle ) then return end

	if self.M2Clip <= 0 then
		self.M2Clip = self.M2Clipsize
		vehicle:EmitSound("MG_RELOAD")
		self:SetNextM2Fire( vehicle, CurTime() + 9 )
		return
	end

	self.M2Clip = self.M2Clip - 1

	local effectdata = EffectData()
		effectdata:SetOrigin( shootOrigin )
		effectdata:SetAngles( Attachment.Ang )
		effectdata:SetEntity( vehicle )
		effectdata:SetAttachment( ID )
		effectdata:SetScale( 4 )
	util.Effect( "CS_MuzzleFlash_X", effectdata, true, true )

	local shootDirection = Attachment.Ang:Forward()

	m2_fire( ply, vehicle, shootOrigin + shootDirection * 40, shootDirection )

	self:SetNextM2Fire( vehicle, CurTime() + (60 / 600) )
end

function simfphys.weapon:ControlM240( vehicle, deltapos )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end

	local pod = vehicle.pSeat[1]

	if not IsValid( pod ) then return end

	local ply = pod:GetDriver()

	if not IsValid( ply ) then return end

	self:AimM240( ply, vehicle, pod )

	local ID = vehicle:LookupAttachment( "muzzle_m240" )
	local Attachment = vehicle:GetAttachment( ID )

	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()

	local fire = ply:KeyDown( IN_ATTACK )

	if fire then
		self:AttackM240( vehicle, ply, shootOrigin, Attachment, ID )
	end

	if ply:KeyDown(IN_RELOAD) and self:CanAttackM240( vehicle ) and self.M240Clip < self.M240Clipsize then
		self.M240Clip = self.M240Clipsize
		vehicle:EmitSound("MG_RELOAD", 75, 75)
		self:SetNextFire( vehicle, CurTime() + 7 )
	end
end

function simfphys.weapon:AttackM240( vehicle, ply, shootOrigin, Attachment, ID )

	if not self:CanAttackM240( vehicle ) then return end

	if self.M240Clip <= 0 then
		self.M240Clip = self.M240Clipsize
		vehicle:EmitSound("MG_RELOAD", 75, 75)
		self:SetNextFire( vehicle, CurTime() + 7 )
		return
	end

	self.M240Clip = self.M240Clip - 1

	local effectdata = EffectData()
		effectdata:SetOrigin( shootOrigin )
		effectdata:SetAngles( Attachment.Ang )
		effectdata:SetEntity( vehicle )
		effectdata:SetAttachment( ID )
		effectdata:SetScale( 2 )
	util.Effect( "CS_MuzzleFlash_X", effectdata, true, true )

	local shootDirection = Attachment.Ang:Forward()

	m240_fire( ply, vehicle, shootOrigin + shootDirection * 40, shootDirection )

	self:SetNextFire( vehicle, CurTime() + (60 / 800) )
end

function simfphys.weapon:CanAttackM240( vehicle )
	vehicle.NextShoot3 = vehicle.NextShoot3 or 0
	return vehicle.NextShoot3 < CurTime()
end

function simfphys.weapon:SetNextFire( vehicle, time )
	vehicle.NextShoot3 = time
end

function simfphys.weapon:CanAttackM2( vehicle )
	vehicle.NextShoot4 = vehicle.NextShoot4 or 0
	return vehicle.NextShoot4 < CurTime()
end

function simfphys.weapon:SetNextM2Fire( vehicle, time )
	vehicle.NextShoot4 = time
end

function simfphys.weapon:PrimaryAttack( vehicle, ply, shootOrigin, Attachment )
	if not self:CanPrimaryAttack( vehicle ) then return end

	local shootDirection = Attachment.Ang:Forward()

	cannon_fire( ply, vehicle, shootOrigin + shootDirection * 80, shootDirection )

	local effectdata = EffectData()
		effectdata:SetEntity( vehicle )
	util.Effect( "arctic_abrams_muzzle", effectdata, true, true )

	self:SetNextPrimaryFire( vehicle, CurTime() + 4.5 )
end

function simfphys.weapon:CanPrimaryAttack( vehicle )
	vehicle.NextShoot = vehicle.NextShoot or 0
	return vehicle.NextShoot < CurTime()
end

function simfphys.weapon:SetNextPrimaryFire( vehicle, time )
	vehicle.NextShoot = time

	vehicle:SetNWFloat( "SpecialCam_LoaderNext", time )
end


function simfphys.weapon:SecondaryAttack( vehicle, ply, deltapos, cPos, cAng )

	if not self:CanSecondaryAttack( vehicle ) then return end

	local ID = vehicle:LookupAttachment( "muzzle_coax" )
	local Attachment = vehicle:GetAttachment( ID )

	local effectdata = EffectData()
		effectdata:SetOrigin( Attachment.Pos + deltapos )
		effectdata:SetAngles( Attachment.Ang + Angle(0,90,0) )
		effectdata:SetEntity( vehicle )
		effectdata:SetAttachment( ID )
		effectdata:SetScale( 2 )
	util.Effect( "CS_MuzzleFlash_X", effectdata, true, true )

	local trace = util.TraceLine( {
		start = cPos,
		endpos = cPos + cAng:Forward() * 50000,
		filter = vehicle.VehicleData["filter"]
	} )

	m240_fire( ply, vehicle, Attachment.Pos, (trace.HitPos - Attachment.Pos):GetNormalized() )

	self:SetNextSecondaryFire( vehicle, CurTime() + (60 / 600) )
end

function simfphys.weapon:CanSecondaryAttack( vehicle )
	vehicle.NextShoot2 = vehicle.NextShoot2 or 0
	return vehicle.NextShoot2 < CurTime()
end

function simfphys.weapon:SetNextSecondaryFire( vehicle, time )
	vehicle.NextShoot2 = time
end

function simfphys.weapon:ModPhysics( vehicle, wheelslocked )
	if wheelslocked and self:IsOnGround( vehicle ) then
		local phys = vehicle:GetPhysicsObject()
		phys:ApplyForceCenter( -vehicle:GetVelocity() * phys:GetMass() * 0.04 )
	end
end

function simfphys.weapon:ControlTrackSounds( vehicle, wheelslocked ) 
	local speed = math.abs( self:GetForwardSpeed( vehicle ) )
	local fastenuf = speed > 20 and not wheelslocked and self:IsOnGround( vehicle )

	if fastenuf ~= vehicle.fastenuf then
		vehicle.fastenuf = fastenuf

		if fastenuf then
			vehicle.track_snd = CreateSound( vehicle, "simulated_vehicles/tiger/tiger_tracks.wav" )
			vehicle.track_snd:PlayEx(0,0)
			vehicle:CallOnRemove( "stopmesounds", function( vehicle )
				if vehicle.track_snd then
					vehicle.track_snd:Stop()
				end
			end)
		else
			if vehicle.track_snd then
				vehicle.track_snd:Stop()
				vehicle.track_snd = nil
			end
		end
	end

	if vehicle.track_snd then
		vehicle.track_snd:ChangePitch( math.Clamp(60 + speed / 40,0,150) )
		vehicle.track_snd:ChangeVolume( math.min( math.max(speed - 20,0) / 200,1) )
	end
end

function simfphys.weapon:Think( vehicle )
	if not IsValid( vehicle ) or not vehicle:IsInitialized() then return end

	vehicle.wOldPos = vehicle.wOldPos or Vector(0,0,0)
	local deltapos = vehicle:GetPos() - vehicle.wOldPos
	vehicle.wOldPos = vehicle:GetPos()

	local handbrake = vehicle:GetHandBrakeEnabled()

	self:UpdateSuspension( vehicle )
	self:DoWheelSpin( vehicle )
	self:ControlTurret( vehicle, deltapos )
	self:ControlM240( vehicle, deltapos )
	self:ControlM2( vehicle, deltapos )
	self:ControlTrackSounds( vehicle, handbrake )
	self:ModPhysics( vehicle, handbrake )
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

	for i, v in pairs( m1a1_susdata ) do
		local pos = vehicle:GetAttachment( vehicle:LookupAttachment( m1a1_susdata[i].attachment ) ).Pos + Up * 10

		local trace = util.TraceHull( {
			start = pos,
			endpos = pos + Up * - 100,
			maxs = Vector(10,10,0),
			mins = -Vector(10,10,0),
			filter = vehicle.filterEntities,
		} )
		local Dist = (pos - trace.HitPos):Length() - 38

		if trace.Hit then
			vehicle.susOnGround = true
		end

		vehicle.oldDist[i] = vehicle.oldDist[i] and (vehicle.oldDist[i] + math.Clamp(Dist - vehicle.oldDist[i],-5,1)) or 0

		vehicle:SetPoseParameter(m1a1_susdata[i].poseparameter, vehicle.oldDist[i] )
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