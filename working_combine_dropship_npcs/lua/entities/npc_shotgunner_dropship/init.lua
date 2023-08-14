AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )

function ENT:SpawnFunction( tr )
if ( !tr.Hit ) then return end
	
local SpawnPos = tr.HitPos + tr.HitNormal * 6
self.Spawn_angles = ply:GetAngles()
self.Spawn_angles.pitch = 0
self.Spawn_angles.roll = 0
self.Spawn_angles.yaw = self.Spawn_angles.yaw + 180
	
local ent = ents.Create( "npc_shotgunner_dropship" )
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
self.npc:SetName( "Shotgunner Overwatch Dropship")
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

	undo.Create( "Overwatch Shotgunner Dropship" )
	undo.AddEntity( DropShip_Corpse )	
	undo.SetCustomUndoText( "Undone Overwatch Shotgunner Dropship" )
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
	if npc:GetNWBool("HasTroops") == true and IsValid(Crate) and Crate:GetParent() == npc and npc:GetName() == "Shotgunner Overwatch Dropship" and Crate:GetName() == "dropship_container" and not self.SquadDeploying then
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

							self.ShotgunSoldier1 = ents.Create( "npc_combine_s" )
							self.ShotgunSoldier1:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-35 )
							self.ShotgunSoldier1:SetKeyValue( "spawnflags", "644" )
							if IsValid(self.ShotgunSoldier1) then
							self.ShotgunSoldier1:SetKeyValue( "squadname", "Shotgun Drop Squad".. self.ShotgunSoldier1:EntIndex() )
							end
							self.ShotgunSoldier1:Give( "weapon_shotgun" )
							self.ShotgunSoldier1:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )
							self.ShotgunSoldier1:Spawn()
							self.ShotgunSoldier1:Activate()
						local ShotgunSoldier1_name = "DeployingShotgunSoldier1" .. self.ShotgunSoldier1:EntIndex()
						self.ShotgunSoldier1:SetName( ShotgunSoldier1_name )
							self.SequencePlayed = false
							self.ShotgunSoldier1_Sequence = ents.Create( "scripted_sequence" )
							self.ShotgunSoldier1_Sequence:SetName( ShotgunSoldier1_name .. "_wake_seq" )
							self.ShotgunSoldier1_Sequence:SetKeyValue( "spawnflags", "624" )
							self.ShotgunSoldier1_Sequence:SetKeyValue( "m_iszEntity", ShotgunSoldier1_name )
							self.ShotgunSoldier1_Sequence:SetKeyValue( "m_iszIdle", "idle1" )
							self.ShotgunSoldier1_Sequence:SetKeyValue( "m_fMoveTo", "4" )
							self.ShotgunSoldier1_Sequence:SetKeyValue( "m_iszPlay", "Dropship_Deploy" )
							self.ShotgunSoldier1_Sequence:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-35  )
							self.ShotgunSoldier1_Sequence:Spawn()
							self.ShotgunSoldier1_Sequence:Activate()
							self.ShotgunSoldier1_Sequence:SetParent( self.ShotgunSoldier1 )
								if self.SequencePlayed == false then
								self.ShotgunSoldier1_Sequence:Fire( "BeginSequence", "", 0 )
								self.SequencePlayed = true
								timer.Simple(2.6666666666667,function()
									if IsValid(self.ShotgunSoldier1) and self.SequencePlayed and IsValid(self.container) and not self.ShotgunSoldier1:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
									self.ShotgunSoldier1:ExitScriptedSequence()
									self.ShotgunSoldier1:SetLastPosition( self.container:GetPos() + self.container:GetForward()*600 )
									self.ShotgunSoldier1:SetSchedule(SCHED_FORCED_GO_RUN)
									end
									end)
								end
								end
							end)

							timer.Simple(3,function()
								if IsValid(self.container) then

							self.ShotgunSoldier2 = ents.Create( "npc_combine_s" )
							self.ShotgunSoldier2:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-36 )
							self.ShotgunSoldier2:SetKeyValue( "spawnflags", "644" )
							if IsValid(self.ShotgunSoldier1) then
							self.ShotgunSoldier2:SetKeyValue( "squadname", "Shotgun Drop Squad".. self.ShotgunSoldier1:EntIndex() )
							end
							self.ShotgunSoldier2:Give( "weapon_shotgun" )
							self.ShotgunSoldier2:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )
							self.ShotgunSoldier2:Spawn()
							self.ShotgunSoldier2:Activate()
						local ShotgunSoldier2_name = "Tier1OverwatchDeployingSoldier2" .. self.ShotgunSoldier2:EntIndex()
						self.ShotgunSoldier2:SetName( ShotgunSoldier2_name )
							self.SequencePlayed = false
							self.ShotgunSoldier2_Sequence = ents.Create( "scripted_sequence" )
							self.ShotgunSoldier2_Sequence:SetName( ShotgunSoldier2_name .. "_wake_seq" )
							self.ShotgunSoldier2_Sequence:SetKeyValue( "spawnflags", "624" )
							self.ShotgunSoldier2_Sequence:SetKeyValue( "m_iszEntity", ShotgunSoldier2_name )
							self.ShotgunSoldier2_Sequence:SetKeyValue( "m_iszIdle", "idle1" )
							self.ShotgunSoldier2_Sequence:SetKeyValue( "m_fMoveTo", "4" )
							self.ShotgunSoldier2_Sequence:SetKeyValue( "m_iszPlay", "Dropship_Deploy" )
							self.ShotgunSoldier2_Sequence:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-36 )
							self.ShotgunSoldier2_Sequence:Spawn()
							self.ShotgunSoldier2_Sequence:Activate()
							self.ShotgunSoldier2_Sequence:SetParent( self.ShotgunSoldier2 )
								if self.SequencePlayed == false then
								self.ShotgunSoldier2_Sequence:Fire( "BeginSequence", "", 0 )
								self.SequencePlayed = true
								timer.Simple(2.6666666666667,function()
									if IsValid(self.ShotgunSoldier2) and self.SequencePlayed and IsValid(self.container) and not self.ShotgunSoldier2:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
									self.ShotgunSoldier2:ExitScriptedSequence()
									self.ShotgunSoldier2:SetLastPosition( self.container:GetPos() + self.container:GetForward()*500 + self.container:GetRight()*math.random(100,150) )
									self.ShotgunSoldier2:SetSchedule(SCHED_FORCED_GO_RUN)
									end
									end)

								end
								end
							end)

							timer.Simple(6,function()
								if IsValid(self.container) then

							self.ShotgunSoldier3 = ents.Create( "npc_combine_s" )
							self.ShotgunSoldier3:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-36 )
							self.ShotgunSoldier3:SetKeyValue( "spawnflags", "644" )
							if IsValid(self.ShotgunSoldier1) then
							self.ShotgunSoldier3:SetKeyValue( "squadname", "Shotgun Drop Squad".. self.ShotgunSoldier1:EntIndex() )
							end
							self.ShotgunSoldier3:Give( "weapon_shotgun" )
							self.ShotgunSoldier3:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )
							self.ShotgunSoldier3:Spawn()
							self.ShotgunSoldier3:Activate()
						local ShotgunSoldier3_name = "Tier1OverwatchDeployingSoldier3" .. self.ShotgunSoldier3:EntIndex()
						self.ShotgunSoldier3:SetName( ShotgunSoldier3_name )
							self.SequencePlayed = false
							self.ShotgunSoldier3_Sequence = ents.Create( "scripted_sequence" )
							self.ShotgunSoldier3_Sequence:SetName( ShotgunSoldier3_name .. "_wake_seq" )
							self.ShotgunSoldier3_Sequence:SetKeyValue( "spawnflags", "624" )
							self.ShotgunSoldier3_Sequence:SetKeyValue( "m_iszEntity", ShotgunSoldier3_name )
							self.ShotgunSoldier3_Sequence:SetKeyValue( "m_iszIdle", "idle1" )
							self.ShotgunSoldier3_Sequence:SetKeyValue( "m_fMoveTo", "4" )
							self.ShotgunSoldier3_Sequence:SetKeyValue( "m_iszPlay", "Dropship_Deploy" )
							self.ShotgunSoldier3_Sequence:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-36 )
							self.ShotgunSoldier3_Sequence:Spawn()
							self.ShotgunSoldier3_Sequence:Activate()
							self.ShotgunSoldier3_Sequence:SetParent( self.ShotgunSoldier3 )
								if self.SequencePlayed == false then
								self.ShotgunSoldier3_Sequence:Fire( "BeginSequence", "", 0 )
								self.SequencePlayed = true
								timer.Simple(2.6666666666667,function()
									if IsValid(self.ShotgunSoldier3) and self.SequencePlayed and IsValid(self.container) and not self.ShotgunSoldier3:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
									self.ShotgunSoldier3:ExitScriptedSequence()
									self.ShotgunSoldier3:SetLastPosition( self.container:GetPos() + self.container:GetForward()*500 + self.container:GetRight()*math.random(-100,-150) )
									self.ShotgunSoldier3:SetSchedule(SCHED_FORCED_GO_RUN)
									end
									end)

								end
								end
							end)

							timer.Simple(9,function()
								if IsValid(self.container) then

							self.ShotgunSoldier4 = ents.Create( "npc_combine_s" )
							self.ShotgunSoldier4:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-36 )
							self.ShotgunSoldier4:SetKeyValue( "spawnflags", "644" )
							if IsValid(self.ShotgunSoldier1) then
							self.ShotgunSoldier4:SetKeyValue( "squadname", "Shotgun Drop Squad".. self.ShotgunSoldier1:EntIndex() )
							end
							self.ShotgunSoldier4:Give( "weapon_shotgun" )
							self.ShotgunSoldier4:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )
							self.ShotgunSoldier4:Spawn()
							self.ShotgunSoldier4:Activate()
						local ShotgunSoldier4_name = "Tier1OverwatchDeployingSoldier4" .. self.ShotgunSoldier4:EntIndex()
						self.ShotgunSoldier4:SetName( ShotgunSoldier4_name )
							self.SequencePlayed = false
							self.ShotgunSoldier4_Sequence = ents.Create( "scripted_sequence" )
							self.ShotgunSoldier4_Sequence:SetName( ShotgunSoldier4_name .. "_wake_seq" )
							self.ShotgunSoldier4_Sequence:SetKeyValue( "spawnflags", "624" )
							self.ShotgunSoldier4_Sequence:SetKeyValue( "m_iszEntity", ShotgunSoldier4_name )
							self.ShotgunSoldier4_Sequence:SetKeyValue( "m_iszIdle", "idle1" )
							self.ShotgunSoldier4_Sequence:SetKeyValue( "m_fMoveTo", "4" )
							self.ShotgunSoldier4_Sequence:SetKeyValue( "m_iszPlay", "Dropship_Deploy" )
							self.ShotgunSoldier4_Sequence:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-36 )
							self.ShotgunSoldier4_Sequence:Spawn()
							self.ShotgunSoldier4_Sequence:Activate()
							self.ShotgunSoldier4_Sequence:SetParent( self.ShotgunSoldier4 )
								if self.SequencePlayed == false then
								self.ShotgunSoldier4_Sequence:Fire( "BeginSequence", "", 0 )
								self.SequencePlayed = true
								timer.Simple(2.6666666666667,function()
									if IsValid(self.ShotgunSoldier4) and self.SequencePlayed and IsValid(self.container) and not self.ShotgunSoldier4:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
									self.ShotgunSoldier4:ExitScriptedSequence()
									self.ShotgunSoldier4:SetLastPosition( self.container:GetPos() + self.container:GetForward()*450 + self.container:GetRight()*math.random(50,100) )
									self.ShotgunSoldier4:SetSchedule(SCHED_FORCED_GO_RUN)
									end
									end)

								end
								end
							end)

							timer.Simple(12,function()
								if IsValid(self.container) then

							self.ShotgunSoldier5 = ents.Create( "npc_combine_s" )
							self.ShotgunSoldier5:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-36 )
							self.ShotgunSoldier5:SetKeyValue( "spawnflags", "644" )
							if IsValid(self.ShotgunSoldier1) then
							self.ShotgunSoldier5:SetKeyValue( "squadname", "Shotgun Drop Squad".. self.ShotgunSoldier1:EntIndex() )
							end
							self.ShotgunSoldier5:Give( "weapon_shotgun" )
							self.ShotgunSoldier5:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )
							self.ShotgunSoldier5:Spawn()
							self.ShotgunSoldier5:Activate()
						local ShotgunSoldier5_name = "Tier1OverwatchDeployingSoldier5" .. self.ShotgunSoldier5:EntIndex()
						self.ShotgunSoldier5:SetName( ShotgunSoldier5_name )
							self.SequencePlayed = false
							self.ShotgunSoldier5_Sequence = ents.Create( "scripted_sequence" )
							self.ShotgunSoldier5_Sequence:SetName( ShotgunSoldier5_name .. "_wake_seq" )
							self.ShotgunSoldier5_Sequence:SetKeyValue( "spawnflags", "624" )
							self.ShotgunSoldier5_Sequence:SetKeyValue( "m_iszEntity", ShotgunSoldier5_name )
							self.ShotgunSoldier5_Sequence:SetKeyValue( "m_iszIdle", "idle1" )
							self.ShotgunSoldier5_Sequence:SetKeyValue( "m_fMoveTo", "4" )
							self.ShotgunSoldier5_Sequence:SetKeyValue( "m_iszPlay", "Dropship_Deploy" )
							self.ShotgunSoldier5_Sequence:SetPos( self.container:GetPos() + self.container:GetForward()*-26 + self.container:GetUp()*-36 )
							self.ShotgunSoldier5_Sequence:Spawn()
							self.ShotgunSoldier5_Sequence:Activate()
							self.ShotgunSoldier5_Sequence:SetParent( self.ShotgunSoldier5 )
								if self.SequencePlayed == false then
								self.ShotgunSoldier5_Sequence:Fire( "BeginSequence", "", 0 )
								self.SequencePlayed = true
								timer.Simple(2.6666666666667,function()
									if IsValid(self.ShotgunSoldier5) and self.SequencePlayed and IsValid(self.container) and not self.ShotgunSoldier5:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
									self.ShotgunSoldier5:ExitScriptedSequence()
									self.ShotgunSoldier5:SetLastPosition( self.container:GetPos() + self.container:GetForward()*450 + self.container:GetRight()*math.random(-50,-100) )
									self.ShotgunSoldier5:SetSchedule(SCHED_FORCED_GO_RUN)
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


hook.Add("EntityTakeDamage", "Shotgunner Overwatch Dropship Damage", function(ent, dmginfo)

if ent:GetName() == "Shotgunner Overwatch Dropship" and dmginfo:IsDamageType(DMG_BLAST) and ent:Health() > 0 then
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
