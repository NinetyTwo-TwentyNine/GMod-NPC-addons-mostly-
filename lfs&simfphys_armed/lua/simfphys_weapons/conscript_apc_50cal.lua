
local function MachineGunFire(ply,vehicle,shootOrigin,Attachment)

	vehicle:EmitSound("sherman_fire_mg", 120)

	local projectile = {}
		projectile.filter = vehicle.VehicleData["filter"]
		projectile.shootOrigin = shootOrigin
		projectile.shootDirection = Attachment.Ang:Forward()
		projectile.attacker = ply
		projectile.Tracer	= 1
		projectile.HullSize = 5
		projectile.attackingent = vehicle
		projectile.Spread = Vector(0.008,0.008,0.008)
		projectile.Damage = 20
		projectile.ArmourPiercing = true
		projectile.Force = 12
	
	simfphys.FireHitScan( projectile )
end

function simfphys.weapon:ValidClasses()
	
	local classes = {
		"sim_fphys_conscriptapc_armed2"
	}
	
	return classes
end

function simfphys.weapon:Initialize( vehicle )
	local data = {}
	data.Attachment = "muzzle_left"
	data.Direction = Vector(1,0,0)

	simfphys.RegisterCrosshair( vehicle:GetDriverSeat(), data )
	simfphys.RegisterCamera( vehicle:GetDriverSeat(), Vector(13,45,50), Vector(13,45,50), true )
	
	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end
	
	for i = 2, table.Count( vehicle.pSeat ) do
		simfphys.RegisterCamera( vehicle.pSeat[ i ], Vector(0,0,60), Vector(0,0,60) )
	end


	vehicle:ManipulateBoneScale(vehicle:LookupBone("turret_pitch"), Vector(0,0,0))
	vehicle:ManipulateBoneScale(vehicle:LookupBone("turret_yaw"), Vector(0,0,0))

	local ID = vehicle:LookupAttachment( "muzzle_left" )
	local attachmentdata = vehicle:GetAttachment( ID )

	local prop = ents.Create( "gmod_sent_vehicle_fphysics_attachment" )
	prop:SetModel( "models/blu/tanks/leopard2a7_gib_4.mdl" )			
	prop:SetPos( attachmentdata.Pos + vehicle:GetUp() * -115 + vehicle:GetForward() * 25 + vehicle:GetRight() * 10 )
	prop:SetAngles( attachmentdata.Ang + Angle(0,-90,-90) )
	prop:SetModelScale( 1.0 ) 
	prop:Spawn()
	prop:Activate()
	prop:SetNotSolid( true )
	prop:SetParent( vehicle, ID )
	prop.DoNotDuplicate = true
end

function simfphys.weapon:AimWeapon( ply, vehicle, pod )	
	local Aimang = pod:WorldToLocalAngles( ply:EyeAngles() )
	local AimRate = 200
	
	local Angles = vehicle:WorldToLocalAngles( Aimang ) - Angle(0,90,0)
	
	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw and math.ApproachAngle( vehicle.sm_pp_yaw, Angles.y, AimRate * FrameTime() ) or 0
	vehicle.sm_pp_pitch = vehicle.sm_pp_pitch and math.ApproachAngle( vehicle.sm_pp_pitch, Angles.p, AimRate * FrameTime() ) or 0
	vehicle.sm_pp_pitch = ( (vehicle.sm_pp_pitch > -20) and vehicle.sm_pp_pitch ) or -20
	
	local TargetAng = Angle(vehicle.sm_pp_pitch,vehicle.sm_pp_yaw,0)
	TargetAng:Normalize() 
	
	vehicle:SetPoseParameter("turret_yaw", TargetAng.y )
	vehicle:SetPoseParameter("turret_pitch", -TargetAng.p )
	
	return Aimang
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
	
	local ID = vehicle:LookupAttachment( "muzzle_left" )
	local Attachment = vehicle:GetAttachment( ID )
	
	self:AimWeapon( ply, vehicle, pod )
	
	vehicle.wOldPos = vehicle.wOldPos or Vector(0,0,0)
	local deltapos = vehicle:GetPos() - vehicle.wOldPos
	vehicle.wOldPos = vehicle:GetPos()

	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()

	local fire = ply:KeyDown( IN_ATTACK )
	
	local Rate = FrameTime() / 5
	vehicle.smTmpMG = vehicle.smTmpMG and vehicle.smTmpMG + math.Clamp((fire and 1 or 0) - vehicle.smTmpMG,-Rate * 6,Rate) or 0
	
	if fire then
		self:PrimaryAttack( vehicle, ply, shootOrigin, Attachment, ID )
	end
	
	vehicle.OldFire = vehicle.OldFire or false
	if vehicle.OldFire ~= fire then
		vehicle.OldFire = fire
	end
end

function simfphys.weapon:CanPrimaryAttack( vehicle )
	vehicle.NextShoot = vehicle.NextShoot or 0
	return vehicle.NextShoot < CurTime()
end

function simfphys.weapon:SetNextPrimaryFire( vehicle, time )
	vehicle.NextShoot = time
end

function simfphys.weapon:PrimaryAttack( vehicle, ply, shootOrigin, Attachment, ID )
	if not self:CanPrimaryAttack( vehicle ) then return end
	
	local effectdata = EffectData()
		effectdata:SetOrigin( shootOrigin )
		effectdata:SetAngles( Attachment.Ang )
		effectdata:SetEntity( vehicle )
		effectdata:SetAttachment( ID )
		effectdata:SetScale( 4 )
	util.Effect( "CS_MuzzleFlash", effectdata, true, true )
	
	MachineGunFire(ply,vehicle,shootOrigin,Attachment)
	
	self:SetNextPrimaryFire( vehicle, CurTime() + 0.1 + (vehicle.smTmpMG ^ 5) * 0.05 )
end
