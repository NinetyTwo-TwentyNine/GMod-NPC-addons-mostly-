CreateConVar("sk_npc_dmg_emplacement", 13, FCVAR_NONE, "")


-- This SWEP was generated by mblunk's swep factory.
SWEP.Base = "swep_zach88889_base"

-- Visual/sound settings
if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "smg"
end

-- Visual/sound settings
SWEP.PrintName		= "Detached Emplacement Gun"
SWEP.Category		= "NPC SWEPS"
SWEP.Slot			= 2
SWEP.SlotPos		= 4
SWEP.DrawAmmo		= true
SWEP.DrawCrosshair	= true
SWEP.ViewModelFlip	= false
SWEP.ViewModelFOV	= 64
SWEP.ViewModel		= "models/v_models/v_smg1.mdl"
SWEP.WorldModel		= "models/weapons/w_pulsemg.mdl"
SWEP.ReloadSound	= "weapons/ar2/npc_ar2_reload.wav"
SWEP.MuzzleAttachment	= "1"

-- Other settings
SWEP.Weight			= 5
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false

-- SWEP info
SWEP.Author			= "Zach88889"
SWEP.Contact		= ""
SWEP.Purpose		= "No one."
SWEP.Instructions	= ""

-- Primary fire settings
SWEP.Primary.Sound				= "Weapon_FuncTank.Single"
SWEP.Primary.NumShots			= 1
SWEP.Primary.Delay				= 0.1
SWEP.Primary.ClipSize			= 90
SWEP.Primary.DefaultClip		= 90
SWEP.Primary.Tracer				= 1
SWEP.Primary.TakeAmmoPerBullet	= false
SWEP.Primary.Automatic			= true
SWEP.Primary.Ammo				= "ar2"
SWEP.Primary.DistantSound 		= "weapons/ar1/ar1_dist2.wav"
SWEP.Primary.DistantSoundLevel= 140
SWEP.Primary.DistantSoundPitch1= 80
SWEP.Primary.DistantSoundPitch2= 75
SWEP.Primary.DistantSoundVolume= 0.4

-- Hooks
function SWEP:Equip(owner)
	self:SetWeaponHoldType( self.HoldType )
	timer.Simple(0.01, function()
	if IsValid(self) && IsValid(owner) then
		if owner:GetClass() == "npc_combine_s" then
			owner:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_GOOD )
		else
			owner:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_POOR )
		end
	end
	end)
end

function SWEP:PrimaryAttack()
if IsValid(self.Owner:GetEnemy()) then
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.FireDelay = CurTime() + self.Primary.Delay
	self:SetNextPrimaryFire( self.FireDelay )
	sound.Play(Sound(self.Primary.DistantSound),self:GetPos(),self.Primary.DistantSoundLevel,math.random(self.Primary.DistantSoundPitch1,self.Primary.DistantSoundPitch2),self.Primary.DistantSoundVolume)
	self:ShotThatThing()
	end
end

function SWEP:ShotThatThing()
	local attPos = self.Owner:GetShootPos()
	local attAng = self:GetAttachment(self.MuzzleAttachment).Ang
	local posTgt = self.Owner:GetEnemy():BodyTarget(attPos)
	local angAcc = (posTgt-attPos):Angle()
	local bullet = {}
		bullet.Num = self.Primary.NumberofShots //The number of shots fired
		bullet.Src = self.Owner:GetShootPos() //Gets where the bullet comes from
		bullet.Dir = Angle(math.ApproachAngle(attAng.p,angAcc.p,45),math.ApproachAngle(attAng.y,angAcc.y,35),0):Forward()
		bullet.Tracer = 1 
		bullet.Spread = Vector(0.02,0.02,0.02)*(5-self.Owner:GetCurrentWeaponProficiency())
		bullet.Damage = GetConVarNumber("sk_npc_dmg_emplacement")
		bullet.AmmoType = self.Primary.Ammo
		bullet.TracerName = "AR2Tracer"
	self.Owner:FireBullets( bullet )
	self.Owner:MuzzleFlash()
	self.Weapon:EmitSound(Sound(self.Primary.Sound))
	self:TakePrimaryAmmo( 1 )
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

	timer.Simple(self.Primary.Delay, function()
	if !IsValid(self) or !IsValid(self.Owner) then return end
		self:Think()
		end)
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

function SWEP:OnDrop()
	self:SetKeyValue("spawnflags", tostring(bit.bor(tonumber(self:GetKeyValues()["spawnflags"]), 2)))
end