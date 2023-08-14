

hook.Add("EntityEmitSound", "GunshipCannonFix", function(data)
	if data.Entity then
		local npc = data.Entity
		if npc:GetClass() == "npc_combinegunship" then
			if data.SoundName == "npc/strider/charging.wav" then
				npc.ChargeTime = CurTime()
			end
			if data.SoundName == "npc/strider/fire.wav" then
				if npc.ChargeTime then
					if math.Round(CurTime() - npc.ChargeTime, 3) == 3.045 then
						npc.CannonExplosion = util.TraceLine( {
							start = npc:GetBonePosition(npc:LookupBone("Gunship.Belly_Weapon")),
							endpos = npc:GetUp() * -2147483647,
							filter = function(hit) return (hit != npc) end
						} )
						
						local dmginfo_damage = 200
						local dmginfo_radius = 250

						for k,v in pairs(ents.FindInSphere(npc.CannonExplosion.HitPos, dmginfo_radius)) do
							local tr = util.TraceLine( {
								start = npc.CannonExplosion.HitPos,
								endpos = v:BodyTarget(npc.CannonExplosion.HitPos),
								filter = function( hit ) return ( hit == v && hit != npc ) end
							} )

							if tr.Entity == v then
								local dmginfo_distance = npc.CannonExplosion.HitPos:Distance(tr.HitPos)

								local dmginfo = DamageInfo()
								dmginfo:SetDamage(math.Round(dmginfo_damage * (1 - dmginfo_distance / dmginfo_radius)))
								if dmginfo:GetDamage() < 0 then
									dmginfo:SetDamage(0)
								end
								dmginfo:SetInflictor(npc)
								dmginfo:SetAttacker(npc)
								dmginfo:SetDamageType(DMG_DISSOLVE)
								dmginfo:SetDamagePosition(tr.HitPos)

								if !v:PassesDamageFilter(dmginfo) then
									dmginfo:SetDamageType(bit.bor(DMG_DISSOLVE, DMG_BLAST, DMG_AIRBOAT))
									v:TakeDamageInfo(dmginfo)
								end
							end
						end
					else
						print("Cannon attack failed!")
						print("Cannon charge time is "..CurTime() - npc.ChargeTime)
					end
				end
			end
		end
	end
end)