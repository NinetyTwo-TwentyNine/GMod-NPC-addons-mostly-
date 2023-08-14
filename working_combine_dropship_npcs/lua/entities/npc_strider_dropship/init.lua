AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )

function ENT:SpawnFunction( tr )
if ( !tr.Hit ) then return end
	
local SpawnPos = tr.HitPos + tr.HitNormal * 6
self.Spawn_angles = ply:GetAngles()
self.Spawn_angles.pitch = 0
self.Spawn_angles.roll = 0
self.Spawn_angles.yaw = self.Spawn_angles.yaw + 180
	
local ent = ents.Create( "npc_slightly_improved_gunship" )
ent:SetKeyValue( "disableshadows", "1" )
ent:SetAngles( self.Spawn_angles )
ent:SetPos(SpawnPos)
ent:Spawn()

return ent
end


function ENT:Initialize()
self:SetModel("models/props_lab/huladoll.mdl")
self:SetNoDraw(true)
self:DrawShadow(false)
self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
self:SetName(self.PrintName)
self:SetOwner(self.Owner)

self.npc = ents.Create( "npc_combinedropship" )
self.npc:SetPos(self:GetPos() + self:GetUp()*300)
self.npc:SetAngles(self:GetAngles())
self.npc:SetKeyValue( "squadname", "overwatch" )
self.npc:SetKeyValue( "GunRange", "3000" )
self.npc:SetKeyValue( "CrateType", "-1" )
self.npc:SetNWBool( "HasStrider", true )
self.npc:SetNWBool( "HasTroops", false )
self.npc:SetSpawnEffect(false)
self.npc:Spawn()
self.npc:Activate()
self:SetParent(self.npc)
self.npc:SetHealth(100)
self.npc:SetMaxHealth(100)
self.npc:CapabilitiesAdd( CAP_MOVE_FLY )
self.npc:CapabilitiesAdd(CAP_SQUAD)
if IsValid(self.npc) and IsValid(self) then self.npc:DeleteOnRemove(self) end
self:DeleteOnRemove(self.npc)

if( IsValid(self.npc))then
local min,max = self.npc:GetCollisionBounds()
local hull = self.npc:GetHullType()
self.npc:SetSolid(SOLID_BBOX)
self.npc:SetCollisionGroup(COLLISION_GROUP_NPC)
self.npc:SetMoveType( MOVETYPE_FLY ) 
self.npc:SetKeyValue( "Invulnerable", "0" )
self.npc:SetName( "Strider DropShip" )
self.npc:SetKeyValue( "spawnflags", "32768" )
self.npc:SetPos(self.npc:GetPos())
self.npc:SetHullType(hull)
self.npc:SetHullSizeNormal()
self.npc:SetCollisionBounds(min,max)
self.npc:DropToFloor()
self.npc:SetModelScale(1)
self.StriderDrooped = false
end
end

function ENT:Think()
local npc = self.npc

self:DropStrider(npc)
self:CreateRagdoll(npc)
self:Relationship(npc)
self:Strider_Deployed_ByShiper(npc)
self:FlyAwayWhenStriderHasBeenDeployed(npc)
self:YouHaveHitTheEdgeOfTheMap(npc)

end

function ENT:Relationship(npc)

local citizens = ents.FindByClass( "npc_citizen" )
	for _, x in pairs( citizens ) do
		if !x:IsNPC() then return end
		if x:GetClass() ~= self:GetClass() and IsValid(x) and IsValid(x:GetActiveWeapon()) and x:GetActiveWeapon():GetClass() == "weapon_rpg" then 
		x:AddEntityRelationship( npc, D_HT, 99 )
		npc:AddEntityRelationship( x, D_HT, 99 )
		end
	end
end

hook.Add("EntityTakeDamage", "Strider Dropship Will Take Damage Now", function(ent, dmginfo)
if ent:GetName() == "Strider DropShip" and dmginfo:IsDamageType(DMG_BLAST) and ent:Health() > 0 then
ent:SetHealth(ent:Health()-30)
end

end)

function ENT:DropStrider(npc)
local npc = self.npc
local EnemyPosition = npc:GetEnemy()
if npc:GetNWBool( "HasStrider" ) == false then return end
if IsValid(npc:GetEnemy()) and npc:GetEnemy():IsOnGround() and not self.LandZoneReady then
self.strider_landing = ents.Create("path_track")
local strider_landing_name = "PlaceToFakeLand" .. self.strider_landing:EntIndex()
self.strider_landing:SetName( strider_landing_name )
self.strider_landing:SetPos( EnemyPosition:GetPos() + EnemyPosition:GetForward()*math.random(400,1100) + EnemyPosition:GetUp()*560 )
self.strider_landing:Spawn()
npc:Fire("SetTrack", strider_landing_name )
	self.LandZoneReady = true
end
if IsValid(self.strider_landing) and npc:GetPos():Distance(self.strider_landing:GetPos()) <= 70 then
	self.IAmAtLandingPoint = true
else
	self.IAmAtLandingPoint = false
end
if npc:GetNWBool( "HasStrider" ) == true and self.LandZoneReady then
timer.Create("DeployingStriderFromShip"..self.strider_landing:EntIndex(),1.5,math.Round(10),function()

if npc:GetNWBool( "HasStrider" ) == true then


	timer.Simple(15,function()
		if IsValid(npc) and npc:GetNWBool( "HasStrider" ) == true and self.IAmAtLandingPoint then
		npc:Fire( "DropStrider" )
		npc:SetNWBool( "HasStrider", false )
		npc:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		end
	end)


timer.Simple(100,function()
if IsValid(npc) and npc:GetNWBool( "HasStrider" ) == false then
	npc:SetCollisionGroup(COLLISION_GROUP_NPC)
end
end)

end
end)

end
end

function ENT:CreateRagdoll(npc)
local npc = self.npc
if npc:Health() <= 0 and math.random(1,1000) ~= 997 then

self.esplersion = ents.Create( "env_explosion")
self.esplersion:SetPos(npc:GetPos())
self.esplersion:SetAngles(npc:GetAngles())
self.esplersion:Spawn()
self.esplersion:Activate()
self.esplersion:Fire("Explode")

timer.Simple(0.3,function()
	esplersion1 = ents.Create( "env_explosion")
	esplersion1:SetPos(DropShip_Corpse:GetPos())
	esplersion1:SetAngles(DropShip_Corpse:GetAngles())
	esplersion1:Spawn()
	esplersion1:Activate()
	esplersion1:Fire("Explode")
end)

timer.Simple(1,function()
	esplersion2 = ents.Create( "env_explosion")
	esplersion2:SetPos(DropShip_Corpse:GetPos())
	esplersion2:SetAngles(DropShip_Corpse:GetAngles())
	esplersion2:Spawn()
	esplersion2:Activate()
	esplersion2:Fire("Explode")
end)

timer.Simple(1.1,function()
	esplersion3 = ents.Create( "env_explosion")
	esplersion3:SetPos(DropShip_Corpse:GetPos())
	esplersion3:SetAngles(DropShip_Corpse:GetAngles())
	esplersion3:Spawn()
	esplersion3:Activate()
	esplersion3:Fire("Explode")
end)

timer.Simple(1.5,function()
	esplersion4 = ents.Create( "env_explosion")
	esplersion4:SetPos(DropShip_Corpse:GetPos())
	esplersion4:SetAngles(DropShip_Corpse:GetAngles())
	esplersion4:Spawn()
	esplersion4:Activate()
	esplersion4:Fire("Explode")
end)

timer.Simple(1.7,function()
	esplersion5 = ents.Create( "env_explosion")
	esplersion5:SetPos(DropShip_Corpse:GetPos())
	esplersion5:SetAngles(DropShip_Corpse:GetAngles())
	esplersion5:Spawn()
	esplersion5:Activate()
	esplersion5:Fire("Explode")
end)

timer.Simple(2,function()
	esplersion6 = ents.Create( "env_explosion")
	esplersion6:SetPos(DropShip_Corpse:GetPos())
	esplersion6:SetAngles(DropShip_Corpse:GetAngles())
	esplersion6:Spawn()
	esplersion6:Activate()
	esplersion6:Fire("Explode")
end)

	DropShip_Corpse = ents.Create("prop_ragdoll")
	DropShip_Corpse:SetModel( "models/combine_dropship.mdl" )
	DropShip_Corpse:SetPos( npc:GetPos() )
	DropShip_Corpse:SetAngles( npc:GetAngles() )
	DropShip_Corpse:SetBodygroup(0, 1)
	DropShip_Corpse:SetBodygroup(1, 1)
	DropShip_Corpse:SetNotSolid(false)
	DropShip_Corpse:SetNoDraw(false)
	DropShip_Corpse:Spawn()

	undo.Create( "Strider Dropship" )
	undo.AddEntity( DropShip_Corpse )	
	undo.SetCustomUndoText( "Undone Strider Dropship" )
	for _, Strider_DropShip_Corpse_To_Undo in pairs( player.GetAll()) do 
		undo.SetPlayer(Strider_DropShip_Corpse_To_Undo) 
	end 
	undo.Finish()

	npc:Remove()
end
end

function ENT:Strider_Deployed_ByShiper(npc)

	for _, Deplerd_Stroodor in pairs ( ents.FindByClass( "npc_strider" ) ) do
		if self.StriderDrooped then return end
		if not self.StriderDrooped and self.IAmAtLandingPoint and Deplerd_Stroodor:GetName() ~= Deployed_Strider_Name then
		self.StriderDrooped = true
		timer.Simple(5,function()
			if IsValid(Deplerd_Stroodor) then
		self.Deployed_Strider = ents.Create( "npc_strider" )
		self.Deployed_Strider:SetKeyValue( "spawnflags", "644" )
		local Deployed_Strider_Name = "StriderThatWasDeployed" .. self.Deployed_Strider:EntIndex()
		self.Deployed_Strider:SetName( Deployed_Strider_Name )
		self.Deployed_Strider:SetPos( Deplerd_Stroodor:GetPos() )
		self.Deployed_Strider:SetAngles( Deplerd_Stroodor:GetAngles() + Angle(0,0,180) )
		self.Deployed_Strider:Spawn()
		self.Deployed_Strider:Activate()

		self.SequencePlayed = false
		self.Deployed_Strider_Sequence = ents.Create( "scripted_sequence" )
		self.Deployed_Strider_Sequence:SetName( Deployed_Strider_Name .. "_wake_seq" )
		self.Deployed_Strider_Sequence:SetKeyValue( "spawnflags", "624" )
		self.Deployed_Strider_Sequence:SetKeyValue( "m_iszEntity", Deployed_Strider_Name )
		self.Deployed_Strider_Sequence:SetKeyValue( "m_iszIdle", "carried" )
		self.Deployed_Strider_Sequence:SetKeyValue( "m_fMoveTo", "4" )
		self.Deployed_Strider_Sequence:SetKeyValue( "m_iszPlay", "Deploy" )
		self.Deployed_Strider_Sequence:SetPos( self.Deployed_Strider:GetPos() )
		self.Deployed_Strider_Sequence:Spawn()
		self.Deployed_Strider_Sequence:Activate()
		self.Deployed_Strider_Sequence:SetParent( self.Deployed_Strider )
			if self.SequencePlayed == false then
			self.Deployed_Strider_Sequence:Fire( "BeginSequence", "", 0 )
			self.SequencePlayed = true
			end
				undo.Create( "Deployed Strider" )
				undo.AddEntity( self.Deployed_Strider )	
				undo.SetCustomUndoText( "Undone Deployed Strider" )
			for _, Strider_DropShip_Corpse_To_Undo in pairs( player.GetAll()) do 
				undo.SetPlayer(Strider_DropShip_Corpse_To_Undo) 
			end 
			undo.Finish()

			Deplerd_Stroodor:Remove()
			timer.Simple(4,function()
				self.Time_To_Get_The_Fuck_Outta_Here = true
			end)
		end
		end)
		end
	end
end


function ENT:FlyAwayWhenStriderHasBeenDeployed( npc )
	if self.Time_To_Get_The_Fuck_Outta_Here and not self.FoundMyEscapeRoute then
		self.FoundMyEscapeRoute = true
		self.Rendezvous_Point = ents.Create( "path_track" )
		self.Rendezvous_Point:SetPos( npc:GetPos() + Vector(9999,9999,9999) )
		local Rendezvous_Point_Name = "Rendezvous_Point".. self.Rendezvous_Point:EntIndex()
		self.Rendezvous_Point:SetName( Rendezvous_Point_Name )
		self.Rendezvous_Point:Spawn()
		npc:Fire( "FlyToPathTrack", Rendezvous_Point_Name )
	end
end

function ENT:YouHaveHitTheEdgeOfTheMap(npc)
	local npc = self.npc
	local Trace = util.QuickTrace( npc:GetPos(), npc:GetForward()*300, npc )
	if IsValid(npc) and IsValid(self.Rendezvous_Point) and self.FoundMyEscapeRoute and npc:GetPos():Distance(self.Rendezvous_Point:GetPos()) ~= self.Rendezvous_Point:GetPos() and (!Trace.Hit || npc:NearestPoint(Trace.HitPos):Distance(Trace.HitPos) <= 300) and Trace.HitWorld and not util.IsInWorld( npc:GetForward()*300 ) then
		if math.random(1,2) == 1 then
		print("'GOD DAMN IT ROSS!' - All of the Game Grumps")
		elseif math.random(1,2) == 2 then
		print("'I think it gave you credit for the 50. WHAT THE FUCK?!' - Dan Avidan 2015")
		else
		print("'I have reached the singularity!' - Arin Hanson 2017")
		end
		npc:Remove()
	elseif IsValid(npc) and IsValid(self.Rendezvous_Point) and self.FoundMyEscapeRoute and npc:GetPos():Distance(self.Rendezvous_Point:GetPos()) <= 50 then
		if math.random(1,2) == 1 then
		print("'GOD DAMN IT ROSS!' - All of the Game Grumps")
		elseif math.random(1,2) == 2 then
		print("'I think it gave you credit for the 50. WHAT THE FUCK?!' - Dan Avidan 2015")
		else
		print("'I have reached the singularity!' - Arin Hanson 2017")
		end
		npc:Remove()
		elseif IsValid(npc) and IsValid(self.Rendezvous_Point) and self.FoundMyEscapeRoute and npc:GetPos():Distance(self.Rendezvous_Point:GetPos()) > 50 and util.IsInWorld( npc:GetForward()*300 ) then
			timer.Simple(60,function()
				if IsValid(npc) then
						if math.random(1,2) == 1 then
						print("'GOD DAMN IT ROSS!' - All of the Game Grumps")
						elseif math.random(1,2) == 2 then
						print("'I think it gave you credit for the 50. WHAT THE FUCK?!' - Dan Avidan 2015")
						else
						print("'I have reached the singularity!' - Arin Hanson 2017")
						end
					npc:Remove()
				end
			end)
	end
end



function ENT:OnRemove()
if IsValid(self.npc) then
self.npc:Remove()
end
end