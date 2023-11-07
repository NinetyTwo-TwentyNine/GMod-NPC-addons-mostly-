--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile()

ENT.Type            = "anim"

function ENT:SetupDataTables()
	self:NetworkVar( "Bool",0, "Disabled" )
	self:NetworkVar( "Bool",1, "CleanMissile" )
	self:NetworkVar( "Bool",2, "DirtyMissile" )
	self:NetworkVar( "Entity",0, "Attacker" )
	self:NetworkVar( "Entity",1, "Inflictor" )
	self:NetworkVar( "Entity",2, "LockOn" )
	self:NetworkVar( "Float",0, "StartVelocity" )
end

if SERVER then
	local ImpactSounds = {
		"physics/metal/metal_sheet_impact_bullet1.wav",
		"weapons/rpg/shotdown.wav",
	}

	function ENT:SpawnFunction( ply, tr, ClassName )

		if not tr.Hit then return end

		local ent = ents.Create( ClassName )
		ent:SetPos( tr.HitPos + tr.HitNormal * 20 )
		ent:Spawn()
		ent:Activate()

		return ent

	end

	function ENT:BlindFire()
		if self:GetDisabled() then return end
		
		local pObj = self:GetPhysicsObject()
		
		if IsValid( pObj ) then
			pObj:SetVelocityInstantaneous( self:GetForward() * (self:GetStartVelocity() + 3000) )
		end
	end
	
	function ENT:FollowTarget( followent )
		local speed = self:GetStartVelocity() + (self:GetDirtyMissile() and 5000 or 3500)
		local turnrate = (self:GetCleanMissile() or self:GetDirtyMissile()) and 60 or 50
		
		local TargetPos = followent:LocalToWorld( followent:OBBCenter() )
		
		if isfunction( followent.GetMissileOffset ) then
			local Value = followent:GetMissileOffset()
			if isvector( Value ) then
				TargetPos = followent:LocalToWorld( Value )
			end
		end
		
		local pos = TargetPos + followent:GetVelocity() * 0.25
		
		local pObj = self:GetPhysicsObject()
		
		if IsValid( pObj ) then
			if not self:GetDisabled() then
				local targetdir = (pos - self:GetPos()):GetNormalized()
				
				local AF = self:WorldToLocalAngles( targetdir:Angle() )
				AF.p = math.Clamp( AF.p * 400,-turnrate,turnrate )
				AF.y = math.Clamp( AF.y * 400,-turnrate,turnrate )
				AF.r = math.Clamp( AF.r * 400,-turnrate,turnrate )
				
				local AVel = pObj:GetAngleVelocity()
				pObj:AddAngleVelocity( Vector(AF.r,AF.p,AF.y) - AVel ) 
				
				pObj:SetVelocityInstantaneous( self:GetForward() * speed )
			end
		end
	end

	function ENT:Initialize()	
		self:SetModel( "models/weapons/w_missile_launch.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		self:PhysWake()
		local pObj = self:GetPhysicsObject()
		
		if IsValid( pObj ) then
			pObj:EnableGravity( false ) 
			pObj:SetMass( 1 ) 
		end
		
		self.SpawnTime = CurTime()
		self.Filter = {self.Owner}
	end

	function ENT:Think()	
		local curtime = CurTime()
		self:NextThink( curtime )
		
		local Target = self:GetLockOn()
		if IsValid( Target ) then
			self:FollowTarget( Target )
			self.RemoveTimer = 0
		else
			self:BlindFire()
			self.RemoveTimer = (self.RemoveTimer or 0) + FrameTime()
			if self.RemoveTimer >= 15 then
				self.MarkForRemove = true
			end
		end

		if self.SpawnTime + 0.2 < curtime then
			local trace = util.TraceHull( {
				start = self:GetPos(),
				endpos = self:GetPos() + self:GetVelocity() * FrameTime(),
				maxs = self:OBBMaxs(),
				mins = self:OBBMins(),
				mask = MASK_SOLID,
				filter = function( ent )
					if ent ~= self and not table.HasValue( self.Filter, ent ) then return true end
				end
			} )
			if trace.Hit || self.MarkForRemove then
				self:Detonate(trace.HitPos)
			end
		end
		
		return true
	end

	local IsThisSimfphys = {
		["gmod_sent_vehicle_fphysics_base"] = true,
		["gmod_sent_vehicle_fphysics_wheel"] = true,
	}
	
	function ENT:PhysicsCollide( data )
		//if !IsValid(self:GetLockOn()) then
			self:Detonate(data.HitPos)
		//end
	end

	function ENT:BreakMissile()
		if not self:GetDisabled() then
			self:SetDisabled( true )
			
			local pObj = self:GetPhysicsObject()
			
			if IsValid( pObj ) then
				pObj:EnableGravity( true )
				self:PhysWake()
				self:EmitSound( "Missile.ShotDown" )
			end
		end
	end

	function ENT:Detonate(target_pos)
		local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
		util.Effect( "lfs_missile_explosion", effectdata )

		if not self.Explode then
			self.Explode = true

			local Dir = self:GetForward()
			if isvector(target_pos) then
				Dir = (target_pos - self:GetPos()):Angle():Forward()
			end
			local Pos = self:GetPos() - Dir * 10

			local bullet = {}
				bullet.Num 			= 1
				bullet.Src 			= Pos
				bullet.Dir 			= Dir
				bullet.Spread 		= Vector(0,0,0)
				bullet.Distance		= 100
				bullet.Tracer		= 0
				bullet.TracerName	= "simfphys_tracer"
				bullet.Force		= 30000
				bullet.Damage		= self:GetDirtyMissile() and 300 or 175
				bullet.HullSize		= self:OBBMaxs() - self:OBBMins()
				bullet.Attacker 	= IsValid( self:GetAttacker() ) and self:GetAttacker() or self
				bullet.Callback = function(att, tr, dmginfo)
					dmginfo:SetDamageType(DMG_BLAST + DMG_AIRBOAT)
					
					if tr.Entity ~= Entity(0) then
						if tr.Entity.LFS or tr.Entity.IdentifiesAsLFS or IsThisSimfphys[ tr.Entity:GetClass() ] then
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
				splash_dmginfo:SetAttacker( IsValid( self:GetAttacker() ) and self:GetAttacker() or self )
				splash_dmginfo:SetInflictor( self ) 
				splash_dmginfo:SetDamageType(DMG_SONIC)
				splash_dmginfo:SetDamage(100)
			util.BlastDamageInfo(splash_dmginfo, self:GetPos(), 200)
		end

		self:Remove()
	end

	function ENT:OnTakeDamage( dmginfo )	
		if dmginfo:GetDamageType() ~= DMG_AIRBOAT then return end
		
		if self:GetAttacker() == dmginfo:GetAttacker() then return end
		
		self:BreakMissile()
	end

	function ENT:OnTakeDamage( dmginfo )	
		if !dmginfo:IsDamageType(DMG_AIRBOAT) then return end
		
		if self:GetAttacker() == dmginfo:GetAttacker() then return end
		
		self:BreakMissile()
	end
else
	function ENT:Initialize()	
		self.snd = CreateSound(self, "weapons/flaregun/burn.wav")
		self.snd:Play()

		local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
			effectdata:SetEntity( self )
		util.Effect( "lfs_missile_trail", effectdata )
	end

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:SoundStop()
		if self.snd then
			self.snd:Stop()
		end
	end

	function ENT:Think()
		if self:GetDisabled() then 
			self:SoundStop()
		end

		return true
	end

	function ENT:OnRemove()
		self:SoundStop()
	end
end