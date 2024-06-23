
ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_heli" )

ENT.PrintName = "AH-64"
ENT.Author = "DarkLord20172002"
ENT.Information = ""
ENT.Category = "[Merydian] Helicopters"

ENT.Spawnable		= true
ENT.AdminSpawnable	= false

ENT.MDL = "models/ah-64d_apache_longbow.mdl"
ENT.IsArmored = true

ENT.AITEAM = 2


ENT.Mass = 5000
ENT.Inertia = Vector(6000,6000,6000)
ENT.Drag = 0

ENT.SeatPos = Vector(44,0,-81)
ENT.SeatAng = Angle(0,-90,6)

ENT.MaxThrustHeli = 9
ENT.MaxTurnPitchHeli = 20
ENT.MaxTurnYawHeli = 35
ENT.MaxTurnRollHeli = 55

ENT.ThrustEfficiencyHeli = 0.8

ENT.RotorPos = Vector(80,0,0)
ENT.RotorAngle = Angle(0,0,0)
ENT.RotorRadius = 300

ENT.MaxHealth = 2500

ENT.MaxPrimaryAmmo = 36
ENT.MaxSecondaryAmmo = 8
ENT.MaxTertiaryAmmo = 1000

function ENT:AddDataTables()
	self:NetworkVar( "Int",11, "AmmoTertiary", { KeyName = "tertiaryammo", Edit = { type = "Int", order = 5,min = 0, max = self.MaxTertiaryAmmo, category = "Weapons"} } )
	
	self:SetAmmoTertiary( self.MaxTertiaryAmmo )
end

local key = "lfs_ah64"
local table = {Category = ENT.Category, Name = ENT.PrintName, IconOverride = ENT.IconOverride, AdminOnly = ENT.AdminOnly}
list.GetForEdit("lfs_vehicles")[key] = table

sound.Add( {
	name = "2a42_mi28_loop",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	sound = "^lfs_custom/mi28n/mi28n_30mm.wav"
} )

sound.Add( {
	name = "2a42_mi28_lastshot",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	sound = "^lfs_custom/mi28n/mi28n_30mm_end.wav"
} )

sound.Add( {
	name = "TOW_FIRE",
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 135,
	sound = "^lfs_custom/mi28n/tow_missile.wav"
} )
