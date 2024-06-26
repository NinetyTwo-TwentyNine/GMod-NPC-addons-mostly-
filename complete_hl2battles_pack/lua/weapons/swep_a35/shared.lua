-- This SWEP was generated by mblunk's swep factory.
SWEP.Base = "swep_zach88889_base"

if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "smg"
end

-- Visual/sound settings
SWEP.PrintName		= "Grenade Launcher"
SWEP.Category		= "NPC SWEPS"
SWEP.Slot			= 2
SWEP.SlotPos		= 5
SWEP.DrawAmmo		= true
SWEP.DrawCrosshair	= true
SWEP.ViewModelFlip	= true
SWEP.ViewModelFOV	= 50
SWEP.ViewModel			= "models/weapons/v_rpg.mdl"
SWEP.WorldModel			= "models/weapons/w_a35.mdl"
SWEP.ReloadSound	= "weapons/ar2/ar2_reload.wav"
SWEP.AnimPrefix		= "smg2"
SWEP.HoldType		= "smg"

-- Other settings
SWEP.Weight			= 5
SWEP.AutoSwitchTo	= false
SWEP.AutoSwitchFrom	= false
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false

-- SWEP info
SWEP.Author			= "Zach88889"
SWEP.Contact		= ""
SWEP.Purpose		= "No one."
SWEP.Instructions	= ""

-- Primary fire settings
SWEP.Primary.Sound				= "rocketShoot.Play"
SWEP.Primary.NumShots			= 1
SWEP.Primary.Delay				= 2.5
SWEP.Primary.ClipSize			= 6
SWEP.Primary.DefaultClip		= 6
SWEP.Primary.Tracer				= 1
SWEP.Primary.TakeAmmoPerBullet	= false
SWEP.Primary.Automatic			= false
SWEP.Primary.Ammo				= "SMG1_Grenade"

-- Hooks

function SWEP:Equip(owner)
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:PrimaryAttack()
if IsValid(self.Owner:GetEnemy()) then
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.FireDelay = CurTime() + self.Primary.Delay
	self:SetNextPrimaryFire( self.FireDelay )
	self:ShotThatThing()
	end
end

function SWEP:ShotThatThing()
	local Dist=(self.Owner:GetEnemy():GetPos()-self.Owner:GetPos()):Length()
	local shoot_pos = self.Owner:GetShootPos() + self.Owner:GetRight() * 5 + self.Owner:GetUp() * -5
	local shoot_angle = self.Owner:GetEnemy():BodyTarget(shoot_pos) - shoot_pos
	shoot_angle = shoot_angle + Vector(math.Rand(-3.125,3.125), math.Rand(-3.125,3.125), math.Rand(3.125,6.25)) * (5-self.Owner:GetCurrentWeaponProficiency()) * (shoot_angle:Distance(Vector(0,0,0))/(Dist/7))
	shoot_angle:Normalize()
	shoot_pos = shoot_pos + shoot_angle * 100

	local rocket = ents.Create( "grenade_ar2" )
		rocket:SetPos( shoot_pos )
		rocket:SetAngles( shoot_angle:Angle() )
		rocket:SetOwner( self.Owner )
		rocket.trail = util.SpriteTrail(rocket, 0, Color(0,0,0,255), false, 3, 0, 1, 0, "trails/smoke.vmt")
		rocket:Spawn()
		rocket:SetVelocity( shoot_angle * Dist )
	self.Owner:MuzzleFlash()
	self.Weapon:EmitSound(Sound(self.Primary.Sound),500,100)
	self:TakePrimaryAmmo(1)
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
if !IsValid(self) or !IsValid(self.Owner) then return end

if self.Owner:IsCurrentSchedule(43) then
	self:NPCShoot_Primary( ShootPos, ShootDir )
	end

if self.Owner:IsCurrentSchedule(51) then
	self:Reload()
	end
end

function SWEP:NPCShoot_Primary( ShootPos, ShootDir )
if !IsValid(self) or !IsValid(self.Owner) or self:Clip1() <= 0 or self.FireDelay > CurTime() then return end
	self:PrimaryAttack()
end

function SWEP:Reload()
if !IsValid(self) or !IsValid(self.Owner) then return end
	self.Weapon:EmitSound(self.ReloadSound)
	self:SetClip1(self.Primary.ClipSize)
end

function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:OnRemove()
end

function SWEP:OnRestore()
end

function SWEP:Precache()
end

function SWEP:OwnerChanged()
end

function SWEP:OnDrop()
	self:SetKeyValue("spawnflags", tostring(bit.bor(tonumber(self:GetKeyValues()["spawnflags"]), 2)))
end

sound.Add( {
	name = "rocketShoot.Play",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = { 100, 100 },
	sound = "weapons/ar2/npc_ar2_altfire.wav"
} )