if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

SWEP.Author="Silverlan & Jackarunda"
SWEP.Contact=""
SWEP.Purpose=""
SWEP.Instructions=""
SWEP.Category="AI Weapons"

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.ViewModel="models/weapons/v_rpg.mdl"
SWEP.WorldModel="models/weapons/w_rocket_launcher.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "RPG_Round"

/*---------------------------------------------------------
---------------------------------------------------------*/
function SWEP:Initialize()
	self:SetWeaponHoldType("rpg")
	if(SERVER)then
		//self:SetNPCMinBurst(4000)
		//self:SetNPCMaxBurst(8000)
		//self:SetNPCMinRestTime(3)
		//self:SetNPCMaxRestTime(3)
		self:SetNPCFireRate(3)
	end
	self.NextFireTime=CurTime()
end

function SWEP:Equip(owner)
	timer.Simple(FrameTime(), function()
	if IsValid(self) && IsValid(owner) then
		if owner:GetClass() == "npc_combine_s" || owner:GetClass() == "npc_citizen" then
			owner:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )
		end
	end
	end)
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
end

/*------------------------------------
    Reload
------------------------------------*/
function SWEP:Reload()
	return true
end 

/*---------------------------------------------------------
   Name: GetCapabilities
   Desc: For NPCs, returns what they should try to do with it.
---------------------------------------------------------*/
function SWEP:GetCapabilities()
	return CAP_WEAPON_RANGE_ATTACK1
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
end
