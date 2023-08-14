
SWEP.PrintName	= "NPC Weapon Base"
SWEP.Author	= "Zach88889"
SWEP.Contact	= ""
SWEP.Purpose	= ""
SWEP.Instructions	= ""
SWEP.Category	= "NPC Weapons"
SWEP.Spawnable = false
SWEP.AdminSpawnable	= false
SWEP.AutoSwitchTo	= false 
SWEP.AutoSwitchFrom	= false

SWEP.WorldModel	= ""
SWEP.HoldType	= "Shotgun"

SWEP.MuzzleAttachment	= "1"
SWEP.ShellAttachment	= "2"
SWEP.MuzzleEffect = "MuzzleEffect" 
SWEP.ShellEffect	= "ShellEject"
SWEP.Tracer	= "Tracer"
SWEP.TracerX	= 1

SWEP.Damage	= 1
SWEP.Force	= 0
SWEP.Spread	= Vector(0, 0, 0) 
SWEP.SpreadMPenalty	= 1
SWEP.BurstCount	= 0 
SWEP.BurstDelay	= 0 
SWEP.Primary.NumShots	= 1
SWEP.Primary.ClipSize	= 1 
SWEP.Primary.DefaultClip	= 1 
SWEP.Primary.Delay	= 0 
SWEP.FireDelay = 0 
SWEP.Primary.Ammo	= "ar2" 
SWEP.Primary.Sound	= "Weapon_FuncTank.Single"

function SWEP:Initialize()

self:SetHoldType(self.HoldType)
if SERVER then
self:Think()
end

end

function SWEP:PrimaryAttack()

if not self:CanPrimaryAttack() then
self:AIReload()
return
end

local curtime = CurTime()

if self.FireDelay > curtime then
return
end

if self.Owner:IsNPC() and IsValid(self.Owner:GetEnemy()) then

self.FireDelay = curtime + self.Primary.Delay

for i=0, self.BurstCount do

timer.Simple(i * self.BurstDelay, function()

if not IsValid(self) or not IsValid(self.Owner) then
return
end

if not self.Owner:GetEnemy() or not self:CanPrimaryAttack() then
return
end

self:Shoot()

end)

end

end

end

function SWEP:Shoot()

local owner = self.Owner
local enemy = owner:GetEnemy()
local enemycl = enemy:GetClass()
local targetPos = nil

if enemy:IsPlayer() or enemycl == "npc_combine_s" or enemycl == "npc_citizen" or enemycl == "npc_metropolice" then

if enemy:LookupBone("ValveBiped.Bip01_Head1") == nil then

targetPos = enemy:EyePos()

else

targetPos = enemy:GetBonePosition(enemy:LookupBone("ValveBiped.Bip01_Head1"))

end

elseif enemycl == "npc_fastzombie" or enemycl == "npc_poisonzombie" or enemycl == "npc_zombie_torso" or enemycl == "npc_fastzombie_torso" or enemycl == "npc_headcrab" or enemycl == "npc_headcrab_black" or enemycl == "npc_headcrab_fast" then

targetPos = enemy:WorldSpaceCenter()

else

targetPos = enemy:EyePos()

end

local muzzlePos = self.Weapon:GetAttachment(self.MuzzleAttachment).Pos
local direction = (targetPos - muzzlePos):GetNormalized()
local spread = nil

if owner:IsMoving() then

spread = self.Spread * self.SpreadMPenalty

else

spread = self.Spread

end

local bulletInfo = {}
bulletInfo.Attacker = owner
bulletInfo.Damage = self.Damage + math.random(-1, 1)
bulletInfo.Force = self.Force
bulletInfo.Num = self.Primary.NumShots
bulletInfo.Tracer = self.TracerX
bulletInfo.TracerName = self.Tracer
bulletInfo.AmmoType = self.Primary.Ammo
bulletInfo.Dir = direction
bulletInfo.Spread = spread
bulletInfo.Src = muzzlePos

owner:FireBullets(bulletInfo)
self:ShootEffects()

self:TakePrimaryAmmo(1)

end

function SWEP:ShootEffects()

local shootSound = Sound(self.Primary.Sound)
self.Weapon:EmitSound(shootSound, SNDLVL_GUNFIRE, 100, 1, CHAN_WEAPON)

local muzzleEffect = EffectData()
local muzzleAttach = self.Weapon:GetAttachment(self.MuzzleAttachment)
muzzleEffect:SetEntity(self.Weapon)
muzzleEffect:SetOrigin(muzzleAttach.Pos)
muzzleEffect:SetAngles(muzzleAttach.Ang)
muzzleEffect:SetScale(1)
muzzleEffect:SetMagnitude(1)
muzzleEffect:SetRadius(1)
util.Effect(self.MuzzleEffect, muzzleEffect)

local shellEffect = EffectData()
local shellAttach = self.Weapon:GetAttachment(self.ShellAttachment)
shellEffect:SetEntity(self.Weapon)
shellEffect:SetOrigin(shellAttach.Pos)
shellEffect:SetAngles(shellAttach.Ang)
shellEffect:SetScale(1)
shellEffect:SetMagnitude(1)
shellEffect:SetRadius(1)
util.Effect(self.ShellEffect, shellEffect)

self.Owner:MuzzleFlash()

end

function SWEP:AIReload()

if not IsValid(self) or not IsValid(self.Owner) then
return
end

local owner = self.Owner

if owner:IsNPC() and not owner:IsCurrentSchedule(SCHED_HIDE_AND_RELOAD) and not owner:IsCurrentSchedule(SCHED_RELOAD) and not owner:GetActivity() == ACT_RELOAD then
owner:SetSchedule(SCHED_RELOAD)
end

end

function SWEP:SecondaryAttack()

end

function SWEP:Think()

timer.Simple(engine.TickInterval() * 5, function()

if IsValid(self) then
self:Think()
end

end)

if not IsValid(self.Owner) then
self:Remove()
return
end

if IsValid(self.Owner) and IsValid(self.Owner:GetEnemy()) then

local owner = self.Owner
local enemy = owner:GetEnemy()

if self:CanPrimaryAttack() and owner:GetActivity() ~= ACT_RELOAD and enemy:Health() > 0 then

if enemy:Visible(owner) then

self:PrimaryAttack()

end

end

end

end
function SWEP:CanPrimaryAttack()

if self.Weapon:Clip1() <= 0 then

return false

end

return true

end

function SWEP:Deploy()

return true

end

function SWEP:Holster()

end

function SWEP:OnRemove()

end

function SWEP:OnRestore()

end

function SWEP:Precache()

end

function SWEP:OnDrop()

self:Remove()

end