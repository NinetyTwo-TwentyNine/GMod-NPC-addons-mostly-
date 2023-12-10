--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	if self:GetAI() then
		self:EmitSound( "SPITFIRE_FIRE_LASTSHOT" )
	end

	self:SetNextPrimary( 0.03 )

	local fP = {
		Vector(141.83,-121.84,68.4),
		Vector(141.83,121.84,68.4),
		Vector(136.44,-128.69,68.49),
		Vector(136.44,128.69,68.49),
		Vector(129.23,-135.24,68.31),
		Vector(129.23,135.24,68.31),
		Vector(122.84,-142.46,68.32),
		Vector(122.84,142.46,68.32)
	}

	self.NumPrim = self.NumPrim and self.NumPrim + 1 or 1
	if self.NumPrim > 8 then self.NumPrim = 1 end

	local Attacker = self
	if IsValid( self:GetDriver() ) then Attacker = self:GetDriver()
	elseif IsValid( self:AIGetSelf() ) then Attacker = self:AIGetSelf() end
	
	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= self:LocalToWorld( fP[self.NumPrim] )
	bullet.Dir 	= self:LocalToWorldAngles( Angle(-0.5,(fP[self.NumPrim].y > 0 and -2 or 2),0) ):Forward()
	bullet.Spread 	= Vector( 0.015,  0.015, 0 )
	bullet.Tracer	= 1
	bullet.TracerName	= "lfs_tracer_green"
	bullet.Force	= 100
	bullet.HullSize 	= 10
	bullet.Damage	= 32
	bullet.Attacker 	= Attacker
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(att, tr, dmginfo)
		dmginfo:SetDamageType(DMG_BULLET)
	end
	self:FireBullets( bullet )
	
	self:TakePrimaryAmmo( 2 )
end

function ENT:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondary( 0.1 )

	self:TakeSecondaryAmmo()
	
	if istable( self.MissileEnts ) then
		local Missile = self.MissileEnts[ self:GetAmmoSecondary() + 1 ]
		Missile:EmitSound( "npc/waste_scanner/grenade_fire.wav" )
		if IsValid( Missile ) then
			local Attacker = self
			if IsValid( self:GetDriver() ) then Attacker = self:GetDriver()
			elseif IsValid( self:AIGetSelf() ) then Attacker = self:AIGetSelf() end

			local ent = ents.Create( "lunasflightschool_missile" )
			local mPos = Missile:GetPos()
			local Ang = self:WorldToLocal( mPos ).y > 0 and -1 or 1
			ent:SetPos( mPos )
			ent:SetAngles( self:LocalToWorldAngles( Angle(0,Ang,0) ) )
			ent:SetOwner( self )
			ent:Spawn()
			ent:Activate()
			ent:SetAttacker( Attacker )
			ent:SetInflictor( self )
			ent:SetStartVelocity( self:GetVelocity():Length() )
			
			if IsValid( self.wheel_R ) then
				table.insert(ent.Filter, self.wheel_R)
			end
			if IsValid( self.wheel_L ) then
				table.insert(ent.Filter, self.wheel_L)
			end
			if IsValid( self.wheel_C ) then
				table.insert(ent.Filter, self.wheel_C)
			end

			for k,v in pairs(ent.Filter) do
				constraint.NoCollide( ent, v, 0, 0 )
			end
		end
	end
end

function ENT:RunOnSpawn()
	if not self:GetAI() then
		self:SetBodygroup( 15, 1 )
	end
	--[[
	if self.LandingGearUp then
		self:SetBodygroup( 13, 0 )
	else
		self:SetBodygroup( 13, 1 ) 
	end
	]]--
	
	self:SetBodygroup( 23, 1 )
	
	self.MissileEnts = {}
	
	for k,v in pairs( self.MISSILES ) do
		for _,n in pairs( v ) do
			local Missile = ents.Create( "prop_dynamic" )
			Missile:SetModel( self.MISSILEMDL )
			Missile:SetPos( self:LocalToWorld( n ) )
			Missile:SetAngles( self:GetAngles() )
			Missile:SetMoveType( MOVETYPE_NONE )
			Missile:Spawn()
			Missile:Activate()
			Missile:SetNotSolid( true )
			Missile:DrawShadow( false )
			Missile:SetParent( self )
			Missile.DoNotDuplicate = true
			self:dOwner( Missile )
			
			table.insert( self.MissileEnts, Missile )
		end
	end
end

function ENT:HandleWeapons(Fire1, Fire2)
	local Driver = self:GetDriver()
	local AI = self:AIGetSelf()

	local Fire1 = false
	local Fire2 = false
	
	if IsValid( Driver ) then
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyDown( IN_ATTACK )
		end
		
		if self:GetAmmoSecondary() > 0 then
			Fire2 = Driver:KeyDown( IN_ATTACK2 )
		end
	elseif IsValid( AI ) then
		local Target = self:AIGetTarget()
			
		if IsValid( Target ) then
			if self:AITargetInfront( Target, 30 ) then
				Fire1 = true

				local TraceFilter = {self,self.wheel_L,self.wheel_R,self.wheel_C}
				local startpos =  self:GetRotorPos()
				local tr = util.TraceHull( {
					start = startpos,
					endpos = (startpos + self:GetForward() * 50000),
					mins = Vector( -30, -30, -30 ),
					maxs = Vector( 30, 30, 30 ),
					filter = TraceFilter
				} )
				if IsValid(tr.Entity) then
					local TraceEntity = tr.Entity

					if TraceEntity != Target then
						TraceEntity = simfphys.IdentifyVehicleTarget(AI, TraceEntity)
					end

					if (self:AIGetRelationship(TraceEntity) == D_HT || self:AIGetRelationship(TraceEntity) == D_FR) && !(TraceEntity:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 1) then
						//if self:AITargetInfront( TraceEntity, 25 ) then
							Fire2 = true
						//end
					elseif self:AIGetRelationship(TraceEntity) == D_LI && !(TraceEntity:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 1) then
						Fire1 = false
					end
				end
			end
		end
	end
	
	if Fire1 then
		self:PrimaryAttack()
	end
	
	if istable( self.MissileEnts ) then
		for k, v in pairs( self.MissileEnts ) do
			if IsValid( v ) then
				if k > self:GetAmmoSecondary() then
					v:SetNoDraw( true )
				else
					v:SetNoDraw( false )
				end
			end
		end
	end
	
	if self.OldFire2 ~= Fire2 then
		if Fire2 then
			self:SecondaryAttack()
		end
		self.OldFire2 = Fire2
	end

	if self.OldFire ~= Fire1 then

		if Fire1 then
			if not self:GetAI() then
				self.wpn1 = CreateSound( self, "SPITFIRE_FIRE_LOOP" )
				self.wpn1:Play()
				self:CallOnRemove( "stopmesounds1", function( ent )
					if ent.wpn1 then
						ent.wpn1:Stop()
					end
				end)
			end
		else
			if self.OldFire == true then
				if self.wpn1 then
					self.wpn1:Stop()
				end
				self.wpn1 = nil

				if not self:GetAI() then
					self:EmitSound( "SPITFIRE_FIRE_LASTSHOT" )
				end
			end
		end
		
		self.OldFire = Fire1
	end
end

function ENT:OnEngineStarted()
	self:EmitSound( "lfs/cessna/start.wav" )
end

function ENT:OnEngineStopped()
	self:EmitSound( "lfs/cessna/stop.wav" )
end

function ENT:OnLandingGearToggled( bOn )
	self:EmitSound( "lfs/bf109/gear.wav" )
	--[[
	if bOn then
		self:SetBodygroup( 13, 0 )
	else
		self:SetBodygroup( 13, 1 ) 
	end
	]]
end

function ENT:OnAICreated()
	self:SetBodygroup( 15, 0 )
end

function ENT:OnAIRemoved()
	self:SetBodygroup( 15, 1 )
end
