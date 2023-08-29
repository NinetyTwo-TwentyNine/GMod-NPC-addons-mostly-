
local function MachineGunFire(ply,vehicle,shootOrigin,Attachment,damage)

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
		projectile.Damage = damage
		projectile.ArmourPiercing = true
		projectile.Force = 12
	
	simfphys.FireHitScan( projectile )
end

function simfphys.weapon:ValidClasses()
	
	local classes = {
		"sim_fphys_v8elite_armed2"
	}
	
	return classes
end

function simfphys.weapon:Initialize( vehicle )
	--vehicle:SetBodygroup(1,1)

	local ID = vehicle:LookupAttachment( "gun_ref" )
	local attachmentdata = vehicle:GetAttachment( ID )

	local prop = ents.Create( "gmod_sent_vehicle_fphysics_attachment" )
	prop:SetModel( "models/blu/tanks/leopard2a7_gib_4.mdl" )			
	prop:SetPos( attachmentdata.Pos + vehicle:GetUp() * -88 + vehicle:GetRight() * -30 + vehicle:GetForward() * 25.5 )
	prop:SetAngles( attachmentdata.Ang + Angle(0,-90,0) )
	prop:SetModelScale( 0.8 ) 
	prop:Spawn()
	prop:Activate()
	prop:SetNotSolid( true )
	prop:SetParent( vehicle, ID )
	prop.DoNotDuplicate = true

	simfphys.RegisterCrosshair( vehicle:GetDriverSeat() )
	
	simfphys.SetOwner( vehicle.EntityOwner, prop )
end

function simfphys.weapon:AimWeapon( ply, vehicle, pod )	
	local Aimang = ply:EyeAngles()
	local AimRate = 250
	
	local Angles = vehicle:WorldToLocalAngles( Aimang ) - Angle(0,90,0)
	
	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw and math.ApproachAngle( vehicle.sm_pp_yaw, Angles.y, AimRate * FrameTime() ) or 0
	vehicle.sm_pp_pitch = vehicle.sm_pp_pitch and math.ApproachAngle( vehicle.sm_pp_pitch, Angles.p, AimRate * FrameTime() ) or 0
	
	local TargetAng = Angle(vehicle.sm_pp_pitch,vehicle.sm_pp_yaw,0)
	TargetAng:Normalize() 
	
	vehicle:SetPoseParameter("vehicle_weapon_yaw", -TargetAng.y )
	vehicle:SetPoseParameter("vehicle_weapon_pitch", -TargetAng.p )
	
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
	
	local ID = vehicle:LookupAttachment( "muzzle" )
	local Attachment = vehicle:GetAttachment( ID )
	
	self:AimWeapon( ply, vehicle, pod )
	
	vehicle.wOldPos = vehicle.wOldPos or Vector(0,0,0)
	local deltapos = vehicle:GetPos() - vehicle.wOldPos
	vehicle.wOldPos = vehicle:GetPos()

	local shootOrigin = Attachment.Pos + vehicle:GetUp()*5 + Attachment.Ang:Forward()*7 + deltapos * engine.TickInterval()

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
	
	/*local effectdata = EffectData()
		effectdata:SetOrigin( shootOrigin )
		effectdata:SetAngles( Attachment.Ang )
		effectdata:SetEntity( vehicle )
		effectdata:SetAttachment( ID )
		effectdata:SetScale( 1 )
	util.Effect( "AirboatMuzzleFlash", effectdata, true, true )*/
	
	MachineGunFire(ply,vehicle,shootOrigin,Attachment,20)
	
	self:SetNextPrimaryFire( vehicle, CurTime() + 0.1 + (vehicle.smTmpMG ^ 5) * 0.05 )
end
