function GB_EnterAuditHistoryIconButton()
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:ClearLines()
    if GB_CurrentItemLargessIconItem ~= nil then
        GameTooltip:SetHyperlink(GB_CurrentItemLargessIconItem)
        GameTooltip:Show()
    end
end

function GB_LeaveAuditHistoryIconButton()
    GameTooltip:Hide()
end

function GB_ModifyAuditAmount(item, value)
    if GB_AuditHistory == nil then
        GB_AuditHistory = {}
    end 
    

end

function GB_DelAuditHistoryItem()
    if GB_AuditHistory == nil then
        GB_AuditHistory = {}
    end 
    table.remove(GB_AuditHistory, GB_AuditHistoryCurrentEntry)
end

function GB_EnterAuditHistoryButton(self)
    --GB_ItemLargessEntryOnClick(self:GetParent())
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:ClearLines()
    if (self:GetParent().typ == "repair") then
        GameTooltip:AddLine("Repair")
    elseif (self:GetParent().source == 0) then
        GameTooltip:AddLine("Gold")
    else
        GameTooltip:SetHyperlink(self:GetParent().data)
    end    
    --GameTooltip_SetDefaultAnchor(GameTooltip, self)
    GameTooltip:Show()
    --end
end
 
function GB_LeaveAuditHistoryButton()
    GameTooltip:Hide()
end

function GB_CreateAuditHistoryView()
   local i,frame,textString,moneyFrame   
   
   --GB_UIFrame:SetScript("OnShow",GBH_UIShow)   
   GB_AuditHistoryScrollFrame:EnableMouse()
   GB_AuditHistoryScrollFrame:EnableMouseWheel(1)   
   GB_AuditHistoryScrollFrame:SetScript("OnShow",GB_AuditHistoryFrameUpdate) 
   GB_AuditHistoryFrame:SetScript("OnUpdate",function() GB_AuditHistoryUpdate() end)
   GB_AuditHistoryScrollFrame:Show()     
   
   --List Entry Frames (faux scroll frames)
   for i = 0,GB_NUM_AUDIT_HISTORY_ENTRIES-1 do       
      frame = CreateFrame("Button","GB_AuditHistoryEntry"..i,GB_AuditHistoryScrollFrame,"GB_AuditHistoryEntryTemplate")
      frame:SetPoint("TOPLEFT",0,-i*28)  
      --_G["GBH_ItemLargessEntry"..i.."_ItemLargess"]:SetScale(.9)
      frame:Show() 
   end 
   --GB_ListEntryNormalTexture = frame:GetNormalTexture()
   GB_AuditHistoryScrollFrame:SetPoint("TOPLEFT",15,-100) 
   GB_AuditHistoryCurrentEntry = 0
   --MoneyFrame_Update(GB_RosterMoneyFrame, 0); 
   GB_AuditHistoryUpdate()
   
end  

function GB_AuditHistoryUpdate()
    local i,dataOffset,offset,n,m,r,g,b
    local moneyFrame,textString,entryFrame
    local transTypeString, itemIcon, itemIconTexture, sourceIcon, sourceIconTexture, playerName, countText
    
    n = #GB_AuditHistory    
    FauxScrollFrame_Update(GB_AuditHistoryScrollFrame,n,GB_NUM_AUDIT_HISTORY_ENTRIES,28,nil,nil,nil,nil,nil,nil,true);
    offset = FauxScrollFrame_GetOffset(GB_AuditHistoryScrollFrame);
       
       for i = 0,GB_NUM_AUDIT_HISTORY_ENTRIES-1 do
          dataOffset = offset + i + 1 
          transTypeString = _G["GB_AuditHistoryEntry"..i.."_Type"]
          itemIcon = _G["GB_AuditHistoryEntry"..i.."_ItemIcon"]
          itemIconTexture = _G["GB_AuditHistoryEntry"..i.."_ItemIcon_Texture"]
          sourceIcon = _G["GB_AuditHistoryEntry"..i.."_SourceIcon"]
          sourceIconTexture = _G["GB_AuditHistoryEntry"..i.."_SourceIcon_Texture"]
          playerName = _G["GB_AuditHistoryEntry"..i.."_PlayerName"]
          moneyFrame = _G["GB_AuditHistoryEntry"..i.."_ItemLargess"]          
          entryFrame = _G["GB_AuditHistoryEntry"..i]   
          countText = _G["GB_AuditHistoryEntry"..i.."_ItemIcon_Count"]
          
          if dataOffset <= n then 
            --set transaction type icon
            if (GB_AuditHistory[dataOffset].typ == "withdraw" or GB_AuditHistory[dataOffset].typ == "repair") then
                --set string to minus sign
                transTypeString:SetText("-")
                transTypeString:SetTextColor(1,0,0)
                playerName:SetTextColor(1,0,0)
            else
                --set string to plus sign
                transTypeString:SetText("+")
                transTypeString:SetTextColor(1,0.81,0)
                playerName:SetTextColor(1,0.81,0)
            end
            
            -- set item icon texture
            if (GB_AuditHistory[dataOffset].source > 0) then
                local tex = GetItemIcon(GB_AuditHistory[dataOffset].itemLink)
                itemIconTexture:SetTexture(tex)
                if (GB_AuditHistory[dataOffset].count > 1) then
                    countText:SetText(tostring(GB_AuditHistory[dataOffset].count))
                else
                    countText:SetText("")
                end
            else
                --set text to money or repair icon
                if (GB_AuditHistory[dataOffset].typ == "repair") then
                    itemIconTexture:SetTexture("interface\\icons\\ability_repair.png")
                else    
                    itemIconTexture:SetTexture("interface\\icons\\INV_Misc_Coin_02.png")
                end
                countText:SetText("")
            end   
                        
            ---set player name
            playerName:SetText(GB_AuditHistory[dataOffset].name)
            
            --set item money
            MoneyFrame_Update(moneyFrame, GB_AuditHistory[dataOffset].amount);             
            
            --set current index
            entryFrame.index = dataOffset  
            entryFrame.data = GB_AuditHistory[dataOffset].itemLink
            entryFrame.typ = GB_AuditHistory[dataOffset].typ
            entryFrame.source = GB_AuditHistory[dataOffset].source
            if GB_AuditHistoryCurrentEntry == dataOffset then
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

function GB_AuditHistoryEntryOnClick(self)
    GB_AuditHistoryCurrentEntry = self.index
    --GB_Message(self.index)   
    local tex = GetItemIcon(self.data)
    --GBH_AuditHistoryIconButtonIcon:SetTexture(tex) 
    if self.data ~= nil then
        local name, link, quality = GetItemInfo(self.data)
        GBH_AuditHistoryIconItem = link
        GB_AuditHistoryFrame_AddItemName_String:SetText(name)
        local r,g,b = GetItemQualityColor(quality)
        GB_AuditHistoryFrame_AddItemName_String:SetTextColor(r,g,b,1) 
    end
    MoneyInputFrame_SetCopper(GB_AuditHistoryMoneyFrame, GB_AuditHistory[self.index].amount) 
  
end

function GB_AuditHistoryOnClick()
    --not sure what to with this yet
end

function GB_SortByAuditHistoryItem(a,b)
    local aname = GetItemInfo(a.item)
    local bname = GetItemInfo(b.item)
	
    if GB_AUDIT_ITEM_SORT then  
        return aname > bname
    else      
        return aname < bname
    end
end

function GB_SortByAuditHistoryAmount(a,b)
    if GB_AUDIT_AMOUNT_SORT then
        return tonumber(a.amount) > tonumber(b.amount)
    else
       return tonumber(a.amount) < tonumber(b.amount)
    end
end

function GB_ClearAuditHistory()
    local dialog = StaticPopup_Show("WARNING_AUDIT_HIST_CLEAR") 
end

