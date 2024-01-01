--DO NOT EDIT OR REUPLOAD THIS FILE

ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_heli" )

ENT.PrintName = "Combine Helicopter"
ENT.Author = "Luna"
ENT.Information = "Combine Attack Helicopter from Half Life 2 + Episodes"
ENT.Category = "[Base] Armed"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.IconOverride	= "materials/entities/lvs_helicopter_combine.png"

ENT.MDL = "models/Combine_Helicopter.mdl"
ENT.GibModels = {
	"models/gibs/helicopter_brokenpiece_01.mdl",
	"models/gibs/helicopter_brokenpiece_02.mdl",
	"models/gibs/helicopter_brokenpiece_03.mdl",
	"models/gibs/helicopter_brokenpiece_06_body.mdl",
	"models/gibs/helicopter_brokenpiece_04_cockpit.mdl",
	"models/gibs/helicopter_brokenpiece_05_tailfan.mdl",
}

ENT.AITEAM = 1

ENT.Mass = 3000
ENT.Inertia = Vector(5000,5000,5000)
ENT.Drag = 0

ENT.SeatPos = Vector(120,0,-40)
ENT.SeatAng = Angle(0,-90,0)

ENT.MaxThrustHeli = 7
ENT.MaxTurnPitchHeli = 30
ENT.MaxTurnYawHeli = 50
ENT.MaxTurnRollHeli = 100

ENT.ThrustEfficiencyHeli = 0.6

ENT.RotorPos = Vector(0,0,65)
ENT.RotorAngle = Angle(15,0,0)
ENT.RotorRadius = 310

ENT.MaxHealth = 3500

ENT.MaxPrimaryAmmo = 100
ENT.MaxSecondaryAmmo = 8

ENT.IsArmored = true

local key = "lunasflightschool_combineheli"
local table = {Category = ENT.Category, Name = ENT.PrintName, IconOverride = ENT.IconOverride, AdminOnly = ENT.AdminOnly}
list.GetForEdit("lfs_vehicles")[key] = table
