--DO NOT EDIT OR REUPLOAD THIS FILE

ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "MIG-31"
ENT.Author = "SWINE"
ENT.Information = ""
ENT.Category = "[LFS] Merydian"

ENT.Spawnable		= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/kali/vehicles/hawx/mig-31.mdl"
ENT.IsArmored = true

ENT.AITEAM = 1

ENT.Mass = 3500
ENT.Inertia = Vector(220000,220000,220000)
ENT.Drag = 1

ENT.WheelMass = 300
ENT.WheelRadius = 18.5
ENT.WheelPos_L = Vector(-100,80,-80)
ENT.WheelPos_R = Vector(-100,-80,-80)
ENT.WheelPos_C = Vector(120,0,-80)

ENT.SeatPos = Vector(208,0,15)
ENT.SeatAng = Angle(0,-90,7)

ENT.IdleRPM = 200
ENT.MaxRPM = 2900
ENT.LimitRPM = 4100

ENT.RotorPos = Vector(225,0,83)
ENT.WingPos = Vector(40,0,50)
ENT.ElevatorPos = Vector(-226.05,0,50)
ENT.RudderPos = Vector(-229.69,0,100)

 
ENT.MaxVelocity = 6000

ENT.MaxThrust = 4200

ENT.MaxStability = 0.8

ENT.MaxTurnPitch = 280
ENT.MaxTurnYaw = 500
ENT.MaxTurnRoll = 200

ENT.MaxPerfVelocity = 3200

ENT.MaxHealth = 4000

ENT.MaxPrimaryAmmo = 1000
ENT.MaxSecondaryAmmo = 12

sound.Add( {
	name = "JET_ENGINERPM1",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs_mig31_sounds/jet_engine_1rpm.wav"
} )

sound.Add( {
	name = "JET_ENGINERPM2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs_mig31_sounds/jet_engine_2rpm.wav"
} )

sound.Add( {
	name = "JET_ENGINERPM3",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs_mig31_sounds/jet_engine_3rpm.wav"
} )

sound.Add( {
	name = "JET_ENGINERPM4",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs_mig31_sounds/jet_engine_4rpm.wav"
} )

sound.Add( {
	name = "JET_ENGINEDIST",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs_mig31_sounds/jet_engine_far.wav"
} )

sound.Add( {
	name = "JET_ENGINESTART",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs_mig31_sounds/jet_engine_start.wav"
} )

sound.Add( {
	name = "JET_ENGINESTOP",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs_mig31_sounds/jet_engine_stop.wav"
} )



