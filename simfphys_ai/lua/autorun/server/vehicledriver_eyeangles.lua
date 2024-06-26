SIMFPHYS_AI_NpcIds = {}

hook.Add("InitPostEntity", "Simfphys_VehicleDriver_EyeAngles", function()	// I am insane (in a bad way).
	list.Add("SimfphysAI_DefaultFunctionsSave")
	for k,v in pairs(table.Copy(FindMetaTable("Entity"))) do
		list.GetForEdit("SimfphysAI_DefaultFunctionsSave")[k] = v
	end

	local DefaultEyeAngles = table.Copy(FindMetaTable("Entity")).EyeAngles
	FindMetaTable("Entity").EyeAngles = function(ent)
		if table.HasValue(SIMFPHYS_AI_NpcIds, ent:EntIndex()) then
			return ent:GetTable().EyeAngles()
		end
		return DefaultEyeAngles(ent)
	end
end)