
ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_heli" )

ENT.PrintName = "AH-1Z Viper"
ENT.Author = "DarkLord20172002"
ENT.Information = ""
ENT.Category = "[Merydian] Helicopters"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.MDL = "models/ah-1 cobra/ah1z_b.mdl"
ENT.IsArmored = true

ENT.AITEAM = 2

ENT.Mass = 3000
ENT.Inertia = Vector(5000,5000,5000)
ENT.Drag = 0

ENT.SeatPos = Vector(72,0,48)
ENT.SeatAng = Angle(0,-90,2)

ENT.MaxThrustHeli = 9
ENT.MaxTurnPitchHeli = 30
ENT.MaxTurnYawHeli = 70
ENT.MaxTurnRollHeli = 100

ENT.ThrustEfficiencyHeli = 3.4

ENT.RotorPos = Vector(49,0,128)
ENT.RotorAngle = Angle(0,0,0)
ENT.RotorRadius = 310

ENT.MaxHealth = 2200

ENT.MaxPrimaryAmmo = 28
ENT.MaxSecondaryAmmo = 4
ENT.MaxTertiaryAmmo = 840

function ENT:AddDataTables()
	self:NetworkVar( "Int",11, "AmmoTertiary", { KeyName = "tertiaryammo", Edit = { type = "Int", order = 5,min = 0, max = self.MaxTertiaryAmmo, category = "Weapons"} } )
	
	self:SetAmmoTertiary( self.MaxTertiaryAmmo )
end

local key = "mrydianlfs_ah1z"
local table = {Category = ENT.Category, Name = ENT.PrintName, IconOverride = ENT.IconOverride, AdminOnly = ENT.AdminOnly}
list.GetForEdit("lfs_vehicles")[key] = table

sound.Add( {
	name = "MINIGUN_LOOP",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "lfs_custom/ah6/mg_loop.wav"
} )

sound.Add( {
	name = "MINIGUN_LASTSHOT",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "lfs_custom/ah6/mg_stop.wav"
} )
