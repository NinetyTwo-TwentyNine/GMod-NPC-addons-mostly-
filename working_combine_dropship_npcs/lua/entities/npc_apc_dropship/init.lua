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

		self.Dropship_APC = ents.Create("prop_vehicle_apc" )
		self.Dropship_APC:SetPos(self:GetPos())
		self.Dropship_APC:SetName("Dropship APC"..self.Dropship_APC:EntIndex() )
		self.Dropship_APC:SetKeyValue( "model", "models/combine_apc.mdl" )
		self.Dropship_APC:SetKeyValue( "vehiclescript", "scripts/vehicles/apc_npc.txt" )
		self.Dropship_APC:Spawn()
		self.Dropship_APC:SetOwner( self.npc )
    		self.Dropship_APC:AddEFlags(EFL_DONTBLOCKLOS)

self.npc:SetKeyValue( "squadname", "overwatch" )
self.npc:SetKeyValue( "GunRange", "3000" )
if IsValid(self.Dropship_APC) then
self.npc:SetKeyValue("APCVehicleName", "Dropship APC"..self.Dropship_APC:EntIndex() )
end
self.npc:SetNWBool( "HasAPC", true)
self.npc:SetNWBool( "HasStrider", false )
self.npc:SetNWBool( "HasTroops", false )

self.npc:SetKeyValue( "CrateType", "-2" )

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
self.npc:SetKeyValue( "spawnflags", "32768" )
self.npc:SetName( "APC DropShip" )
self.npc:SetPos(self.npc:GetPos())
self.npc:SetHullType(hull)
self.npc:SetHullSizeNormal()
self.npc:SetCollisionBounds(min,max)
self.npc:DropToFloor()
self.npc:SetModelScale(1)


end
end

function ENT:Think()
local npc = self.npc

self:DropAPC(npc)
self:CreateRagdoll(npc)
self:Relationship(npc)
self:FlyAwayWhenAPCHasBeenDeployed(npc)
self:YouHaveHitTheEdgeOfTheMap(npc)
self:APC_Deployed_ByShiper(npc)

end

function ENT:APC_Deployed_ByShiper(npc)

	for _, Depleried_APC in pairs ( ents.FindByClass( "prop_vehicle_apc" ) ) do
		if self.APCDropped then return end
		local OtherAPCs = ents.FindByClass( "npc_dropship_apc" )
		if not self.APCDropped and self.IAmAtLandingPoint and self.npc:GetNWBool("HasAPC") == false then
		self.APCDropped = true
		if IsValid(Depleried_APC) then

			self.Dropship_APC:Activate()
			self.Dropship_APC:Fire("lock")
			self.Dropship_APC:Fire("TurnOn")

			self.Dropship_APC_Driver = ents.Create( "npc_apcdriver" )
			self.Dropship_APC_Driver:SetKeyValue( "vehicle", "Dropship APC"..self.Dropship_APC:EntIndex() )
			self.Dropship_APC_Driver:SetKeyValue( "driverminspeed", 10 )
			self.Dropship_APC_Driver:SetKeyValue( "drivermaxspeed", 30 )
			self.Dropship_APC_Driver:Spawn()
			self.Dropship_APC_Driver:Activate()

			undo.Create( "Combine APC" )
			undo.AddEntity( self.Dropship_APC )
			undo.SetCustomUndoText( "Undone Combine APC" )
			undo.SetPlayer(self:GetCreator()) 
			undo.Finish()

			timer.Simple(4,function()
				if IsValid(self.npc) and self.npc:GetNWBool("HasAPC") == false then
				self.Time_To_Get_The_Fuck_Outta_Here = true
				end
			end)
			end
		end
	end
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

hook.Add("EntityTakeDamage", "APC Dropship Will Take Damage Now", function(ent, dmginfo)
if ent:GetName() == "APC DropShip" and dmginfo:IsDamageType(DMG_BLAST) and ent:Health() > 0 then
ent:SetHealth(ent:Health()-16)
end

end)

function ENT:DropAPC(npc)
local npc = self.npc
local EnemyPosition = npc:GetEnemy()
if npc:GetNWBool( "HasAPC" ) == false then return end
if IsValid(npc:GetEnemy()) and npc:GetEnemy():IsOnGround() and not self.LandZoneReady then
self.APC_landing = ents.Create("path_track")
local APC_landing_name = "PlaceToDropTheAPC" .. self.APC_landing:EntIndex()
self.APC_landing:SetName( APC_landing_name )
self.APC_landing:SetPos( EnemyPosition:GetPos() + EnemyPosition:GetForward()*math.random(400,1100) + EnemyPosition:GetRight()*math.random(-300,300) + EnemyPosition:GetUp()*150 )
self.APC_landing:Spawn()
npc:Fire("SetTrack", APC_landing_name )
	self.LandZoneReady = true
end
if IsValid(self.APC_landing) and npc:GetPos():Distance(self.APC_landing:GetPos()) <= 70 then
	self.IAmAtLandingPoint = true
else
	self.IAmAtLandingPoint = false
end
if npc:GetNWBool( "HasAPC" ) == true and self.LandZoneReady then
	npc:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
timer.Simple(10,function()
	if IsValid(npc) and npc:GetNWBool("HasAPC") == true then
	npc:Fire( "DropAPC" )
	print("Drop it")
	npc:SetNWBool( "HasAPC", false )
	self.Dropship_APC:SetName( "Dropship APC"..self.Dropship_APC:EntIndex())
	self.Time_To_Get_The_Fuck_Outta_Here = true
	end
	timer.Simple(3,function()
		if IsValid(npc) and npc:GetNWBool("HasAPC") == false then
			npc:SetCollisionGroup(COLLISION_GROUP_NPC)
		end
	end)
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
	if IsValid(DropShip_Corpse) then
	esplersion1 = ents.Create( "env_explosion")
	esplersion1:SetPos(DropShip_Corpse:GetPos())
	esplersion1:SetAngles(DropShip_Corpse:GetAngles())
	esplersion1:Spawn()
	esplersion1:Activate()
	esplersion1:Fire("Explode")
	end
end)

timer.Simple(1,function()
	if IsValid(DropShip_Corpse) then
	esplersion2 = ents.Create( "env_explosion")
	esplersion2:SetPos(DropShip_Corpse:GetPos())
	esplersion2:SetAngles(DropShip_Corpse:GetAngles())
	esplersion2:Spawn()
	esplersion2:Activate()
	esplersion2:Fire("Explode")
	end
end)

timer.Simple(1.1,function()
	if IsValid(DropShip_Corpse) then
	esplersion3 = ents.Create( "env_explosion")
	esplersion3:SetPos(DropShip_Corpse:GetPos())
	esplersion3:SetAngles(DropShip_Corpse:GetAngles())
	esplersion3:Spawn()
	esplersion3:Activate()
	esplersion3:Fire("Explode")
	end
end)

timer.Simple(1.5,function()
	if IsValid(DropShip_Corpse) then
	esplersion4 = ents.Create( "env_explosion")
	esplersion4:SetPos(DropShip_Corpse:GetPos())
	esplersion4:SetAngles(DropShip_Corpse:GetAngles())
	esplersion4:Spawn()
	esplersion4:Activate()
	esplersion4:Fire("Explode")
	end
end)

timer.Simple(1.7,function()
	if IsValid(DropShip_Corpse) then
	esplersion5 = ents.Create( "env_explosion")
	esplersion5:SetPos(DropShip_Corpse:GetPos())
	esplersion5:SetAngles(DropShip_Corpse:GetAngles())
	esplersion5:Spawn()
	esplersion5:Activate()
	esplersion5:Fire("Explode")
	end
end)

timer.Simple(2,function()
	if IsValid(DropShip_Corpse) then
	esplersion6 = ents.Create( "env_explosion")
	esplersion6:SetPos(DropShip_Corpse:GetPos())
	esplersion6:SetAngles(DropShip_Corpse:GetAngles())
	esplersion6:Spawn()
	esplersion6:Activate()
	esplersion6:Fire("Explode")
	end
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

	undo.Create( "APC Dropship" )
	undo.AddEntity( DropShip_Corpse )	
	undo.SetCustomUndoText( "Undone APC Dropship" )
	for _, APC_DropShip_Corpse_To_Undo in pairs( player.GetAll()) do 
		undo.SetPlayer(APC_DropShip_Corpse_To_Undo) 
	end 
	undo.Finish()

	npc:Remove()
end
end


function ENT:FlyAwayWhenAPCHasBeenDeployed( npc )
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