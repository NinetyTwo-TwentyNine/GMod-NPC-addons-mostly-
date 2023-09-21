simfphys.weapon.M2A3Clipsize = 50
simfphys.weapon.MaxRockets = 2

local m2a3_susdata = {}
for i = 1,6 do
	m2a3_susdata[i] = {
		attachment = "sus_left_attach_" .. i,
		poseparameter = "suspension_left_" .. i,
	}

	local ir = i + 6

	m2a3_susdata[ir] = {
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
		projectile.Damage = 80
		projectile.Force = 50
		projectile.Size = 2
		projectile.BlastRadius = 100
		projectile.BlastDamage = 75
		projectile.BlastEffect = "simfphys_tankweapon_explosion_micro"

	simfphys.FirePhysProjectile( projectile )
end

local function atgm_fire(ply,vehicle,shootOrigin,shootDirection)
	vehicle:EmitSound("weapons/stinger_fire1.wav", 125)
	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 450000, shootOrigin )

	local missile = ents.Create( "arctic_avx_atgm" )
	missile:SetPos( shootOrigin )
	missile:SetAngles( shootDirection:Angle() )
	missile:SetOwner( ply )
	missile:Spawn()
	missile:Activate()
	missile.DirVector = shootDirection
	missile.DefaultSpeed = 5000
	missile.UnlockTime = CurTime() + 1.25

	missile:GetPhysicsObject():SetVelocity(shootDirection * missile.DefaultSpeed * 2)

	table.insert(vehicle.MissileTracking, missile)

	vehicle.Rockets = vehicle.Rockets - 1

	local tName = "Reload_timer#"..vehicle:EntIndex()
	if timer.Exists(tName) then return end

	vehicle:EmitSound("simulated_vehicles/weapons/tiger_reload.wav", 70, math.random(90, 110), 1, CHAN_BODY)
	timer.Create(tName, 5, 0, function()
		if !IsValid(vehicle) then timer.Remove(tName) return end
		vehicle.Rockets = vehicle.Rockets + 1
		if vehicle.Rockets >= 2 then timer.Remove(tName) return end
		vehicle:EmitSound("simulated_vehicles/weapons/tiger_reload.wav", 70, math.random(90, 110), 1, CHAN_BODY)
	end)
end

function simfphys.weapon:ValidClasses()
	return { "avx_m2a3" }
end

function simfphys.weapon:Initialize( vehicle )
	net.Start( "avx_ins1_register_tank" )
		net.WriteEntity( vehicle )
		net.WriteString( "m2a3" )
	net.Broadcast()

	self.M2A3Clip = self.M2A3Clipsize
	vehicle:SetNWBool( "TurretSafeMode", false )

	vehicle.Rockets = self.MaxRockets
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
	simfphys.RegisterCamera( vehicle:GetDriverSeat(), Vector(0,-20,75), Vector(0,0,110), true, "muzzle_cannon" )
	
	simfphys.RegisterCamera( vehicle.pSeat[1], Vector(0,60,80), Vector(0,60,80),  true)
	simfphys.RegisterCamera( vehicle.pSeat[2], Vector(0,60,80), Vector(0,60,80),  true)
	simfphys.RegisterCamera( vehicle.pSeat[3], Vector(0,60,80), Vector(0,60,80),  true)
	simfphys.RegisterCamera( vehicle.pSeat[4], Vector(0,60,80), Vector(0,60,80),  true)
	simfphys.RegisterCamera( vehicle.pSeat[5], Vector(0,60,80), Vector(0,60,80),  true)
	simfphys.RegisterCamera( vehicle.pSeat[6], Vector(0,60,80), Vector(0,60,80),  true)
	simfphys.RegisterCamera( vehicle.pSeat[7], Vector(0,60,80), Vector(0,60,80),  true)

	vehicle:SetPoseParameter("cannon_aim_pitch", 75 )
	
	---звук поворота башни
	vehicle.TurretHorizontal = CreateSound(vehicle,"turret1/cannon_turn_loop_1.wav")
	vehicle.TurretHorizontal:SetSoundLevel(100)
	vehicle.TurretHorizontal:Play()
	vehicle:CallOnRemove("stopmgsounds",function(vehicle)
		vehicle.TurretHorizontal:Stop()		
	end)
	---

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

	local AimRate = 50

	local Angles = vehicle:WorldToLocalAngles( Aimang )
	
	---звуки
	local v = math.abs((math.Round(Angles.y,1) - (vehicle.sm_pp_yaw and math.Round(vehicle.sm_pp_yaw,1) or 0)))
	vehicle.VAL_TurretHorizontal = (v <= 0.5 or (v >= 359.7 and v <= 360)) and 0 or 1	
	local ft = FrameTime()
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
	
	---звуки башни
	vehicle.VAL_TurretHorizontal = vehicle.VAL_TurretHorizontal or 0
	vehicle.TurretHorizontal:ChangePitch(vehicle.VAL_TurretHorizontal*100,0.5)
	vehicle.TurretHorizontal:ChangeVolume(vehicle.VAL_TurretHorizontal,0.5)
	
	vehicle.VAL_TurretHorizontal = 0
	---
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

	if ply:KeyDown( IN_RELOAD ) and self.M2A3Clip < self.M2A3Clipsize and self:CanPrimaryAttack(vehicle) then
		self.M2A3Clip = self.M2A3Clipsize
		vehicle:EmitSound("t90ms_reload", 75, 75)
		self:SetNextPrimaryFire( vehicle, CurTime() + 4.5 )
	end
end

function simfphys.weapon:PrimaryAttack( vehicle, ply, shootOrigin, Attachment )
	if not self:CanPrimaryAttack( vehicle ) then return end
	
	if self.M2A3Clip <= 0 then
		self.M2A3Clip = self.M2A3Clipsize
		vehicle:EmitSound("t90ms_reload", 75, 75)
		self:SetNextPrimaryFire( vehicle, CurTime() + 4.5 )
		return
	end

	self.M2A3Clip = self.M2A3Clip - 1

	local shootDirection = -Attachment.Ang:Up()

	cannon_fire( ply, vehicle, shootOrigin + shootDirection * 80, shootDirection )

	local effectdata = EffectData()
		effectdata:SetEntity( vehicle )
	util.Effect( "arctic_m2a3_muzzle", effectdata, true, true )

	self:SetNextPrimaryFire( vehicle, CurTime() + 0.35 )
end

function simfphys.weapon:SecondaryAttack( vehicle, ply, shootOrigin, Attachment )
	if not self:CanSecondaryAttack( vehicle ) then return end

	local shootDirection = -Attachment.Ang:Right()

	atgm_fire( ply, vehicle, shootOrigin + shootDirection * 80, shootDirection )

	if vehicle.Rockets <= 0 then
		self:SetNextSecondaryFire( vehicle, CurTime() + 5 )
	else
		self:SetNextSecondaryFire( vehicle, CurTime() + 1 )
	end
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
	return (vehicle.NextShoot2 < CurTime()) && (vehicle.Rockets > 0) && (table.Count(vehicle.MissileTracking) < self.MaxRockets)
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
			vehicle.track_snd = CreateSound( vehicle, "simulated_vehicles/sherman/tracks.wav" )
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
local trackss
	local gear = vehicle:GetGear()
    local mass = vehicle:GetPhysicsObject():GetMass()
    local TrackTurnRate = 40
    local TrackMultRate = 250
    local AntiFrictionRate = 0.1
    trackss= CreateSound( vehicle, "simulated_vehicles/sherman/tracks.wav")
	if vehicle:EngineActive() and gear == 2 and vehicle.PressedKeys["A"] == true and vehicle.susOnGround == true then
        if vehicle:GetPhysicsObject():GetAngleVelocity().z <= TrackTurnRate then
            vehicle:GetPhysicsObject():ApplyTorqueCenter( Vector(0,0, mass * TrackMultRate ))
            vehicle:GetPhysicsObject():ApplyForceCenter( Vector( 0,0, mass * AntiFrictionRate ))
			trackss:Play()
			trackss:ChangePitch( math.Clamp(50+TrackTurnRate / 80,0,150) ) 
			trackss:ChangeVolume( math.min( math.max(222 - 20,0) / 600,1) ) 
			vehicle:CallOnRemove( "stopmesounds", function( vehicle )
				if trackss then
					trackss:Stop()
				end
			end)
        end
    elseif vehicle:EngineActive() and gear == 2 and vehicle.PressedKeys["A"] == false and vehicle.susOnGround == false then
		trackss:Stop()
    end
    if vehicle:EngineActive() and gear == 2 and vehicle.PressedKeys["D"] == true and vehicle.susOnGround == true then
        if math.abs(vehicle:GetPhysicsObject():GetAngleVelocity().z) <= TrackTurnRate then
            vehicle:GetPhysicsObject():ApplyTorqueCenter( Vector(0,0, -mass * TrackMultRate  ))
            vehicle:GetPhysicsObject():ApplyForceCenter( Vector( 0,0, mass * AntiFrictionRate ))
			trackss:Play()
			trackss:ChangePitch( math.Clamp(50+TrackTurnRate / 80,0,150) ) 
			trackss:ChangeVolume( math.min( math.max(222 - 20,0) / 600,1) ) 
			vehicle:CallOnRemove( "stopmesounds", function( vehicle )
				if trackss then
					trackss:Stop()
				end
			end)
        end
    elseif vehicle:EngineActive() and gear == 2 and vehicle.PressedKeys["D"] == false and vehicle.susOnGround == false then
		trackss:Stop()
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

	for i, v in pairs( m2a3_susdata ) do
		local pos = vehicle:GetAttachment( vehicle:LookupAttachment( m2a3_susdata[i].attachment ) ).Pos + Up * 10

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

		vehicle:SetPoseParameter(m2a3_susdata[i].poseparameter, vehicle.oldDist[i] )
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