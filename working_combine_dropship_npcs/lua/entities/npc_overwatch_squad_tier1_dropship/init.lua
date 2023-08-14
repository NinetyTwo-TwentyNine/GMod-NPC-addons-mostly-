AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )

function ENT:SpawnFunction( tr )
if ( !tr.Hit ) then return end
	
local SpawnPos = tr.HitPos + tr.HitNormal * 6
self.Spawn_angles = ply:GetAngles()
self.Spawn_angles.pitch = 0
self.Spawn_angles.roll = 0
self.Spawn_angles.yaw = self.Spawn_angles.yaw + 180
	
local ent = ents.Create( "npc_overwatch_squad_tier1_dropship" )
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
self.npc:SetKeyValue( "CrateType", "1" )

self.npc:SetNWBool( "HasTroops", true )
self.npc:SetNWBool( "HasStrider", false )
self.npc:SetSpawnEffect(false)
self.npc:Spawn()
self.npc:Activate()
self:SetParent(self.npc)
self.npc:SetHealth(100)
self.npc:SetMaxHealth(100)
self.npc:CapabilitiesAdd( CAP_MOVE_FLY )
self.npc:CapabilitiesAdd(CAP_SQUAD)
if IsValid(self.npc) and IsValid(self) then self.npc:DeleteOnRemove(self) end
if( IsValid(self.npc))then
local min,max = self.npc:GetCollisionBounds()
local hull = self.npc:GetHullType()
self.npc:SetSolid(SOLID_BBOX)
self.npc:SetCollisionGroup(COLLISION_GROUP_NPC)
self.npc:SetMoveType( MOVETYPE_FLY ) 
self.npc:SetKeyValue( "Invulnerable", "0" )
self.npc:SetName( "Tier 1 Overwatch Dropship")
self.npc:SetKeyValue( "spawnflags", "32768" )
self.npc:SetPos(self.npc:GetPos())
self.npc:SetHullType(hull)
self.npc:SetHullSizeNormal()
self.npc:SetCollisionBounds(min,max)
self.npc:DropToFloor()
self.npc:SetModelScale(1)
self.SquadDeploying = false
end
end

function ENT:Think()
local npc = self.npc

self:DropCrate(npc)
self:CreateRagdoll(npc)
self:Relationship(npc)
self:TalkToCrate(npc)
self:DEPLOYTHECERPS(npc)
self:FlyAwayWhenTroopsAreDeployed(npc)
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

function ENT:DropCrate(npc)
local npc = self.npc
if IsValid(npc:GetEnemy()) and npc:GetEnemy():IsOnGround() and not self.FlyZoneReady then
self.crate_landing_flyingpoint = ents.Create("path_track")
local crate_landing_flyingpoint_name = "PlaceToFlyOverTo" .. self.crate_landing_flyingpoint:EntIndex()
self.crate_landing_flyingpoint:SetName( crate_landing_flyingpoint_name )
self.crate_landing_flyingpoint:SetPos( npc:GetEnemy():GetPos() + npc:GetEnemy():GetForward()*math.random(-1200,1200) + npc:GetEnemy():GetRight()*math.random(-1200,1200) + npc:GetEnemy():GetUp()*560 )
self.crate_landing_flyingpoint:Spawn()
npc:Fire("SetTrack", crate_landing_flyingpoint_name )
	self.FlyZoneReady = true
end

if IsValid(self.crate_landing_flyingpoint) and npc:GetPos():Distance(self.crate_landing_flyingpoint:GetPos()) <= 70 then
	self.AtFlyZone = true
else
	self.AtFlyZone = false
end

if npc:GetNWBool("HasTroops") == true and npc:GetEnemy() and not self.GettingReadyToLand and self.AtFlyZone then
	local EnemyPosition = npc:GetEnemy()
	self.GettingReadyToLand = true
self.cargo_spot = ents.Create("scripted_target")
self.cargo_spot:SetPos( npc:GetPos() )
self.cargo_spot:SetNotSolid(true)
self.cargo_spot:SetNoDraw(true)
self.cargo_spot:Spawn()
self.cargo_spot:Activate()
local target_name = "PlaceToLand" .. self.cargo_spot:EntIndex()
self.cargo_spot:SetName( target_name )
npc:Fire("SetLandTarget", target_name )
npc:Fire( "StopWaitingForDropoff" )
if not self.Landing then
npc:Fire( "LandLeaveCrate", 5 )
	self.Landing = true
end
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

	undo.Create( "Overwatch Tier 1 Dropship" )
	undo.SetCustomUndoText( "Undone Tier 1 Overwatch Dropship" )
	undo.AddEntity( DropShip_Corpse )	
	for _, DropShip_Corpse_To_Undo in pairs( player.GetAll()) do 
		undo.SetPlayer(DropShip_Corpse_To_Undo) 
	end 
	undo.Finish()

	npc:Remove()
end
end

function ENT:OnRemove()
if IsValid(self.npc) then
self.npc:Remove()
end
end

function ENT:TalkToCrate(npc)
local npc = self.npc
	for _, Crate in pairs ( ents.FindByClass( "prop_dropship_container" ) ) do
		if self.SquadDeploying then return end
	if npc:GetNWBool("HasTroops") == true and IsValid(Crate) and Crate:GetParent() == npc and npc:GetName() == "Tier 1 Overwatch Dropship" and Crate:GetName() == "dropship_container" and not self.SquadDeploying then
	self.container = Crate
	end
	end
end

function ENT:DEPLOYTHECERPS(npc)
		if IsValid(self.container) then
local Open_Idle = self.container:LookupSequence( "open_idle" )
						if self.container:GetSequence() == Open_Idle and not self.SquadDeploying then
						self.SquadDeploying = true

							timer.Simple(0,function()
								if IsValid(self.container) then

							self.OverwatchSoldier1 = ents.Create( "npc_combine_s" )
							self.OverwatchSoldier1:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-35 )
							self.OverwatchSoldier1:SetKeyValue( "spawnflags", "644" )
							self.OverwatchSoldier1:SetKeyValue( "squadname", "Tier 1 Overwatch Drop Squad".. self.OverwatchSoldier1:EntIndex() )
							self.OverwatchSoldier1:Give( "weapon_smg1" )
							self.OverwatchSoldier1:Spawn()
							self.OverwatchSoldier1:Activate()
						local OverwatchSoldier1_name = "Tier1OverwatchDeployingSoldier1" .. self.OverwatchSoldier1:EntIndex()
						self.OverwatchSoldier1:SetName( OverwatchSoldier1_name )
							self.SequencePlayed = false
							self.OverwatchSoldier1_Sequence = ents.Create( "scripted_sequence" )
							self.OverwatchSoldier1_Sequence:SetName( OverwatchSoldier1_name .. "_wake_seq" )
							self.OverwatchSoldier1_Sequence:SetKeyValue( "spawnflags", "624" )
							self.OverwatchSoldier1_Sequence:SetKeyValue( "m_iszEntity", OverwatchSoldier1_name )
							self.OverwatchSoldier1_Sequence:SetKeyValue( "m_iszIdle", "idle1" )
							self.OverwatchSoldier1_Sequence:SetKeyValue( "m_fMoveTo", "4" )
							self.OverwatchSoldier1_Sequence:SetKeyValue( "m_iszPlay", "Dropship_Deploy" )
							self.OverwatchSoldier1_Sequence:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-35  )
							self.OverwatchSoldier1_Sequence:Spawn()
							self.OverwatchSoldier1_Sequence:Activate()
							self.OverwatchSoldier1_Sequence:SetParent( self.OverwatchSoldier1 )
								if self.SequencePlayed == false then
								self.OverwatchSoldier1_Sequence:Fire( "BeginSequence", "", 0 )
								self.SequencePlayed = true
								timer.Simple(2.6666666666667,function()
									if IsValid(self.OverwatchSoldier1) and self.SequencePlayed and IsValid(self.container) and not self.OverwatchSoldier1:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
									self.OverwatchSoldier1:ExitScriptedSequence()
									self.OverwatchSoldier1:SetLastPosition( self.container:GetPos() + self.container:GetForward()*600 )
									self.OverwatchSoldier1:SetSchedule(SCHED_FORCED_GO_RUN)
									end
									end)
								end
								end
							end)

							timer.Simple(3,function()
								if IsValid(self.container) then

							self.OverwatchSoldier2 = ents.Create( "npc_combine_s" )
							self.OverwatchSoldier2:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-36 )
							self.OverwatchSoldier2:SetKeyValue( "spawnflags", "644" )
							if IsValid(self.OverwatchSoldier1) then
							self.OverwatchSoldier2:SetKeyValue( "squadname", "Tier 1 Overwatch Drop Squad".. self.OverwatchSoldier1:EntIndex() )
							end
							self.OverwatchSoldier2:Give( "weapon_smg1" )
							self.OverwatchSoldier2:Spawn()
							self.OverwatchSoldier2:Activate()
						local OverwatchSoldier2_name = "Tier1OverwatchDeployingSoldier2" .. self.OverwatchSoldier2:EntIndex()
						self.OverwatchSoldier2:SetName( OverwatchSoldier2_name )
							self.SequencePlayed = false
							self.OverwatchSoldier2_Sequence = ents.Create( "scripted_sequence" )
							self.OverwatchSoldier2_Sequence:SetName( OverwatchSoldier2_name .. "_wake_seq" )
							self.OverwatchSoldier2_Sequence:SetKeyValue( "spawnflags", "624" )
							self.OverwatchSoldier2_Sequence:SetKeyValue( "m_iszEntity", OverwatchSoldier2_name )
							self.OverwatchSoldier2_Sequence:SetKeyValue( "m_iszIdle", "idle1" )
							self.OverwatchSoldier2_Sequence:SetKeyValue( "m_fMoveTo", "4" )
							self.OverwatchSoldier2_Sequence:SetKeyValue( "m_iszPlay", "Dropship_Deploy" )
							self.OverwatchSoldier2_Sequence:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-36 )
							self.OverwatchSoldier2_Sequence:Spawn()
							self.OverwatchSoldier2_Sequence:Activate()
							self.OverwatchSoldier2_Sequence:SetParent( self.OverwatchSoldier2 )
								if self.SequencePlayed == false then
								self.OverwatchSoldier2_Sequence:Fire( "BeginSequence", "", 0 )
								self.SequencePlayed = true
								timer.Simple(2.6666666666667,function()
									if IsValid(self.OverwatchSoldier2) and self.SequencePlayed and IsValid(self.container) and not self.OverwatchSoldier2:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
									self.OverwatchSoldier2:ExitScriptedSequence()
									self.OverwatchSoldier2:SetLastPosition( self.container:GetPos() + self.container:GetForward()*500 + self.container:GetRight()*math.random(100,150) )
									self.OverwatchSoldier2:SetSchedule(SCHED_FORCED_GO_RUN)
									end
									end)
								end
								end
							end)

							timer.Simple(6,function()
								if IsValid(self.container) then

							self.OverwatchSoldier3 = ents.Create( "npc_combine_s" )
							self.OverwatchSoldier3:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-36 )
							self.OverwatchSoldier3:SetKeyValue( "spawnflags", "644" )
							if IsValid(self.OverwatchSoldier1) then
							self.OverwatchSoldier3:SetKeyValue( "squadname", "Tier 1 Overwatch Drop Squad".. self.OverwatchSoldier1:EntIndex() )
							end
							self.OverwatchSoldier3:Give( "weapon_smg1" )
							self.OverwatchSoldier3:Spawn()
							self.OverwatchSoldier3:Activate()
						local OverwatchSoldier3_name = "Tier1OverwatchDeployingSoldier3" .. self.OverwatchSoldier3:EntIndex()
						self.OverwatchSoldier3:SetName( OverwatchSoldier3_name )
							self.SequencePlayed = false
							self.OverwatchSoldier3_Sequence = ents.Create( "scripted_sequence" )
							self.OverwatchSoldier3_Sequence:SetName( OverwatchSoldier3_name .. "_wake_seq" )
							self.OverwatchSoldier3_Sequence:SetKeyValue( "spawnflags", "624" )
							self.OverwatchSoldier3_Sequence:SetKeyValue( "m_iszEntity", OverwatchSoldier3_name )
							self.OverwatchSoldier3_Sequence:SetKeyValue( "m_iszIdle", "idle1" )
							self.OverwatchSoldier3_Sequence:SetKeyValue( "m_fMoveTo", "4" )
							self.OverwatchSoldier3_Sequence:SetKeyValue( "m_iszPlay", "Dropship_Deploy" )
							self.OverwatchSoldier3_Sequence:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-36 )
							self.OverwatchSoldier3_Sequence:Spawn()
							self.OverwatchSoldier3_Sequence:Activate()
							self.OverwatchSoldier3_Sequence:SetParent( self.OverwatchSoldier3 )
								if self.SequencePlayed == false then
								self.OverwatchSoldier3_Sequence:Fire( "BeginSequence", "", 0 )
								self.SequencePlayed = true
								timer.Simple(2.6666666666667,function()
									if IsValid(self.OverwatchSoldier3) and self.SequencePlayed and IsValid(self.container) and not self.OverwatchSoldier3:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
									self.OverwatchSoldier3:ExitScriptedSequence()
									self.OverwatchSoldier3:SetLastPosition( self.container:GetPos() + self.container:GetForward()*500 + self.container:GetRight()*math.random(-100,-150) )
									self.OverwatchSoldier3:SetSchedule(SCHED_FORCED_GO_RUN)
									end
									end)
								end
								end
							end)

							timer.Simple(9,function()
								if IsValid(self.container) then

							self.OverwatchSoldier4 = ents.Create( "npc_combine_s" )
							self.OverwatchSoldier4:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-36 )
							self.OverwatchSoldier4:SetKeyValue( "spawnflags", "644" )
							if IsValid(self.OverwatchSoldier1) then
							self.OverwatchSoldier4:SetKeyValue( "squadname", "Tier 1 Overwatch Drop Squad".. self.OverwatchSoldier1:EntIndex() )
							end
							self.OverwatchSoldier4:Give( "weapon_ar2" )
							self.OverwatchSoldier4:Spawn()
							self.OverwatchSoldier4:Activate()
						local OverwatchSoldier4_name = "Tier1OverwatchDeployingSoldier4" .. self.OverwatchSoldier4:EntIndex()
						self.OverwatchSoldier4:SetName( OverwatchSoldier4_name )
							self.SequencePlayed = false
							self.OverwatchSoldier4_Sequence = ents.Create( "scripted_sequence" )
							self.OverwatchSoldier4_Sequence:SetName( OverwatchSoldier4_name .. "_wake_seq" )
							self.OverwatchSoldier4_Sequence:SetKeyValue( "spawnflags", "624" )
							self.OverwatchSoldier4_Sequence:SetKeyValue( "m_iszEntity", OverwatchSoldier4_name )
							self.OverwatchSoldier4_Sequence:SetKeyValue( "m_iszIdle", "idle1" )
							self.OverwatchSoldier4_Sequence:SetKeyValue( "m_fMoveTo", "4" )
							self.OverwatchSoldier4_Sequence:SetKeyValue( "m_iszPlay", "Dropship_Deploy" )
							self.OverwatchSoldier4_Sequence:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-36 )
							self.OverwatchSoldier4_Sequence:Spawn()
							self.OverwatchSoldier4_Sequence:Activate()
							self.OverwatchSoldier4_Sequence:SetParent( self.OverwatchSoldier4 )
								if self.SequencePlayed == false then
								self.OverwatchSoldier4_Sequence:Fire( "BeginSequence", "", 0 )
								self.SequencePlayed = true
								timer.Simple(2.6666666666667,function()
									if IsValid(self.OverwatchSoldier4) and self.SequencePlayed and IsValid(self.container) and not self.OverwatchSoldier4:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
									self.OverwatchSoldier4:ExitScriptedSequence()
									self.OverwatchSoldier4:SetLastPosition( self.container:GetPos() + self.container:GetForward()*450 + self.container:GetRight()*math.random(50,100) )
									self.OverwatchSoldier4:SetSchedule(SCHED_FORCED_GO_RUN)
									end
									end)
								end
								end
							end)

							timer.Simple(12,function()
								if IsValid(self.container) then

							self.OverwatchSoldier5 = ents.Create( "npc_combine_s" )
							self.OverwatchSoldier5:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-36 )
							self.OverwatchSoldier5:SetKeyValue( "spawnflags", "644" )
							if IsValid(self.OverwatchSoldier1) then
							self.OverwatchSoldier5:SetKeyValue( "squadname", "Tier 1 Overwatch Drop Squad".. self.OverwatchSoldier1:EntIndex() )
							end
							self.OverwatchSoldier5:Give( "weapon_shotgun" )
							self.OverwatchSoldier5:Spawn()
							self.OverwatchSoldier5:Activate()
						local OverwatchSoldier5_name = "Tier1OverwatchDeployingSoldier5" .. self.OverwatchSoldier5:EntIndex()
							self.OverwatchSoldier5:SetName( OverwatchSoldier5_name )
							self.SequencePlayed = false
							self.OverwatchSoldier5_Sequence = ents.Create( "scripted_sequence" )
							self.OverwatchSoldier5_Sequence:SetName( OverwatchSoldier5_name .. "_wake_seq" )
							self.OverwatchSoldier5_Sequence:SetKeyValue( "spawnflags", "624" )
							self.OverwatchSoldier5_Sequence:SetKeyValue( "m_iszEntity", OverwatchSoldier5_name )
							self.OverwatchSoldier5_Sequence:SetKeyValue( "m_iszIdle", "idle1" )
							self.OverwatchSoldier5_Sequence:SetKeyValue( "m_fMoveTo", "4" )
							self.OverwatchSoldier5_Sequence:SetKeyValue( "m_iszPlay", "Dropship_Deploy" )
							self.OverwatchSoldier5_Sequence:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-36 )
							self.OverwatchSoldier5_Sequence:Spawn()
							self.OverwatchSoldier5_Sequence:Activate()
							self.OverwatchSoldier5_Sequence:SetParent( self.OverwatchSoldier5 )
								if self.SequencePlayed == false then
								self.OverwatchSoldier5_Sequence:Fire( "BeginSequence", "", 0 )
								self.SequencePlayed = true
								timer.Simple(2.6666666666667,function()
									if IsValid(self.OverwatchSoldier5) and self.SequencePlayed and IsValid(self.container) and not self.OverwatchSoldier5:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
									self.OverwatchSoldier5:ExitScriptedSequence()
									self.OverwatchSoldier5:SetLastPosition( self.container:GetPos() + self.container:GetForward()*450 + self.container:GetRight()*math.random(-50,-100) )
									self.OverwatchSoldier5:SetSchedule(SCHED_FORCED_GO_RUN)
									end
									end)
								end
								end
							end)

							timer.Simple(15,function()
							if IsValid(self.container) && IsValid(self.npc) then
								self.npc:SetNWBool("HasTroops", false)
							end
							self.Time_To_Get_The_Fuck_Outta_Here = true
							end)
						end
		else
		self.Time_To_Get_The_Fuck_Outta_Here = true
		end
end


hook.Add("EntityTakeDamage", "Tier 1 Overwatch Dropship Damage", function(ent, dmginfo)

if ent:GetName() == "Tier 1 Overwatch Dropship" and dmginfo:IsDamageType(DMG_BLAST) and ent:Health() > 0 then
ent:SetHealth(ent:Health()-25)
if !IsValid(ent.container) then
ent.Time_To_Get_The_Fuck_Outta_Here = true
end
end

end)

function ENT:FlyAwayWhenTroopsAreDeployed( npc )
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


---------------- List of Possible Squads 


//Overwatch squad (tier 1): 3 SMG soldiers, 1 ar2 soldier, 1 shotgunner

//Overwatch squad (tier 2): 2 SMG soldiers, 3 ar2 soldiers, 1 shotgunner

//Civil protection squad (tier 1): 3 pistol cops, 1 SMG cop, 1 SMG cop with manhack

//Civil protection squad (tier 2): 2 pistol cops, 2 SMG cops, 2 SMG cops with manhacks

//Elite squad: 5 Elite soldiers

//Overwatch squad (tier 3): 1 SMG soldier, 4 ar2 soldiers, 1 elite soldier, 2 shotgunners

//(maybe bonus) Shotgunner squad: 4 shotgunners, 1 elite soldier

//(maybe bonus) Rollermines: 5 rollermines
