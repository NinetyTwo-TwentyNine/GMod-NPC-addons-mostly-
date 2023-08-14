local function bcDamage( vehicle , position , cdamage )
	if not simfphys.DamageEnabled then return end
	
	cdamage = cdamage or false
	net.Start( "simfphys_spritedamage" )
		net.WriteEntity( vehicle )
		net.WriteVector( position ) 
		net.WriteBool( cdamage ) 
	net.Broadcast()
end

local function DestroyVehicle( ent )
	if not IsValid( ent ) then return end
	if ent.destroyed then return end
	
	ent.destroyed = true
	
	local ply = ent.EntityOwner
	local skin = ent:GetSkin()
	local Col = ent:GetColor()
	Col.r = Col.r * 0.8
	Col.g = Col.g * 0.8
	Col.b = Col.b * 0.8
	
	local bprop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
	bprop:SetModel( ent:GetModel() )			
	bprop:SetPos( ent:GetPos() )
	bprop:SetAngles( ent:GetAngles() )
	for i = 0, ent:GetNumPoseParameters() - 1 do
		local sPose = ent:GetPoseParameterName(i)
		bprop:SetPoseParameter(sPose, ent:GetPoseParameter(sPose))
	end

	bprop:Spawn()
	bprop:Activate()
	bprop:GetPhysicsObject():SetVelocity( ent:GetVelocity() + Vector(math.random(-5,5),math.random(-5,5),math.random(150,250)) ) 
	bprop:GetPhysicsObject():SetMass( ent.Mass * 0.75 )
	bprop.DoNotDuplicate = true
	bprop.MakeSound = true
	bprop:SetColor( Col )
	bprop:SetSkin( skin )
	
	ent.Gib = bprop
	
	simfphys.SetOwner( ply , bprop )
	
	if IsValid( ply ) then
		undo.Create( "Gib" )
		undo.SetPlayer( ply )
		undo.AddEntity( bprop )
		undo.SetCustomUndoText( "Undone Gib" )
		undo.Finish( "Gib" )
		ply:AddCleanup( "Gibs", bprop )
	end
	
	if ent.CustomWheels == true and not ent.NoWheelGibs then
		for i = 1, table.Count( ent.GhostWheels ) do
			local Wheel = ent.GhostWheels[i]
			if IsValid(Wheel) then
				local prop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
				prop:SetModel( Wheel:GetModel() )			
				prop:SetPos( Wheel:LocalToWorld( Vector(0,0,0) ) )
				prop:SetAngles( Wheel:LocalToWorldAngles( Angle(0,0,0) ) )
				prop:SetOwner( bprop )
				prop:Spawn()
				prop:Activate()
				prop:GetPhysicsObject():SetVelocity( ent:GetVelocity() + Vector(math.random(-5,5),math.random(-5,5),math.random(0,25)) )
				prop:GetPhysicsObject():SetMass( 20 )
				prop.DoNotDuplicate = true
				bprop:DeleteOnRemove( prop )
				
				simfphys.SetOwner( ply , prop )
			end
		end
	end
	
	local Driver = ent:GetDriver()
	if IsValid( Driver ) then
		if ent.RemoteDriver ~= Driver then
			Driver:TakeDamage( Driver:Health() + Driver:Armor(), ent.LastAttacker or Entity(0), ent.LastInflictor or Entity(0) )
		end
	end
	
	if ent.PassengerSeats then
		for i = 1, table.Count( ent.PassengerSeats ) do
			local Passenger = ent.pSeat[i]:GetDriver()
			if IsValid( Passenger ) then
				Passenger:TakeDamage( Passenger:Health() + Passenger:Armor(), ent.LastAttacker or Entity(0), ent.LastInflictor or Entity(0) )
			end
		end
	end
	
	ent:Extinguish() 
	
	ent:OnDestroyed()
	
	ent:Remove()
end

local VEHICLE_TYPE_APC = 1
local VEHICLE_TYPE_TANK = 2

local function ArmouredVehicleTakeDamage( ent, dmginfo, vehicleType )
	ent:TakePhysicsDamage( dmginfo )

	if not ent:IsInitialized() then return end

	local Damage = dmginfo:GetDamage()
	local DamagePos = dmginfo:GetDamagePosition()
	local Type = dmginfo:GetDamageType()

	ent.LastAttacker = dmginfo:GetAttacker() 
	ent.LastInflictor = dmginfo:GetInflictor()

	bcDamage( ent , ent:WorldToLocal( DamagePos ) )

	simfphys.ArmouredVehicleApplyDamage( ent, Damage, Type, vehicleType )
end

local function TankTakeDamage( ent, dmginfo )
	ArmouredVehicleTakeDamage( ent, dmginfo, VEHICLE_TYPE_TANK )
end

local function APCTakeDamage( ent, dmginfo )
	ArmouredVehicleTakeDamage( ent, dmginfo, VEHICLE_TYPE_APC )
end




local light_table = {
	ModernLights = false,
	L_HeadLampPos = Vector(138.77,-38.2983,40.4536),
	L_HeadLampAng = Angle(10,0,0),

	R_HeadLampPos = Vector(138.77,38.2983,40.4536),
	R_HeadLampAng = Angle(10,0,0),

	L_RearLampPos = Vector(-133.55 ,-40.0619,40.6141),
	L_RearLampAng = Angle(10,180,0),

	R_RearLampPos = Vector(-133.55 ,40.0619,40.6141),
	R_RearLampAng = Angle(10,180,0),
	
	Headlight_sprites = { 
		{
			pos = Vector(138.77,-38.2983,40.4536),
			material = "sprites/light_ignorez",
			size = 45,
		},
		{
			pos = Vector(138.77,38.2983,40.4536),
			material = "sprites/light_ignorez",
			size = 45,
		},

	},
	Headlamp_sprites = { 
		{
			pos = Vector(138.77,-38.2983,40.4536),
			material = "sprites/light_ignorez",
			size = 45,
		},
		{
			pos = Vector(138.77,38.2983,40.4536),
			material = "sprites/light_ignorez",
			size = 45,
		},
	},
	FogLight_sprites = {
		{
			pos = Vector(135.838,36.3419,45.2833),
			material = "sprites/light_ignorez",
			size = 45,
		},
		{
			pos = Vector(135.838,-36.3419,45.2833),
			material = "sprites/light_ignorez",
			size = 45,
		},

	},
	Rearlight_sprites = {
		Vector(-133.55 ,-40.0619,41.5),
		Vector(-133.55 ,40.0619,41.5),
	},
	Brakelight_sprites = {
		Vector(-133.55 ,-40.0619,41.5),
		Vector(-133.55 ,40.0619,41.5),
	},
	Reverselight_sprites = {
	
		Vector(-133.55 ,-40.0619,40),
		Vector(-133.55 ,40.0619,40),
	},

}
list.Set("simfphys_lights", "avx_lav-c2_lights", light_table)

local light_table = {
	L_HeadLampPos = Vector(126,45,55),
	L_HeadLampAng = Angle(0,0,0),
	R_HeadLampPos = Vector(126,-45,55),
	R_HeadLampAng = Angle(0,0,0),
	
	Headlight_sprites = { 
		Vector(126,45,55),
		Vector(126,-47,55)
	},
	Rearlight_sprites = {
		Vector(-128,45,73),
		Vector(-128,-47,73)
	},
	Brakelight_sprites = {
		Vector(-128,45,73),
		Vector(-128,-47,73)
	},
	
}
list.Set( "simfphys_lights", "avx_m2a3_lights", light_table)

local V = {
	Name = "INS1 Humvee",
	Model = "models/avx/humvee.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Arctic's Gulf War Vehicles",

	Members = {
		Mass = 3600,
		
		MaxHealth = 3200,
		
		IsArmored = false,
		
		EnginePos = Vector(-68,0,60),
		
		OnSpawn = function(ent)
			ent:SetNWBool( "simfphys_NoRacingHud", true )
		end,

		ExplodeVehicle = function(ent)
			DestroyVehicle(ent)
		end,
		
		CustomWheels = true,
		CustomSuspensionTravel = 4,
		
		CustomWheelModel = "models/avx/humvee_wheel.mdl",
		CustomWheelPosFL = Vector(-71,-38,20),
		CustomWheelPosFR = Vector(-71,38,20),
		CustomWheelPosRL = Vector(76,-38,20),
		CustomWheelPosRR = Vector(76,38,20),
		CustomWheelAngleOffset = Angle(0,90,0),
		
		CustomMassCenter = Vector(0,0,0),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-2,-32,64),
		SeatPitch = 0,
		SeatYaw = -90,
		
		FrontWheelRadius = 20,
		RearWheelRadius = 20,
		
		PassengerSeats = {
			{
				pos = Vector(-2,28,32),
				ang = Angle(0,90,0)
			},
			{
				pos = Vector(40,28,32),
				ang = Angle(0,90,0)
			},
			{
				pos = Vector(40,-28,32),
				ang = Angle(0,90,0)
			},
		},
		
		FrontHeight = 15,
		FrontConstant = 50000,
		FrontDamping = 15000,
		FrontRelativeDamping = 5000,
		
		RearHeight = 15,
		RearConstant = 50000,
		RearDamping = 15000,
		RearRelativeDamping = 5000,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 40,
		
		MaxGrip = 90,
		Efficiency = 1.25,
		GripOffset = -14,
		BrakePower = 120,
		BulletProofTires = true,
		
		IdleRPM = 900,
		LimitRPM = 5500,
		PeakTorque = 220,
		PowerbandStart = 1000,
		PowerbandEnd = 4500,
		Turbocharged = true,
		Supercharged = false,
		
		FuelFillPos = Vector(-61.34,49.71,15.98),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 120,
		
		PowerBias = 0,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "simulated_vehicles/misc/Nanjing_loop.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/misc/m50.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 58,
		Sound_MidFadeOutRate = 0.476,
		
		Sound_High = "simulated_vehicles/misc/v8high2.wav",
		Sound_HighPitch = 1,
		Sound_HighVolume = 0.75,
		Sound_HighFadeInRPMpercent = 58,
		Sound_HighFadeInRate = 0.19,
		
		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "simulated_vehicles/horn_2.wav",
		
		ForceTransmission = 1,
		
		DifferentialGear = 0.27,
		Gears = {-0.09,0,0.09,0.18,0.28,0.35}
	}
}
list.Set( "simfphys_vehicles", "avx_hmmwv", V )

local V = {
	Name = "INS1 LAV-C2", 
	Model = Model("models/engineer/us/lav25/lavhq.mdl"),
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Arctic's Gulf War Vehicles",
	SpawnOffset = Vector(0,0,10),
	SpawnAngleOffset = 0,

	Members = {
		Mass = 4000,

		MaxHealth = 4000,
		
		LightsTable = "avx_lav-c2_lights",

		OnSpawn = 
			function(ent) 
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent:SetNWBool( "simfphys_NoHud", true ) 
				ent.OnTakeDamage = APCTakeDamage
			end,

		OnTick = function(ent)
			local turn = ent:GetVehicleSteer() * 2 -- -1 or 1
			ent:SetPoseParameter("steer_wheels", turn / 2)

			if ent:EngineActive() then
				ent:ResetSequence("raise")
			else
				ent:ResetSequence("lower")
			end
		end,

		OnDestroyed = function(ent)
			local gib = ent.Gib
			if !IsValid(gib) then return end
			
			local pos,ang,skin,pitch,yaw = gib:GetPos(),gib:GetAngles(),gib:GetSkin(),ent:GetPoseParameter("cannon_aim_pitch"),ent:GetPoseParameter("cannon_aim_yaw")
			gib:SetPoseParameter("cannon_aim_pitch",pitch)
			gib:SetPoseParameter("cannon_aim_yaw",yaw)

			local wheel_tbl = {}
			while(table.Count(wheel_tbl) < 5) do
				local new_val = math.random(1,8)
				if !table.HasValue(wheel_tbl, new_val) then
					table.insert(wheel_tbl, new_val)
				end
			end
			for k,v in pairs(wheel_tbl) do
				local wheel_name
				if v <= 4 then
					wheel_name = "wheel_l_"..tostring(v)
				else
					wheel_name = "wheel_r_"..tostring(v-4)
				end
				gib:ManipulateBoneScale(gib:LookupBone(wheel_name), Vector(0,0,0))
			end
		end,

		GibModels = {
			"models/engineer/us/lav25/lavhq.mdl",
			"models/salza/skoda_liaz/skoda_liaz_fwheel.mdl",
			"models/salza/skoda_liaz/skoda_liaz_fwheel.mdl",
			"models/salza/skoda_liaz/skoda_liaz_fwheel.mdl",
			"models/salza/skoda_liaz/skoda_liaz_fwheel.mdl",
			"models/salza/skoda_liaz/skoda_liaz_fwheel.mdl"
		},
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FrontWheelRadius = 20,
		RearWheelRadius = 20,
		
		EnginePos = Vector(-68.1931,0,73.9256),
		
		CustomWheels = true,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",		
		CustomWheelPosFL = Vector(91.5602,52.4676,-9),
		CustomWheelPosFR = Vector(91.5602,-52.4676,-9),	
		CustomWheelPosML = Vector(0,52.4676,-9),
		CustomWheelPosMR = Vector(0,-52.4676,-9),
		CustomWheelPosRL = Vector(-86.1969,52.4676,-9),
		CustomWheelPosRR = Vector(-86.1969,-52.4676,-9),
		CustomWheelAngleOffset = Angle(0,0,0),
		
		CustomMassCenter = Vector(0,0,0),
		
		CustomSteerAngle = 30,
		FastSteeringAngle = 15,
		SteeringFadeFastSpeed = 445,
		
		TurnSpeed = 4,
		
		SeatOffset = Vector(78.3507,-19.7656,40.6389),
		SeatPitch = 0,
		SeatYaw = 90,
		
		ModelInfo = {
			Skin = 1,
			WheelColor = Color(0,0,0,0),
			-- WheelColor = Color(0,0,0,255),
		},
		
		PassengerSeats = {
			{
				pos = Vector(0,24.6115,25),
				ang = Angle(0,-90,0)
			},
			
			{
				pos = Vector(-50.6135,-18.6115,10),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-78.6135,-18.6115,10),
				ang = Angle(0,0,0)
			},
-------------
			{
				pos = Vector(-108.6135,-18.6115,10),
				ang = Angle(0,0,0)
			},

		},
		
		
		ExhaustPositions = {
			{
				pos = Vector(-43.2858,-55.0575,48.0862),
				ang = Angle(180,30,0)
			},
			{
				pos = Vector(-50.2858,-55.0575,48.0862),
				ang = Angle(180,30,0)
			},
						{
				pos = Vector(-36.2858,-55.0575,48.0862),
				ang = Angle(180,30,0)
			},
		},
		
		CustomSuspensionTravel = 10,
		
		FrontHeight = 0,
		FrontConstant = 45000,
		FrontDamping = 4000,
		FrontRelativeDamping = 4000,
		
		RearHeight = 0,
		RearConstant = 45000,
		RearDamping = 4000,
		RearRelativeDamping = 4000,
		
		MaxGrip = 100,
		Efficiency = 1,
		GripOffset = 0,
		BrakePower = 70,
		BulletProofTires = true,
		
		IdleRPM = 700,
		LimitRPM = 4500,
		PeakTorque = 160,
		PowerbandStart = 700,
		PowerbandEnd = 4700,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,
		
		FuelFillPos = Vector(-133,18,69),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 300,
		
		PowerBias = -0.5,
		
		EngineSoundPreset = 0,

		Sound_Idle = "engineer/lav25/engine.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "engineer/lav25/low.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 60,
		Sound_MidFadeOutRate = 0.4,
		
		Sound_High = "engineer/lav25/high.wav",
		Sound_HighPitch = 1,
		Sound_HighVolume = 1,
		Sound_HighFadeInRPMpercent = 45,
		Sound_HighFadeInRate = 0.2,
		
		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "common/null.wav",
		ForceTransmission = 1,
		
		DifferentialGear = 0.4,
		Gears = {-0.05,0,0.1,0.14,0.18,0.22,0.26,0.3}
	}
}
list.Set("simfphys_vehicles", "avx_lav-c2", V)

local V = {
	Name = "INS1 M2A3 Bradley",
	Model = "models/cod4/m2_bradley.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Arctic's Gulf War Vehicles",
	SpawnOffset = Vector(0,0,60),
	SpawnAngleOffset = 180,

	Members = {
		Mass = 12000,
		AirFriction = 0,
		--Inertia = Vector(14017.5,46543,47984.5),
		Inertia = Vector(20000,80000,100000),

		OnSpawn = function(ent) 
			ent:SetNWBool( "simfphys_NoRacingHud", true )
			ent.OnTakeDamage = TankTakeDamage
		end,
		
		ExplodeVehicle = function(ent)
			DestroyVehicle(ent)
		end,

		LightsTable = "avx_m2a3_lights",

		MaxHealth = 5400,

		IsArmored = true,

		NoWheelGibs = true,

		FirstPersonViewPos = Vector(100,100,100),

		FrontWheelRadius = 40,
		RearWheelRadius = 40,

		EnginePos = Vector(90,0,60),

		CustomWheels = true,
		CustomSuspensionTravel = 10,

		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		--CustomWheelModel = "models/props_vehicles/apc_tire001.mdl",

		CustomWheelPosRL = Vector(-122,-50,30),
		CustomWheelPosRR = Vector(-122,50,30),
		CustomWheelPosML = Vector(0,-50,30),
		CustomWheelPosMR = Vector(0,50,30),
		CustomWheelPosFL = Vector(110,-50,30),
		CustomWheelPosFR = Vector(110,50,30),
		CustomWheelAngleOffset = Angle(0,0,90),

		CustomMassCenter = Vector(0,0,0),

		CustomSteerAngle = 60,

		SeatOffset = Vector(0,0,48),
		SeatPitch = -15,
		SeatYaw = 90,

		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},

		PassengerSeats = {
			{
				pos = Vector(0,0,32),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,0,32),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,0,32),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,0,32),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,0,32),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,0,32),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,0,32),
				ang = Angle(0,-90,0)
			},
		},

		FrontHeight = 1,
		FrontConstant = 50000,
		FrontDamping = 30000,
		FrontRelativeDamping = 300000,

		RearHeight = 1,
		RearConstant = 50000,
		RearDamping = 20000,
		RearRelativeDamping = 20000,

		FastSteeringAngle = 20,
		SteeringFadeFastSpeed = 300,

		TurnSpeed = 4,

		MaxGrip = 1500,
		Efficiency = 1,
		GripOffset = -500,
		BrakePower = 400,
		BulletProofTires = true,

		IdleRPM = 500,
		LimitRPM = 4500,
		PeakTorque = 610,
		PowerbandStart = 600,
		PowerbandEnd = 2600,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,

		FuelFillPos = Vector(139.42,-3.68,38.38),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 220,
		
		PowerBias = -0.3,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "simulated_vehicles/t90ms/idle.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/sherman/low.wav",
		Sound_MidPitch = 1.5,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 100,
		Sound_MidFadeOutRate = 1,
		
		Sound_High = "simulated_vehicles/t90ms/high.wav",
		Sound_HighPitch = 1.5,
		Sound_HighVolume = 0.7,
		Sound_HighFadeInRPMpercent = 50,
		Sound_HighFadeInRate = 0.2,
		
		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "common/null.wav",
		ForceTransmission = 1,
		
		DifferentialGear = 0.4,
		Gears = {-0.06,0,0.06,0.08,0.1,0.12,0.13}
	}
}
list.Set( "simfphys_vehicles", "avx_m2a3", V )

local V = {
	Name = "INS1 M1A1 Abrams",
	Model = "models/avx/m1a1.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Arctic's Gulf War Vehicles",
	SpawnOffset = Vector(0,0,60),
	SpawnAngleOffset = 0,

	Members = {
		Mass = 30000,
		AirFriction = 7,
		--Inertia = Vector(14017.5,46543,47984.5),
		Inertia = Vector(80000,20000,100000),

		OnSpawn = function(ent)
			ent:SetNWBool( "simfphys_NoRacingHud", true )
			ent:SetNWBool( "simfphys_NoHud", true )
			ent.OnTakeDamage = TankTakeDamage
		end,

		ExplodeVehicle = function(ent)
			DestroyVehicle(ent)
		end,

		MaxHealth = 12800,

		IsArmored = true,

		NoWheelGibs = true,

		FirstPersonViewPos = Vector(-10,-30,20),

		FrontWheelRadius = 40,
		RearWheelRadius = 45,

		EnginePos = Vector(130,0.69,66),

		CustomWheels = true,
		CustomSuspensionTravel = 10,

		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		--CustomWheelModel = "models/props_vehicles/apc_tire001.mdl",

		CustomWheelPosFL = Vector(-122,-37,28),
		CustomWheelPosFR = Vector(-122,37,28),
		CustomWheelPosML = Vector(0,-37,34),
		CustomWheelPosMR = Vector(0,37,34),
		CustomWheelPosRL = Vector(110,-37,34),
		CustomWheelPosRR = Vector(110,37,34),
		CustomWheelAngleOffset = Angle(0,0,90),

		CustomMassCenter = Vector(0,0,0),

		CustomSteerAngle = 60,

		SeatOffset = Vector(48,0,48),
		SeatPitch = -15,
		SeatYaw = -90,

		ModelInfo = {
			WheelColor = Color(0,0,0,0),
			Skin = 0,
		},

		PassengerSeats = {
			{
				pos = Vector(0,0,0),
				ang = Angle(0,90,0)
			},
			{
				pos = Vector(0,0,0),
				ang = Angle(0,90,0)
			}
		},

		FrontHeight = 1,
		FrontConstant = 50000,
		FrontDamping = 30000,
		FrontRelativeDamping = 300000,

		RearHeight = 1,
		RearConstant = 50000,
		RearDamping = 20000,
		RearRelativeDamping = 20000,

		FastSteeringAngle = 20,
		SteeringFadeFastSpeed = 300,

		TurnSpeed = 2,

		MaxGrip = 1000,
		Efficiency = 1,
		GripOffset = -500,
		BrakePower = 450,
		BulletProofTires = true,

		IdleRPM = 600,
		LimitRPM = 2250,
		PeakTorque = 750,
		PowerbandStart = 600,
		PowerbandEnd = 2600,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,

		FuelFillPos = Vector(139.42,-3.68,38.38),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 220,
		
		PowerBias = -0.3,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "simulated_vehicles/t90ms/idle.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/leopard/low.wav",
		Sound_MidPitch = 1.5,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 100,
		Sound_MidFadeOutRate = 1,
		
		Sound_High = "simulated_vehicles/leopard/high.wav",
		Sound_HighPitch = 1.5,
		Sound_HighVolume = 0.7,
		Sound_HighFadeInRPMpercent = 50,
		Sound_HighFadeInRate = 0.2,
		
		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "common/null.wav",
		ForceTransmission = 1,
		
		DifferentialGear = 0.4,
		Gears = {-0.06,0,0.06,0.08,0.1,0.12,0.13}
	}
}
list.Set( "simfphys_vehicles", "avx_m1a1", V )

local V = {
	Name = "INS1 T-72",
	Model = "models/avx/t72.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Arctic's Gulf War Vehicles",
	SpawnOffset = Vector(0,0,60),
	SpawnAngleOffset = 0,

	Members = {
		Mass = 20000,
		AirFriction = 0,
		--Inertia = Vector(14017.5,46543,47984.5),
		Inertia = Vector(20000,80000,100000),

		OnSpawn = function(ent)
			ent:SetNWBool( "simfphys_NoRacingHud", true )
			ent:SetNWBool( "simfphys_NoHud", true )
			ent.OnTakeDamage = TankTakeDamage
		end,

		ExplodeVehicle = function(ent)
			DestroyVehicle(ent)
		end,

		MaxHealth = 8000,

		IsArmored = true,

		NoWheelGibs = true,

		FirstPersonViewPos = Vector(-10,-30,20),

		FrontWheelRadius = 40,
		RearWheelRadius = 45,

		EnginePos = Vector(130,0.69,66),

		CustomWheels = true,
		CustomSuspensionTravel = 10,

		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		--CustomWheelModel = "models/props_vehicles/apc_tire001.mdl",

		CustomWheelPosFL = Vector(-122,-36,38),
		CustomWheelPosFR = Vector(-122,36,38),
		CustomWheelPosML = Vector(0,-36,40),
		CustomWheelPosMR = Vector(0,36,40),
		CustomWheelPosRL = Vector(110,-36,40),
		CustomWheelPosRR = Vector(110,36,40),
		CustomWheelAngleOffset = Angle(0,0,90),

		CustomMassCenter = Vector(0,0,0),

		CustomSteerAngle = 60,

		SeatOffset = Vector(0,0,48),
		SeatPitch = -15,
		SeatYaw = -90,

		ModelInfo = {
			WheelColor = Color(0,0,0,0),
			Skin = 1,
		},

		PassengerSeats = {
			{
				pos = Vector(0,0,32),
				ang = Angle(0,90,0)
			},
			{
				pos = Vector(0,0,32),
				ang = Angle(0,90,0)
			}
		},

		ExhaustPositions = {
			{
				pos = Vector(70,-75,50),
				ang = Angle(115,-90,0)
			},
			{
				pos = Vector(80,-75,50),
				ang = Angle(115,-90,0)
			},
			{
				pos = Vector(90,-75,50),
				ang = Angle(115,-90,0)
			},
		},

		FrontHeight = 1,
		FrontConstant = 50000,
		FrontDamping = 30000,
		FrontRelativeDamping = 300000,

		RearHeight = 1,
		RearConstant = 50000,
		RearDamping = 20000,
		RearRelativeDamping = 20000,

		FastSteeringAngle = 20,
		SteeringFadeFastSpeed = 300,

		TurnSpeed = 4,

		MaxGrip = 3000,
		Efficiency = 1,
		GripOffset = -500,
		BrakePower = 400,
		BulletProofTires = true,

		IdleRPM = 400,
		LimitRPM = 4000,
		PeakTorque = 610,
		PowerbandStart = 600,
		PowerbandEnd = 2600,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,

		FuelFillPos = Vector(139.42,-3.68,38.38),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 220,
		
		PowerBias = -0.3,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "simulated_vehicles/t90ms/idle.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/t90ms/low.wav",
		Sound_MidPitch = 1.5,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 100,
		Sound_MidFadeOutRate = 1,
		
		Sound_High = "simulated_vehicles/t90ms/high.wav",
		Sound_HighPitch = 1.5,
		Sound_HighVolume = 0.7,
		Sound_HighFadeInRPMpercent = 50,
		Sound_HighFadeInRate = 0.2,
		
		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "common/null.wav",
		ForceTransmission = 1,
		
		DifferentialGear = 0.4,
		Gears = {-0.06,0,0.06,0.08,0.1,0.12,0.13}
	}
}
list.Set( "simfphys_vehicles", "avx_t72", V )

local V = {
	Name = "INS1 BMP-2",
	Model = "models/avx/bmp2.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Arctic's Gulf War Vehicles",
	SpawnOffset = Vector(0,0,60),
	SpawnAngleOffset = 180,

	Members = {
		Mass = 10000,
		AirFriction = 0,
		--Inertia = Vector(14017.5,46543,47984.5),
		Inertia = Vector(20000,80000,100000),


		OnSpawn = function(ent)
			ent:SetNWBool( "simfphys_NoRacingHud", true )
			ent.OnTakeDamage = TankTakeDamage
		end,

		ExplodeVehicle = function(ent)
			DestroyVehicle(ent)
		end,

		MaxHealth = 3600,

		IsArmored = true,

		NoWheelGibs = true,

		FirstPersonViewPos = Vector(-10,-30,20),

		FrontWheelRadius = 35,
		RearWheelRadius = 35,

		EnginePos = Vector(50,-15,60),

		CustomWheels = true,
		CustomSuspensionTravel = 10,

		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		--CustomWheelModel = "models/props_vehicles/apc_tire001.mdl",

		CustomWheelPosRL = Vector(-122,-25,25),
		CustomWheelPosRR = Vector(-122,25,25),
		CustomWheelPosML = Vector(0,-25,25),
		CustomWheelPosMR = Vector(0,25,25),
		CustomWheelPosFL = Vector(110,-25,25),
		CustomWheelPosFR = Vector(110,25,25),
		CustomWheelAngleOffset = Angle(0,0,90),

		CustomMassCenter = Vector(0,0,0),

		CustomSteerAngle = 60,

		SeatOffset = Vector(0,0,48),
		SeatPitch = -15,
		SeatYaw = 90,

		ModelInfo = {
			WheelColor = Color(0,0,0,0),
			Skin = 1,
		},

		PassengerSeats = {
			{
				pos = Vector(0,0,32),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,0,32),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,0,32),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,0,32),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,0,32),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,0,32),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,0,32),
				ang = Angle(0,-90,0)
			},
		},

		FrontHeight = 1,
		FrontConstant = 50000,
		FrontDamping = 30000,
		FrontRelativeDamping = 300000,

		RearHeight = 1,
		RearConstant = 50000,
		RearDamping = 20000,
		RearRelativeDamping = 20000,

		FastSteeringAngle = 20,
		SteeringFadeFastSpeed = 300,

		TurnSpeed = 4,

		MaxGrip = 1500,
		Efficiency = 1,
		GripOffset = -500,
		BrakePower = 400,
		BulletProofTires = true,

		IdleRPM = 500,
		LimitRPM = 4500,
		PeakTorque = 610,
		PowerbandStart = 600,
		PowerbandEnd = 2600,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,

		FuelFillPos = Vector(139.42,-3.68,38.38),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 220,
		
		PowerBias = -0.3,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "simulated_vehicles/t90ms/idle.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/sherman/low.wav",
		Sound_MidPitch = 1.5,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 100,
		Sound_MidFadeOutRate = 1,
		
		Sound_High = "simulated_vehicles/t90ms/high.wav",
		Sound_HighPitch = 1.5,
		Sound_HighVolume = 0.7,
		Sound_HighFadeInRPMpercent = 50,
		Sound_HighFadeInRate = 0.2,
		
		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "common/null.wav",
		ForceTransmission = 1,
		
		DifferentialGear = 0.4,
		Gears = {-0.06,0,0.06,0.08,0.1,0.12,0.13}
	}
}
list.Set( "simfphys_vehicles", "avx_bmp2", V )