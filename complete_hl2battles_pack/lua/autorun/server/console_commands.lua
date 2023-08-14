concommand.Add( "ent_getproperties", function (ply, cmd, args)
	local eyetrace = ply:GetEyeTrace()
	if IsValid(eyetrace.Entity) then
		local ent = eyetrace.Entity
		if table.IsEmpty(args) then
			PrintTable(ent:GetKeyValues())
		elseif ent:GetKeyValues()[args[1]] then
			print(ent:GetKeyValues()[args[1]])
		end
	end
end)