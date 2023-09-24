-- DO NOT EDIT OR REUPLOAD THIS SCRIPT
-- DO NOT EDIT OR REUPLOAD THIS SCRIPT
-- DO NOT EDIT OR REUPLOAD THIS SCRIPT
-- DO NOT EDIT OR REUPLOAD THIS SCRIPT

local light_table = {	
	ems_sounds = {"ambient/alarms/apc_alarm_loop1.wav"},
}
list.Set( "simfphys_lights", "capc_siren", light_table)

local light_table = {
	L_HeadLampPos = Vector(71.9,32.85,-5.59),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampPos = Vector(71.9,-32.85,-5.59),
	R_HeadLampAng = Angle(15,0,0),

	L_RearLampPos = Vector(-94,29.08,3.7),
	L_RearLampAng = Angle(40,180,0),
	R_RearLampPos = Vector(-94,-29.08,3.7),
	R_RearLampAng = Angle(40,180,0),
	
	Headlight_sprites = { 
		Vector(71.9,32.85,-5.59),
		Vector(71.9,-32.85,-5.59)
	},
	Headlamp_sprites = { 
		Vector(76.36,26.72,-5.79),
		Vector(76.36,-26.72,-5.79)
	},
	Rearlight_sprites = {
		Vector(-94,34.39,3.7),
		Vector(-94,-34.39,3.7)
	},
	Brakelight_sprites = {
		Vector(-94,29.08,3.7),
		Vector(-94,-29.08,3.7)
	}
}
list.Set( "simfphys_lights", "driprip_ratmobile", light_table)

local light_table = {
	ModernLights = false,
	L_HeadLampPos = Vector(115.493,46.0128,61.655),
	L_HeadLampAng = Angle(10,0,0),

	R_HeadLampPos = Vector(115.493,-46.0128,61.655),
	R_HeadLampAng = Angle(10,0,0),

	L_RearLampPos = Vector(-135.914,27.6727,67.5404),
	L_RearLampAng = Angle(10,180,0),

	R_RearLampPos = Vector(-135.914,-27.6727,67.5404),
	R_RearLampAng = Angle(10,180,0),
	
	Headlight_sprites = { 
		{
			pos = Vector(168.823,38.3722,46.6004),
			material = "sprites/light_ignorez",
			size = 45,
		},
		{
			pos = Vector(168.823,-38.2864,46.6004),
			material = "sprites/light_ignorez",
			size = 45,
		},

	},
	Headlamp_sprites = { 
		{
			pos = Vector(168.823,38.3722,46.6004),
			material = "sprites/light_ignorez",
			size = 45,
		},
		{
			pos = Vector(168.823,-38.2864,46.6004),
			material = "sprites/light_ignorez",
			size = 45,
		},
	},
	FogLight_sprites = {
		{
			pos = Vector(166.891,36.4194,51.4304),
			material = "sprites/light_ignorez",
			size = 45,
		},
		{
			pos = Vector(166.891,-36.3337,51.4304),
			material = "sprites/light_ignorez",
			size = 45,
		},

	},
	Rearlight_sprites = {
		Vector(-103.493,40.1121,48),
		Vector(-103.493,-40.1121,48),
	},
	Brakelight_sprites = {
		Vector(-103.493,40.1121,48),
		Vector(-103.493,-40.1121,48),
	},
	Reverselight_sprites = {
	
		Vector(-103.493,40.1121,46),
		Vector(-103.493,-40.1121,46),
	},

}
list.Set("simfphys_lights", "lav25", light_table)


local V = {
	Name = "HL2 Combine APC",
	Model = "models/combine_apc.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Armed Vehicles",

	Members = {
		Mass = 3500,
		MaxHealth = 6000,
		
		LightsTable = "capc_siren",
		
		IsArmored = true,
		
		OnSpawn = 
			function(ent) 
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent:SetNWBool( "simfphys_NoHud", true ) 
			end,

		ApplyDamage = function( ent, damage, type ) 
			simfphys.TankApplyDamage(ent, damage, type)
		end,
		
		GibModels = {
			"models/combine_apc_destroyed_gib01.mdl",
			"models/combine_apc_destroyed_gib02.mdl",
			"models/combine_apc_destroyed_gib03.mdl",
			"models/combine_apc_destroyed_gib04.mdl",
			"models/combine_apc_destroyed_gib05.mdl",
			"models/combine_apc_destroyed_gib06.mdl",
		},
		
		FrontWheelRadius = 28,
		RearWheelRadius = 28,
		
		SeatOffset = Vector(-25,0,104),
		SeatPitch = 0,
		
		PassengerSeats = {
			{
				pos = Vector(0,-30,50),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,-30,50),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,-30,50),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,-30,50),
				ang = Angle(0,0,0)
			},
		},
		
		FrontHeight = 10,
		FrontConstant = 50000,
		FrontDamping = 3000,
		FrontRelativeDamping = 3000,
		
		RearHeight = 10,
		RearConstant = 50000,
		RearDamping = 3000,
		RearRelativeDamping = 3000,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 70,
		Efficiency = 1.8,
		GripOffset = 0,
		BrakePower = 70,
		BulletProofTires = true,
		
		
		IdleRPM = 750,
		LimitRPM = 6000,
		PeakTorque = 100,
		PowerbandStart = 1500,
		PowerbandEnd = 5800,
		Turbocharged = false,
		Supercharged = false,
		
		FuelFillPos = Vector(32.82,-78.31,81.89),
		
		PowerBias = 0,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "simulated_vehicles/c_apc/apc_idle.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/c_apc/apc_mid.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 100,
		Sound_MidFadeOutRate = 1,
		
		Sound_High = "",
		
		Sound_Throttle = "",
		
		snd_horn = "ambient/alarms/apc_alarm_pass1.wav",
		
		ForceTransmission = 1,
		DifferentialGear = 0.3,
		Gears = {-0.1,0,0.1,0.2,0.3}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_combineapc_armed", V )


local V = {
	Name = "HL2 Jeep taucannon",
	Model = "models/buggy.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Armed Vehicles",

	Members = {
		Mass = 1700,
		
		LightsTable = "jeep",
		
		FrontWheelRadius = 18,
		RearWheelRadius = 20,

		SeatOffset = Vector(0,0,-2),
		SeatPitch = 0,

		FrontHeight = 13.5,
		FrontConstant = 27000,
		FrontDamping = 2800,
		FrontRelativeDamping = 2800,
		
		RearHeight = 13.5,
		RearConstant = 32000,
		RearDamping = 2900,
		RearRelativeDamping = 2900,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 44,
		Efficiency = 1.337,
		GripOffset = 0,
		BrakePower = 40,
		BulletProofTires = true,
		
		IdleRPM = 750,
		LimitRPM = 6500,
		PeakTorque = 100,
		PowerbandStart = 2200,
		PowerbandEnd = 6300,
		
		FuelFillPos = Vector(17.64,-14.55,30.06),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 65,
		
		PowerBias = 0.5,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/jeep/jeep_idle.wav",
		
		snd_low = "simulated_vehicles/jeep/jeep_low.wav",
		snd_low_revdown = "simulated_vehicles/jeep/jeep_revdown.wav",
		snd_low_pitch = 0.9,
		
		snd_mid = "simulated_vehicles/jeep/jeep_mid.wav",
		snd_mid_gearup = "simulated_vehicles/jeep/jeep_second.wav",
		snd_mid_pitch = 1,
		
		snd_horn = "simulated_vehicles/horn_1.wav",
		
		ForceTransmission = 1,
		DifferentialGear = 0.3,
		Gears = {-0.15,0,0.15,0.25,0.35,0.45}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_jeep_armed", V )


local V = {
	Name = "HL2 Jeep airboatgun",
	Model = "models/buggy.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Armed Vehicles",

	Members = {
		Mass = 1700,
		
		LightsTable = "jeep",
		
		FrontWheelRadius = 18,
		RearWheelRadius = 20,

		SeatOffset = Vector(0,0,-2),
		SeatPitch = 0,

		FrontHeight = 13.5,
		FrontConstant = 27000,
		FrontDamping = 2800,
		FrontRelativeDamping = 2800,
		
		RearHeight = 13.5,
		RearConstant = 32000,
		RearDamping = 2900,
		RearRelativeDamping = 2900,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 44,
		Efficiency = 1.337,
		GripOffset = 0,
		BrakePower = 40,
		BulletProofTires = true,
		
		IdleRPM = 750,
		LimitRPM = 6500,
		PeakTorque = 100,
		PowerbandStart = 2200,
		PowerbandEnd = 6300,
		
		FuelFillPos = Vector(17.64,-14.55,30.06),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 65,
		
		PowerBias = 0.5,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/jeep/jeep_idle.wav",
		
		snd_low = "simulated_vehicles/jeep/jeep_low.wav",
		snd_low_revdown = "simulated_vehicles/jeep/jeep_revdown.wav",
		snd_low_pitch = 0.9,
		
		snd_mid = "simulated_vehicles/jeep/jeep_mid.wav",
		snd_mid_gearup = "simulated_vehicles/jeep/jeep_second.wav",
		snd_mid_pitch = 1,
		
		snd_horn = "simulated_vehicles/horn_1.wav",
		
		ForceTransmission = 1,
		DifferentialGear = 0.3,
		Gears = {-0.15,0,0.15,0.25,0.35,0.45}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_jeep_armed2", V )


local V = {
	Name = "Synergy Elite Jeep taucannon",
	Model = "models/vehicles/buggy_elite.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Armed Vehicles",

	Members = {
		Mass = 1700,
		
		LightsTable = "elitejeep",
		
		FrontWheelRadius = 18,
		RearWheelRadius = 20,
		
		SeatOffset = Vector(0,0,-3),
		SeatPitch = 0,
		
		PassengerSeats = {
			{
			pos = Vector(16,-35,21),
			ang = Angle(0,0,9)
			}
		},
		
		Backfire = true,
		ExhaustPositions = {
			{
				pos = Vector(-15.69,-105.94,14.94),
				ang = Angle(90,-90,0)
			},
			{
				pos = Vector(16.78,-105.46,14.35),
				ang = Angle(90,-90,0)
			}
		},
		
		StrengthenSuspension = true,
		
		FrontHeight = 13.5,
		FrontConstant = 27000,
		FrontDamping = 2200,
		FrontRelativeDamping = 1500, 
		
		RearHeight = 13.5,
		RearConstant = 32000,
		RearDamping = 2200,
		RearRelativeDamping = 1500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		ForceTransmission = 1,
		
		TurnSpeed = 8,
		
		MaxGrip = 44,
		Efficiency = 1.4,
		GripOffset = 0,
		BrakePower = 40,
		BulletProofTires = true,
		
		IdleRPM = 750,
		LimitRPM = 7500,
		PeakTorque = 100,
		PowerbandStart = 2500,
		PowerbandEnd = 7300,
		Turbocharged = false,
		Supercharged = false,
		
		FuelFillPos = Vector(20.92,6.95,26.83),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 65,
		
		PowerBias = 0.6,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/v8elite/v8elite_idle.wav",
		
		snd_low = "simulated_vehicles/v8elite/v8elite_low.wav",
		snd_low_revdown = "simulated_vehicles/v8elite/v8elite_revdown.wav",
		snd_low_pitch = 0.8,
		
		snd_mid = "simulated_vehicles/v8elite/v8elite_mid.wav",
		snd_mid_gearup = "simulated_vehicles/v8elite/v8elite_second.wav",
		snd_mid_pitch = 1,
		
		snd_horn = "simulated_vehicles/horn_4.wav",
		
		DifferentialGear = 0.38,
		Gears = {-0.1,0,0.1,0.18,0.25,0.31,0.40}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_v8elite_armed", V )


local V = {
	Name = "Synergy Elite Jeep airboatgun",
	Model = "models/vehicles/buggy_elite.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Armed Vehicles",

	Members = {
		Mass = 1700,
		
		LightsTable = "elitejeep",
		
		FrontWheelRadius = 18,
		RearWheelRadius = 20,
		
		SeatOffset = Vector(0,0,-3),
		SeatPitch = 0,
		
		PassengerSeats = {
			{
			pos = Vector(16,-35,21),
			ang = Angle(0,0,9)
			}
		},
		
		Backfire = true,
		ExhaustPositions = {
			{
				pos = Vector(-15.69,-105.94,14.94),
				ang = Angle(90,-90,0)
			},
			{
				pos = Vector(16.78,-105.46,14.35),
				ang = Angle(90,-90,0)
			}
		},
		
		StrengthenSuspension = true,
		
		FrontHeight = 13.5,
		FrontConstant = 27000,
		FrontDamping = 2200,
		FrontRelativeDamping = 1500, 
		
		RearHeight = 13.5,
		RearConstant = 32000,
		RearDamping = 2200,
		RearRelativeDamping = 1500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		ForceTransmission = 1,
		
		TurnSpeed = 8,
		
		MaxGrip = 44,
		Efficiency = 1.4,
		GripOffset = 0,
		BrakePower = 40,
		BulletProofTires = true,
		
		IdleRPM = 750,
		LimitRPM = 7500,
		PeakTorque = 100,
		PowerbandStart = 2500,
		PowerbandEnd = 7300,
		Turbocharged = false,
		Supercharged = false,
		
		FuelFillPos = Vector(20.92,6.95,26.83),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 65,
		
		PowerBias = 0.6,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/v8elite/v8elite_idle.wav",
		
		snd_low = "simulated_vehicles/v8elite/v8elite_low.wav",
		snd_low_revdown = "simulated_vehicles/v8elite/v8elite_revdown.wav",
		snd_low_pitch = 0.8,
		
		snd_mid = "simulated_vehicles/v8elite/v8elite_mid.wav",
		snd_mid_gearup = "simulated_vehicles/v8elite/v8elite_second.wav",
		snd_mid_pitch = 1,
		
		snd_horn = "simulated_vehicles/horn_4.wav",
		
		DifferentialGear = 0.38,
		Gears = {-0.1,0,0.1,0.18,0.25,0.31,0.40}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_v8elite_armed2", V )


local V = {
	Name = "BRDM (APC)",
	Model = "models/blu/conscript_apc.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Armed Vehicles",
	SpawnOffset = Vector(0,0,50),

	Members = {
		Mass = 4200,
		
		MaxHealth = 3500,
		
		IsArmored = true,
		
		GibModels = {
			"models/blu/conscript_apc.mdl",
			"models/blu/tanks/leopard2a7_gib_4.mdl",
			"models/props_vehicles/apc_tire001.mdl",
			"models/props_vehicles/apc_tire001.mdl",
			"models/props_vehicles/apc_tire001.mdl",
			"models/props_vehicles/apc_tire001.mdl"
		},
		
		EnginePos = Vector(-16.1,-81.68,47.25),
		
		LightsTable = "conapc",
		
		OnSpawn = 
			function(ent) 
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent:SetNWBool( "simfphys_NoHud", true ) 

				ent:ManipulateBoneScale(ent:LookupBone("turret_pitch"), Vector(0,0,0))
				ent:ManipulateBoneScale(ent:LookupBone("turret_yaw"), Vector(0,0,0))
			end,

		ApplyDamage = function( ent, damage, type ) 
			simfphys.APCApplyDamage(ent, damage, type)
		end,

		OnDestroyed = function(ent)
			local gib = ent.Gib
			if !IsValid(gib) then return end
			
			local pos,ang,skin,pitch,yaw = gib:GetPos(),gib:GetAngles(),gib:GetSkin(),ent:GetPoseParameter("turret_pitch"),ent:GetPoseParameter("turret_yaw")
			gib:ManipulateBoneScale(gib:LookupBone("turret_pitch"), Vector(0,0,0))
			gib:ManipulateBoneScale(gib:LookupBone("turret_yaw"), Vector(0,0,0))
		end,
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/props_vehicles/apc_tire001.mdl",
		CustomWheelPosFL = Vector(-45,77,-22),
		CustomWheelPosFR = Vector(45,77,-22),
		CustomWheelPosRL = Vector(-45,-74,-22),
		CustomWheelPosRR = Vector(45,-74,-22),
		CustomWheelAngleOffset = Angle(0,180,0),
		
		CustomMassCenter = Vector(0,0,0),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(65,0,35),
		SeatPitch = 0,
		SeatYaw = 0,
		
		PassengerSeats = {
			{
				pos = Vector(13,75,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
		},
		
		Attachments = {
			{
				model = "models/hunter/plates/plate075x105.mdl",
				material = "lights/white",
				color = Color(0,0,0,255),
				pos = Vector(0.04,57.5,16.74),
				ang = Angle(90,-90,0)
			},
			{
				model = "models/hunter/plates/plate025x05.mdl",
				material = "lights/white",
				color = Color(0,0,0,255),
				pos = Vector(-25.08,91.34,29.46),
				ang = Angle(4.2,-109.19,68.43)
			},
			{
				pos = Vector(-24.63,77.76,8.65),
				ang = Angle(24.05,-12.81,-1.87),
				model = "models/hunter/plates/plate05x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(24.63,77.76,8.65),
				ang = Angle(24.05,-167.19,1.87),
				model = "models/hunter/plates/plate05x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(-30.17,61.36,32.79),
				ang = Angle(-1.21,-92.38,-130.2),
				model = "models/hunter/plates/plate025x05.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(30.17,61.36,32.79),
				ang = Angle(-1.21,-87.62,130.2),
				model = "models/hunter/plates/plate025x05.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(0,72.92,40.54),
				ang = Angle(0,-180,0.79),
				model = "models/hunter/plates/plate1x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(25.08,91.34,29.46),
				ang = Angle(4.2,-70.81,-68.43),
				model = "models/hunter/plates/plate025x05.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(-29.63,79.02,19.28),
				ang = Angle(90,-18,0),
				model = "models/hunter/plates/plate05x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(29.63,79.02,19.28),
				ang = Angle(90,-162,0),
				model = "models/hunter/plates/plate05x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(0,75.33,5.91),
				ang = Angle(0,0,0),
				model = "models/hunter/plates/plate1x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(0,98.02,35.74),
				ang = Angle(63,90,0),
				model = "models/hunter/plates/plate025x025.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(0,100.55,7.41),
				ang = Angle(90,-90,0),
				model = "models/hunter/plates/plate1x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			}
		},
		
		FrontHeight = 20,
		FrontConstant = 50000,
		FrontDamping = 4000,
		FrontRelativeDamping = 3000,
		
		RearHeight = 20,
		RearConstant = 50000,
		RearDamping = 4000,
		RearRelativeDamping = 3000,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 140,
		Efficiency = 1.25,
		GripOffset = -14,
		BrakePower = 120,
		BulletProofTires = true,
		
		IdleRPM = 750,
		LimitRPM = 5500,
		PeakTorque = 180,
		PowerbandStart = 1000,
		PowerbandEnd = 4500,
		Turbocharged = false,
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
list.Set( "simfphys_vehicles", "sim_fphys_conscriptapc_armed2", V )


local V = {
	Name = "BRDM-2",
	Model = "models/blu/conscript_apc.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Armed Vehicles",
	SpawnOffset = Vector(0,0,50),

	Members = {
		Mass = 4800,
		
		MaxHealth = 4200,
		
		IsArmored = true,
		
		GibModels = {
			"models/blu/conscript_apc.mdl",
			"models/props_vehicles/apc_tire001.mdl",
			"models/props_vehicles/apc_tire001.mdl",
			"models/props_vehicles/apc_tire001.mdl",
			"models/props_vehicles/apc_tire001.mdl"
		},
		
		EnginePos = Vector(-16.1,-81.68,47.25),
		
		LightsTable = "conapc",
		
		OnSpawn = 
			function(ent) 
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent:SetNWBool( "simfphys_NoHud", true ) 
			end,

		ApplyDamage = function( ent, damage, type ) 
			simfphys.APCApplyDamage(ent, damage, type)
		end,

		OnDestroyed = function(ent)
			local gib = ent.Gib
			if !IsValid(gib) then return end
			
			local pos,ang,skin,pitch,yaw = gib:GetPos(),gib:GetAngles(),gib:GetSkin(),ent:GetPoseParameter("turret_pitch"),ent:GetPoseParameter("turret_yaw")
			gib:SetPoseParameter("turret_pitch",pitch)
			gib:SetPoseParameter("turret_yaw",yaw)
		end,
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/props_vehicles/apc_tire001.mdl",
		CustomWheelPosFL = Vector(-45,77,-22),
		CustomWheelPosFR = Vector(45,77,-22),
		CustomWheelPosRL = Vector(-45,-74,-22),
		CustomWheelPosRR = Vector(45,-74,-22),
		CustomWheelAngleOffset = Angle(0,180,0),
		
		CustomMassCenter = Vector(0,0,0),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(65,0,35),
		SeatPitch = 0,
		SeatYaw = 0,
		
		PassengerSeats = {
			{
				pos = Vector(13,75,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
		},
		
		Attachments = {
			{
				model = "models/hunter/plates/plate075x105.mdl",
				material = "lights/white",
				color = Color(0,0,0,255),
				pos = Vector(0.04,57.5,16.74),
				ang = Angle(90,-90,0)
			},
			{
				model = "models/hunter/plates/plate025x05.mdl",
				material = "lights/white",
				color = Color(0,0,0,255),
				pos = Vector(-25.08,91.34,29.46),
				ang = Angle(4.2,-109.19,68.43)
			},
			{
				pos = Vector(-24.63,77.76,8.65),
				ang = Angle(24.05,-12.81,-1.87),
				model = "models/hunter/plates/plate05x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(24.63,77.76,8.65),
				ang = Angle(24.05,-167.19,1.87),
				model = "models/hunter/plates/plate05x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(-30.17,61.36,32.79),
				ang = Angle(-1.21,-92.38,-130.2),
				model = "models/hunter/plates/plate025x05.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(30.17,61.36,32.79),
				ang = Angle(-1.21,-87.62,130.2),
				model = "models/hunter/plates/plate025x05.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(0,72.92,40.54),
				ang = Angle(0,-180,0.79),
				model = "models/hunter/plates/plate1x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(25.08,91.34,29.46),
				ang = Angle(4.2,-70.81,-68.43),
				model = "models/hunter/plates/plate025x05.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(-29.63,79.02,19.28),
				ang = Angle(90,-18,0),
				model = "models/hunter/plates/plate05x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(29.63,79.02,19.28),
				ang = Angle(90,-162,0),
				model = "models/hunter/plates/plate05x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(0,75.33,5.91),
				ang = Angle(0,0,0),
				model = "models/hunter/plates/plate1x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(0,98.02,35.74),
				ang = Angle(63,90,0),
				model = "models/hunter/plates/plate025x025.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(0,100.55,7.41),
				ang = Angle(90,-90,0),
				model = "models/hunter/plates/plate1x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			}
		},
		
		FrontHeight = 20,
		FrontConstant = 50000,
		FrontDamping = 4000,
		FrontRelativeDamping = 3000,
		
		RearHeight = 20,
		RearConstant = 50000,
		RearDamping = 4000,
		RearRelativeDamping = 3000,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 140,
		Efficiency = 1.25,
		GripOffset = -14,
		BrakePower = 120,
		BulletProofTires = true,
		
		IdleRPM = 750,
		LimitRPM = 5500,
		PeakTorque = 180,
		PowerbandStart = 1000,
		PowerbandEnd = 4500,
		Turbocharged = false,
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
list.Set( "simfphys_vehicles", "sim_fphys_conscriptapc_armed", V )


local V = {
	Name = "LAV-25", 
	Model = Model("models/engineer/us/lav25/lav25.mdl"),
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Armed Vehicles",
	SpawnOffset = Vector(0,0,10),
	SpawnAngleOffset = 0,

	Members = {
		Mass = 5000,

		MaxHealth = 4800,
		
		LightsTable = "lav25",

		OnSpawn = function(ent)
			ent:SetNWBool( "simfphys_NoRacingHud", true )
			ent:SetNWBool( "simfphys_NoHud", true ) 

			ent:SetBodygroup( 2, 1 )
			ent:SetBodygroup( 3, 1 )
			ent:SetBodygroup( 4, 1 )
			ent:SetBodygroup( 5, 1 )
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

		ApplyDamage = function( ent, damage, type ) 
			simfphys.APCApplyDamage(ent, damage, type)
		end,
		
		OnDestroyed = function(ent)
			local gib = ent.Gib
			if !IsValid(gib) then return end
			
			local pos,ang,skin,pitch,yaw = gib:GetPos(),gib:GetAngles(),gib:GetSkin(),ent:GetPoseParameter("cannon_aim_pitch"),ent:GetPoseParameter("cannon_aim_yaw")
			gib:SetPoseParameter("cannon_aim_pitch",pitch)
			gib:SetPoseParameter("cannon_aim_yaw",yaw)

			gib:SetBodygroup( 2, 1 )
			gib:SetBodygroup( 3, 1 )
			gib:SetBodygroup( 4, 1 )
			gib:SetBodygroup( 5, 1 )

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
			"models/engineer/us/lav25/lav25.mdl",
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
		CustomWheelPosFL = Vector(91.5602,52.4676,-4),
		CustomWheelPosFR = Vector(91.5602,-52.4676,-4),	
		CustomWheelPosML = Vector(0,52.4676,-4),
		CustomWheelPosMR = Vector(0,-52.4676,-4),
		CustomWheelPosRL = Vector(-86.1969,52.4676,-4),
		CustomWheelPosRR = Vector(-86.1969,-52.4676,-4),
		CustomWheelAngleOffset = Angle(0,0,0),
		
		CustomMassCenter = Vector(0,0,0),
		
		CustomSteerAngle = 30,
		FastSteeringAngle = 15,
		SteeringFadeFastSpeed = 445,
		
		TurnSpeed = 4,
		
		SeatOffset = Vector(108.3507,-19.7656,50.6389),
		SeatPitch = 0,
		SeatYaw = 90,
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
			-- WheelColor = Color(0,0,0,255),
		},
		
		PassengerSeats = {
			{
				pos = Vector(-20.6135,24.6115,25),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-20.6135,-4.6115,25),
				ang = Angle(0,-90,0)
			},
-------------
			{
				pos = Vector(-45.6135,-8.6115,12),
				ang = Angle(0,180,0)
			},
-------------
			{
				pos = Vector(-62.6135,-8.6115,12),
				ang = Angle(0,180,0)
			},
			{
				pos = Vector(-78.6135,-8.6115,12),
				ang = Angle(0,180,0)
			},
			{
				pos = Vector(-45.6135,8.6115,12),
				ang = Angle(0,0,0)
			},
-------------
			{
				pos = Vector(-62.6135,8.6115,12),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-78.6135,8.6115,12),
				ang = Angle(0,0,0)
			},
		},
		
		
		ExhaustPositions = {
			{
				pos = Vector(-13.2303,-55.0575,48.0862),
				ang = Angle(180,30,0)
			},
			{
				pos = Vector(-6.2303,-55.0575,48.0862),
				ang = Angle(180,30,0)
			},
						{
				pos = Vector(-20.2303,-55.0575,48.0862),
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
list.Set("simfphys_vehicles", "sim_fphys_lav-25_armed", V)


local V = {
	Name = "DIPRIP - Ratmobile",
	Model = "models/ratmobile/ratmobile.mdl",
	Category = "Armed Vehicles",
	SpawnOffset = Vector(0,0,25),

	Members = {
		Mass = 4800,
		FrontWheelMass = 225,
		RearWheelMass = 225,
		
		LightsTable = "driprip_ratmobile",
		
		FirstPersonViewPos = Vector(0,0,40),
		
		IsArmored = true,
		
		OnSpawn = 
			function(ent) 
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent:SetNWBool( "simfphys_NoHud", true ) 
			end,
		
		EnginePos = Vector(20,0,0),
		
		MaxHealth = 5000,
		
		FrontWheelRadius = 20,
		RearWheelRadius = 20,
		
		SeatOffset = Vector(-35,0,15),
		SeatPitch = 0,
		
		CustomMassCenter = Vector(0,0,-5),

		ExhaustPositions = {
			{
				pos = Vector(6.54,44.25,13.19),
				ang = Angle(-15,0,0)
			},
			{
				pos = Vector(-1.85,44.15,14.79),
				ang = Angle(-15,0,0)
			},
			{
				pos = Vector(-9.87,44.49,16.03),
				ang = Angle(-15,0,0)
			},
			{
				pos = Vector(6.54,-44.25,13.19),
				ang = Angle(-15,0,0)
			},
			{
				pos = Vector(-1.85,-44.15,14.79),
				ang = Angle(-15,0,0)
			},
			{
				pos = Vector(-9.87,-44.49,16.03),
				ang = Angle(-15,0,0)
			},
			{
				pos = Vector(-92.45,20.94,-6.35),
				ang = Angle(-90,0,0)
			},
			{
				pos = Vector(-92.45,-20.94,-6.35),
				ang = Angle(-90,0,0)
			},
		},

		FrontHeight = 16,
		FrontConstant = 70000,
		FrontDamping = 6000,
		FrontRelativeDamping = 6000,
		
		RearHeight = 16.5,
		RearConstant = 70000,
		RearDamping = 6000,
		RearRelativeDamping = 6000,
		
		StrengthenSuspension = true,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 140,
		Efficiency = 1,
		GripOffset = -5,
		BrakePower = 120,
		BulletProofTires = true,
		
		IdleRPM = 750,
		LimitRPM = 7500,
		PeakTorque = 320,
		PowerbandStart = 1500,
		PowerbandEnd = 6500,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,
		
		FuelFillPos = Vector(-75.5,-0.01,9.58),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 120,
		
		PowerBias = 0.25,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "simulated_vehicles/ratmobile/idle.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/ratmobile/loop.wav",
		Sound_MidPitch = 0.9,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 100,
		Sound_MidFadeOutRate = 1,
		
		Sound_HighPitch = 0,
		Sound_HighVolume = 0,
		Sound_HighFadeInRPMpercent = 0,
		Sound_HighFadeInRate = 0,
		
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "common/null.wav",
		
		ForceTransmission = 1,
		
		DifferentialGear = 0.28,
		Gears = {-0.1,0,0.1,0.2,0.3,0.4,0.5}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_ratmobile", V )


local V = {
	Name = "DIPRIP - Chaos126p",
	Model = "models/chaos126p/chaos126p.mdl",
	Category = "Armed Vehicles",
	SpawnOffset = Vector(0,0,30),

	Members = {
		Mass = 4800,
		FrontWheelMass = 225,
		RearWheelMass = 225,
		
		FirstPersonViewPos = Vector(0,0,40),
		
		IsArmored = true,
		
		OnSpawn = 
			function(ent) 
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent:SetNWBool( "simfphys_NoHud", true ) 
			end,
		
		EnginePos = Vector(49.98,0,14.16),
		
		MaxHealth = 5000,
		
		FrontWheelRadius = 22,
		RearWheelRadius = 23.5,
		
		SeatOffset = Vector(-6,0,23),
		SeatPitch = 0,
		
		CustomMassCenter = Vector(0,0,0),

		ExhaustPositions = {
			{
				pos = Vector(-73.69,21.88,21.45),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-77.48,23.3,16.93),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-81.22,23.87,12.01),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-75.21,6.14,-13.95),
				ang = Angle(-90,0,0)
			},
			
			{
				pos = Vector(-73.69,-21.88,21.45),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-77.48,-23.3,16.93),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-81.22,-23.87,12.01),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-75.21,-6.14,-13.95),
				ang = Angle(-90,0,0)
			},
		},

		FrontHeight = 17,
		FrontConstant = 70000,
		FrontDamping = 8000,
		FrontRelativeDamping = 8000,
		
		RearHeight = 18,
		RearConstant = 70000,
		RearDamping = 8000,
		RearRelativeDamping = 8000,
		
		StrengthenSuspension = true,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 140,
		Efficiency = 1,
		GripOffset = -5,
		BrakePower = 120,
		BulletProofTires = true,
		
		IdleRPM = 750,
		LimitRPM = 7500,
		PeakTorque = 280,
		PowerbandStart = 1500,
		PowerbandEnd = 6500,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,
		
		FuelFillPos = Vector(-12.89,32.29,4.28),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 120,
		
		PowerBias = 0.25,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "simulated_vehicles/4banger/4banger_idle.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/4banger/4banger_mid.wav",
		Sound_MidPitch = 0.85,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 100,
		Sound_MidFadeOutRate = 1,
		
		Sound_HighPitch = 0,
		Sound_HighVolume = 0,
		Sound_HighFadeInRPMpercent = 0,
		Sound_HighFadeInRate = 0,
		
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "common/null.wav",
		
		ForceTransmission = 1,
		
		DifferentialGear = 0.25,
		Gears = {-0.1,0,0.1,0.2,0.3,0.4,0.5}
	}
}
list.Set("simfphys_vehicles", "sim_fphys_chaos126p", V )


local V = {
	Name = "DIPRIP - Hedgehog",
	Model = "models/hedgehog/hedgehog.mdl",
	Category = "Armed Vehicles",
	SpawnOffset = Vector(0,0,25),

	Members = {
		Mass = 4800,
		FrontWheelMass = 225,
		RearWheelMass = 225,
		
		FirstPersonViewPos = Vector(0,0,40),
		
		IsArmored = true,
		
		OnSpawn = 
			function(ent) 
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent:SetNWBool( "simfphys_NoHud", true ) 
			end,
		
		EnginePos = Vector(-83.52,0,30.16),
		
		MaxHealth = 5000,
		
		FrontWheelRadius = 16,
		RearWheelRadius = 16,
		
		SeatOffset = Vector(-25,0,37),
		SeatPitch = 0,
		
		CustomMassCenter = Vector(0,0,2),

		ExhaustPositions = {
			{
				pos = Vector(-77.06,11.36,43.69),
				ang = Angle(0,0,15)
			},
			{
				pos = Vector(-82.32,11.36,43.69),
				ang = Angle(0,0,15)
			},
			{
				pos = Vector(-87.7,11.36,43.69),
				ang = Angle(0,0,15)
			},
			{
				pos = Vector(-103.14,16.92,-6),
				ang = Angle(-90,0,0)
			},
			{
				pos = Vector(-77.06,-11.36,43.69),
				ang = Angle(0,0,-15)
			},
			{
				pos = Vector(-82.32,-11.36,43.69),
				ang = Angle(0,0,-15)
			},
			{
				pos = Vector(-87.7,-11.36,43.69),
				ang = Angle(0,0,-15)
			},
			{
				pos = Vector(-103.14,-16.92,-6),
				ang = Angle(-90,0,0)
			},
		},

		FrontHeight = 15,
		FrontConstant = 70000,
		FrontDamping = 8500,
		FrontRelativeDamping = 8500,
		
		RearHeight = 15,
		RearConstant = 70000,
		RearDamping = 8500,
		RearRelativeDamping = 8500,
		
		StrengthenSuspension = true,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 140,
		Efficiency = 1,
		GripOffset = -5,
		BrakePower = 120,
		BulletProofTires = true,
		
		IdleRPM = 750,
		LimitRPM = 7500,
		PeakTorque = 300,
		PowerbandStart = 1500,
		PowerbandEnd = 6500,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,
		
		FuelFillPos = Vector(-29.73,36.13,28.99),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 120,
		
		PowerBias = 0.25,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "simulated_vehicles/hedgehog/idle.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/hedgehog/loop.wav",
		Sound_MidPitch = 0.8,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 100,
		Sound_MidFadeOutRate = 1,
		
		Sound_HighPitch = 0,
		Sound_HighVolume = 0,
		Sound_HighFadeInRPMpercent = 0,
		Sound_HighFadeInRate = 0,
		
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "common/null.wav",
		
		ForceTransmission = 1,
		
		DifferentialGear = 0.32,
		Gears = {-0.1,0,0.1,0.2,0.3,0.4,0.5}
	}
}
list.Set("simfphys_vehicles", "sim_fphys_hedgehog", V )


local light_table = {
	L_HeadLampPos = Vector(110,34.5,50),
	R_HeadLampPos = Vector(110,34.5,50),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampAng = Angle(15,0,0),
	
	Headlight_sprites = { 
		Vector(110,-48.5,57.5),
		Vector(110,48.5,57.5),
		Vector(110,-48.5,57),
		Vector(110,48.5,57),
	},

	Rearlight_sprites = {
		Vector(-127,55,44),
		Vector(-127,55,49),
		Vector(-127,-55.5,44),
		Vector(-127,-55.5,49),
	},
}
list.Set( "simfphys_lights", "fv510warrior", light_table)

local light_table = {
	L_HeadLampPos = Vector(131.772,41.7122,55.8729),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampPos = Vector(131.772,-41.7122,55.8729),
	R_HeadLampAng = Angle(15,0,0),
	
	L_RearLampPos = Vector(-132.997,39.4836,71.7594),
	L_RearLampAng = Angle(15,180,0),
	R_RearLampPos = Vector(-132.997,-39.4836,71.7594),
	R_RearLampAng = Angle(15,180,0),
	
	Headlight_sprites = { 
		Vector(131.115,-57.2759,50.1532), --- правый
		Vector(131.115,57.2759,50.1532), --- левый
		{
			pos = Vector(103.1,71.6348,53.363),
			material = "sprites/light_ignorez",
			size = 20,
			color = Color(255,178,0,255),
		},
		{
			pos = Vector(95.0735,72.5396,37.5364),
			material = "sprites/light_ignorez",
			size = 20,
			color = Color(255,178,0,255),
		},
		{
			pos = Vector(-16.519,72.5343,37.4973),
			material = "sprites/light_ignorez",
			size = 20,
			color = Color(255,178,0,255),
		},
		{
			pos = Vector(-114.955,71.962,40.7963),
			material = "sprites/light_ignorez",
			size = 20,
			color = Color(255,178,0,255),
		},
		{
			pos = Vector(-137.68,66.3261,33.8326),
			material = "sprites/light_ignorez",
			size = 20,
			color = Color(255,178,0,255),
		},
		
		{
			pos = Vector(103.1,-71.6348,53.363),
			material = "sprites/light_ignorez",
			size = 20,
			color = Color(255,178,0,255),
		},
		{
			pos = Vector(95.0735,-72.5396,37.5364),
			material = "sprites/light_ignorez",
			size = 20,
			color = Color(255,178,0,255),
		},
		{
			pos = Vector(-16.519,-72.5343,37.4973),
			material = "sprites/light_ignorez",
			size = 20,
			color = Color(255,178,0,255),
		},
		{
			pos = Vector(-114.955,-71.962,40.7963),
			material = "sprites/light_ignorez",
			size = 20,
			color = Color(255,178,0,255),
		},
		{
			pos = Vector(-137.68,-66.3261,33.8326),
			material = "sprites/light_ignorez",
			size = 20,
			color = Color(255,178,0,255),
		},
	},
	
	Headlamp_sprites = { 
		Vector(131.115,-57.2759,50.1532), --- правый
		Vector(131.115,57.2759,50.1532), --- левый
	},
	
	Brakelight_sprites = {
		Vector(-139,-46.5066,46.6838),
		Vector(-139,46.5066,46.6838),
	},
	Rearlight_sprites = {		
		Vector(-139,-57.2923,46.6838),
		Vector(-139,57.2923,46.6838),
	},
	
	Turnsignal_sprites = { -- поворотники
		Right = { -- правый
		Vector(127.435,-58.4184,55.4947),
		Vector(-138.824,-59.122,46.684),
		},
		Left = { -- левый
		Vector(127.435,58.4184,55.4947),
		Vector(-138.824,59.122,46.684),
		},
	},
}
list.Set( "simfphys_lights", "spz_puma", light_table)


local V = {
	Name = "FV-510 Warrior", 
	Model = "models/vehicles_shelby/tanks/fv510_warrior/fv510_warrior.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Armed Vehicles",
	SpawnOffset = Vector(0,0,10),
	SpawnAngleOffset = 0,

	Members = {
		Mass = 10000,
		AirFriction = 0,
		Inertia = Vector(20000,90000,100000),
		
		LightsTable = "fv510warrior",

		OnSpawn = function(ent)
			ent:SetNWBool( "simfphys_NoRacingHud", true )
			ent:SetNWBool( "simfphys_NoHud", true ) 
		end,
		
		ApplyDamage = function( ent, damage, type ) 
			simfphys.TankApplyDamage(ent, damage, type)
		end,

		OnCSTick = function(ent)
			ent:SetPoseParameter("spin_wheels_right",ent.trackspin_r)
			ent:SetPoseParameter("spin_wheels_left",ent.trackspin_l)
		end,

		OnDestroyed = function(ent)
			local gib = ent.Gib
			if !IsValid(gib) then return end
			
			local pos,ang,skin,pitch,yaw = gib:GetPos(),gib:GetAngles(),gib:GetSkin(),ent:GetPoseParameter("cannon_aim_pitch"),ent:GetPoseParameter("cannon_aim_yaw")
			gib:SetPoseParameter("cannon_aim_pitch",pitch)
			gib:SetPoseParameter("cannon_aim_yaw",yaw)
		end,
		
		MaxHealth = 5400,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(0,0,0),
		
		FrontWheelRadius = 20,
		RearWheelRadius = 20,
		
		EnginePos = Vector(35,-16,76),
		
		CustomWheels = true,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		
		CustomWheelPosFL = Vector(80,55,8),
		CustomWheelPosFR = Vector(80,-55,8),
		
		CustomWheelPosML = Vector(-10,55,8),
		CustomWheelPosMR = Vector(-10,-55,8),
		
		CustomWheelPosRL = Vector(-100,55,8),
		CustomWheelPosRR = Vector(-100,-55,8),
		CustomWheelAngleOffset = Angle(0,180,0),
		
		CustomMassCenter = Vector(-10.8125,0.875,51.4375),
		
		CustomSteerAngle = 60,
		FastSteeringAngle = 20,
		SteeringFadeFastSpeed = 300,
		
		TurnSpeed = 4,
		
		SeatOffset = Vector(50,-25,50),
		SeatPitch = 0,
		SeatYaw = 90,
		
		ModelInfo = {
			WheelColor = Color(255,0,255,0),
			-- WheelColor = Color(0,0,0,255),
		},
		
		ExhaustPositions = {
			{
				pos = Vector(40,-55,65),
				ang = Angle(-0,-90,0)
			},
			{
				pos = Vector(30,-55,65),
				ang = Angle(-0,-90,0)
			},
			{
				pos = Vector(20,-55,65),
				ang = Angle(-0,-90,0)
			},
			{
				pos = Vector(40,-55,65),
				ang = Angle(-0,-90,0)
			},
			{
				pos = Vector(30,-55,65),
				ang = Angle(-0,-90,0)
			},
			{
				pos = Vector(20,-55,65),
				ang = Angle(-0,-90,0)
			},
			{
				pos = Vector(40,-55,65),
				ang = Angle(-0,-90,0)
			},
			{
				pos = Vector(30,-55,65),
				ang = Angle(-0,-90,0)
			},
			{
				pos = Vector(20,-55,65),
				ang = Angle(-0,-90,0)
			},
			{
				pos = Vector(40,-55,65),
				ang = Angle(-0,-90,0)
			},
			{
				pos = Vector(30,-55,65),
				ang = Angle(-0,-90,0)
			},
			{
				pos = Vector(20,-55,65),
				ang = Angle(-0,-90,0)
			},
			{
				pos = Vector(40,-55,65),
				ang = Angle(-0,-90,0)
			},
			{
				pos = Vector(30,-55,65),
				ang = Angle(-0,-90,0)
			},
			{
				pos = Vector(20,-55,65),
				ang = Angle(-0,-90,0)
			},
			{
				pos = Vector(40,-55,65),
				ang = Angle(-0,-90,0)
			},
			{
				pos = Vector(30,-55,65),
				ang = Angle(-0,-90,0)
			},
			{
				pos = Vector(20,-55,65),
				ang = Angle(-0,-90,0)
			},
		},
		
		PassengerSeats = {
			{
				pos = Vector(-30,20,55),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-30,-10,55),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-50,-25,25),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-70,-25,25),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-80,-25,25),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-100,-25,25),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-60,25,25),
				ang = Angle(0,180,0)
			},
			{
				pos = Vector(-80,25,25),
				ang = Angle(0,180,0)
			},
			{
				pos = Vector(-100,25,25),
				ang = Angle(0,180,0)
			},
		},
		
		CustomSuspensionTravel = 5,
		
		FrontHeight = -1,
		FrontConstant = 37000,
		FrontDamping = 42800,
		FrontRelativeDamping = 5500,
		
		RearHeight = -1,
		RearConstant = 37000,
		RearDamping = 42800,
		RearRelativeDamping = 5500,
		
		MaxGrip = 1000,
		Efficiency = 1.5,
		GripOffset = -300,
		BrakePower = 60,
		BulletProofTires = true,
		
		IdleRPM = 600,
		LimitRPM = 4500,
		PeakTorque = 410,
		PowerbandStart = 600,
		PowerbandEnd = 2000,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = false,
		
		FuelFillPos = Vector( 8.5, -33.88, 76.5 ),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 340,
		
		PowerBias = -0.5,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "new_sound/comet_engine_rpm_33.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "new_sound/comet_engine_rpm_66.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 100,
		Sound_MidFadeOutRate = 1,
		
		Sound_High = "new_sound/comet_engine_rpm_99.wav",
		Sound_HighPitch = 1.1,
		Sound_HighVolume = 1,
		Sound_HighFadeInRPMpercent = 50,
		Sound_HighFadeInRate = 0.2,
		
		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "common/null.wav",
		ForceTransmission = 1,
		
		DifferentialGear = 0.5,
		Gears = {-0.2,0,0.04,0.08,0.1,0.15,0.2,0.25,0.35,0.4,0.45}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_fv-510_armed", V )


local V = {
	Name = "SPZ Puma", 
	Model = "models/apc/ger/puma/puma.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Armed Vehicles",
	SpawnOffset = Vector(0,0,10),
	SpawnAngleOffset = 0,

	Members = {
		Mass = 8500,
		AirFriction = 0,
		Inertia = Vector(20000,90000,100000),
		
		LightsTable = "spz_puma",

		OnSpawn = function(ent)
			ent:SetNWBool( "simfphys_NoRacingHud", true )
			ent:SetNWBool( "simfphys_NoHud", true ) 
		end,
		
		ApplyDamage = function( ent, damage, type ) 
			simfphys.TankApplyDamage(ent, damage, type)
		end,	

		OnCSTick = function(ent)
			ent:SetPoseParameter("spin_wheels_right",ent.trackspin_r)
			ent:SetPoseParameter("spin_wheels_left",ent.trackspin_l)
		end,
		
		OnDestroyed = function(ent)
			local gib = ent.Gib
			if !IsValid(gib) then return end
			
			local pos,ang,skin,pitch,yaw = gib:GetPos(),gib:GetAngles(),gib:GetSkin(),ent:GetPoseParameter("cannon_aim_pitch"),ent:GetPoseParameter("cannon_aim_yaw")
			gib:SetPoseParameter("cannon_aim_pitch",pitch)
			gib:SetPoseParameter("cannon_aim_yaw",yaw)

			gib:ManipulateBoneAngles(gib:LookupBone("r_pitch"), Angle(22-pitch,11,0))
			gib:ManipulateBonePosition(gib:LookupBone("r_pitch"), Vector(0,5,0))

			gib:ManipulateBoneScale(gib:LookupBone("pitch"), Vector(0,0,0))
			gib:ManipulateBoneScale(gib:LookupBone("barrel"), Vector(0,0,0))
		end,

		GibModels = {
			"models/apc/ger/puma/puma.mdl",
			"models/gibs/helicopter_brokenpiece_02.mdl",
			"models/gibs/helicopter_brokenpiece_03.mdl",
			"models/gibs/manhack_gib01.mdl",
			"models/gibs/manhack_gib03.mdl",
			"models/gibs/manhack_gib04.mdl"
		},
		
		MaxHealth = 5400,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(0,0,0),
		
		FrontWheelRadius = 20,
		RearWheelRadius = 20,
		
		EnginePos = Vector(58.2297,-29,68.0042),
		
		CustomWheels = true,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		
		CustomWheelPosFL = Vector(70,50,9),
		CustomWheelPosFR = Vector(70,-50,9),
		
		CustomWheelPosML = Vector(-10,50,9),
		CustomWheelPosMR = Vector(-10,-50,9),
		
		CustomWheelPosRL = Vector(-80,50,9),
		CustomWheelPosRR = Vector(-80,-50,9),
		CustomWheelAngleOffset = Angle(0,180,0),
		
		CustomMassCenter = Vector(0,0,10),
		
		CustomSteerAngle = 30,
		FastSteeringAngle = 15,
		SteeringFadeFastSpeed = 445,
		
		TurnSpeed = 4,
		
		SeatOffset = Vector(28.2014,-24.2811,50),
		SeatPitch = 0,
		SeatYaw = 90,
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
			-- WheelColor = Color(0,0,0,255),
		},
		
		ExhaustPositions = {
		},
		
		PassengerSeats = {
			{
				pos = Vector(-4.87896,17.3452,25),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-4.87896,-17.3452,25),
				ang = Angle(0,-90,0)
			},
			---
			{
				pos = Vector(-40.476,15.0523,27),
				ang = Angle(0,180,10)
			},
			{
				pos = Vector(-58.516,15.0523,27),
				ang = Angle(0,180,10)
			},
			{
				pos = Vector(-76.556,15.0523,27),
				ang = Angle(0,180,10)
			},
			{
				pos = Vector(-94.5959,15.0523,27),
				ang = Angle(0,180,10)
			},
			---
			{
				pos = Vector(-40.476,-15.0523,27),
				ang = Angle(0,0,10)
			},
			{
				pos = Vector(-58.516,-15.0523,27),
				ang = Angle(0,0,10)
			},
			{
				pos = Vector(-76.556,-15.0523,27),
				ang = Angle(0,0,10)
			},
		},
		
		CustomSuspensionTravel = 7,
		
		FrontHeight = -1,
		FrontConstant = 37000,
		FrontDamping = 42800,
		FrontRelativeDamping = 5500,
		
		RearHeight = -1,
		RearConstant = 32000,
		RearDamping = 42900,
		RearRelativeDamping = 5500,
		
		MaxGrip = 1000,
		Efficiency = 2,
		GripOffset = -300,
		BrakePower = 60,
		BulletProofTires = true,
		
		IdleRPM = 600,
		LimitRPM = 3500,
		PeakTorque = 300,
		PowerbandStart = 600,
		PowerbandEnd = 3600,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = false,
		
		FuelFillPos = Vector(87,-51,67),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 200,
		
		PowerBias = -0.4,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "puma/engine/puma_rpm_33_load.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "puma/engine/puma_rpm_66_load.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 100,
		Sound_MidFadeOutRate = 0.4,
		
		Sound_High = "puma/engine/puma_rpm_99_load.wav",
		Sound_HighPitch = 1,
		Sound_HighVolume = 1,
		Sound_HighFadeInRPMpercent = 60,
		Sound_HighFadeInRate = 0.2,
		
		snd_horn = "common/null.wav",
		ForceTransmission = 1,
		
		DifferentialGear = 0.5,
		Gears = {-0.14,0,0.1,0.15,0.2,0.245}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_spzpuma_armed", V )


local V = {
	Name = "DOD:S Tiger Tank",
	Model = "models/blu/tanks/tiger.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Armed Vehicles",
	SpawnOffset = Vector(0,0,60),
	SpawnAngleOffset = 90,

	Members = {
		Mass = 10000,
		AirFriction = 5,
		Inertia = Vector(10000,80000,100000),
		
		OnSpawn = 
			function(ent) 
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent:SetNWBool( "simfphys_NoHud", true ) 
			end,
			
		ApplyDamage = function( ent, damage, type ) 
			simfphys.TankApplyDamage(ent, damage, type)
		end,
		
		GibModels = {
			"models/blu/tanks/tiger_gib_1.mdl",
			"models/blu/tanks/tiger_gib_2.mdl",
			"models/blu/tanks/tiger_gib_3.mdl",
			"models/blu/tanks/tiger_gib_4.mdl",
		},

		MaxHealth = 7200,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(0,-50,15),
		
		FrontWheelRadius = 45,
		RearWheelRadius = 45,
		
		EnginePos = Vector(-79.66,0,72.21),
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		
		CustomWheelPosFL = Vector(110,45,45),
		CustomWheelPosFR = Vector(110,-45,45),
		CustomWheelPosML = Vector(5,45,40),
		CustomWheelPosMR = Vector(5,-45,40),
		CustomWheelPosRL = Vector(-100,45,45),
		CustomWheelPosRR = Vector(-100,-45,45),
		CustomWheelAngleOffset = Angle(0,0,90),
		
		CustomMassCenter = Vector(0,0,5),
		
		CustomSteerAngle = 60,
		
		SeatOffset = Vector(70,0,55),
		SeatPitch = 0,
		SeatYaw = 90,
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},
			
		ExhaustPositions = {
			{
				pos = Vector(-118,-16.62,72.6),
				ang = Angle(115,0,0)
			},
			{
				pos = Vector(-118,-16.62,72.6),
				ang = Angle(115,60,0)
			},
			{
				pos = Vector(-118,-16.62,72.6),
				ang = Angle(115,-60,0)
			},
			
			{
				pos = Vector(-118,16.62,72.6),
				ang = Angle(115,0,0)
			},
			{
				pos = Vector(-118,16.62,72.6),
				ang = Angle(115,60,0)
			},
			{
				pos = Vector(-118,16.62,72.6),
				ang = Angle(115,-60,0)
			},
		},

		
		PassengerSeats = {
			{
				pos = Vector(0,0,50),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,0,50),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,0,50),
				ang = Angle(0,-90,0)
			}
		},
		
		FrontHeight = 23,
		FrontConstant = 50000,
		FrontDamping = 6000,
		FrontRelativeDamping = 6000,
		
		RearHeight = 23,
		RearConstant = 50000,
		RearDamping = 6000,
		RearRelativeDamping = 6000,
		
		FastSteeringAngle = 14,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 6,
		
		MaxGrip = 800,
		Efficiency = 0.7,
		GripOffset = -300,
		BrakePower = 150,
		BulletProofTires = true,
		
		IdleRPM = 600,
		LimitRPM = 4500,
		PeakTorque = 280,
		PowerbandStart = 600,
		PowerbandEnd = 3500,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,
		
		FuelFillPos = Vector(-111.88,-0.14,59.15),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 160,
		
		PowerBias = -0.5,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "simulated_vehicles/misc/nanjing_loop.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/misc/m50.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 58,
		Sound_MidFadeOutRate = 0.476,
		
		Sound_High = "simulated_vehicles/tiger/tiger_high.wav",
		Sound_HighPitch = 0.75,
		Sound_HighVolume = 0.75,
		Sound_HighFadeInRPMpercent = 40,
		Sound_HighFadeInRate = 0.19,
		
		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "common/null.wav",
		
		ForceTransmission = 1,
		
		DifferentialGear = 0.21,
		Gears = {-0.1,0,0.05,0.07,0.09,0.11,0.13}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_tank", V )


local V = {
	Name = "DOD:S Sherman Tank",
	Model = "models/blu/tanks/sherman.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Armed Vehicles",
	SpawnOffset = Vector(0,0,60),
	SpawnAngleOffset = 90,

	Members = {
		Mass = 8000,
		AirFriction = 7,
		Inertia = Vector(10000,80000,100000),
		
		OnSpawn = 
			function(ent) 
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent:SetNWBool( "simfphys_NoHud", true ) 
			end,
			
		ApplyDamage = function( ent, damage, type ) 
			simfphys.TankApplyDamage(ent, damage, type)
		end,

		GibModels = {
			"models/blu/tanks/sherman_gib_1.mdl",
			"models/blu/tanks/sherman_gib_2.mdl",
			"models/blu/tanks/sherman_gib_3.mdl",
			"models/blu/tanks/sherman_gib_4.mdl",
			"models/blu/tanks/sherman_gib_6.mdl",
			"models/blu/tanks/sherman_gib_7.mdl",
		},
		
		MaxHealth = 5400,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(0,-50,15),
		
		FrontWheelRadius = 40,
		RearWheelRadius = 40,
		
		EnginePos = Vector(-79.66,0,72.21),
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		
		CustomWheelPosFL = Vector(100,35,50),
		CustomWheelPosFR = Vector(100,-35,50),
		CustomWheelPosML = Vector(-5,35,50),
		CustomWheelPosMR = Vector(-5,-35,50),
		CustomWheelPosRL = Vector(-110,35,50),
		CustomWheelPosRR = Vector(-110,-35,50),
		CustomWheelAngleOffset = Angle(0,0,90),
		
		CustomMassCenter = Vector(0,0,3),
		
		CustomSteerAngle = 60,
		
		SeatOffset = Vector(60,-15,55),
		SeatPitch = 0,
		SeatYaw = 90,
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},
		
		ExhaustPositions = {
			{
				pos = Vector(-90.47,17.01,52.77),
				ang = Angle(180,0,0)
			},
			{
				pos = Vector(-90.47,-17.01,52.77),
				ang = Angle(180,0,0)
			},
		},

		
		PassengerSeats = {
			{
				pos = Vector(50,-15,30),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,0,30),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,0,30),
				ang = Angle(0,-90,0)
			}
		},
		
		FrontHeight = 22,
		FrontConstant = 50000,
		FrontDamping = 5000,
		FrontRelativeDamping = 5000,
		
		RearHeight = 22,
		RearConstant = 50000,
		RearDamping = 5000,
		RearRelativeDamping = 5000,
		
		FastSteeringAngle = 14,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 6,
		
		MaxGrip = 800,
		Efficiency = 0.85,
		GripOffset = -300,
		BrakePower = 100,
		BulletProofTires = true,
		
		IdleRPM = 600,
		LimitRPM = 4500,
		PeakTorque = 250,
		PowerbandStart = 600,
		PowerbandEnd = 3500,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,
		
		FuelFillPos = Vector(-46.03,-34.64,75.23),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 160,
		
		PowerBias = -0.5,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "simulated_vehicles/sherman/idle.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/sherman/low.wav",
		Sound_MidPitch = 1.3,
		Sound_MidVolume = 0.75,
		Sound_MidFadeOutRPMpercent = 50,
		Sound_MidFadeOutRate = 0.85,
		
		Sound_High = "simulated_vehicles/sherman/high.wav",
		Sound_HighPitch = 1,
		Sound_HighVolume = 1,
		Sound_HighFadeInRPMpercent = 20,
		Sound_HighFadeInRate = 0.2,
		
		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "common/null.wav",
		
		ForceTransmission = 1,
		
		DifferentialGear = 0.3,
		Gears = {-0.1,0,0.05,0.08,0.11,0.12}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_tank2", V )


local light_table = {
	L_HeadLampPos = Vector(-122.5,-33.02,25.81),
	L_HeadLampAng = Angle(15,180,0),
	R_HeadLampPos = Vector(-122.5,33.02,25.81),
	R_HeadLampAng = Angle(15,180,0),
	
	Headlight_sprites = { 
		Vector(-122.5,-33.02,25.81),
		Vector(-122.5,33.02,25.81)
	},
	Headlamp_sprites = { 
		Vector(-122.5,-33.02,25.81),
		Vector(-122.5,33.02,25.81)
	},
	
	Rearlight_sprites = {
		Vector(150.06,-55.65,36.7),
	},
	Brakelight_sprites = {
		Vector(150.06,-55.65,36.7),
	},
}
list.Set( "simfphys_lights", "t90ms", light_table)

local light_table = {
	L_HeadLampPos = Vector(95,47,55),
	R_HeadLampPos = Vector(95,-47,55),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampAng = Angle(15,0,0),

	L_RearLampPos = Vector(-210,-63.5,55),
	R_RearLampPos = Vector(-210,64,54.5),
	L_RearLampAng = Angle(0,0,0),
	R_RearLampAng = Angle(0,0,0),
	
	Headlight_sprites = { 
		Vector(95,47.5,55),Vector(95,47,55),
		Vector(95,-47.5,55),Vector(95,-47,55),
	},

	Rearlight_sprites = {
		Vector(-210,-63.5,55),
		Vector(-210,64,54.5),
	},
}
list.Set( "simfphys_lights", "challenger", light_table)

local light_table = {
	L_HeadLampPos = Vector(-32.85,147.6,45.07),
	L_HeadLampAng = Angle(15,90,0),
	R_HeadLampPos = Vector(32.85,147.6,45.07),
	R_HeadLampAng = Angle(15,90,0),
	
	Headlight_sprites = { 
		Vector(-32.85,147.6,45.07),
		Vector(32.85,147.6,45.07)
	},
	Headlamp_sprites = { 
		Vector(-32.85,147.6,45.07),
		Vector(32.85,147.6,45.07)
	},
	Rearlight_sprites = {
		Vector(-62.95,-153.98,47.47),
		Vector(62.95,-153.98,47.47)
	},
	Brakelight_sprites = {
		Vector(-54.66,-154.5,47.43),
		Vector(54.66,-154.5,47.43),
		Vector(28.12,-145.85,29.81),
		Vector(-28.12,-145.85,29.81),
	},
	
	Turnsignal_sprites = {
		Left = {
			Vector(-59.3,-153.26,47.1),
			Vector(-62.7,132.59,54.49)
		},
		Right = {
			Vector(59.3,-153.26,47.1),
			Vector(62.7,132.59,54.49)
		},
	},


}
list.Set( "simfphys_lights", "leopard", light_table)


local V = {
	Name = "Leopard 2A7",
	Model = "models/blu/tanks/leopard2a7.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Armed Vehicles",
	SpawnOffset = Vector(0,0,60),
	SpawnAngleOffset = 90,

	Members = {
		Mass = 30000,
		AirFriction = 7,
		--Inertia = Vector(14017.5,46543,47984.5),
		Inertia = Vector(80000,20000,100000),
		
		LightsTable = "leopard",
		
		OnSpawn = 
			function(ent)
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent:SetNWBool( "simfphys_NoHud", true ) 
			end,
		
		ApplyDamage = function( ent, damage, type ) 
			simfphys.TankApplyDamage(ent, damage, type)
		end,
		
		GibModels = {
			"models/blu/tanks/leopard2a7_gib_1.mdl",
			"models/blu/tanks/leopard2a7_gib_2.mdl",
			"models/blu/tanks/leopard2a7_gib_3.mdl",
			"models/blu/tanks/leopard2a7_gib_4.mdl",
			"models/props_c17/pulleywheels_small01.mdl",
			"models/props_c17/pulleywheels_small01.mdl",
		},
		
		MaxHealth = 12800,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(0,-50,50),
		
		FrontWheelRadius = 40,
		RearWheelRadius = 45,
		
		EnginePos = Vector(0,-125.72,69.45),
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		--CustomWheelModel = "models/props_vehicles/apc_tire001.mdl",
		
		CustomWheelPosFL = Vector(-50,122,35),
		CustomWheelPosFR = Vector(50,122,35),
		CustomWheelPosML = Vector(-50,0,37),
		CustomWheelPosMR = Vector(50,0,37),
		CustomWheelPosRL = Vector(-50,-110,37),
		CustomWheelPosRR = Vector(50,-110,37),
		CustomWheelAngleOffset = Angle(0,0,90),
		
		CustomMassCenter = Vector(0,0,8),
		
		CustomSteerAngle = 60,
		
		SeatOffset = Vector(55,25,35),
		SeatPitch = -15,
		SeatYaw = 0,
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},
			
		ExhaustPositions = {
			{
				pos = Vector(-34.53,-147.48,42.92),
				ang = Angle(90,-90,0)
			},
			{
				pos = Vector(34.53,-147.48,42.92),
				ang = Angle(90,-90,0)
			},
			{
				pos = Vector(-34.53,-147.48,42.92),
				ang = Angle(90,-90,0)
			},
			{
				pos = Vector(34.53,-147.48,42.92),
				ang = Angle(90,-90,0)
			},
		},

		
		PassengerSeats = {
			{
				pos = Vector(0,0,40),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,50),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,50),
				ang = Angle(0,0,0)
			}
		},
		
		FrontHeight = 27,
		FrontConstant = 50000,
		FrontDamping = 30000,
		FrontRelativeDamping = 300000,
		
		RearHeight = 27,
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
		
		FuelFillPos = Vector(-53.14,-143.23,71.42),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 220,
		
		PowerBias = -0.3,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "simulated_vehicles/leopard/start.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/leopard/low.wav",
		Sound_MidPitch = 1.3,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 60,
		Sound_MidFadeOutRate = 0.4,
		
		Sound_High = "simulated_vehicles/leopard/high.wav",
		Sound_HighPitch = 1.2,
		Sound_HighVolume = 1,
		Sound_HighFadeInRPMpercent = 45,
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
list.Set( "simfphys_vehicles", "sim_fphys_tank3", V )


local V = {
	Name = "T-90MS",
	Model = "models/blu/tanks/t90ms.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Armed Vehicles",
	SpawnOffset = Vector(0,0,60),
	SpawnAngleOffset = 90,

	Members = {
		Mass = 25000,
		AirFriction = 0,
		--Inertia = Vector(14017.5,46543,47984.5),
		Inertia = Vector(20000,80000,100000),
		
		LightsTable = "t90ms",
		
		OnSpawn = 
			function(ent) 
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent:SetNWBool( "simfphys_NoHud", true ) 
			end,

		ApplyDamage = function( ent, damage, type ) 
			simfphys.TankApplyDamage(ent, damage, type)
		end,
		
		GibModels = {
			"models/blu/tanks/t90ms_gib_1.mdl",
			"models/blu/tanks/t90ms_gib_2.mdl",
			"models/blu/tanks/t90ms_gib_3.mdl",
			"models/blu/tanks/t90ms_gib_4.mdl",
		},
		
		MaxHealth = 10000,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(-10,-30,20),
		
		FrontWheelRadius = 40,
		RearWheelRadius = 45,
		
		EnginePos = Vector(106.08,0.69,38.34),
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		--CustomWheelModel = "models/props_vehicles/apc_tire001.mdl",
		
		CustomWheelPosFL = Vector(-122,-50,16),
		CustomWheelPosFR = Vector(-122,50,16),
		CustomWheelPosML = Vector(0,-50,20),
		CustomWheelPosMR = Vector(0,50,20),
		CustomWheelPosRL = Vector(110,-50,20),
		CustomWheelPosRR = Vector(110,50,20),
		CustomWheelAngleOffset = Angle(0,0,90),
		
		CustomMassCenter = Vector(0,0,0),
		
		CustomSteerAngle = 60,
		
		SeatOffset = Vector(68,-13,8),
		SeatPitch = -15,
		SeatYaw = -90,
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},

		
		ExhaustPositions = {
			{
				pos = Vector(71,-75,30.4),
				ang = Angle(115,-90,0)
			},
			{
				pos = Vector(67,-75,30.4),
				ang = Angle(115,-90,0)
			},
			{
				pos = Vector(0,0,50),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,0,50),
				ang = Angle(0,-90,0)
			}
		},
		
		
		PassengerSeats = {
			{
				pos = Vector(0,0,0),
				ang = Angle(0,90,0)
			},
			{
				pos = Vector(0,0,0),
				ang = Angle(0,90,0)
			},
			{
				pos = Vector(0,0,0),
				ang = Angle(0,90,0)
			}
		},
		
		FrontHeight = 27,
		FrontConstant = 50000,
		FrontDamping = 30000,
		FrontRelativeDamping = 300000,
		
		RearHeight = 27,
		RearConstant = 50000,
		RearDamping = 20000,
		RearRelativeDamping = 20000,
		
		FastSteeringAngle = 20,
		SteeringFadeFastSpeed = 300,
		
		TurnSpeed = 3,
		
		MaxGrip = 1000,
		Efficiency = 1,
		GripOffset = -500,
		BrakePower = 450,
		BulletProofTires = true,
		
		IdleRPM = 600,
		LimitRPM = 3500,
		PeakTorque = 780,
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
list.Set( "simfphys_vehicles", "sim_fphys_tank4", V )


local V = {
	Name = "Challenger Mk.3", 
	Model = "models/vehicles_shelby/tanks/challenger_mk3/challenger_mk3.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Armed Vehicles",
	SpawnOffset = Vector(0,0,10),
	SpawnAngleOffset = 0,

	Members = {
		Mass = 35000,
		AirFriction = 0,
		Inertia = Vector(20000,90000,100000),
		
		LightsTable = "challenger",

		OnSpawn = 
			function(ent) 
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent:SetNWBool( "simfphys_NoHud", true ) 
			end,
		
		ApplyDamage = function( ent, damage, type ) 
			simfphys.TankApplyDamage(ent, damage, type)
		end,

		OnDestroyed = function(ent)
			local gib = ent.Gib
			if !IsValid(gib) then return end
			
			local pos,ang,skin,pitch,yaw = gib:GetPos(),gib:GetAngles(),gib:GetSkin(),ent:GetPoseParameter("cannon_aim_pitch"),ent:GetPoseParameter("cannon_aim_yaw")
			gib:SetPoseParameter("cannon_aim_pitch",pitch)
			gib:SetPoseParameter("cannon_aim_yaw",yaw)
		end,
		
		MaxHealth = 12800,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(0,0,0),
		
		FrontWheelRadius = 20,
		RearWheelRadius = 20,
		
		EnginePos = Vector(-200,0,73),
		
		CustomWheels = true,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		
		CustomWheelPosFL = Vector(90,60,5),
		CustomWheelPosFR = Vector(90,-60,5),
		
		CustomWheelPosML = Vector(-40,60,5),
		CustomWheelPosMR = Vector(-40,-60,5),
		
		CustomWheelPosRL = Vector(-180,60,5),
		CustomWheelPosRR = Vector(-180,-60,5),
		CustomWheelAngleOffset = Angle(0,180,0),
		
		CustomMassCenter = Vector(0,0,-10),
		
		CustomSteerAngle = 60,
		FastSteeringAngle = 20,
		SteeringFadeFastSpeed = 300,
		
		TurnSpeed = 3,
		
		SeatOffset = Vector(50,0,50),
		SeatPitch = 0,
		SeatYaw = 90,
		
		ModelInfo = {
			WheelColor = Color(255,0,255,0),
			-- WheelColor = Color(0,0,0,255),
		},
		
		ExhaustPositions = {
			{
				pos = Vector(-135,69,70),
				ang = Angle(90,90,90)
			},
			{
				pos = Vector(-135,-69,70),
				ang = Angle(90,-90,90)
			},
			{
				pos = Vector(-135,69,70),
				ang = Angle(90,90,90)
			},
			{
				pos = Vector(-135,-69,70),
				ang = Angle(90,-90,90)
			},
			{
				pos = Vector(-135,69,70),
				ang = Angle(90,90,90)
			},
			{
				pos = Vector(-135,-69,70),
				ang = Angle(90,-90,90)
			},
			{
				pos = Vector(-135,69,70),
				ang = Angle(90,90,90)
			},
			{
				pos = Vector(-135,-69,70),
				ang = Angle(90,-90,90)
			},
			{
				pos = Vector(-135,69,70),
				ang = Angle(90,90,90)
			},
			{
				pos = Vector(-135,-69,70),
				ang = Angle(90,-90,90)
			},
			{
				pos = Vector(-135,69,70),
				ang = Angle(90,90,90)
			},
			{
				pos = Vector(-135,-69,70),
				ang = Angle(90,-90,90)
			},
			{
				pos = Vector(-135,69,70),
				ang = Angle(90,90,90)
			},
			{
				pos = Vector(-135,-69,70),
				ang = Angle(90,-90,90)
			},
		},
		
		PassengerSeats = {
			{
				pos = Vector(-55,-25,60),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-30,16,45),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-30,-25,45),
				ang = Angle(0,-90,0)
			},
		},
		
		CustomSuspensionTravel = 5,
		
		FrontHeight = -1,
		FrontConstant = 37000,
		FrontDamping = 42800,
		FrontRelativeDamping = 5500,
		
		RearHeight = -1,
		RearConstant = 37000,
		RearDamping = 42800,
		RearRelativeDamping = 5500,
		
		MaxGrip = 1000,
		Efficiency = 1.2,
		GripOffset = -300,
		BrakePower = 60,
		BulletProofTires = true,
		
		IdleRPM = 600,
		LimitRPM = 3000,
		PeakTorque = 700,
		PowerbandStart = 600,
		PowerbandEnd = 3500,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = false,
		
		FuelFillPos = Vector(-208.824,-52.8,47.256),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 600,
		
		PowerBias = -0.4,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "new_sound/chieftain_engine_rpm_33.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "new_sound/chieftain_engine_rpm_66.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 100,
		Sound_MidFadeOutRate = 1,
		
		Sound_High = "new_sound/chieftain_engine_rpm_99.wav",
		Sound_HighPitch = 1.1,
		Sound_HighVolume = 1,
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
list.Set( "simfphys_vehicles", "sim_fphys_tank5", V )