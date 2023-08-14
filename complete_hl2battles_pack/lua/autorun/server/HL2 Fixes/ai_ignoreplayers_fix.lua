
cvars.AddChangeCallback("ai_ignoreplayers", function(convar, oldValue, newValue)
	if !(tonumber(oldValue) == 0 && tonumber(newValue) == 1) then return end

	for _,npc in pairs(ents.GetAll()) do
		if !npc:IsNPC() then continue end

		for __,enemy in pairs(npc:GetKnownEnemies()) do
			if !IsValid(enemy) then continue end

			if enemy:IsPlayer() then
				npc:ClearEnemyMemory(enemy)
			end
		end
	end
end)