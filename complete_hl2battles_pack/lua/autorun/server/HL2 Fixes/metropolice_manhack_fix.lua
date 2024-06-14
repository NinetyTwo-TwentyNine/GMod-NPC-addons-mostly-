
hook.Add("OnEntityCreated", "Elite Metropolice Setup", function(ent)
	if ent:GetClass() == "npc_metropolice" then
		timer.Simple(FrameTime(), function()
			if !IsValid(ent) then return end
			if ent:GetSkin() != 2 then return end

			ent:CapabilitiesAdd(CAP_AIM_GUN)
			ent:SetMaxHealth(0)

			local ply = ent:GetCreator()
			if !IsValid(ply) then
				for _, v in pairs(player.GetAll()) do
					if v:IsListenServerHost() then
						ply = v
						break
					end
				end
			end
			if !IsValid(ply) then return end

			if ConVarExists("esboxnpcs_soldier_elite_proficiency") && ConVarExists("esboxnpcs_soldier_ar2_proficiency") then
				if ply:GetInfoNum("esboxnpcs_soldier_elite_proficiency", 0) > 0 then
					ent:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
				elseif ply:GetInfoNum("esboxnpcs_soldier_ar2_proficiency", 0) > 0 && IsValid(ent:GetActiveWeapon()) && ent:GetActiveWeapon():GetClass() == "weapon_ar2" then
					ent:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_GOOD)
				end
			end
		end)
	end
end)


hook.Add("OnEntityCreated", "Manhack Owner Setup", function(ent)
	if ent:GetClass() == "npc_manhack" then
		timer.Simple(FrameTime(), function()
		if IsValid(ent) && IsValid(ent:GetParent()) then
			if ent:GetParent():GetClass() == "npc_metropolice" then
				ent.ManhackOwner = ent:GetParent()
			end
		end
		end)
	end
end)

hook.Add("EntityTakeDamage", "Metropolice Gets the Kill Instead of His Manhack", function(target, dmginfo)
	if IsValid(dmginfo:GetAttacker()) then
		if dmginfo:GetAttacker():GetClass() == "npc_manhack" then
			if IsValid(dmginfo:GetAttacker().ManhackOwner) then
				dmginfo:SetInflictor(dmginfo:GetAttacker())
				dmginfo:SetAttacker(dmginfo:GetAttacker().ManhackOwner)
			end
		end
	end
end)