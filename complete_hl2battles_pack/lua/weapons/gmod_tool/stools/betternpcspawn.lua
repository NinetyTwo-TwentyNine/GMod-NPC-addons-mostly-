TOOL.Category = "NPC"
TOOL.Name = "Better NPC Spawner"

TOOL.ClientConVar["category"] = ""
TOOL.ClientConVar["name"] = ""
TOOL.ClientConVar["slot"] = ""
TOOL.ClientConVar["keyvalue"] = ""

TOOL.Information = {
  {name = "left"},
  {name = "reload"}
}


local NPCNames = {}
if SERVER then
  cvars.AddChangeCallback("bns_npc_check_complete", function()
    if GetConVarNumber("bns_npc_check_complete") == 1 then
      for k,v in pairs(list.Get("NPC")) do
        if !table.IsEmpty(list.Get("BNS_NPCKeyValues")[v.Class]) then
          if !NPCNames[v.Category] then
            NPCNames[v.Category] = {}
          end
          NPCNames[v.Category][v.Name] = k
        end
      end
    end
  end)
end


local DefaultNPCList = {}
local DefaultKeyValues = {}
if SERVER then
  util.AddNetworkString("BNS_SendNamesCategories")
  util.AddNetworkString("BNS_ReceiveNamesCategories")

  util.AddNetworkString("BNS_SendDefaultKeyValues")
  util.AddNetworkString("BNS_ReceiveDefaultKeyValues")

  util.AddNetworkString("BNS_SendNPCTable")
  util.AddNetworkString("BNS_ReceiveNPCTable")

  util.AddNetworkString("BNS_SendServerNPCList")
  util.AddNetworkString("BNS_ReceiveServerNPCList")

  util.AddNetworkString("BNS_SetServerPlayerNPCList")
  util.AddNetworkString("BNS_SetClientNPCList")


  local SendNPCNamesCategories = function(len, ply)
    net.Start("BNS_ReceiveNamesCategories")
      net.WriteTable(NPCNames)
    net.Send(ply)
  end
  net.Receive("BNS_SendNamesCategories", SendNPCNamesCategories)

  local SendDefaultNPCKeyValues = function(len, ply)
    DefaultKeyValues = list.Get("BNS_NPCKeyValues")[list.Get("NPC")[net.ReadString()].Class]
    net.Start("BNS_ReceiveDefaultKeyValues")
      net.WriteTable(DefaultKeyValues)
    net.Send(ply)
  end
  net.Receive("BNS_SendDefaultKeyValues", SendDefaultNPCKeyValues)

  local SendServerNPCList = function(len, ply)
    net.Start("BNS_ReceiveServerNPCList")
      net.WriteString(util.TableToJSON(list.Get("BNS_AllNPCTemplates")))
    net.Send(ply)
  end
  net.Receive("BNS_SendServerNPCList", SendServerNPCList)

  local SetServerPlayerNPCList = function(len, ply)
    DefaultNPCList = util.JSONToTable(net.ReadString())
    if ply:IsListenServerHost() then
      for k,v in pairs(list.Get("BNS_AllNPCTemplates")) do
        list.Set("BNS_AllNPCTemplates", k, DefaultNPCList[k])
        list.Set("NPC", k, DefaultNPCList[k])
      end
    end

    local NewNPCList = util.JSONToTable(net.ReadString())
    if ply:IsListenServerHost() then
      for k,v in pairs(NewNPCList) do
        list.Set("BNS_AllNPCTemplates", k, NewNPCList[k])
        list.Set("NPC", k, NewNPCList[k])
      end
    else
      list.Set("BNS_PlayerNPCTemplates", ply:AccountID(), NewNPCList)
      if table.IsEmpty(list.Get("BNS_PlayerNPCTemplates")[ply:AccountID()]) then
        list.GetForEdit("BNS_PlayerNPCTemplates")[ply:AccountID()] = nil
      end
    end
  end
  net.Receive("BNS_SetServerPlayerNPCList", SetServerPlayerNPCList)
end


local NPCTable = {}
local ChangedNPCTemplates = {}
if CLIENT then
  local SendNPCTable = function(len, ply)
    net.Start("BNS_ReceiveNPCTable")
      net.WriteTable(NPCTable)
    net.SendToServer()
  end
  net.Receive("BNS_SendNPCTable", SendNPCTable)

  local SetClientNPCList = function(len, ply)
    for k,v in pairs({"Skin", "SpawnFlags", "KeyValues", "Weapons", "Model", "Material", "Health"}) do
      if NPCTable[v] then
        list.GetForEdit("NPC")[NPCNames[GetConVarString("betternpcspawn_category")][GetConVarString("betternpcspawn_name")]][v] = NPCTable[v]
      else
        list.GetForEdit("NPC")[NPCNames[GetConVarString("betternpcspawn_category")][GetConVarString("betternpcspawn_name")]][v] = nil
      end
    end

    print("==================================================")
    PrintTable(list.Get("NPC")[NPCNames[GetConVarString("betternpcspawn_category")][GetConVarString("betternpcspawn_name")]])
    print("==================================================")

    if !table.HasValue(ChangedNPCTemplates, NPCNames[GetConVarString("betternpcspawn_category")][GetConVarString("betternpcspawn_name")]) then
      table.insert(ChangedNPCTemplates, NPCNames[GetConVarString("betternpcspawn_category")][GetConVarString("betternpcspawn_name")])
    end
  end
  net.Receive("BNS_SetClientNPCList", SetClientNPCList)
end


function TOOL.BuildCPanel(cpanel)
  GetConVar("betternpcspawn_category"):SetString("")
  GetConVar("betternpcspawn_name"):SetString("")
  GetConVar("betternpcspawn_slot"):SetString("")
  GetConVar("betternpcspawn_keyvalue"):SetString("")

  function BuildThePanel()
    NPCNames = net.ReadTable()

    DefaultNPCList = table.Copy(list.Get("NPC"))
    local TemplateTable = {}

    local npclabel = vgui.Create("DLabel", cpanel)
    npclabel:Dock(TOP)
    npclabel:SetText("")
    npclabel:SetColor(Color(0, 0, 0, 255))
    npclabel:SetContentAlignment(5)

    local keyvaluetext = vgui.Create("DTextEntry", cpanel)
    keyvaluetext:SetSize(100, 25)
    keyvaluetext:CenterHorizontal()
    keyvaluetext:SetPos(keyvaluetext:GetX() - 100, 50)
    keyvaluetext:SetEnabled(false)
    keyvaluetext:SetEnterAllowed(false)
    keyvaluetext.OnEnter = function()
      if !NPCTable.KeyValues then
        NPCTable.KeyValues = {}
      end
      if keyvaluetext:GetText() == "" then
        NPCTable.KeyValues[GetConVarString("betternpcspawn_keyvalue")] = nil
      else
        NPCTable.KeyValues[GetConVarString("betternpcspawn_keyvalue")] = keyvaluetext:GetText()
      end
      if table.IsEmpty(NPCTable.KeyValues) then
        NPCTable.KeyValues = nil
      end
      npclabel:SetText(table.ToString(NPCTable))
    end

    local keyvalueselector = vgui.Create("DComboBox", cpanel)
    keyvalueselector:SetSize(100, 25)
    keyvalueselector:CenterHorizontal()
    keyvalueselector:SetPos(keyvalueselector:GetX() - 100, 75)
    keyvalueselector:SetEnabled(false)
    keyvalueselector.OnSelect = function(panel, index, value)
      LocalPlayer():ConCommand(string.format("betternpcspawn_keyvalue %s", value))

      keyvaluetext:SetEnabled(true)
      keyvaluetext:SetEnterAllowed(true)
      keyvaluetext:SetPlaceholderText("'"..value.."' value")
      keyvaluetext:SetValue(tostring(DefaultKeyValues[value]))
      if NPCTable.KeyValues then
        if NPCTable.KeyValues[value] then
          keyvaluetext:SetValue(NPCTable.KeyValues[value])
        end
      end
    end

    local weaponremover = vgui.Create("DComboBox", cpanel)
    weaponremover:SetSize(100, 25)
    weaponremover:CenterHorizontal()
    weaponremover:SetPos(weaponremover:GetX() + 100, 75)
    weaponremover:SetEnabled(false)
    weaponremover.OnSelect = function(panel, index, value)
      table.RemoveByValue(NPCTable.Weapons, value)
      weaponremover:Clear()
      weaponremover:SetText("Remove selected weapon")
      if table.IsEmpty(NPCTable.Weapons) then
        weaponremover:SetEnabled(false)
      else
        for k,v in pairs(NPCTable.Weapons) do
          weaponremover:AddChoice(v)
        end
      end
      npclabel:SetText(table.ToString(NPCTable))
    end

    local weaponinserter = vgui.Create("DTextEntry", cpanel)
    weaponinserter:SetSize(100, 25)
    weaponinserter:CenterHorizontal()
    weaponinserter:SetPos(weaponinserter:GetX() + 100, 50)
    weaponinserter:SetEnabled(false)
    weaponinserter:SetEnterAllowed(false)
    weaponinserter.OnEnter = function()
      if weaponinserter:GetText() != "" then
        if !table.HasValue(NPCTable.Weapons, weaponinserter:GetText()) then
          table.insert(NPCTable.Weapons, weaponinserter:GetText())
          weaponremover:AddChoice(weaponinserter:GetText())
          weaponremover:SetEnabled(true)
        end
        weaponinserter:SetText("")
        npclabel:SetText(table.ToString(NPCTable))
      end
    end

    local multiroletext = vgui.Create("DTextEntry", cpanel)
    multiroletext:SetSize(100, 25)
    multiroletext:CenterHorizontal()
    multiroletext:SetY(50)
    multiroletext:SetEnabled(false)
    multiroletext:SetEnterAllowed(false)
    multiroletext.OnEnter = function()
      if multiroletext:GetText() == "" then
        NPCTable[GetConVarString("betternpcspawn_slot")] = nil
      else
        NPCTable[GetConVarString("betternpcspawn_slot")] = multiroletext:GetText()
      end
      npclabel:SetText(table.ToString(NPCTable))
    end

    local multiroleselector = vgui.Create("DComboBox", cpanel)
    multiroleselector:SetSize(100, 25)
    multiroleselector:CenterHorizontal()
    multiroleselector:SetY(75)
    multiroleselector:SetEnabled(false)
    multiroleselector:AddChoice("SpawnFlags")
    multiroleselector:AddChoice("Health")
    multiroleselector:AddChoice("Skin")
    multiroleselector:AddChoice("Model")
    multiroleselector:AddChoice("Material")
    multiroleselector.OnSelect = function(panel, index, value)
      LocalPlayer():ConCommand(string.format("betternpcspawn_slot %s", value))

      multiroletext:SetValue("")
      if NPCTable[value] then
        multiroletext:SetValue(NPCTable[value])
      end
      multiroletext:SetPlaceholderText(""..value.." value")
      if value == "Health" || value == "Skin" || value == "SpawnFlags" then
        multiroletext:SetNumeric(true)
      else
        multiroletext:SetNumeric(false)
      end
      multiroletext:SetEnabled(true)
      multiroletext:SetEnterAllowed(true)
    end

    local function DisableTemplateParameters()
      table.Empty(NPCTable)
      npclabel:SetText("")

      keyvaluetext:SetText("")
      keyvaluetext:SetPlaceholderText("")
      keyvaluetext:SetEnabled(false)
      keyvaluetext:SetEnterAllowed(false)

      keyvalueselector:Clear()
      keyvalueselector:SetEnabled(false)
      keyvalueselector:SetText("")
      GetConVar("betternpcspawn_keyvalue"):SetString("")

      weaponinserter:SetText("")
      weaponinserter:SetPlaceholderText("")
      weaponinserter:SetEnabled(false)
      weaponinserter:SetEnterAllowed(false)

      weaponremover:Clear()
      weaponremover:SetEnabled(false)
      weaponremover:SetText("")

      multiroletext:SetText("")
      multiroletext:SetPlaceholderText("")
      multiroletext:SetEnabled(false)
      multiroletext:SetEnterAllowed(false)

      multiroleselector:SetEnabled(false)
      multiroleselector:SetText("")
      GetConVar("betternpcspawn_slot"):SetString("")
    end

    local function ResetTemplateParameters()
      npclabel:SetText(table.ToString(NPCTable))

      keyvaluetext:SetText("")
      keyvaluetext:SetPlaceholderText("Value")
      keyvaluetext:SetEnabled(false)
      keyvaluetext:SetEnterAllowed(false)

      keyvalueselector:SetEnabled(true)
      keyvalueselector:SetText("Key")
      GetConVar("betternpcspawn_keyvalue"):SetString("")

      if NPCTable.Weapons then
        weaponinserter:SetText("")
        weaponinserter:SetPlaceholderText("Add a weapon")
        weaponinserter:SetEnabled(true)
        weaponinserter:SetEnterAllowed(true)

        weaponremover:Clear()
        weaponremover:SetEnabled(false)
        if !table.IsEmpty(NPCTable.Weapons) then
          for k,v in pairs(NPCTable.Weapons) do
            weaponremover:AddChoice(v)
          end
          weaponremover:SetEnabled(true)
        end
        weaponremover:SetText("Remove selected weapon")
      end

      multiroletext:SetText("")
      multiroletext:SetPlaceholderText("Value")
      multiroletext:SetEnabled(false)
      multiroletext:SetEnterAllowed(false)

      multiroleselector:SetText("Slot")
      multiroleselector:SetEnabled(true)
      GetConVar("betternpcspawn_slot"):SetString("")
    end


    local templateselector = vgui.Create("DComboBox", cpanel)
    templateselector:SetSize(300, 25)
    templateselector:CenterHorizontal()
    templateselector:SetY(125)
    templateselector:SetText("Choose an already created template")
    templateselector:SetEnabled(false)
    templateselector.OnSelect = function(panel, index, value)
      NPCTable = table.Copy(TemplateTable[list.Get("NPC")[NPCNames[GetConVarString("betternpcspawn_category")][GetConVarString("betternpcspawn_name")]].Class][value])
      ResetTemplateParameters()

      templateselector:SetText("Choose an already created template")
    end

    local templatestorer = vgui.Create("DButton", cpanel)
    templatestorer:SetSize(300, 25)
    templatestorer:CenterHorizontal()
    templatestorer:SetY(150)
    templatestorer:SetText("Save current NPC template")
    templatestorer:SetEnabled(false)
    templatestorer.DoClick = function()
      if !TemplateTable[list.Get("NPC")[NPCNames[GetConVarString("betternpcspawn_category")][GetConVarString("betternpcspawn_name")]].Class] then
        TemplateTable[list.Get("NPC")[NPCNames[GetConVarString("betternpcspawn_category")][GetConVarString("betternpcspawn_name")]].Class] = {}
      end
      if !TemplateTable[list.Get("NPC")[NPCNames[GetConVarString("betternpcspawn_category")][GetConVarString("betternpcspawn_name")]].Class][table.ToString(NPCTable)] then
        TemplateTable[list.Get("NPC")[NPCNames[GetConVarString("betternpcspawn_category")][GetConVarString("betternpcspawn_name")]].Class][table.ToString(NPCTable)] = table.Copy(NPCTable)
        templateselector:AddChoice(table.ToString(NPCTable))
        templateselector:SetEnabled(true)
      end
    end

    local function DisableTemplateSaves()
      templateselector:Clear()
      templateselector:SetText("Choose an already created template")
      templateselector:SetEnabled(false)

      templatestorer:SetEnabled(false)
    end

    local function ResetTemplateSaves(npcname)
      templateselector:Clear()
      if TemplateTable[list.Get("NPC")[NPCNames[GetConVarString("betternpcspawn_category")][npcname]].Class] then
        for k,v in pairs(TemplateTable[list.Get("NPC")[NPCNames[GetConVarString("betternpcspawn_category")][npcname]].Class]) do
          templateselector:AddChoice(k)
        end
        templateselector:SetEnabled(true)
      else
        templateselector:SetEnabled(false)
      end
      templateselector:SetText("Choose an already created template")

      templatestorer:SetEnabled(true)
    end


    local npcselector = vgui.Create("DComboBox", cpanel)
    npcselector:SetSize(300, 25)
    npcselector:CenterHorizontal()
    npcselector:SetY(200)
    npcselector:SetText("Default NPC templates")
    npcselector:SetEnabled(false)
    npcselector.OnSelect = function(panel, index, value)
      LocalPlayer():ConCommand(string.format("betternpcspawn_name %s", value))

      net.Start("BNS_SendDefaultKeyValues")
        net.WriteString(NPCNames[GetConVarString("betternpcspawn_category")][value])
      net.SendToServer()

      function GetDefaultNPCKeyValues()
        DefaultKeyValues = net.ReadTable()

        DisableTemplateParameters()

        for k,v in pairs(list.Get("NPC")[NPCNames[GetConVarString("betternpcspawn_category")][value]]) do
          if k == "SpawnFlags" || k == "Health" || k == "Skin" || k == "Model" || k == "Material" || k == "Weapons" || k == "KeyValues" then
            if k == "KeyValues" then
              NPCTable.KeyValues = {}
              for k1,v1 in pairs(v) do
                NPCTable.KeyValues[string.lower(k1)] = tostring(v1)
              end
            elseif k == "Weapons" then
              NPCTable.Weapons = v
            else
              NPCTable[k] = tostring(v)
            end
          end
        end

        for k,v in pairs(DefaultKeyValues) do
          if k != "hammerid" && k != "classname" && k != "health" && k != "max_health" then
            keyvalueselector:AddChoice(k)
          end
        end

        ResetTemplateParameters()
        ResetTemplateSaves(value)
      end
      net.Receive("BNS_ReceiveDefaultKeyValues", GetDefaultNPCKeyValues)
    end

    local categoryselector = vgui.Create("DComboBox", cpanel)
    categoryselector:SetSize(300, 25)
    categoryselector:CenterHorizontal()
    categoryselector:SetY(225)
    categoryselector:SetText("NPC list categories")
    for k,v in pairs(NPCNames) do
      categoryselector:AddChoice(k)
    end
    categoryselector.OnSelect = function(panel, index, value)
      LocalPlayer():ConCommand(string.format("betternpcspawn_category %s", value))

      DisableTemplateParameters()
      DisableTemplateSaves()

      npcselector:Clear()
      npcselector:SetEnabled(true)
      npcselector:SetText("Default NPC templates")
      for k,v in pairs(NPCNames[value]) do
        npcselector:AddChoice(k)
      end
      GetConVar("betternpcspawn_name"):SetString("")
    end

    local function ResetTemplateCategories()
      DisableTemplateParameters()
      DisableTemplateSaves()

      npcselector:Clear()
      npcselector:SetEnabled(false)
      npcselector:SetText("Default NPC templates")
      GetConVar("betternpcspawn_name"):SetString("")

      categoryselector:SetText("NPC list categories")
      GetConVar("betternpcspawn_category"):SetString("")
    end


    local presetselector = vgui.Create("DPanel", cpanel)

    local psCBox = vgui.Create("DComboBox", presetselector)
    psCBox:SetWide(194)
    psCBox:AddChoice("")
    for _,f in ipairs(file.Find("betternpcspawner/*.txt", "DATA")) do
      psCBox:AddChoice(string.sub(f, 1, -5))
    end
    psCBox.OnSelect = function(psCBox, idx, val, data)
      table.Empty(TemplateTable)
      table.Empty(ChangedNPCTemplates)

      net.Start("BNS_SendServerNPCList")
      net.SendToServer()

      function OnGotServerNPCList()
        if !LocalPlayer():IsListenServerHost() then
	  DefaultNPCList = util.JSONToTable(net.ReadString())
        end
        for k,v in pairs(DefaultNPCList) do list.Set("NPC", k, v) end

        net.Start("BNS_SetServerPlayerNPCList")
        net.WriteString(util.TableToJSON(DefaultNPCList))

        local content = file.Read("betternpcspawner/"..val..".txt", "DATA")
        if (content) then
          local data = util.JSONToTable(content)
          TemplateTable = table.Copy(data.SavedTemplates)
          ChangedNPCTemplates = table.GetKeys(data.ChangedTemplates)

          net.WriteString(util.TableToJSON(data.ChangedTemplates))
          for k,v in pairs(data.ChangedTemplates) do
            if list.Get("NPC")[k] then
              list.GetForEdit("NPC")[k] = data.ChangedTemplates[k]
              print("==================================================")
              PrintTable(list.Get("NPC")[k])
              print("==================================================")
            end
          end
        else
          net.WriteString(util.TableToJSON({}))
        end
        net.SendToServer()
      end
      net.Receive("BNS_ReceiveServerNPCList", OnGotServerNPCList)

      ResetTemplateCategories()
    end

    local savebutton = vgui.Create("DImageButton", presetselector)
    savebutton:SetImage("gui/silkicons/disk.vmt")
    savebutton:SetSize(16,16)
    savebutton:SetPos(psCBox:GetWide(), psCBox:GetTall()*0.5 - 8)
    savebutton:SizeToContents()
    savebutton.OnMousePressed = function(savebutton)
      local p = vgui.Create("DFrame")
      p:SetSize(220, 110) 
      p:SetPos(ScrW()*0.5 - 110, ScrH()*0.5 - 55)
      p:MakePopup()
      p:ShowCloseButton(true)
      p:SetTitle("Preset Save Window")
		
      local l = vgui.Create("DLabel", p)
      l:SetText("Name:")
      l:SetPos(20,40)

      local teName = vgui.Create("DTextEntry", p)
      teName:SetSize(146,16)
      teName:SetPos(55,42)
		
      local bSave = vgui.Create("DButton", p)
      bSave:SetText("Save")
      bSave:SetSize(80,21)
      bSave:SetPos(20,70)
      bSave:SetEnabled(false)
      bSave.DoClick = function(bSave)
        p:Close()
        if (teName:GetValue() != "") then
          local data = {}
          data.SavedTemplates = TemplateTable
          data.ChangedTemplates = {}
          for k,v in pairs(ChangedNPCTemplates) do
            if list.Get("NPC")[v] then
              data.ChangedTemplates[v] = list.Get("NPC")[v]
            end
          end
          file.CreateDir("betternpcspawner")
          file.Write("betternpcspawner/"..teName:GetValue()..".txt", util.TableToJSON(data))
          if !table.HasValue(psCBox.Choices, teName:GetValue()) then
            psCBox:AddChoice(teName:GetValue())
          end
        end
      end

      teName.OnChange = function()
        if !table.IsEmpty(ChangedNPCTemplates) || !table.IsEmpty(TemplateTable) then
          bSave:SetEnabled(teName:GetValue() != "")
        end
      end
		
      local bCancel = vgui.Create("DButton", p)
      bCancel:SetText("Cancel")
      bCancel:SetSize(80,21)
      bCancel:SetPos(120,70)
      bCancel.DoClick = function()
        p:Close()
      end
    end

    presetselector:SetTall(psCBox:GetTall())
    presetselector:SetWide(psCBox:GetWide() + savebutton:GetWide())
    presetselector:CenterHorizontal()
    presetselector:SetY(275)

    local function CentralizeThePanel()
      keyvaluetext:CenterHorizontal()
      keyvaluetext:SetX(keyvaluetext:GetX() - (keyvaluetext:GetWide() + multiroletext:GetWide())/2)
      keyvalueselector:CenterHorizontal()
      keyvalueselector:SetX(keyvalueselector:GetX() - (keyvalueselector:GetWide() + multiroleselector:GetWide())/2)

      weaponinserter:CenterHorizontal()
      weaponinserter:SetX(weaponinserter:GetX() + (weaponinserter:GetWide() + multiroletext:GetWide())/2)
      weaponremover:CenterHorizontal()
      weaponremover:SetX(weaponremover:GetX() + (weaponremover:GetWide() + multiroleselector:GetWide())/2)

      multiroletext:CenterHorizontal()
      multiroleselector:CenterHorizontal()

      templateselector:CenterHorizontal()
      templatestorer:CenterHorizontal()

      npcselector:CenterHorizontal()
      categoryselector:CenterHorizontal()

      presetselector:CenterHorizontal()
    end

    local tName = "Centralizing the panel#"LocalPlayer():EntIndex()
    timer.Create(tName, FrameTime(), 0, function()
      if !IsValid(LocalPlayer()) then timer.Remove(tName) return end
      if !IsValid(cpanel) then return end
      CentralizeThePanel()
    end)
  end

  local tName = "SetupFunction#"..LocalPlayer():EntIndex()
  timer.Create(tName, 0.1, 0, function()
    if GetConVarNumber("bns_npc_check_complete") == 1 then
      timer.Remove(tName)

      net.Start("BNS_SendNamesCategories")
        net.WriteEntity(LocalPlayer())
      net.SendToServer()

      net.Receive("BNS_ReceiveNamesCategories", BuildThePanel)
    end
  end)

  language.Add("tool.betternpcspawn.name", "Better NPC Spawner")
  language.Add("tool.betternpcspawn.left", "Create NPC with chosen properties.")
  language.Add("tool.betternpcspawn.reload", "Apply changes to the NPC list.")
  language.Add("tool.betternpcspawn.desc", "Make NPCs with any properties.")
end


function TOOL:LeftClick( trace )
  if IsValid(self:GetOwner()) then
    if SERVER then
      if not self:GetOwner():CheckLimit("npcs") then return false end

      if self:GetOwner():GetInfo("betternpcspawn_name") != "" then
        net.Start("BNS_SendNPCTable")
        net.Send(self:GetOwner())

        local NPCTableReceived = function(len, ply)
          NPCTable = net.ReadTable()

          for k,v in pairs(list.Get("NPC")[NPCNames[self:GetOwner():GetInfo("betternpcspawn_category")][self:GetOwner():GetInfo("betternpcspawn_name")]]) do
            if k != "Skin" && k != "SpawnFlags" && k != "KeyValues" && k != "Weapons" && k != "Model" && k != "Material" && k != "Health" then
              NPCTable[k] = v
            end
          end
          list.Set("NPC", NPCNames[self:GetOwner():GetInfo("betternpcspawn_category")][self:GetOwner():GetInfo("betternpcspawn_name")], NPCTable)
          hook.Run("PlayerSpawnNPC", self:GetOwner(), NPCNames[self:GetOwner():GetInfo("betternpcspawn_category")][self:GetOwner():GetInfo("betternpcspawn_name")], true)
          NPCTable = list.Get("NPC")[NPCNames[self:GetOwner():GetInfo("betternpcspawn_category")][self:GetOwner():GetInfo("betternpcspawn_name")]]

          local npc = ents.Create(NPCTable.Class)
          npc:SetPos(trace.HitPos)
          if NPCTable.Offset then
            npc:SetPos(Vector(npc:GetPos().x, npc:GetPos().y, npc:GetPos().z + NPCTable.Offset))
          end
          npc:SetAngles(Angle(0, self:GetOwner():GetAngles().y - 180, 0))

          if NPCTable.Model then
            npc:SetKeyValue("model", NPCTable.Model)
          end
          if NPCTable.Skin then
            npc:SetKeyValue("skin", NPCTable.Skin)
          end
          if NPCTable.SpawnFlags then
            npc:SetKeyValue("spawnflags", NPCTable.SpawnFlags)
          end
          if NPCTable.Weapons && !table.IsEmpty(NPCTable.Weapons) then
            npc:SetKeyValue("additionalequipment", table.Random(NPCTable.Weapons))
          end
          if NPCTable.KeyValues then
            for k,v in pairs(NPCTable.KeyValues) do
              npc:SetKeyValue(k, v)
            end
          end

          npc:Spawn()
          npc:Activate()
          hook.Run("PlayerSpawnedNPC", self:GetOwner(), npc)
          if NPCTable.Material then
            npc:SetMaterial(NPCTable.Material)
          end
          if NPCTable.Model && npc:GetModel() != NPCTable.Model then
            npc:SetModel(NPCTable.Model)
          end
          if NPCTable.Health then
            npc:SetHealth(tonumber(NPCTable.Health))
          end

          self:GetOwner():AddCount("npcs", npc)
          undo.Create(NPCTable.Name)
          undo.AddEntity(npc)
          undo.SetPlayer(self:GetOwner())
          undo.SetCustomUndoText("Undone "..NPCTable.Name)
          undo.Finish()
          self:GetOwner():AddCleanup("npcs", npc)
        end
        net.Receive("BNS_ReceiveNPCTable", NPCTableReceived)
      end
    end
    return true
  end
end

function TOOL:Reload( )
  if IsValid(self:GetOwner()) then
    if SERVER then
      if self:GetOwner():GetInfo("betternpcspawn_name") != "" then
        net.Start("BNS_SetClientNPCList")
        net.Send(self:GetOwner())


        net.Start("BNS_SendNPCTable")
          net.WriteEntity(self:GetOwner())
        net.Send(self:GetOwner())

        local NPCTableReceived = function(len, ply)
          NPCTable = net.ReadTable()

          for k,v in pairs(list.Get("NPC")[NPCNames[self:GetOwner():GetInfo("betternpcspawn_category")][self:GetOwner():GetInfo("betternpcspawn_name")]]) do
            if k != "Skin" && k != "SpawnFlags" && k != "KeyValues" && k != "Weapons" && k != "Model" && k != "Material" && k != "Health" then
              NPCTable[k] = v
            end
          end

          if !self:GetOwner():IsListenServerHost() then
            if !list.Get("BNS_PlayerNPCTemplates")[self:GetOwner():AccountID()] then
              list.GetForEdit("BNS_PlayerNPCTemplates")[self:GetOwner():AccountID()] = {}
            end
            list.GetForEdit("BNS_PlayerNPCTemplates")[self:GetOwner():AccountID()][NPCNames[self:GetOwner():GetInfo("betternpcspawn_category")][self:GetOwner():GetInfo("betternpcspawn_name")]] = NPCTable
          else
            list.Set("BNS_AllNPCTemplates", NPCNames[self:GetOwner():GetInfo("betternpcspawn_category")][self:GetOwner():GetInfo("betternpcspawn_name")], NPCTable)
            list.Set("NPC", NPCNames[self:GetOwner():GetInfo("betternpcspawn_category")][self:GetOwner():GetInfo("betternpcspawn_name")], NPCTable)
          end
        end
        net.Receive("BNS_ReceiveNPCTable", NPCTableReceived)
      end
    end
    return true
  end
end