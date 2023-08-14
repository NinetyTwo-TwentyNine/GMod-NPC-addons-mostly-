TOOL.Category = "Marums tools"
TOOL.Name = "Clientside Strange Model Maker"
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 

if (CLIENT) then
language.Add( "tool.clientside_weird_model_maker.name", "Clientside Weird Model Maker" )
language.Add( "tool.clientside_weird_model_maker.desc", "Used to visualize model strings for MRTS" )
TOOL.Information = {
	{ name = "left", stage = 0 },
	{ name = "right", stage = 0 }
}
language.Add( "tool.clientside_weird_model_maker.left", "Click: Place model and open menu" )
language.Add( "tool.clientside_weird_model_maker.right", "Click: Open menu" )
end

function TOOL:Deploy()
	self.menuframe = nil
end

function TOOL:Think()
	if (CLIENT) then
		if (self.menuframe == nil) then
			if (LocalPlayer():KeyDown(IN_ATTACK)) then
				MRTSMMPlaceModel(LocalPlayer():GetEyeTrace().HitPos)
				self:OpenMenu()
			elseif (LocalPlayer():KeyDown(IN_ATTACK2)) then
				self:OpenMenu()
			end
		end
	end
end

function TOOL:OpenMenu()
	local w = ScrW()/4
	local h = ScrH()

	self.menuframe = vgui.Create( "DFrame" )
	self.menuframe:SetSize( w, h ) -- Set the size of the panel
	self.menuframe:Dock(RIGHT)
	self.menuframe:MakePopup()
	self.menuframe:SetKeyboardInputEnabled(true)
	self.menuframe:SetTitle("Clientside Weird Model Maker")

	self.menuframe.OnClose = function()
		self.menuframe = nil
	end

	MRTSMMUpdate()

	local TextEntry = vgui.Create( "DTextEntry", self.menuframe ) -- create the form as a child of frame
	TextEntry:SetPos( 25, 30 )
	TextEntry:SetSize( w-50, h-320 )
	TextEntry:SetMultiline( true )
	TextEntry:SetText( MRTSMMJson )
	TextEntry.OnEnter = function( self )
		chat.AddText( self:GetValue() )	-- print the form's text as server text
	end

	local updateButton = vgui.Create( "DButton", self.menuframe)
	updateButton:SetSize(w/12, 40)
	updateButton:SetText("<<")
	updateButton:SetPos(w/12, h-280)
	updateButton.DoClick = function()
		MRTSMMRotation = -50
	end
	local updateButton = vgui.Create( "DButton", self.menuframe)
	updateButton:SetSize(w/12, 40)
	updateButton:SetText("<")
	updateButton:SetPos(w/12+w/12, h-280)
	updateButton.DoClick = function()
		MRTSMMRotation = -10
	end
	local updateButton = vgui.Create( "DButton", self.menuframe)
	updateButton:SetSize(w/12, 40)
	updateButton:SetText("stop")
	updateButton:SetPos(w/12+w/6, h-280)
	updateButton.DoClick = function()
		MRTSMMRotation = 0
	end
	local updateButton = vgui.Create( "DButton", self.menuframe)
	updateButton:SetSize(w/12, 40)
	updateButton:SetText(">")
	updateButton:SetPos(w/12+w/4, h-280)
	updateButton.DoClick = function()
		MRTSMMRotation = 10
	end
	local updateButton = vgui.Create( "DButton", self.menuframe)
	updateButton:SetSize(w/12, 40)
	updateButton:SetText(">>")
	updateButton:SetPos(w/12+w/3, h-280)
	updateButton.DoClick = function()
		MRTSMMRotation = 50
	end

	local updateButton = vgui.Create( "DButton", self.menuframe)
	updateButton:SetSize(w/6, 40)
	updateButton:SetText("Toggle Aiming")
	updateButton:SetPos(w/2+w/12, h-280)
	updateButton.DoClick = function()
		MRTSMMPointAround = not MRTSMMPointAround
	end

	local updateButton = vgui.Create( "DButton", self.menuframe)
	updateButton:SetSize(w/6, 40)
	updateButton:SetText("Toggle Moving")
	updateButton:SetPos(w/2+w/12+w/6, h-280)
	updateButton.DoClick = function()
		MRTSMMMoving = not MRTSMMMoving
	end

	local DColorPalette = vgui.Create( "DColorPalette", self.menuframe )
	DColorPalette:SetPos( w/12, h-160 )
	DColorPalette:SetSize( 160, 50 )
	DColorPalette.OnValueChanged = function( s, value )
		MRTSMMColor = value
		MRTSMMUpdate()
	end

	local updateButton = vgui.Create( "DButton", self.menuframe)
	updateButton:SetSize(w/3, 50)
	updateButton:SetText("Update")
	updateButton:SetPos(w/12, h-220)
	updateButton.DoClick = function()
		MRTSMMJson = TextEntry:GetValue()
		MRTSMMUpdate()
	end

	local label = vgui.Create( "DLabel", self.menuframe )
	label:SetPos(w/12, h-130)
	label:SetSize( w/3, 25 )
	label:SetText( "Windup Milliseconds" )

	local Scratch = vgui.Create( "DNumberWang", self.menuframe )
	Scratch:SetPos(w/12, h-105)
	Scratch:SetSize( w/3, 25 )
	Scratch:SetMin( 0 )
	Scratch:SetMax( 5000 )
	Scratch:SetValue( MRTSMMWindup*1000 )
	Scratch.OnValueChanged = function()
		MRTSMMWindup = Scratch:GetValue()/1000
	end

	local animateButton = vgui.Create( "DButton", self.menuframe)
	animateButton:SetSize(w/3, 50)
	animateButton:SetText("Play animation")
	animateButton:SetPos(w/2+w/12, h-150)
	animateButton.DoClick = function()
		MRTSMManim = CurTime()+MRTSMMWindup
	end

	local label = vgui.Create( "DLabel", self.menuframe )
	label:SetPos(w/12, h-80)
	label:SetSize( w/3, 25 )
	label:SetText( "Size" )

	local Scratch = vgui.Create( "DNumberWang", self.menuframe )
	Scratch:SetPos(w/12, h-55)
	Scratch:SetSize( w/3, 25 )
	Scratch:SetValue( MRTSMMSize )
	Scratch:SetMin( 1 )
	Scratch:SetMax( 100 )
	Scratch.OnValueChanged = function()
		MRTSMMSize = Scratch:GetValue()
		MRTSMMSizeChanged = CurTime()
	end

	local deleteButton = vgui.Create( "DButton", self.menuframe)
	deleteButton:SetSize(w/3, 50)
	deleteButton:SetText("Delete Model")
	deleteButton:SetPos(w/2+w/12, h-80)
	deleteButton.DoClick = function()
		MRTSMMDelete()
		self.menuframe:Close()
	end

	local copyToClipboardButton = vgui.Create( "DButton", self.menuframe)
	copyToClipboardButton:SetSize(w/3, 50)
	copyToClipboardButton:SetText("Copy to clipboard")
	copyToClipboardButton:SetPos(w/2+w/12, h-220)
	copyToClipboardButton.DoClick = function()
		SetClipboardText( TextEntry:GetValue() )
	end
end