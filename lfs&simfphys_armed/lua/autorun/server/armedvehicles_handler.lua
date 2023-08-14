-- DO NOT EDIT OR REUPLOAD THIS SCRIPT

resource.AddWorkshop("831680603")

simfphys = istable( simfphys ) and simfphys or {}

simfphys.ManagedVehicles = istable( simfphys.ManagedVehicles ) and simfphys.ManagedVehicles or {}
simfphys.Weapons = {}
simfphys.weapon = {}

util.AddNetworkString( "simfphys_tank_do_effect" ) -- some people still use this so we have to keep it
util.AddNetworkString( "simfphys_update_tracks" )

--resource.AddSingleFile( "materials/effects/simfphys_armed/gauss_beam.vmt" )
--resource.AddSingleFile( "materials/effects/simfphys_armed/gauss_beam.vtf" )
--resource.AddSingleFile( "materials/effects/simfphys_armed/spark.vmt" )
--resource.AddSingleFile( "materials/effects/simfphys_armed/spark.vtf" )
--resource.AddSingleFile( "materials/effects/simfphys_armed/spark_brightness.vtf" )

local ImpactSounds = {
	"physics/metal/metal_sheet_impact_bullet2.wav",
	"physics/metal/metal_sheet_impact_hard2.wav",
	"physics/metal/metal_sheet_impact_hard6.wav",
}

sound.Add( {
	name = "apc_fire",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 110,
	pitch = { 90, 110 },
	sound = "^simulated_vehicles/weapons/apc_fire.wav"
} )

sound.Add( {
	name = "tiger_fire",
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 140,
	pitch = { 90, 110 },
	sound = "^simulated_vehicles/weapons/tiger_cannon.wav"
} )

sound.Add( {
	name = "leopard_fire",
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 140,
	pitch = { 90, 110 },
	sound = "^simulated_vehicles/weapons/leopard_cannon.wav"
} )

sound.Add( {
	name = "leopard_fire_mg",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 110,
	pitch = { 90, 100 },
	sound = {"^simulated_vehicles/weapons/leopard_mg1.wav","^simulated_vehicles/weapons/leopard_mg2.wav","^simulated_vehicles/weapons/leopard_mg3.wav"}
} )

sound.Add( {
	name = "t90ms_fire",
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 140,
	pitch = { 90, 110 },
	sound = "^simulated_vehicles/weapons/t90ms_cannon.wav"
} )

sound.Add( {
	name = "tiger_fire_mg",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 110,
	pitch = { 90, 110 },
	sound = "^simulated_vehicles/weapons/tiger_mg.wav"
} )

sound.Add( {
	name = "tiger_fire_mg_new",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 110,
	pitch = { 90, 110 },
	sound = {"^simulated_vehicles/weapons/tiger_mg1.wav","^simulated_vehicles/weapons/tiger_mg2.wav","^simulated_vehicles/weapons/tiger_mg3.wav"}
} )

sound.Add( {
	name = "tiger_reload",
	channel = CHAN_STREAM,
	volume = 1.0,
	level = 70,
	pitch = { 90, 110 },
	sound = "simulated_vehicles/weapons/tiger_reload.wav"
} )

sound.Add( {
	name = "sherman_fire",
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 140,
	pitch = { 90, 110 },
	sound = "^simulated_vehicles/weapons/sherman_cannon.wav"
} )

sound.Add( {
	name = "sherman_fire_mg",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 110,
	pitch = { 90, 110 },
	sound = "^simulated_vehicles/weapons/sherman_mg.wav"
} )

sound.Add( {
	name = "sherman_reload",
	channel = CHAN_STREAM,
	volume = 1.0,
	level = 70,
	pitch = { 90, 110 },
	sound = "simulated_vehicles/weapons/sherman_reload.wav"
} )

sound.Add( {
	name = "t90ms_reload",
	channel = CHAN_STREAM,
	volume = 1.0,
	level = 70,
	pitch = { 90, 110 },
	sound = "simulated_vehicles/weapons/t90ms_reload.wav"
} )

sound.Add( {
	name = "taucannon_fire",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 80,
	pitch = { 95, 105 },
	sound = "weapons/gauss/fire1.wav"
} )

-- seriously guys, you are not supposed to copy this script. I had to create this workaround because people keep stealing the entire code.
function simfphys.FireHitScan( data )
	simfphys.FireBullet( data )
end

function simfphys.FirePhysProjectile( data )
	simfphys.FirePhysBullet( data )
end

function simfphys.RegisterCrosshair( ent, data )
	simfphys.xhairRegister( ent, data )
end

function simfphys.RegisterCamera( ent, offset_firstperson, offset_thirdperson, bLocalAng, attachment )
	simfphys.CameraRegister( ent, offset_firstperson, offset_thirdperson, bLocalAng, attachment )
end

function simfphys.armedAutoRegister( vehicle )
	simfphys.WeaponSystemRegister( vehicle )
	
	return true
end

function simfphys.CameraRegister( ent, offset_firstperson, offset_thirdperson, bLocalAng, attachment )
	if not IsValid( ent ) then return end
	
	offset_firstperson = isvector( offset_firstperson ) and offset_firstperson or Vector(0,0,0)
	offset_thirdperson = isvector( offset_thirdperson ) and offset_thirdperson or Vector(0,0,0)
	
	ent:SetNWBool( "simfphys_SpecialCam", true )
	ent:SetNWBool( "SpecialCam_LocalAngles",  bLocalAng or false )
	ent:SetNWVector( "SpecialCam_Firstperson", offset_firstperson )
	ent:SetNWVector( "SpecialCam_Thirdperson", offset_thirdperson )
	
	if isstring( attachment ) then 
		ent:SetNWString( "SpecialCam_Attachment", attachment )
	end
end

function simfphys.FirePhysBullet( data )
	if not data then return end
	if not istable( data.filter ) then return end
	if not isvector( data.shootOrigin ) then return end
	if not isvector( data.shootDirection ) then return end
	if not IsValid( data.attacker ) then return end
	if not IsValid( data.attackingent ) then return end
	if not isnumber( data.DeflectAng ) then data.DeflectAng = 25 end
	if not data.ArmourPiercing then data.ArmourPiercing = false end
	
	local projectile = ents.Create( "simfphys_tankprojectile" )
	projectile:SetPos( data.shootOrigin )
	projectile:SetAngles( data.shootDirection:Angle() )
	projectile:SetOwner( data.attackingent )
	projectile.Attacker = data.attacker
	projectile.DeflectAng = data.DeflectAng
	projectile.AttackingEnt = data.attackingent 
	projectile.ArmourPiercing = data.ArmourPiercing
	projectile.Force = data.Force and data.Force or 100
	projectile.Damage = data.Damage and data.Damage or 100
	projectile.BlastRadius = data.BlastRadius and data.BlastRadius or 200
	projectile.BlastDamage = data.BlastDamage and data.BlastDamage or 50
	projectile:SetBlastEffect( isstring( data.BlastEffect ) and data.BlastEffect or "simfphys_tankweapon_explosion" )
	projectile:SetSize( data.Size and data.Size or 1 )
	projectile.Filter = table.Copy( data.filter )
	projectile:Spawn()
	projectile:Activate()
end

function simfphys.FireBullet( data )
	if not data then return end
	if not istable( data.filter ) then return end
	if not isvector( data.shootOrigin ) then return end
	if not isvector( data.shootDirection ) then return end
	if not IsValid( data.attacker ) then return end
	if not IsValid( data.attackingent ) then return end
	
	data.Spread = data.Spread or Vector(0,0,0)
	data.Tracer = data.Tracer or 0
	data.HullSize = data.HullSize or 1

	local shouldPierceArmour = data.ArmourPiercing or false
	
	local trace = util.TraceHull( {
		start = data.shootOrigin,
		endpos = data.shootOrigin + (data.shootDirection + Vector(math.Rand(-data.Spread.x,data.Spread.x),math.Rand(-data.Spread.y,data.Spread.y),math.Rand(-data.Spread.x,data.Spread.x)) )* 50000,
		filter = data.filter,
		maxs = data.HullSize,
		mins = -data.HullSize
	} )
	
	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= trace.HitPos - data.shootDirection * 5
	bullet.Dir 			= data.shootDirection
	bullet.Spread 		= Vector(0,0,0)
	bullet.TracerName	= "simfphys_tracer_hit"
	bullet.Tracer		= 1
	bullet.Force		= (data.Force and data.Force or 1)
	bullet.Damage		= (data.Damage and data.Damage or 1)
	bullet.HullSize		= data.HullSize
	bullet.Attacker 		= data.attacker
	bullet.Callback = function(att, tr, dmginfo)
		if shouldPierceArmour then
			dmginfo:SetDamageType( DMG_DIRECT + DMG_BULLET )
		else
			dmginfo:SetDamageType( DMG_BULLET )
		end

		if tr.Entity ~= Entity(0) then
			if simfphys.IsCar( tr.Entity ) then
				sound.Play( Sound( ImpactSounds[ math.random(1,table.Count( ImpactSounds )) ] ), tr.HitPos, SNDLVL_90dB)
			end
		end
	end
	data.attackingent:FireBullets( bullet )
	
	data.attackingent.hScanTracer = data.attackingent.hScanTracer and (data.attackingent.hScanTracer + 1) or 0
	
	if data.Tracer > 0 then
		if data.attackingent.hScanTracer >= data.Tracer then 
			data.attackingent.hScanTracer = 0
			
			local effectdata = EffectData()
			effectdata:SetStart( data.shootOrigin ) 
			effectdata:SetOrigin( trace.HitPos )
			util.Effect( "simfphys_tracer", effectdata )
		end
	end
end

function simfphys.xhairRegister( ent, data )
	if not IsValid( ent ) then return end
	
	local data = istable( data ) and data or {}
	
	local Base = data.Attachment or "muzzle"
	local Dir = data.Direction or Vector(1,0,0)
	local Type = data.Type and data.Type or 0
	
	ent:SetNWInt( "CrosshairType", Type )
	ent:SetNWBool( "HasCrosshair", true )
	ent:SetNWString( "Attachment", Base )
	ent:SetNWVector( "Direction", Dir )
	
	if data.Attach_Start_Left and data.Attach_Start_Right then
		ent:SetNWBool( "CalcCenterPos", true )
		ent:SetNWString( "Start_Left", data.Attach_Start_Left )
		ent:SetNWString( "Start_Right", data.Attach_Start_Right )
	end
end

function simfphys.WeaponSystemRegister( vehicle )
	if not IsValid( vehicle ) then return end
	
	simfphys.Weapons = istable( simfphys.Weapons ) and table.Empty( simfphys.Weapons ) or {}
	
	for k,v in pairs( file.Find("simfphys_weapons/*.lua", "LUA") ) do
		local name = string.Explode( ".", v )[1]
		
		table.Empty( simfphys.weapon )
		
		include("simfphys_weapons/"..v)
		
		simfphys.Weapons[ name ] = table.Copy( simfphys.weapon )
	end
	
	local class = vehicle:GetSpawn_List()
	
	for wpnname,tbldata in pairs( simfphys.Weapons ) do
		for _,v in pairs( tbldata.ValidClasses() ) do
			if class == v then
				local data = {}
				data.entity = vehicle
				data.func = tbldata

				table.insert(simfphys.ManagedVehicles, data)

				tbldata.Initialize( tbldata, vehicle )
			end
		end
	end
end

local DMG_PROPEXPLOSION = 134217792 -- should use CTakeDamageInfo:IsDamageType( number dmgType ) at some point
local DMG_LUABULLET = 8194

local ExceptionDMGTypes = {
	DMG_LUABULLET,
	DMG_BULLET,
}

local ValidDMGTypes = {
	DMG_PROPEXPLOSION,
	DMG_AIRBOAT,
	DMG_BLAST,
	DMG_BLAST_SURFACE,
	DMG_ENERGYBEAM,
	DMG_SHOCK,
	DMG_SONIC,
	DMG_CRUSH,
	DMG_GENERIC,
	DMG_DIRECT,
	DMG_SLOWBURN,
	DMG_BURN,
	DMG_NEVERGIB,
	DMG_ALWAYSGIB,
	DMG_SNIPER,
	DMG_CLUB,
	DMG_MISSILEDEFENSE,
}

local function DMGContainsTypeFromTable(dmgType, dmgTable)
	if !isnumber(dmgType) or !istable(dmgTable) then return false end

	local final_dmgType = 0
	for k,v in pairs(dmgTable) do
		final_dmgType = bit.bor(final_dmgType, v)
	end

	if bit.band(dmgType, final_dmgType) != 0 then
		return true
	else
		return false
	end
end
	
local VEHICLE_TYPE_APC = 1
local VEHICLE_TYPE_TANK = 2

function simfphys.ArmouredVehicleApplyDamage(ent, Damage, Type, vehicleType)
	if not IsValid( ent ) or not isnumber( Damage ) or not isnumber( Type ) or not isnumber(vehicleType) then return end
	
	if vehicleType == VEHICLE_TYPE_TANK then
		if (DMGContainsTypeFromTable(Type, ExceptionDMGTypes) and Damage > 100) then Damage = Damage - 100
		elseif !DMGContainsTypeFromTable(Type, ValidDMGTypes) then return end
	end

	if DMGContainsTypeFromTable(Type, {DMG_BLAST, DMG_BLAST_SURFACE}) then
		Damage = Damage * 10
	elseif DMGContainsTypeFromTable(Type, {DMG_AIRBOAT}) then
		Damage = Damage * 3
	end

	local MaxHealth = ent:GetMaxHealth()
	local CurHealth = ent:GetCurHealth()
		
	local NewHealth = math.max( math.Round(CurHealth - Damage,0) , 0 )
		
	if NewHealth <= (MaxHealth * 0.6) then
		if NewHealth <= (MaxHealth * 0.3) then
			ent:SetOnFire( true )
			ent:SetOnSmoke( false )
		else
			ent:SetOnSmoke( true )
		end
	end
		
	if MaxHealth > 30 and NewHealth <= 31 then
		if ent:EngineActive() then
			ent:DamagedStall()
		end
	end
		
	if NewHealth <= 0 then
		if (bit.band(Type, DMG_GENERIC) == 0 and bit.band(Type, DMG_CRUSH) == 0) or Damage > MaxHealth then
				
			ent:ExplodeVehicle()
				
			return
		end
			
		if ent:EngineActive() then
			ent:DamagedStall()
		end
			
		ent:SetCurHealth( 0 )
			
		return
	end
		
	ent:SetCurHealth( NewHealth )
end

function simfphys.APCApplyDamage(ent, Damage, Type)
	simfphys.ArmouredVehicleApplyDamage(ent, Damage, Type, VEHICLE_TYPE_APC)
end

function simfphys.TankApplyDamage(ent, Damage, Type)
	simfphys.ArmouredVehicleApplyDamage(ent, Damage, Type, VEHICLE_TYPE_TANK)
end


function simfphys.IdentifyVehicleTarget(npc, target)
	if !IsValid(target) || !IsValid(npc) then return end

	if target:GetClass() == "gmod_sent_vehicle_fphysics_wheel" then target = target:GetBaseEnt() end

	if target:IsVehicle() || target:GetClass() == "gmod_sent_vehicle_fphysics_base" then
		if IsValid(target:GetDriver()) then
			target = target:GetDriver()
		end
	elseif target.Base == "lunasflightschool_basescript" || target.Base == "lunasflightschool_basescript_heli" || target.Base == "lunasflightschool_basescript_gunship" then
		if IsValid(target:GetDriver()) then
			target = target:GetDriver()
		elseif IsValid(target:AIGetSelf()) then
			target = target:AIGetSelf()
		end
	end

	if target:GetClass() == "gmod_sent_vehicle_fphysics_base" || target.Base == "lunasflightschool_basescript" || target.Base == "lunasflightschool_basescript_heli" || target.Base == "lunasflightschool_basescript_gunship" then
		for _,seat in pairs( target:GetPassengerSeats() ) do
			local seat_driver = seat:GetDriver()
			if !IsValid(seat_driver) then continue end

			local disposition = npc:Disposition(seat_driver)
			if (disposition == D_HT || disposition == D_FR) && !(seat_driver:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 1) then
				target = seat_driver
				break
			end
		end
	end

	return target
end


hook.Add("Think", "simfphys_weaponhandler", function()
	if simfphys.ManagedVehicles then
		for k, v in pairs( simfphys.ManagedVehicles ) do
			if IsValid( v.entity ) then
				if v.func then
					v.func.Think( v.func,v.entity )
				end
			else
				simfphys.ManagedVehicles[k] = nil
			end
		end
	end
end)

timer.Simple(18, function() 
	if simfphys.VERSION < 1.2 then
		print( "[SIMFPHYS ARMED]: SIMFPHYS BASE IS OUT OF DATE!" )
		
		if (simfphys.armedAutoRegister and not simfphys.armedAutoRegister()) or simfphys.RegisterEquipment then
			print("[SIMFPHYS ARMED]: ONE OF YOUR ADDITIONAL SIMFPHYS-ARMED PACKS IS CAUSING CONFLICTS!!!")
			print("[SIMFPHYS ARMED]: PRECAUTIONARY RESTORING FUNCTION:")
			print("[SIMFPHYS ARMED]: simfphys.FireHitScan")
			print("[SIMFPHYS ARMED]: simfphys.FirePhysProjectile")
			print("[SIMFPHYS ARMED]: simfphys.RegisterCrosshair")
			print("[SIMFPHYS ARMED]: simfphys.RegisterCamera")
			print("[SIMFPHYS ARMED]: simfphys.armedAutoRegister")
			print("[SIMFPHYS ARMED]: REMOVING FUNCTION:")
			print("[SIMFPHYS ARMED]: simfphys.RegisterEquipment")
			print("[SIMFPHYS ARMED]: CLEARING OUTDATED ''RegisterEquipment'' HOOK")
			print("[SIMFPHYS ARMED]: !!!FUNCTIONALITY IS NOT GUARANTEED!!!")
		
			simfphys.FireHitScan = function( data ) simfphys.FireBullet( data ) end
			simfphys.FirePhysProjectile = function( data ) simfphys.FirePhysBullet( data ) end
			simfphys.RegisterCrosshair = function( ent, data ) simfphys.xhairRegister( ent, data ) end
			simfphys.RegisterCamera = 
				function( ent, offset_firstperson, offset_thirdperson, bLocalAng, attachment )
					simfphys.CameraRegister( ent, offset_firstperson, offset_thirdperson, bLocalAng, attachment )
				end
			
			hook.Remove( "PlayerSpawnedVehicle","simfphys_armedvehicles" )
			simfphys.RegisterEquipment = nil
			simfphys.armedAutoRegister = function( vehicle ) simfphys.WeaponSystemRegister( vehicle ) return true end
		end
	end
end)
