--DO NOT EDIT OR REUPLOAD THIS FILE

ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "F-18"
ENT.Author = "SWINE"
ENT.Information = ""
ENT.Category = "[LFS] Merydian"

ENT.Spawnable		= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/sentry/fa18f.mdl"
ENT.IsArmored = true

ENT.AITEAM = 2

ENT.Mass = 2700
ENT.Inertia = Vector(220000,220000,220000)
ENT.Drag = 1

ENT.WheelMass = 300
ENT.WheelRadius = 18.5
ENT.WheelPos_L = Vector(-80,80,26)
ENT.WheelPos_R = Vector(-80,-80,26)
ENT.WheelPos_C = Vector(110,0,26)

ENT.SeatPos = Vector(168,0,96.5)
ENT.SeatAng = Angle(0,-90,7)

ENT.IdleRPM = 200
ENT.MaxRPM = 2900
ENT.LimitRPM = 4100

ENT.RotorPos = Vector(225,0,83)
ENT.WingPos = Vector(40,0,50)
ENT.ElevatorPos = Vector(-226.05,0,50)
ENT.RudderPos = Vector(-229.69,0,100)

 
ENT.MaxVelocity = 3400

ENT.MaxThrust = 2100

ENT.MaxStability = 0.8

ENT.MaxTurnPitch = 310
ENT.MaxTurnYaw = 700
ENT.MaxTurnRoll = 300

ENT.MaxPerfVelocity = 2100

ENT.MaxHealth = 3300

ENT.MaxPrimaryAmmo = 1200
ENT.MaxSecondaryAmmo = 4

sound.Add( {
	name = "JET_ENGINERPM1",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs_f18_sounds/jet_engine_1rpm.wav"
} )

sound.Add( {
	name = "JET_ENGINERPM2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs_f18_sounds/jet_engine_2rpm.wav"
} )

sound.Add( {
	name = "JET_ENGINERPM3",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs_f18_sounds/jet_engine_3rpm.wav"
} )

sound.Add( {
	name = "JET_ENGINERPM4",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs_f18_sounds/jet_engine_4rpm.wav"
} )

sound.Add( {
	name = "JET_ENGINEDIST",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs_f18_sounds/jet_engine_far.wav"
} )

sound.Add( {
	name = "F18_GUN_LOOP",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	sound = "lfs_f18_sounds/f18gun.wav"
} )

sound.Add( {
	name = "F18_GUN_LAST",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	sound = "lfs_f18_sounds/f18gun_last.wav"
} )

sound.Add( {
	name = "JET_ENGINESTART",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs_f18_sounds/jet_engine_start.wav"
} )

sound.Add( {
	name = "JET_ENGINESTOP",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs_f18_sounds/jet_engine_stop.wav"
} )



