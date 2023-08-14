simfphys.weapon.BMP2Clipsize = 25
simfphys.weapon.MaxMissiles = 1

local bmp2_susdata = {}
for i = 1,6 do
	bmp2_susdata[i] = {
		attachment = "sus_left_attach_" .. i,
		poseparameter = "suspension_left_" .. i,
	}

	local ir = i + 6

	bmp2_susdata[ir] = {
		attachment = "sus_right_attach_" .. i,
		poseparameter = "suspension_right_" .. i,
	}
end

local function cannon_fire(ply,vehicle,shootOrigin,shootDirection)
	vehicle:EmitSound("apc_fire", 130)

	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 250000, shootOrigin )

	local projectile = {}
		projectile.filter = vehicle.VehicleData["filter"]
		projectile.shootOrigin = shootOrigin - (shootDirection * 100)
		projectile.shootDirection = shootDirection + (VectorRand() * 0.003)
		projectile.attacker = ply
		projectile.attackingent = vehicle
		//projectile.ArmourPiercing = true
		projectile.Damage = 40
		projectile.Force = 50
		projectile.Size = 2
		projectile.BlastRadius = 100
		projectile.BlastDamage = 60
		projectile.BlastEffect = "simfphys_tankweapon_explosion_micro"

	simfphys.FirePhysProjectile( projectile )
end

local function atgm_fire(ply,vehicle,shootOrigin,shootDirection)
	vehicle:EmitSound("weapons/stinger_fire1.wav", 125)
	vehicle:EmitSound("simulated_vehicles/weapons/tiger_reload.wav", 70, math.random(90, 110), 1, CHAN_BODY)

	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 300000, shootOrigin )

	local missile = ents.Create( "arctic_avx_atgm" )
	missile:SetPos( shootOrigin )
	missile:SetAngles( shootDirection:Angle() )
	missile:SetOwner( ply )
	missile:Spawn()
	missile:Activate()
	missile.DirVector = shootDirection
	missile.DefaultSpeed = 3750
	missile.UnlockTime = CurTime() + 1.5

	missile:GetPhysicsObject():SetVelocity(shootDirection * missile.DefaultSpeed * 2)

	table.insert(vehicle.MissileTracking, missile)
end

function simfphys.weapon:ValidClasses()
	return { "avx_bmp2" }
end

function simfphys.weapon:Initialize( vehicle )
	net.Start( "avx_ins1_register_tank" )
		net.WriteEntity( vehicle )
		net.WriteString( "bmp2" )
	net.Broadcast()

	self.BMP2Clip = self.BMP2Clipsize
	vehicle.MissileTracking = {}
	vehicle:CallOnRemove("LaunchMissilesStraight"..vehicle:EntIndex(), function()
		for _,missile in pairs(vehicle.MissileTracking) do
			if !IsValid(missile) then continue end

			local phys = missile:GetPhysicsObject()
			local vel = missile:GetAngles():Forward() * missile.DefaultSpeed * 2
			phys:SetVelocity( vel )
		end
		table.Empty(vehicle.MissileTracking)
	end)

	simfphys.RegisterCrosshair( vehicle:GetDriverSeat(), { Attachment = "muzzle_cannon", Direction = Vector(0, 0, -1), Type = 4 } )
	simfphys.RegisterCamera( vehicle:GetDriverSeat(), Vector(0,-20,75), Vector(0,50,110), true, "muzzle_cannon" )

	vehicle:SetPoseParameter("cannon_aim_pitch", 75 )

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

function simfphys.weapon:AimCannon( ply, vehicle, pod, Attachment )
	if not IsValid( pod ) then return end

	local Aimang = pod:WorldToLocalAngles( ply:EyeAngles() )
	Aimang:Normalize()

	local AimRate = 120

	local Angles = vehicle:WorldToLocalAngles( Aimang )

	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw and math.ApproachAngle( vehicle.sm_pp_yaw, Angles.y, AimRate * FrameTime() ) or 0
	vehicle.sm_pp_pitch = vehicle.sm_pp_pitch and math.ApproachAngle( vehicle.sm_pp_pitch, -Angles.p, AimRate * FrameTime() ) or 0

	local TargetAng = Angle(vehicle.sm_pp_pitch,vehicle.sm_pp_yaw,0)
	TargetAng:Normalize()

	vehicle:SetPoseParameter("turret_yaw", TargetAng.y )
	vehicle:SetPoseParameter("cannon_aim_yaw", TargetAng.y )
	vehicle:SetPoseParameter("cannon_aim_pitch", -TargetAng.p + 70 )
end

function simfphys.weapon:ControlTurret( vehicle, deltapos )
	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end

	local pod = vehicle:GetDriverSeat()

	if not IsValid( pod ) then return end

	local ply = pod:GetDriver()

	if not IsValid( ply ) then return end

	local ID = vehicle:LookupAttachment( "muzzle_cannon" )
	local Attachment = vehicle:GetAttachment( ID )

	self:AimCannon( ply, vehicle, pod, Attachment )

	local DeltaP = deltapos * engine.TickInterval()

	local fire = ply:KeyDown( IN_ATTACK )
	local fire2 = ply:KeyDown( IN_ATTACK2 )

	if fire then
		self:PrimaryAttack( vehicle, ply, Attachment.Pos + DeltaP, Attachment )
	end

	local ID2 = vehicle:LookupAttachment( "muzzle_missile" )
	local Attachment2 = vehicle:GetAttachment( ID2 )

	if fire2 then
		self:SecondaryAttack( vehicle, ply, Attachment2.Pos + DeltaP, Attachment2 )
	end

	if ply:KeyDown( IN_RELOAD ) and self.BMP2Clip < self.BMP2Clipsize and self:CanPrimaryAttack(vehicle) then
		self.BMP2Clip = self.BMP2Clipsize
		vehicle:EmitSound("t90ms_reload", 75, 75)
		self:SetNextPrimaryFire( vehicle, CurTime() + 4.5 )
	end
end

function simfphys.weapon:PrimaryAttack( vehicle, ply, shootOrigin, Attachment )
	if not self:CanPrimaryAttack( vehicle ) then return end

	if self.BMP2Clip <= 0 then
		self.BMP2Clip = self.BMP2Clipsize
		vehicle:EmitSound("t90ms_reload", 75, 75)
		self:SetNextPrimaryFire( vehicle, CurTime() + 4.5 )
		return
	end

	self.BMP2Clip = self.BMP2Clip - 1

	local shootDirection = -Attachment.Ang:Up()

	cannon_fire( ply, vehicle, shootOrigin + shootDirection * 80, shootDirection )

	local effectdata = EffectData()
		effectdata:SetEntity( vehicle )
	util.Effect( "arctic_bmp2_muzzle", effectdata, true, true )

	self:SetNextPrimaryFire( vehicle, CurTime() + (0.12) )
end

function simfphys.weapon:SecondaryAttack( vehicle, ply, shootOrigin, Attachment )
	if not self:CanSecondaryAttack( vehicle ) then return end

	local shootDirection = -Attachment.Ang:Right()

	atgm_fire( ply, vehicle, shootOrigin + shootDirection * 80, shootDirection )

	self:SetNextSecondaryFire( vehicle, CurTime() + 7.5 )
end

function simfphys.weapon:CanPrimaryAttack( vehicle )
	vehicle.NextShoot = vehicle.NextShoot or 0
	return vehicle.NextShoot < CurTime()
end

function simfphys.weapon:SetNextPrimaryFire( vehicle, time )
	vehicle.NextShoot = time
end

function simfphys.weapon:CanSecondaryAttack( vehicle )
	vehicle.NextShoot2 = vehicle.NextShoot2 or 0
	return (vehicle.NextShoot2 < CurTime()) && (table.Count(vehicle.MissileTracking) < self.MaxMissiles)
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
	self:ControlTrackSounds( vehicle, handbrake )
	self:ModPhysics( vehicle, handbrake )

	local ID = vehicle:LookupAttachment( "muzzle_cannon" )
	local Attachment = vehicle:GetAttachment( ID )

	local filter = table.Copy(vehicle.MissileTracking or {})
	table.Add(filter, {vehicle})

	local tr = util.TraceLine( {
		start = Attachment.Pos,
		endpos = Attachment.Pos + -Attachment.Ang:Up() * 100000,
		filter = filter
	} )
	local Aimpos = tr.HitPos

	local remove = {}
	for i, missile in pairs(vehicle.MissileTracking or {}) do
		if IsValid( missile ) then
			if missile.UnlockTime < CurTime() then
				missile:GetPhysicsObject():SetVelocity(missile.DirVector * missile.DefaultSpeed * 2)
				table.insert(remove, i)
				continue
			end

			local targetdir = Aimpos - missile:GetPos()
			targetdir:Normalize()
			missile.DirVector = missile.DirVector + (targetdir - missile.DirVector) * 0.1

			local vel = -missile:GetVelocity() + missile.DirVector * missile.DefaultSpeed

			local phys = missile:GetPhysicsObject()

			phys:SetVelocity( vel )
			missile:SetAngles( missile.DirVector:Angle() )
		else
			table.insert(remove, i)
		end
	end

	for k, i in pairs(remove) do
		table.remove(vehicle.MissileTracking, i)
	end
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

	for i, v in pairs( bmp2_susdata ) do
		local pos = vehicle:GetAttachment( vehicle:LookupAttachment( bmp2_susdata[i].attachment ) ).Pos + Up * 10

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

		vehicle:SetPoseParameter(bmp2_susdata[i].poseparameter, vehicle.oldDist[i] )
	end
end

function simfphys.weapon:DoWheelSpin( vehicle )
	local spin_r = (vehicle.VehicleData[ "spin_4" ] + vehicle.VehicleData[ "spin_6" ]) * -1.25
	local spin_l = (vehicle.VehicleData[ "spin_3" ] + vehicle.VehicleData[ "spin_5" ]) * -1.25

	net.Start( "simfphys_update_tracks", true )
		net.WriteEntity( vehicle )
		net.WriteFloat( spin_r )
		net.WriteFloat( spin_l )
	net.Broadcast()

	vehicle:SetPoseParameter("spin_wheels_right", spin_r)
	vehicle:SetPoseParameter("spin_wheels_left", spin_l )
end