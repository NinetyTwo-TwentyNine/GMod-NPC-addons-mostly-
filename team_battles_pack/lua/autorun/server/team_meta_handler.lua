hook.Add("InitPostEntity", "Player's && NPCs' team synchronization", function()
	FindMetaTable("Player").Team = function(ply)
		return ply:GetInternalVariable("TeamNum")
	end
	FindMetaTable("Player").SetTeam = function(ply, val)
		ply:SetKeyValue("TeamNum", val)
	end

	FindMetaTable("NPC").Team = function(npc)
		return npc:GetInternalVariable("TeamNum")
	end
	FindMetaTable("NPC").SetTeam = function(npc, val)
		npc:SetKeyValue("TeamNum", val)
	end
end)