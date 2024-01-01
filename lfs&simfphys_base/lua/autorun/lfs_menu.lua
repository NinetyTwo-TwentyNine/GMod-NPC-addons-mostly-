hook.Add( "LFSPopulateVehicles", "AddEntityContent", function( pnlContent, tree, node )

	local Categorised = {}

	-- Add this list into the tormoil
	local Vehicles = list.Get( "lfs_vehicles" )
	if Vehicles then
		for k, v in pairs( Vehicles ) do

			v.Category = v.Category or "Other"
			Categorised[ v.Category ] = Categorised[ v.Category ] or {}
			v.ClassName = k
			v.PrintName = v.Name
			table.insert( Categorised[ v.Category ], v )

		end
	end
	--
	-- Add a tree node for each category
	--
	for CategoryName, v in SortedPairs( Categorised ) do

		-- Add a node to the tree
		local node = tree:AddNode( CategoryName, "icon16/bricks.png" )
		
			-- When we click on the node - populate it using this function
		node.DoPopulate = function( self )
			
			-- If we've already populated it - forget it.
			if self.PropPanel then return end
			
			-- Create the container panel
			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )
			
			for k, ent in SortedPairsByMemberValue( v, "PrintName" ) do
				
				spawnmenu.CreateContentIcon( "lfs_vehicles", self.PropPanel, {
					nicename	= ent.PrintName or ent.ClassName,
					spawnname	= ent.ClassName,
					material	= ent.IconOverride || "entities/"..ent.ClassName..".png",
					admin		= ent.AdminOnly
				} )
				
			end
			
		end
		
		-- If we click on the node populate it and switch to it.
		node.DoClick = function( self )
			
			self:DoPopulate()
			pnlContent:SwitchPanel( self.PropPanel )
			
		end

	end

	-- Select the first node
	local FirstNode = tree:Root():GetChildNode( 0 )
	if IsValid( FirstNode ) then
		FirstNode:InternalDoClick()
	end
end )


if CLIENT then

	spawnmenu.AddCreationTab( "Lunasflightschool", function()

		local ctrl = vgui.Create( "SpawnmenuContentPanel" )
		ctrl:CallPopulateHook( "LFSPopulateVehicles" )
		return ctrl

	end, "icon16/car.png", 50 )

	spawnmenu.AddContentType( "lfs_vehicles", function( container, obj )
		if not obj.material then return end
		if not obj.nicename then return end
		if not obj.spawnname then return end

		local icon = vgui.Create( "ContentIcon", container )
		icon:SetContentType( "lfs_vehicles" )
		icon:SetSpawnName( obj.spawnname )
		icon:SetName( obj.nicename )
		icon:SetMaterial( obj.material )
		icon:SetAdminOnly( obj.admin )
		icon:SetColor( Color( 0, 0, 0, 255 ) )
		icon.DoClick = function()
			RunConsoleCommand( "gm_spawnsent", obj.spawnname )
			surface.PlaySound( "ui/buttonclickrelease.wav" )
		end
		icon.OpenMenu = function( icon )

			local menu = DermaMenu()
				menu:AddOption( "Copy to Clipboard", function() SetClipboardText( obj.spawnname ) end )
				--menu:AddSpacer()
				--menu:AddOption( "Delete", function() icon:Remove() hook.Run( "SpawnlistContentChanged", icon ) end )
			menu:Open()

		end
	
		if IsValid( container ) then
			container:Add( icon )
		end

		return icon

	end )
end