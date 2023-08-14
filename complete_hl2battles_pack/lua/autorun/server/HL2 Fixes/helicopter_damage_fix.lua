
hook.Add("OnEntityCreated", "Helicopter Takes Damage From Explosions", function(ent)
	if ent:GetClass() == "grenade_ar2" || ent:GetClass() == "npc_grenade_frag" || ent:GetClass() == "concussiveblast" then
		ent:CallOnRemove("DamageHelicopters", function()
			local dmginfo_damage, dmginfo_radius
			if ent:GetClass() == "grenade_ar2" then
				dmginfo_damage = GetConVarNumber("sk_npc_dmg_smg1_grenade")
				if IsValid(ent:GetOwner()) then
					if ent:GetOwner():IsPlayer() then
						dmginfo_damage = GetConVarNumber("sk_plr_dmg_smg1_grenade")
					end
				end
				dmginfo_radius = GetConVarNumber("sk_smg1_grenade_radius")
			end
			if ent:GetClass() == "npc_grenade_frag" then
				dmginfo_damage = GetConVarNumber("sk_npc_dmg_fraggrenade")
				if IsValid(ent:GetOwner()) then
					if ent:GetOwner():IsPlayer() then
						dmginfo_damage = GetConVarNumber("sk_plr_dmg_fraggrenade")
					end
				end
				dmginfo_radius = GetConVarNumber("sk_fraggrenade_radius")
			end
			if ent:GetClass() == "concussiveblast" then
				dmginfo_damage = 200
				dmginfo_radius = 250
			end

			for k,v in pairs(ents.FindInSphere(ent:GetPos(), dmginfo_radius)) do
				if IsValid(v) && v:GetClass() == "npc_helicopter" then
					local tr = util.TraceLine( {
						start = ent:GetPos(),
						endpos = v:BodyTarget(ent:GetPos()),
						filter = function( hit ) return ( hit == v ) end
					} )
					if tr.Entity == v then
						local dmginfo_distance = ent:GetPos():Distance(tr.HitPos)

						local dmginfo = DamageInfo()
						dmginfo:SetDamage(math.Round(dmginfo_damage * (1 - dmginfo_distance / dmginfo_radius)))
						if dmginfo:GetDamage() < 0 then
							dmginfo:SetDamage(0)
						end
						dmginfo:SetInflictor(ent)
						dmginfo:SetAttacker(ent)
						if IsValid(ent:GetOwner()) then
							dmginfo:SetAttacker(ent:GetOwner())
						end
						dmginfo:SetDamageType(DMG_AIRBOAT)
						dmginfo:SetDamagePosition(tr.HitPos)
						v:TakeDamageInfo(dmginfo)
					end
				end
			end
		end)
	end
end)