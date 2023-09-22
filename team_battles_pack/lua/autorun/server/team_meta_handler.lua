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

	local DefaultSetKeyValue = table.Copy(FindMetaTable("Entity")).SetKeyValue
	FindMetaTable("Entity").SetKeyValue = function(ent, key, val)	-- GMod Wiki says that the SetKeyValue function should call a hook each time it gets called. Apparently, that's not exactly true (22.09.2023) 
		hook.Run( "EntityKeyValue", ent, tostring(key), tostring(val) )
		return DefaultSetKeyValue(ent, key, val)
	end
end)