
ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_heli" )

ENT.PrintName = "Mi-35"
ENT.Author = ""
ENT.Information = ""
ENT.Category = "[Merydian] Helicopters"

ENT.Spawnable		= true
ENT.AdminSpawnable	= false

ENT.MDL = "models/mi-35v.mdl"
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
ENT.RotorRadius = 350

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
ENT.MISSILES[1] = Vector(45,-48,56)
ENT.MISSILES[2] = Vector(45,48,56)
ENT.MISSILES[3] = Vector(45,-80,50)
ENT.MISSILES[4] = Vector(45,80,50)

local key = "ktlfs_mi35"
local table = {Category = ENT.Category, Name = ENT.PrintName, IconOverride = ENT.IconOverride, AdminOnly = ENT.AdminOnly}
list.GetForEdit("lfs_vehicles")[key] = table

sound.Add( {
	name = "LFS23MM_FIRE_LOOP",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	sound = "^lfs_custom/ka29/23mm_loop.wav"
} )

sound.Add( {
	name = "LFS23MM_LASTSHOT",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	sound = "^lfs_custom/ka29/23mm_lastshot.wav"
} )
