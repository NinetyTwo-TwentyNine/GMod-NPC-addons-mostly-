
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

hook.Add("EntityTakeDamage", "Metropolice Gets a Kill Instead of His Manhack", function(target, dmginfo)
	if IsValid(dmginfo:GetAttacker()) then
		if dmginfo:GetAttacker():GetClass() == "npc_manhack" then
			if IsValid(dmginfo:GetAttacker().ManhackOwner) then
				dmginfo:SetInflictor(dmginfo:GetAttacker())
				dmginfo:SetAttacker(dmginfo:GetAttacker().ManhackOwner)
			end
		end
	end
end)