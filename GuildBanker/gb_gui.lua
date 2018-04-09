GB_NUM_HITLIST_ENTRIES = 14
GB_NUM_ITEMLARGESS_ENTRIES = 8
GB_NUM_AUDIT_HISTORY_ENTRIES = 8
GB_SelectedBounty = -1

----------------------
--  Minimap Button  --
----------------------
do
	local dragMode = nil
	
	local function moveButton(self)
		if dragMode == "free" then
			local centerX, centerY = Minimap:GetCenter()
			local x, y = GetCursorPosition()
			x, y = x / self:GetEffectiveScale() - centerX, y / self:GetEffectiveScale() - centerY
			self:ClearAllPoints()
			self:SetPoint("CENTER", x, y)
		else
			local centerX, centerY = Minimap:GetCenter()
			local x, y = GetCursorPosition()
			x, y = x / self:GetEffectiveScale() - centerX, y / self:GetEffectiveScale() - centerY
			centerX, centerY = math.abs(x), math.abs(y)
			centerX, centerY = (centerX / math.sqrt(centerX^2 + centerY^2)) * 80, (centerY / sqrt(centerX^2 + centerY^2)) * 80
			centerX = x < 0 and -centerX or centerX
			centerY = y < 0 and -centerY or centerY
			self:ClearAllPoints()
			self:SetPoint("CENTER", centerX, centerY)
		end
	end

	local button = CreateFrame("Button", "GBMinimapButton", Minimap)
	button:SetHeight(32)
	button:SetWidth(32)
	button:SetFrameStrata("MEDIUM")
	button:SetPoint("CENTER", -65.35, -38.8)
	button:SetMovable(true)
	button:SetUserPlaced(true)
	button:SetNormalTexture("interface\\minimap\\tracking\\Auctioneer")
	button:SetPushedTexture("interface\\minimap\\tracking\\Auctioneer")
	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

	button:SetScript("OnMouseDown", function(self, button)
		if IsShiftKeyDown() and IsAltKeyDown() then
			dragMode = "free"
			self:SetScript("OnUpdate", moveButton)
		elseif IsShiftKeyDown() then
			dragMode = nil
			self:SetScript("OnUpdate", moveButton)        
		end
	end)
	button:SetScript("OnMouseUp", function(self)
		self:SetScript("OnUpdate", nil)
	end)
	button:SetScript("OnClick", function(self, button)
		if IsShiftKeyDown() then return end        
        GB_ToggleHitList()
	end)
	button:SetScript("OnEnter", function(self)
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		GameTooltip:SetText("Guild Banker")
        GameTooltip:AddLine("Left Click to toggle main panel",1,1,1)
        GameTooltip:AddLine("Shift+Click to move this button on the minimap",1,1,1)
        GameTooltip:AddLine("Shift+Alt+Click to move this button anywhere",1,1,1)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	function GB_ToggleMinimapButton()
		self.Options.ShowMinimapButton = not self.Options.ShowMinimapButton
		if self.Options.ShowMinimapButton then
			button:Show()
		else
			button:Hide()
		end
	end

	function GB_HideMinimapButton()
		return button:Hide()
	end
end

function GB_ToggleHitList()
    if (GB_ListFrame:IsShown()) then
        GB_ListFrame:Hide();
    else
        GB_ListFrame:Show();
    end
end

function GB_ExitHitListEntry(self)
    GameTooltip:Hide()
end

function GB_CreateGUI()
   local i,frame,textString,moneyFrame   
   
   --Set Column Header Widths (kludgey adaptation to 4.0.1 guild roster)
   
   --balance view
   GB_ColumnHeaderGuildieMiddle:SetWidth(150-9)
   GB_ColumnHeaderLargessMiddle:SetWidth(161-9)
   
   --item balance view
   GB_ColumnHeaderItemMiddle:SetWidth(150-9)
   GB_ColumnHeaderItemLargessMiddle:SetWidth(161-9)  
   
   --show default frame    
   GB_LargessViewFrame:Show()   
   MoneyFrame_Update(GB_GuildBalanceFrame, GB_Balance); 
   GB_GuildBalanceFrame:SetScript("OnUpdate",function() GB_GuiUpdate() end)   
 
   GB_UIFrame:SetPoint("TOPLEFT",-5,2)
   GB_LargessViewFrame:SetPoint("TOPLEFT",5,2)
   GB_LargessDetails:SetScript("OnUpdate",function() GBH_RosterLargessUpdate() end)       
end

function GB_CreateFriendsTab()   
   FriendsFrameTab6 = CreateFrame("Button", "FriendsFrameTab" ..6, FriendsFrame, "FriendsFrameTabTemplate");
   FriendsFrameTab6:SetPoint("LEFT", "FriendsFrameTab" .. 5, "RIGHT", -14, 0);
   FriendsFrameTab6:SetID(6);
   PanelTemplates_SetNumTabs(FriendsFrame, 6);
   PanelTemplates_UpdateTabs(FriendsFrame);
   FriendsFrameTab6:SetPoint("LEFT", "FriendsFrameTab" .. 5, "RIGHT", -14, 0);
   FriendsFrameTab6:SetText("GBH")
   TabID = 6

   -- add ourself to the subframe list....
   tinsert(FRIENDSFRAME_SUBFRAMES, "GB_UIFrame");

   hooksecurefunc("FriendsFrame_Update", GB_FriendsFrame_Update);
end

function GB_FriendsFrame_Update()
   if(FriendsFrame.selectedTab == 6) then
      FriendsFrameTitleText:SetText("Guild Bounty Hunter");
      if(GB_UIFrame:IsVisible()) then
         return;
      end
      FriendsFrameTopLeft:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopLeft");
      FriendsFrameTopRight:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopRight");
      FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\GuildFrame-BotLeft");      
      FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\GuildFrame-BotRight");
      
      --GB_UIFrame:ScrollFrameUpdate();
      GB_UIFrame:SetParent("FriendsFrame");
      GB_UIFrame:SetAllPoints();
      GB_UIFrame:Show();
      
      FriendsFrame_ShowSubFrame("NonExistingFrame"); -- so all friendframe tabs get hidden  
      FriendsFrame_ShowSubFrame("GB_UIFrame")
   end
end

function GB_DelayScript(script,delay,id)   
   if id == nil then
      id = "GB_TimerFrame"
   else
      id = "GB_TimerFrame"..id
   end
   local f = CreateFrame("Frame",id,UIParent)
   local stop = time() + delay
   f:SetScript("OnUpdate",function() GB_TimerUpdate(stop,f,script) end)   
end

function GB_TimerUpdate(stop,self,script)   
   local t = time()    
   if t >= stop then       
      self:SetScript("OnUpdate",nil)
      RunScript(script)
   end   
end

function GB_SortByName(a,b)    
   if GBH_NAME_SORT then      
      return a.name > b.name
   else      
      return a.name < b.name
   end
end
   
function GB_SortByAmount(a,b)   
   if GBH_AMOUNT_SORT then
      return tonumber(a.amount) > tonumber(b.amount)   
   else
      return tonumber(a.amount) < tonumber(b.amount) 
   end
end

function GB_GuiUpdate()     
    if GB_Balance == nil then
        return
    end
    local balance = GB_Balance 
    if balance < 0 then 
      balance = abs(balance)
      GBH_NegLargess:Show()
    else 
      GBH_NegLargess:Hide()
    end
      --GB_Message(balance)
      MoneyFrame_Update(GB_GuildBalanceFrame, balance);      
end

function GB_EnterItemButton(self)
    --GameTooltip_SetDefaultAnchor(GameTooltip,UIParent)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Guild Bank Item Price List")
    GameTooltip:AddLine("Set the price for guild bank items",1,1,1)
    GameTooltip:Show()
end

function GB_LeaveItemButton()
    GameTooltip:Hide()
end

function GB_DisplayItemLargess()
    GB_LargessViewFrame:Hide()      
    GB_UIFrame:Hide()   
    GB_ItemLargessFrame:Show()    
    GB_AuditHistoryFrame:Hide()
    GB_ConfigScrollFrame:Hide()
    
    --set portrait icon
    SetPortraitToTexture(GB_ListFrameSkullnXBonesTexture,"interface\\icons\\inv_ingot_03")
    --GB_HitListFrameSkullnXBones:SetFrameStrata("BACKGROUND")   
end

function GB_DisplayAuditHistory()
    GB_LargessViewFrame:Hide()      
    GB_UIFrame:Hide()   
    GB_ItemLargessFrame:Hide()
    GB_AuditHistoryFrame:Show()
    GB_ConfigScrollFrame:Hide() 
    --set portrait icon
    SetPortraitToTexture(GB_ListFrameSkullnXBonesTexture,"interface\\icons\\inv_misc_book_07")
    --GB_HitListFrameSkullnXBones:SetFrameStrata("BACKGROUND")   
end

function GB_EnterLargessReportButton(self)  
    --GameTooltip_SetDefaultAnchor(GameTooltip,UIParent)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Guild Bank Balance Report")
    GameTooltip:AddLine("A list of bank balances for all guild members",1,1,1)
    GameTooltip:Show()
end

function GB_LeaveLargessReportButton()
    GameTooltip:Hide()
end  

function GB_EnterAuditButton(self)
    --GameTooltip_SetDefaultAnchor(GameTooltip,UIParent)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Audit Guild Bank")
    GameTooltip:AddLine("Open the guild bank logs and audit all transactions",1,1,1)
    GameTooltip:Show()
end

function GB_LeaveAuditButton()
    GameTooltip:Hide()
end

function GB_EnterConfigButton(self)
    --GameTooltip_SetDefaultAnchor(GameTooltip,UIParent)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Configuration")
    GameTooltip:AddLine("Change some GBH settings",1,1,1)
    GameTooltip:Show()
end

function GB_LeaveConfigButton()
    GameTooltip:Hide()
end

function GB_LargessReportButtonOnClick()
    
    GB_ItemLargessFrame:Hide()
    GB_LargessViewFrame:Show()  
    GB_GuildBalanceFrame:Show()   
    GB_AuditHistoryFrame:Hide()  
    GB_ConfigScrollFrame:Hide()
    --set portrait icon
    SetPortraitToTexture(GB_ListFrameSkullnXBonesTexture,"interface\\icons\\inv_misc_coin_02")
    --GB_HitListFrameSkullnXBones:SetFrameStrata("BACKGROUND")   
end

function GB_CreateLargessView()
   local i,frame,textString,moneyFrame   
   
   --GB_UIFrame:SetScript("OnShow",GBH_UIShow)   
   GB_LargessScrollFrame:EnableMouse()
   GB_LargessScrollFrame:EnableMouseWheel(1)   
   GB_LargessScrollFrame:SetScript("OnShow",GB_LargessFrameUpdate) 
   GB_LargessScrollFrame:Show()   
   MoneyFrame_Update(GB_GuildBalanceFrame, GB_Balance); 
   
   --List Entry Frames (faux scroll frames)
   for i = 0,GB_NUM_HITLIST_ENTRIES-1 do       
      frame = CreateFrame("Button","GB_LargessEntry"..i,GB_LargessScrollFrame,"GB_LargessEntryTemplate")
      frame:SetPoint("TOPLEFT",0,-i*17)
      frame:Show() 
   end 
   GB_ListEntryNormalTexture = frame:GetNormalTexture()
   GB_LargessScrollFrame:SetPoint("TOPLEFT",10,-100) 
   GB_LargessCurrentEntry = 0
   MoneyFrame_Update(GBH_RosterMoneyFrame, 0); 
   
end  

function GB_SetupLargessViewList()
    local i, name, balance
    
    GB_LargessViewList = {}
    for i= 1, #GB_GuildMates do
        name = GB_GuildMates[i].name
        balance = GB_AuditData[name].balance
        table.insert(GB_LargessViewList, {name=name, balance=balance})
    end
    
    if GB_SORT_LARGESS_VIEW == "LARGESS" then
        table.sort(GB_LargessViewList,GB_SortByGuildieLargess)
    elseif GB_SORT_LARGESS_VIEW == "GUILDIE" then
        table.sort(GB_LargessViewList,GB_SortByGuildie)
    end
end

function GB_LargessFrameUpdate()
    local i,dataOffset,offset,n,m
    local moneyFrame,textString,entryFrame,negLargess  
    
    GB_SetupLargessViewList()
    n = #GB_LargessViewList
    FauxScrollFrame_Update(GB_LargessScrollFrame,n,GB_NUM_HITLIST_ENTRIES,17,nil,nil,nil,nil,nil,nil,true);
    offset = FauxScrollFrame_GetOffset(GB_LargessScrollFrame);
       
    for i = 0,GB_NUM_HITLIST_ENTRIES-1 do
        dataOffset = offset + i + 1      
        textString = _G["GB_LargessEntry"..i.."_GuildieName"]
        moneyFrame = _G["GB_LargessEntry"..i.."_LargessAmount"]
        negLargess = _G["GB_LargessEntry"..i.."_LargessAmount_NegGuildieLargess"]
        entryFrame = _G["GB_LargessEntry"..i]      
        if dataOffset <= n then   
            --set bounty money
            MoneyFrame_Update(moneyFrame, abs(GB_LargessViewList[dataOffset].balance));
            if GB_LargessViewList[dataOffset].balance < 0 then
                negLargess:Show()
                textString:SetTextColor(1,0,0)
            else
                textString:SetTextColor(1,0.81,0)
                negLargess:Hide()
            end
            --set target name
            textString:SetText(GB_LargessViewList[dataOffset].name)
            entryFrame.index = dataOffset
            if GB_LargessCurrentEntry == dataOffset then
                --set selected texture            
                entryFrame:LockHighlight()
            else
                --reset normal texture
                entryFrame:UnlockHighlight()
            end        
            entryFrame:Show()         
        else
            entryFrame:Hide()                
        end        
    end    
end

function GB_LargessEntryOnClick(self)
    GB_LargessCurrentEntry = self.index
    GB_LargessFrameUpdate()
    --GB_Message(i)
    
end

--TODO: rename this but make sure it doesn't conflict with the other GB_RosterLargessUpdate function
function GBH_RosterLargessUpdate()     
   local i = GB_LargessCurrentEntry    
   if GB_GuildMates == nil or GB_AuditData == nil then
        return
   end
   if i > 0 then  
      GuildRoster()
      GB_AuditInit()
      GB_AuditLoad()
      --GB_SetupLargessViewList()
      GB_LargessFrameUpdate()
      local balance = GB_LargessViewList[i].balance 
      if balance < 0 then 
         balance = abs(balance)
         GB_NegRosterLargess:Show()
      else 
         GB_NegRosterLargess:Hide()
      end
      --GB_Message(balance)
      --TODO: rename GBH_RosterMoneyFrame but make sure it doesn't conflict
      MoneyFrame_Update(GBH_RosterMoneyFrame, balance);      
   end
end

function GB_RosterLargessAdd()  
   if GB_GetAdminLevel() < GB_ADMIN then
        GB_Message("You do not have permission to adjust guild balances.")
        return
   end
   local i = GB_LargessCurrentEntry     
   local name = GB_LargessViewList[i].name
   local add = MoneyInputFrame_GetCopper(GB_LargessModFrame)  
   local base = GB_LargessViewList[i].balance   
   GB_SetLargess(name,base+add)
   local moneystr = GBL_CopperToGold(add)
   GB_Message(moneystr.." added to "..name.."'s guild balance.") 
   --GB_SetupLargessViewList()
end
   
 function GB_RosterLargessSub()  
    if GB_GetAdminLevel() < GB_ADMIN then
        GB_Message("You do not have permission to adjust guild balances.")
        return
   end
   local i = GB_LargessCurrentEntry     
   local name = GB_LargessViewList[i].name
   local sub = MoneyInputFrame_GetCopper(GB_LargessModFrame)  
   local base = GB_LargessViewList[i].balance   
   GB_SetLargess(name,base-sub)
   local moneystr = GBL_CopperToGold(sub)
   GB_Message(moneystr.." subtracted from "..name.."'s guild balance.","red") 
   --GB_SetupLargessViewList()
end 

function GB_RosterLargessEq()   
    if GB_GetAdminLevel() < GB_ADMIN then
        GB_Message("You do not have permission to adjust guild balances.")
        return
    end
   local i = GB_LargessCurrentEntry     
   local name = GB_LargessViewList[i].name
   local set = MoneyInputFrame_GetCopper(GB_LargessModFrame)    
   GB_SetLargess(name,set)
   local moneystr = GBL_CopperToGold(set)
   GB_Message(name.."'s Balance set to "..moneystr) 
   --GB_SetupLargessViewList()
end

function GBL_RosterLargessAdd()  
   if GB_GetAdminLevel() < GB_ADMIN then
        GB_Message("You do not have permission to adjust guild balances.")
        return
   end
   local i = GetGuildRosterSelection()     
   local name = GB_GuildMates[i].name
   local add = MoneyInputFrame_GetCopper(GBL_LargessModFrame)  
   local base = GB_AuditData[name].balance   
   GB_SetLargess(name,base+add)
   local moneystr = GBL_CopperToGold(add)
   GB_Message(moneystr.." added to "..name.."'s guild balance.") 
end
   
 function GBL_RosterLargessSub()  
    if GB_GetAdminLevel() < GB_ADMIN then
        GB_Message("You do not have permission to adjust guild balances.")
        return
   end
   local i = GetGuildRosterSelection()     
   local name = GB_GuildMates[i].name
   local sub = MoneyInputFrame_GetCopper(GBL_LargessModFrame)  
   local base = GB_AuditData[name].balance   
   GB_SetLargess(name,base-sub)
   local moneystr = GBL_CopperToGold(sub)
   GB_Message(moneystr.." subtracted from "..name.."'s guild balance.","red") 
end 

function GBL_RosterLargessEq()   
    if GB_GetAdminLevel() < GB_ADMIN then
        GB_Message("You do not have permission to adjust guild balance.")
        return
    end
   local i = GetGuildRosterSelection()     
   local name = GB_GuildMates[i].name
   local set = MoneyInputFrame_GetCopper(GBL_LargessModFrame)    
   GB_SetLargess(name,set)
   local moneystr = GBL_CopperToGold(set)
   GB_Message(name.."'s Balance set to "..moneystr) 
end

function GB_RosterLargessUpdate()     
   local i = GetGuildRosterSelection()      
   if GB_GuildMates == nil or GB_AuditData == nil then
        return
   end
   if i > 0 then  
      GB_AuditInit()
      GB_AuditLoad()
      local balance = GB_AuditData[GB_GuildMates[i].name].balance 
      if balance < 0 then 
         balance = abs(balance)
         GBL_NegRosterLargess:Show()
      else 
         GBL_NegRosterLargess:Hide()
      end
      --GB_Message(balance)
      MoneyFrame_Update(GB_RosterMoneyFrame, balance);      
   end
end