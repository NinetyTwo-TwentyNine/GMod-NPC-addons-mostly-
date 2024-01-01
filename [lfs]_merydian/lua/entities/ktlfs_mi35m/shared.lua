--Made by karltroid51 and Merydian

ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_heli" )

ENT.PrintName = "Mi-35M"
ENT.Author = ""
ENT.Information = ""
ENT.Category = "[Merydian] Helicopters"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.MDL = "models/mi-35.mdl"
ENT.IsArmored = true

ENT.AITEAM = 1

ENT.Mass = 4000
ENT.Inertia = Vector(8000,8000,8000)
ENT.Drag = 0

ENT.SeatPos = Vector(155,-2,74)
ENT.SeatAng = Angle(0,-90,0)

ENT.MaxThrustHeli = 9
ENT.MaxTurnPitchHeli = 30
ENT.MaxTurnYawHeli = 40
ENT.MaxTurnRollHeli = 50

ENT.ThrustEfficiencyHeli = 2

ENT.RotorPos = Vector(0,0,180)
ENT.RotorAngle = Angle(0,0,0)
ENT.RotorRadius = 360

ENT.MaxHealth = 2000

ENT.MaxPrimaryAmmo = 64
ENT.MaxSecondaryAmmo = 16
ENT.MaxTertiaryAmmo = 1470

function ENT:AddDataTables()
	self:NetworkVar( "Int",11, "AmmoTertiary", { KeyName = "tertiaryammo", Edit = { type = "Int", order = 5,min = 0, max = self.MaxTertiaryAmmo, category = "Weapons"} } )
	
	self:SetAmmoTertiary( self.MaxTertiaryAmmo )
end

ENT.MISSILEENT = "lunasflightschool_missile"
ENT.MISSILES = {}
ENT.MISSILES[1] = Vector(45,-48,56)
ENT.MISSILES[2] = Vector(45,48,56)

local key = "ktlfs_mi35m"
local table = {Category = ENT.Category, Name = ENT.PrintName, IconOverride = ENT.IconOverride, AdminOnly = ENT.AdminOnly}
list.GetForEdit("lfs_vehicles")[key] = table

sound.Add( {
	name = "GSHG_FIRE_LOOP",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	sound = "^lfs_custom/ka29/gshg_loop.wav"
} )

sound.Add( {
	name = "GSHG_LASTSHOT",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	sound = "^lfs_custom/ka29/gshg_lastshot.wav"
} )
