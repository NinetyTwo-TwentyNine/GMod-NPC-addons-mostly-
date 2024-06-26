function ENT:ApplyDamage( damage, type, attacker )
	if bit.band(type, DMG_BLAST) != 0 || bit.band(type, DMG_BLAST_SURFACE) != 0 then 
		damage = damage * 10
	elseif bit.band(type, DMG_AIRBOAT) != 0 then 
		damage = damage * 3
	elseif bit.band(type, DMG_BULLET) then 
		damage = damage * 2
	end

	if IsValid(attacker) then
		local Driver = self:GetDriver()
		if IsValid(Driver) && Driver:IsNPC() then
			Driver:MarkTookDamageFromEnemy( attacker )
			Driver:UpdateEnemyMemory( attacker, attacker:GetPos() )
		end

		if self.PassengerSeats then
			for i = 1, table.Count( self.PassengerSeats ) do
				local Passenger = self.pSeat[i]:GetDriver()
				if IsValid(Passenger) && Passenger:IsNPC() then
					Passenger:UpdateEnemyMemory( attacker, attacker:GetPos() )
				end
			end
		end
	end
	
	local MaxHealth = self:GetMaxHealth()
	local CurHealth = self:GetCurHealth()
	
	local NewHealth = math.max( math.Round(CurHealth - damage,0) , 0 )
	
	if NewHealth <= (MaxHealth * 0.6) then
		if NewHealth <= (MaxHealth * 0.3) then
			self:SetOnFire( true )
			self:SetOnSmoke( false )
		else
			self:SetOnSmoke( true )
		end
	end
	
	if MaxHealth > 30 and NewHealth <= 31 then
		if self:EngineActive() then
			self:DamagedStall()
		end
	end
	
	if NewHealth <= 0 then
		if (bit.band(type, DMG_CRUSH) == 0 and bit.band(type, DMG_GENERIC) == 0) or damage > MaxHealth then
			
			self:ExplodeVehicle()
			
			return
		end
		
		if self:EngineActive() then
			self:DamagedStall()
		end
		
		self:SetCurHealth( 0 )
		
		return
	end
	
	self:SetCurHealth( NewHealth )
end

function ENT:HurtPlayers( damage )
	if not simfphys.pDamageEnabled then return end
	
	local Driver = self:GetDriver()
	
	if IsValid( Driver ) then
		if self.RemoteDriver ~= Driver then
			Driver:TakeDamage(damage, Entity(0), self )
		end
	end
	
	if self.PassengerSeats then
		for i = 1, table.Count( self.PassengerSeats ) do
			local Passenger = self.pSeat[i]:GetDriver()
			
			if IsValid(Passenger) then
				Passenger:TakeDamage(damage, Entity(0), self )
			end
		end
	end
end

function ENT:ExplodeVehicle()
	if not IsValid( self ) then return end
	if self.destroyed then return end
	
	self.destroyed = true

	local ply = self.EntityOwner
	local skin = self:GetSkin()
	local Col = self:GetColor()
	Col.r = Col.r * 0.8
	Col.g = Col.g * 0.8
	Col.b = Col.b * 0.8
	
	if self.GibModels then
		local bprop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
		bprop:SetModel( self.GibModels[1] )
		bprop:SetPos( self:GetPos() )
		bprop:SetAngles( self:GetAngles() )
		bprop.MakeSound = true
		bprop:Spawn()
		bprop:Activate()
		bprop:GetPhysicsObject():SetVelocity( self:GetVelocity() + Vector(math.random(-5,5),math.random(-5,5),math.random(150,250)) ) 
		bprop:GetPhysicsObject():SetMass( self.Mass * 0.75 )
		bprop.DoNotDuplicate = true
		bprop:SetColor( Col )
		bprop:SetSkin( skin )
		
		self.Gib = bprop
		
		simfphys.SetOwner( ply , bprop )
		
		if IsValid( ply ) then
			undo.Create( "Gib" )
			undo.SetPlayer( ply )
			undo.AddEntity( bprop )
			undo.SetCustomUndoText( "Undone Gib" )
			undo.Finish( "Gib" )
			ply:AddCleanup( "Gibs", bprop )
		end
		
		bprop.Gibs = {}
		for i = 2, table.Count( self.GibModels ) do
			local prop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
			prop:SetModel( self.GibModels[i] )			
			prop:SetPos( self:GetPos() )
			prop:SetAngles( self:GetAngles() )
			prop:SetOwner( bprop )
			prop:Spawn()
			prop:Activate()
			prop.DoNotDuplicate = true
			bprop:DeleteOnRemove( prop )
			bprop.Gibs[i-1] = prop
			
			local PhysObj = prop:GetPhysicsObject()
			if IsValid( PhysObj ) then
				PhysObj:SetVelocityInstantaneous( VectorRand() * 500 + self:GetVelocity() + Vector(0,0,math.random(150,250)) )
				PhysObj:AddAngleVelocity( VectorRand() )
			end
			
			
			simfphys.SetOwner( ply , prop )
		end
	else
		
		local bprop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
		bprop:SetModel( self:GetModel() )			
		bprop:SetPos( self:GetPos() )
		bprop:SetAngles( self:GetAngles() )
		bprop.MakeSound = true
		bprop:Spawn()
		bprop:Activate()
		bprop:GetPhysicsObject():SetVelocity( self:GetVelocity() + Vector(math.random(-5,5),math.random(-5,5),math.random(150,250)) ) 
		bprop:GetPhysicsObject():SetMass( self.Mass * 0.75 )
		bprop.DoNotDuplicate = true
		bprop:SetColor( Col )
		bprop:SetSkin( skin )
		for i = 0, self:GetNumBodyGroups() do
			bprop:SetBodygroup(i, self:GetBodygroup(i))
		end
		
		self.Gib = bprop
		
		simfphys.SetOwner( ply , bprop )
		
		if IsValid( ply ) then
			undo.Create( "Gib" )
			undo.SetPlayer( ply )
			undo.AddEntity( bprop )
			undo.SetCustomUndoText( "Undone Gib" )
			undo.Finish( "Gib" )
			ply:AddCleanup( "Gibs", bprop )
		end
		
		if self.CustomWheels == true and not self.NoWheelGibs then
			bprop.Wheels = {}
			for i = 1, table.Count( self.GhostWheels ) do
				local Wheel = self.GhostWheels[i]
				if IsValid(Wheel) then
					local prop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
					prop:SetModel( Wheel:GetModel() )			
					prop:SetPos( Wheel:LocalToWorld( Vector(0,0,0) ) )
					prop:SetAngles( Wheel:LocalToWorldAngles( Angle(0,0,0) ) )
					prop:SetOwner( bprop )
					prop:Spawn()
					prop:Activate()
					prop:GetPhysicsObject():SetVelocity( self:GetVelocity() + Vector(math.random(-5,5),math.random(-5,5),math.random(0,25)) )
					prop:GetPhysicsObject():SetMass( 20 )
					prop.DoNotDuplicate = true
					bprop:DeleteOnRemove( prop )
					bprop.Wheels[i] = prop
					
					simfphys.SetOwner( ply , prop )
				end
			end
		end
	end

	local effectdata = EffectData()
		effectdata:SetOrigin( self:LocalToWorld( self:OBBCenter() ) )
	util.Effect( "lfs_explosion", effectdata )


	local Driver = self:GetDriver()
	if IsValid( Driver ) then
		if self.RemoteDriver ~= Driver then
			Driver:TakeDamage( Driver:Health() + Driver:Armor(), self.LastAttacker or Entity(0), self.LastInflictor or Entity(0) )
		end
	end
	
	if self.PassengerSeats then
		for i = 1, table.Count( self.PassengerSeats ) do
			local Passenger = self.pSeat[i]:GetDriver()
			if IsValid( Passenger ) then
				Passenger:TakeDamage( Passenger:Health() + Passenger:Armor(), self.LastAttacker or Entity(0), self.LastInflictor or Entity(0) )
			end
		end
	end

	self:Extinguish() 
	
	self:OnDestroyed()
	
	hook.Run( "simfphysOnDestroyed", self, self.Gib )
	
	self:Remove()
end

function ENT:OnTakeDamage( dmginfo )
	if not self:IsInitialized() then return end
	
	if hook.Run( "simfphysOnTakeDamage", self, dmginfo ) then return end
	
	local Damage = dmginfo:GetDamage() 
	local DamagePos = dmginfo:GetDamagePosition() 
	local Type = dmginfo:GetDamageType()
	local Driver = self:GetDriver()
	
	self.LastAttacker = dmginfo:GetAttacker() 
	self.LastInflictor = dmginfo:GetInflictor()
	
	if simfphys.DamageEnabled then
		net.Start( "simfphys_spritedamage" )
			net.WriteEntity( self )
			net.WriteVector( self:WorldToLocal( DamagePos ) ) 
			net.WriteBool( false ) 
		net.Broadcast()
		
		self:ApplyDamage( Damage, Type, self.LastAttacker )
	end

	if self.IsArmored then return end
	
	if IsValid(Driver) then
		local Distance = (DamagePos - Driver:GetPos()):Length() 
		if (Distance < 70) then
			local Damage = (70 - Distance) / 22
			dmginfo:ScaleDamage( Damage )
			Driver:TakeDamageInfo( dmginfo )
			
			local effectdata = EffectData()
				effectdata:SetOrigin( DamagePos )
			util.Effect( "BloodImpact", effectdata, true, true )
		end
	end
	
	if self.PassengerSeats then
		for i = 1, table.Count( self.PassengerSeats ) do
			local Passenger = self.pSeat[i]:GetDriver()
			
			if IsValid(Passenger) then
				local Distance = (DamagePos - Passenger:GetPos()):Length()
				local Damage = (70 - Distance) / 22
				if (Distance < 70) then
					dmginfo:ScaleDamage( Damage )
					Passenger:TakeDamageInfo( dmginfo )
					
					local effectdata = EffectData()
						effectdata:SetOrigin( DamagePos )
					util.Effect( "BloodImpact", effectdata, true, true )
				end
			end
		end
	end
end

local function Spark( pos , normal , snd )
	local effectdata = EffectData()
	effectdata:SetOrigin( pos - normal )
	effectdata:SetNormal( -normal )
	util.Effect( "stunstickimpact", effectdata, true, true )
	
	if snd then
		sound.Play( Sound( snd ), pos, 75)
	end
end

function ENT:PhysicsCollide( data, physobj )

	if hook.Run( "simfphysPhysicsCollide", self, data, physobj ) then return end

	if IsValid( data.HitEntity ) then
		if data.HitEntity:IsNPC() or data.HitEntity:IsNextBot() or data.HitEntity:IsPlayer() then
			Spark( data.HitPos , data.HitNormal , "MetalVehicle.ImpactSoft" )
			return
		end
	end
	
	if ( data.Speed > 60 && data.DeltaTime > 0.2 ) then
		
		local pos = data.HitPos

		local physics_dmginfo = DamageInfo()
			physics_dmginfo:SetAttacker( Entity(0) )
			physics_dmginfo:SetInflictor( Entity(0) )
			physics_dmginfo:SetDamageType( DMG_CLUB )
		
		if (data.Speed > 1000) then
			Spark( pos , data.HitNormal , "MetalVehicle.ImpactHard" )
			
			self:HurtPlayers( 5 )
			
			physics_dmginfo:SetDamage( (data.Speed / 7) * simfphys.DamageMul )
			self:TakeDamageInfo( physics_dmginfo )
		else
			Spark( pos , data.HitNormal , "MetalVehicle.ImpactSoft" )
			
			if data.Speed > 250 then
				local hitent = data.HitEntity:IsPlayer()
				if not hitent then
					if simfphys.DamageMul > 1 then
						physics_dmginfo:SetDamage( (data.Speed / 28) * simfphys.DamageMul )
						self:TakeDamageInfo( physics_dmginfo )
					end
				end
			end
			
			if data.Speed > 500 then
				self:HurtPlayers( 2 )

				physics_dmginfo:SetDamage( (data.Speed / 14) * simfphys.DamageMul )
				self:TakeDamageInfo( physics_dmginfo )
			end
		end
	end
end
