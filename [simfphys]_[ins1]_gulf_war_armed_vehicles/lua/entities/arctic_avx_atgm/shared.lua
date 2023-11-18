ENT.Type 				= "anim"
ENT.Base 				= "base_entity"
ENT.PrintName 			= "ATGM"
ENT.Author 				= ""
ENT.Information 		= ""

ENT.Spawnable 			= true


AddCSLuaFile()

ENT.Model = "models/weapons/w_missile_closed.mdl"
ENT.FuseTime = 30
ENT.ArmTime = 0.25
ENT.Ticks = 0

if SERVER then

function ENT:Initialize()
    self:SetModel( self.Model )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
    self:DrawShadow( true )

    self.SpawnTime = CurTime()

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:SetBuoyancyRatio(0)
        phys:SetDragCoefficient(0)
        phys:EnableGravity( false )
    end

    self.MotorSound = CreateSound( self, "weapons/rpg/rocket1.wav")
    self.MotorSound:Play()
end

function ENT:OnRemove()
    self.MotorSound:Stop()
end

end

local images_muzzle = {"effects/muzzleflash1", "effects/muzzleflash2", "effects/muzzleflash3", "effects/muzzleflash4"}

local function TableRandomChoice(tbl)
    return tbl[math.random(#tbl)]
end

function ENT:Think()
    if SERVER then
	local curtime = CurTime()

	if curtime > self.SpawnTime + self.FuseTime then
	    self:Detonate()
	elseif curtime > self.SpawnTime + self.ArmTime then
	    local trace = util.TraceHull( {
		start = self:GetPos(),
		endpos = self:GetPos() + self:GetVelocity() * FrameTime() * 2,
		maxs = self:OBBMaxs(),
		mins = self:OBBMins(),
		mask = MASK_SOLID,
		filter = function( ent )
		    if ent ~= self then return true end
		end
	    } )
	    if trace.Hit then
		self:Detonate(trace.HitPos)
	    end
	end

	self:NextThink( curtime )
	return true
    else
        if self.Ticks % 5 == 0 then
            local emitter = ParticleEmitter(self:GetPos())

            if !self:IsValid() or self:WaterLevel() > 2 then return end

            local smoke = emitter:Add("particle/particle_smokegrenade", self:GetPos())
            smoke:SetVelocity( VectorRand() * 25 )
            smoke:SetGravity( Vector(math.Rand(-5, 5), math.Rand(-5, 5), math.Rand(-20, -25)) )
            smoke:SetDieTime( math.Rand(2.0, 2.5) )
            smoke:SetStartAlpha( 255 )
            smoke:SetEndAlpha( 0 )
            smoke:SetStartSize( 0 )
            smoke:SetEndSize( 125 )
            smoke:SetRoll( math.Rand(-180, 180) )
            smoke:SetRollDelta( math.Rand(-0.2,0.2) )
            smoke:SetColor( 20, 20, 20 )
            smoke:SetAirResistance( 5 )
            smoke:SetPos( self:GetPos() )
            smoke:SetLighting( false )
            emitter:Finish()
        end

        local emitter = ParticleEmitter(self:GetPos())

        local fire = emitter:Add(TableRandomChoice(images_muzzle), self:GetPos())
        fire:SetVelocity(self:GetAngles():Forward() * -1000)
        fire:SetDieTime(0.5)
        fire:SetStartAlpha(255)
        fire:SetEndAlpha(0)
        fire:SetStartSize(32)
        fire:SetEndSize(0)
        fire:SetRoll( math.Rand(-180, 180) )
        fire:SetColor(255, 255, 255)
        fire:SetPos(self:GetPos())

        emitter:Finish()

        self.Ticks = self.Ticks + 1
    end
end

function ENT:Detonate(target_pos)
    if !self:IsValid() then return end
    local effectdata = EffectData()
        effectdata:SetOrigin( self:GetPos() )

    if self:WaterLevel() >= 1 then
        util.Effect( "WaterSurfaceExplosion", effectdata )
    else
        util.Effect( "Explosion", effectdata)
    end

    local Dir = self:GetForward()
    if isvector(target_pos) then
        Dir = (target_pos - self:GetPos()):Angle():Forward()
    end
    local Pos = self:GetPos() - Dir * 10

    local attacker = self

    if self.Owner:IsValid() then
        attacker = self.Owner
    end

    local bullet = {}
        bullet.Num 			= 1
        bullet.Src 			= Pos
        bullet.Dir 			= Dir
        bullet.Spread 		= Vector(0,0,0)
        bullet.Distance		= 160
        bullet.Tracer		= 0
        bullet.TracerName	= "simfphys_tracer"
        bullet.Force		= 30000
        bullet.Damage		= 250
        bullet.HullSize		= self:OBBMaxs() - self:OBBMins()
        bullet.Attacker 	= attacker
        bullet.Callback = function(att, tr, dmginfo)
            dmginfo:SetDamageType(DMG_BLAST + DMG_AIRBOAT)
        end
    self:FireBullets( bullet )

    local splash_dmginfo = DamageInfo()
    splash_dmginfo:SetAttacker(attacker)
    splash_dmginfo:SetInflictor(self)
    splash_dmginfo:SetDamage(150)
    splash_dmginfo:SetDamageType(DMG_BLAST + DMG_AIRBOAT)
    util.BlastDamageInfo(splash_dmginfo, self:GetPos(), 250)

    self:Remove()
end

function ENT:PhysicsCollide(colData, collider)
    if CurTime() > self.SpawnTime + self.ArmTime then
	self:Detonate(colData.HitPos)
    end
end

function ENT:Draw()
    self:DrawModel()
end