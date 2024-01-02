AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include('shared.lua')

local ImpactSounds = {
	"physics/metal/metal_sheet_impact_bullet1.wav",
	"weapons/rpg/shotdown.wav",
}

local DeflectSounds = {
	"simulated_vehicles/weapons/physproj_rico.wav",
	"simulated_vehicles/weapons/physproj_rico1.wav",
	"simulated_vehicles/weapons/physproj_rico2.wav",
	"simulated_vehicles/weapons/physproj_rico3.wav",
}

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local size = math.random( 16, 48 )

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * size )
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:Initialize()	
	self:SetModel( "models/weapons/w_missile_launch.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_NONE )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	
	local pObj = self:GetPhysicsObject()
	
	if IsValid( pObj ) then
		pObj:EnableMotion( false )  
	end
	
	self.SpawnTime = CurTime()
	self.Vel = self:GetForward() * 200
end

local DMG_PROPEXPLOSION = 134217792
local DMG_LUABULLET = 8194

local function CanDeflectOn( ent )
	if !IsValid(ent) then return false end
	return (ent:GetClass() == "gmod_sent_vehicle_fphysics_wheel" || ent:GetClass() == "gmod_sent_vehicle_fphysics_base" || ent.LFS || ent.IdentifiesAsLFS)
end

function ENT:Think()	
	local curtime = CurTime()
	self:NextThink( curtime )
	
	local Size = self:GetSize() * 0.5
	local FixTick = FrameTime() * 66.666
	
	local trace = util.TraceHull( {
		start = self:GetPos(),
		endpos = self:GetPos() + self.Vel * FixTick,
		maxs = Size,
		mins = -Size,
		filter = function( ent )
			if ent ~= self and not table.HasValue( self.Filter, ent ) then return true end
		end
	} )
	
	if trace.Hit then
		self:SetPos( trace.HitPos )
		
		local shootDirection = self:GetForward()
		
		local hitangle = math.deg( math.acos( math.Clamp( trace.HitNormal:Dot(shootDirection) ,-1,1) ) ) - 90
		
		self.DeflectAng = self.DeflectAng or 25

		local candeflect = CanDeflectOn( trace.Entity ) and (trace.Entity.IsArmored && !self.ArmourPiercing)
		
		if hitangle < self.DeflectAng and not self.Bounced and candeflect then
			
			local thVel = self.Vel:Length()
			
			local Ax = math.deg( math.acos( math.Clamp( trace.HitNormal:Dot(shootDirection) ,-1,1) ) )
			local Fx = math.cos( math.rad( Ax ) ) * thVel
			
			self.Vel = (shootDirection * thVel - trace.HitNormal * Fx * 2) * math.max((1 - hitangle / 45) * 0.5,0.2)
			
			trace.Entity:GetPhysicsObject():ApplyForceOffset( shootDirection * thVel * self.Force * 0.5, trace.HitPos ) 
			
			table.insert( self.Filter, trace.Entity )
			
			self:SetPos( self:GetPos() + self.Vel * FixTick )
			
			self.Vel = self.Vel - Vector(0,0,0.15) * FixTick
			
			local effectdata = EffectData()
				effectdata:SetOrigin( trace.HitPos )
				effectdata:SetNormal( self.Vel:GetNormalized() * 10 )
			util.Effect( "simfphys_tracer_hit", effectdata, true, true )
			
			if Size >= 5 then
				sound.Play( Sound( DeflectSounds[ math.random(1,table.Count( DeflectSounds )) ] ), trace.HitPos, 140)
			else
				sound.Play( Sound( "simulated_vehicles/weapons/physproj_rico"..math.random(1,3)..".wav" ), trace.HitPos, 140)
			end
			
			self.Bounced = true -- only bounce once
		else
			local bullet = {}
				bullet.Num 			= 1
				bullet.Src 			= self:GetPos() - shootDirection * 10
				bullet.Dir 			= shootDirection
				bullet.Spread 		= Vector(0,0,0)
				bullet.Distance		= 160
				bullet.Tracer		= 0
				bullet.TracerName	= "simfphys_tracer"
				bullet.Force		= self.Force
				bullet.Damage		= self.Damage
				bullet.HullSize		= self:GetSize()
				bullet.Attacker 	= self.Attacker
				bullet.Callback = function(att, tr, dmginfo)
					if self.ArmourPiercing then
						dmginfo:SetDamageType(DMG_BLAST + DMG_AIRBOAT)
					else
						dmginfo:SetDamageType(DMG_DIRECT + DMG_AIRBOAT)
					end
					
					util.Decal("scorch", tr.HitPos - tr.HitNormal, tr.HitPos + tr.HitNormal)
					
					if tr.Entity ~= Entity(0) then
						if simfphys.IsCar( tr.Entity ) || tr.Entity.LFS || tr.Entity.IdentifiesAsLFS then
							local effectdata = EffectData()
								effectdata:SetOrigin( tr.HitPos )
								effectdata:SetNormal( tr.HitNormal )
							util.Effect( "manhacksparks", effectdata, true, true )
							
							sound.Play( Sound( ImpactSounds[ math.random(1,table.Count( ImpactSounds )) ] ), tr.HitPos, 140)
						end
					end
				end

			self:FireBullets( bullet )

			local splash_dmginfo = DamageInfo()
				splash_dmginfo:SetAttacker( IsValid( self.Attacker ) and self.Attacker or self )
				splash_dmginfo:SetInflictor( IsValid( self.AttackingEnt ) and self.AttackingEnt or self )
				splash_dmginfo:SetDamage(self.BlastDamage)
				splash_dmginfo:SetDamageType(DMG_SONIC)
			util.BlastDamageInfo(splash_dmginfo, self:GetPos(), self.BlastRadius)
		
			self:Remove()
		end
	else
		self:SetPos( self:GetPos() + self.Vel * FixTick )
		
		local Rate = FrameTime() * 30
		
		self.smVal = self.smVal and self.smVal + math.Clamp(15 - self.smVal,-Rate,Rate)  or 0
		
		self.Vel = self.Vel - Vector(0,0,self.smVal / 100) * FixTick
	end
	
	if (self.SpawnTime + 12) < curtime then
		self:Remove()
	end
	
	return true
end

function ENT:PhysicsCollide( data )
end

function ENT:OnTakeDamage( dmginfo )
	return
end

function ENT:Use( activator, caller )
end

function ENT:OnRemove()
	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
	util.Effect( self:GetBlastEffect(), effectdata )
end