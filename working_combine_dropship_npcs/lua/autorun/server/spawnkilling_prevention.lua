


hook.Add("EntityTakeDamage", "Protect MetroCops and Combine Soldiers As They Come Out of Ship", function(npc, damage)
	local deployering = npc:LookupSequence("Dropship_Deploy")
	if npc:GetSequence() == deployering and (npc:GetClass() == "npc_metropolice" or npc:GetClass() == "npc_combine_s") then
		damage:ScaleDamage(0)
	end
end)