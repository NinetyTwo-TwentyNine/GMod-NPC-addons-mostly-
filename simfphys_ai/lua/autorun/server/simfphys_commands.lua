concommand.Add( "simfphys_nameseats", function (ply, cmd, args)
	local eyetrace = ply:GetEyeTrace()
	if IsValid(eyetrace.Entity) then
		local ent = eyetrace.Entity
		if ent:GetClass() == "gmod_sent_vehicle_fphysics_base" then
			local index = ent:EntIndex()
			ent.DriverSeat:SetName("simfphys["..index.."]driver_seat")
			print(ent.DriverSeat:GetName())
			if ent.PassengerSeats then
				for i = 1,table.Count(ent.PassengerSeats) do
					ent.pSeat[i]:SetName("simfphys["..index.."]passenger_seat#"..i)
					print(ent.pSeat[i]:GetName())
				end
			end
		end
	end
end)