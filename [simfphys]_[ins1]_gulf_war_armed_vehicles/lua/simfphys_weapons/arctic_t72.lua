simfphys.weapon.NSVTClipsize = 100

local t72_susdata = {}
for i = 1,6 do
	t72_susdata[i] = {
		attachment = "sus_left_attach_" .. i,
		poseparameter = "suspension_left_" .. i,
	}

	local ir = i + 6

	t72_susdata[ir] = {
		attachment = "sus_right_attach_" .. i,
		poseparameter = "suspension_right_" .. i,
	}
end

local function nsvt_fire(ply,vehicle,shootOrigin,shootDirection)

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
		projectile.Damage = 25
		//projectile.ArmourPiercing = true
		projectile.Force = 12

	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 3000, shootOrigin )

	simfphys.FireHitScan( projectile )

end

local function cannon_fire(ply,vehicle,shootOrigin,shootDirection)
	vehicle:EmitSound("tiger_fire", 150)
	vehicle:EmitSound("t90ms_reload")

	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 1500000, shootOrigin )

	local projectile = {}
		projectile.filter = vehicle.VehicleData["filter"]
		projectile.shootOrigin = shootOrigin - (shootDirection * 200)
		projectile.shootDirection = shootDirection
		projectile.attacker = ply
		projectile.attackingent = vehicle
		projectile.ArmourPiercing = true
		projectile.Damage = 360
		projectile.Force = 1500
		projectile.Size = 8
		projectile.BlastRadius = 150
		projectile.BlastDamage = 200
		projectile.BlastEffect = "simfphys_tankweapon_explosion"

	simfphys.FirePhysProjectile( projectile )
end

local function mg_fire(ply,vehicle,shootOrigin,shootDirection)

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
		projectile.Damage = 18
		projectile.Force = 12

	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 3000, shootOrigin )

	simfphys.FireHitScan( projectile )

end

function simfphys.weapon:ValidClasses()
	return { "avx_t72" }
end

function simfphys.weapon:Initialize( vehicle )
	net.Start( "avx_ins1_register_tank" )
		net.WriteEntity( vehicle )
		net.WriteString( "t72" )
	net.Broadcast()

	self.NSVTClip = self.NSVTClipsize

	vehicle:SetNWBool( "SpecialCam_Loader", true )
	vehicle:SetNWFloat( "SpecialCam_LoaderTime", 3.5 )

	simfphys.RegisterCrosshair( vehicle:GetDriverSeat(), { Attachment = "muzzle_cannon", Type = 4 } )
	simfphys.RegisterCamera( vehicle:GetDriverSeat(), Vector(-175,-30,16), Vector(0,50,110), true, "muzzle_cannon" )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end

	simfphys.RegisterCrosshair( vehicle.pSeat[1] , { Attachment = "muzzle_nsvt", Type = 5 } )
	simfphys.RegisterCamera( vehicle.pSeat[1], Vector(-64,0,16), Vector(0,40,140), true, "muzzle_nsvt" )

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

function simfphys.weapon:AimNSVT( ply, vehicle, pod )
	if not IsValid( pod ) then return end

	local reloading = (not self:CanAttackNSVT(vehicle)) and self.NSVTClip == self.NSVTClipsize
	local Aimang = pod:WorldToLocalAngles( ply:EyeAngles() )
	local AimRate = 150

	local Angles = vehicle:WorldToLocalAngles( Aimang )
	if reloading then
		Angles.p = -75
	end

	vehicle.sm_ppNSVT_yaw = vehicle.sm_ppNSVT_yaw and math.ApproachAngle( vehicle.sm_ppNSVT_yaw, Angles.y, AimRate * FrameTime() ) or 180
	vehicle.sm_ppNSVT_pitch = vehicle.sm_ppNSVT_pitch and math.ApproachAngle( vehicle.sm_ppNSVT_pitch, Angles.p, AimRate * FrameTime() ) or 0

	local TargetAng = Angle(vehicle.sm_ppNSVT_pitch,vehicle.sm_ppNSVT_yaw,0)
	TargetAng:Normalize()

	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw or 180

	vehicle:SetPoseParameter("nsvt_aim_yaw", TargetAng.y - vehicle.sm_pp_yaw )
	vehicle:SetPoseParameter("nsvt_aim_pitch", -TargetAng.p )
end

function simfphys.weapon:AimCannon( ply, vehicle, pod, Attachment )
	if not IsValid( pod ) then return end

	local Aimang = pod:WorldToLocalAngles( ply:EyeAngles() )
	Aimang:Normalize()

	local AimRate = 90

	local Angles = vehicle:WorldToLocalAngles( Aimang )

	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw and math.ApproachAngle( vehicle.sm_pp_yaw, Angles.y, AimRate * FrameTime() ) or 180
	vehicle.sm_pp_pitch = vehicle.sm_pp_pitch and math.ApproachAngle( vehicle.sm_pp_pitch, Angles.p, AimRate * FrameTime() ) or 0

	local TargetAng = Angle(vehicle.sm_pp_pitch,vehicle.sm_pp_yaw,0)
	TargetAng:Normalize()

	vehicle:SetPoseParameter("turret_yaw", TargetAng.y - 180 )
	vehicle:SetPoseParameter("cannon_aim_yaw", TargetAng.y - 180 )

	local pclamp = math.Clamp( (math.cos( math.rad(TargetAng.y) ) - 0.7) * 6,0,1) ^ 2 * 15
	vehicle:SetPoseParameter("cannon_aim_pitch", math.Clamp(-TargetAng.p,-11 + pclamp,20) )
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

function simfphys.weapon:ControlNSVT( vehicle, deltapos )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end

	local pod = vehicle.pSeat[1]

	if not IsValid( pod ) then return end

	local ply = pod:GetDriver()

	if not IsValid( ply ) then return end

	self:AimNSVT( ply, vehicle, pod )

	local ID = vehicle:LookupAttachment( "muzzle_nsvt" )
	local Attachment = vehicle:GetAttachment( ID )

	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()

	local fire = ply:KeyDown( IN_ATTACK )

	if fire then
		self:AttackNSVT( vehicle, ply, shootOrigin, Attachment, ID )
	end

	if ply:KeyDown(IN_RELOAD) and self:CanAttackNSVT( vehicle ) and self.NSVTClip < self.NSVTClipsize then
		self.NSVTClip = self.NSVTClipsize
		vehicle:EmitSound("MG_RELOAD", 75, 75)
		self:SetNextNSVTFire( vehicle, CurTime() + 7 )
	end
end

function simfphys.weapon:AttackNSVT( vehicle, ply, shootOrigin, Attachment, ID )

	if not self:CanAttackNSVT( vehicle ) then return end

	if self.NSVTClip <= 0 then
		self.NSVTClip = self.NSVTClipsize
		vehicle:EmitSound("MG_RELOAD", 75, 75)
		self:SetNextNSVTFire( vehicle, CurTime() + 7 )
		return
	end

	self.NSVTClip = self.NSVTClip - 1

	local effectdata = EffectData()
		effectdata:SetOrigin( shootOrigin )
		effectdata:SetAngles( Attachment.Ang )
		effectdata:SetEntity( vehicle )
		effectdata:SetAttachment( ID )
		effectdata:SetScale( 4 )
	util.Effect( "CS_MuzzleFlash_X", effectdata, true, true )

	local shootDirection = Attachment.Ang:Forward()

	nsvt_fire( ply, vehicle, shootOrigin + shootDirection * 40, shootDirection )

	self:SetNextNSVTFire( vehicle, CurTime() + (60 / 600) )
end

function simfphys.weapon:CanAttack( vehicle )
	vehicle.NextShoot3 = vehicle.NextShoot3 or 0
	return vehicle.NextShoot3 < CurTime()
end

function simfphys.weapon:SetNextFire( vehicle, time )
	vehicle.NextShoot3 = time
end

function simfphys.weapon:CanAttackNSVT( vehicle )
	vehicle.NextShoot4 = vehicle.NextShoot4 or 0
	return vehicle.NextShoot4 < CurTime()
end

function simfphys.weapon:SetNextNSVTFire( vehicle, time )
	vehicle.NextShoot4 = time
end

function simfphys.weapon:PrimaryAttack( vehicle, ply, shootOrigin, Attachment )
	if not self:CanPrimaryAttack( vehicle ) then return end

	local shootDirection = Attachment.Ang:Forward()

	cannon_fire( ply, vehicle, shootOrigin + shootDirection * 80, shootDirection )

	local effectdata = EffectData()
		effectdata:SetEntity( vehicle )
	util.Effect( "arctic_abrams_muzzle", effectdata, true, true )

	self:SetNextPrimaryFire( vehicle, CurTime() + 3.5 )
end

function simfphys.weapon:SecondaryAttack( vehicle, ply, deltapos, cPos, cAng )
	if not self:CanSecondaryAttack( vehicle ) then return end

	local turret = vehicle:LookupBone("turret_yaw")
	local attachment_pos, attachment_ang = vehicle:GetBonePosition(turret)

	local attachment_deltapos,_ = LocalToWorld( Vector(20, 23, -30), Angle(), Vector(0,0,0), attachment_ang )
	attachment_pos = attachment_pos + attachment_deltapos

/*
	local effectdata = EffectData()
		effectdata:SetOrigin( attachment_pos + deltapos )
		effectdata:SetAngles( attachment_ang + Angle(0,90,0) )
		effectdata:SetEntity( vehicle )
		effectdata:SetScale( 2 )
	util.Effect( "CS_MuzzleFlash_X", effectdata, true, true )
*/

	local trace = util.TraceLine( {
		start = cPos,
		endpos = cPos + cAng:Forward() * 50000,
		filter = vehicle.VehicleData["filter"]
	} )

	mg_fire( ply, vehicle, attachment_pos, (trace.HitPos - attachment_pos):GetNormalized() )

	self:SetNextSecondaryFire( vehicle, CurTime() + (60/600) )
end

function simfphys.weapon:CanPrimaryAttack( vehicle )
	vehicle.NextShoot = vehicle.NextShoot or 0
	return vehicle.NextShoot < CurTime()
end

function simfphys.weapon:SetNextPrimaryFire( vehicle, time )
	vehicle.NextShoot = time

	vehicle:SetNWFloat( "SpecialCam_LoaderNext", time )
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
			vehicle.track_snd = CreateSound( vehicle, "simulated_vehicles/sherman/sherman_tracks.wav" )
			vehicle.track_snd:PlayEx(0,0)
			vehicle:CallOnRemove( "stopmesounds", function( veh )
				if veh.track_snd then
					veh.track_snd:Stop()
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
	self:ControlNSVT( vehicle, deltapos )
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

	for i, v in pairs( t72_susdata ) do
		local pos = vehicle:GetAttachment( vehicle:LookupAttachment( t72_susdata[i].attachment ) ).Pos + Up * 10

		local trace = util.TraceHull( {
			start = pos,
			endpos = pos + Up * - 100,
			maxs = Vector(10,10,0),
			mins = -Vector(10,10,0),
			filter = vehicle.filterEntities,
		} )
		local Dist = (pos - trace.HitPos):Length() - 50

		if trace.Hit then
			vehicle.susOnGround = true
		end

		vehicle.oldDist[i] = vehicle.oldDist[i] and (vehicle.oldDist[i] + math.Clamp(Dist - vehicle.oldDist[i],-5,1)) or 0

		vehicle:SetPoseParameter(t72_susdata[i].poseparameter, vehicle.oldDist[i] )
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