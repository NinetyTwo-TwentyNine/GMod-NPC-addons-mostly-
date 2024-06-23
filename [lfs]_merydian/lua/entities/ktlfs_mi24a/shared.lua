
ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_heli" )

ENT.PrintName = "Mi-24A"
ENT.Author = ""
ENT.Information = ""
ENT.Category = "[Merydian] Helicopters"

ENT.Spawnable		= true
ENT.AdminSpawnable	= false

ENT.MDL = "models/mi24a.mdl"
ENT.IsArmored = true

ENT.AITEAM = 1

ENT.Mass = 4000
ENT.Inertia = Vector(8000,8000,8000)
ENT.Drag = 0

ENT.WheelMass = 180
ENT.WheelRadius = 1
ENT.WheelPos_C = Vector(140,0,-197)
ENT.WheelPos_L = Vector(-90,70,-201)
ENT.WheelPos_R = Vector(-90,-70,-201)

ENT.SeatPos = Vector(132,0,-140)
ENT.SeatAng = Angle(0,-90,0)

ENT.MaxThrustHeli = 9
ENT.MaxTurnPitchHeli = 30
ENT.MaxTurnYawHeli = 40
ENT.MaxTurnRollHeli = 50

ENT.ThrustEfficiencyHeli = 2

ENT.RotorPos = Vector(0,0,0)
ENT.RotorAngle = Angle(0,0,0)
ENT.RotorRadius = 320

ENT.MaxHealth = 2000

ENT.MaxPrimaryAmmo = 128
ENT.MaxSecondaryAmmo = 4
ENT.MaxTertiaryAmmo = 1470

function ENT:AddDataTables()
	self:NetworkVar( "Int",11, "AmmoTertiary", { KeyName = "tertiaryammo", Edit = { type = "Int", order = 5,min = 0, max = self.MaxTertiaryAmmo, category = "Weapons"} } )
	
	self:SetAmmoTertiary( self.MaxTertiaryAmmo )
end

ENT.MISSILEENT = "lunasflightschool_missile"
ENT.MISSILES = {}
ENT.MISSILES[1] = Vector(0,-80,-140)
ENT.MISSILES[2] = Vector(0,80,-140)
ENT.MISSILES[3] = Vector(0,-115,-145)
ENT.MISSILES[4] = Vector(0,115,-145)

local key = "ktlfs_mi24a"
local table = {Category = ENT.Category, Name = ENT.PrintName, IconOverride = ENT.IconOverride, AdminOnly = ENT.AdminOnly}
list.GetForEdit("lfs_vehicles")[key] = table

sound.Add( {
	name = "2A42_FIRE_LOOP",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	sound = "^lfs_custom/ka29/2a42_loop.wav"
} )

sound.Add( {
	name = "2A42_LASTSHOT",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	sound = "^lfs_custom/ka29/2a42_lastshot.wav"
} )
