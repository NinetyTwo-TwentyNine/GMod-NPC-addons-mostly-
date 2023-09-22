concommand.Add( "ent_getproperties", function (ply, cmd, args)
	local eyetrace = ply:GetEyeTrace()
	if IsValid(eyetrace.Entity) then
		local ent = eyetrace.Entity
		if table.IsEmpty(args) then
			PrintTable(ent:GetKeyValues())
		else
			for k,v in pairs(ent:GetKeyValues()) do
				if string.lower(k) == string.lower(args[1]) then
					print(v)
					break
				end
			end
		end
	end
end)