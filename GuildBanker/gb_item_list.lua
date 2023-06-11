function GB_AddItemToLargessList(item, value)
    if GB_ItemLargess == nil then
        GB_ItemLargess = {}
    end 
    
    --prevent duplicate entries
    local i, name1, name2, argflag    
    
    if item == nil then
        --not using arguments
        argflag = false
        item = GB_CurrentItemLargessIconItem
        name2 = GetItemInfo(GB_CurrentItemLargessIconItem)
        value = TSMAPI:GetItemValue(GB_CurrentItemLargessIconItem, "DBRegionMarketAvg")         
    else
        --using arguments
        argflag = true
        name2 = GetItemInfo(item)
        value = TSMAPI:GetItemValue(item, "DBRegionMarketAvg")         
    end
    
    --search for item in list to avoid duplicate entries
    for i = 1, #GB_ItemLargess do
        name1 = GetItemInfo(GB_ItemLargess[i].item)
        --name2 = GetItemInfo(GB_CurrentItemLargessIconItem)
        --gb_debug(name1.." : "..name2)
        if name1 == name2 then    
            gb_debug(name1.." exists!")
            
            if argflag then 
                return 
            end
			
            --GB_ItemLargess[i].balance = MoneyInputFrame_GetCopper(GB_ItemLargessMoneyFrame)    
            GB_ItemLargess[i].balance = value
            GB_ItemLargess[i].timestamp = time()
            ChatThrottleLib:SendAddonMessage("NORMAL","GB_IL_UPDATE", GB_ItemLargessToString(i),"GUILD")
            return 
        end
    end
        
    table.insert(GB_ItemLargess, {timestamp=time(),item=item,balance=value}) 
    ChatThrottleLib:SendAddonMessage("NORMAL","GB_IL_UPDATE", GB_ItemLargessToString(#GB_ItemLargess),"GUILD")
end
Please note that this is a simplified example and the actual implementation might need to handle edge cases and errors. For example, the TSM API might return nil if it doesn't have a price for an item, and your addon should be prepared to handle that.

Also, please note that this change assumes that the TSM addon is installed and loaded before your addon. If that's not the case, you might need to add some code to check if the TSM API is available before calling it.





User
can you send me the whole code edited im stupid
ChatGPT
Sure, I understand. Here's the entire code with the changes made to the GB_AddItemToLargessList(item, value) function:

lua
Copy code
function GB_EnterItemLargessIconButton()
    GameTooltip_SetDefaultAnchor(GameTooltip,UIParent)
    GameTooltip:ClearLines()
    if GB_CurrentItemLargessIconItem ~= nil then
        GameTooltip:SetHyperlink(GB_CurrentItemLargessIconItem)
        GameTooltip:Show()
    end
end

function GBH_LeaveItemLargessIconButton()
    GameTooltip:Hide()
end

function GB_AddItemToLargessList(item, value)
    if GB_ItemLargess == nil then
        GB_ItemLargess = {}
    end 
    
    --prevent duplicate entries
    local i, name1, name2, argflag    
    
    if item == nil then
        --not using arguments
        argflag = false
        item = GB_CurrentItemLargessIconItem
        name2 = GetItemInfo(GB_CurrentItemLargessIconItem)
        value = TSMAPI:GetItemValue(GB_CurrentItemLargessIconItem, "DBRegionMarketAvg")         
    else
        --using arguments
        argflag = true
        name2 = GetItemInfo(item)
        value = TSMAPI:GetItemValue(item, "DBRegionMarketAvg")         
    end
    
    --search for item in list to avoid duplicate entries
    for i = 1, #GB_ItemLargess do
        name1 = GetItemInfo(GB_ItemLargess[i].item)
        if name1 == name2 then    
            gb_debug(name1.." exists!")
            
            if argflag then 
                return 
            end
			
            GB_ItemLargess[i].balance = value
            GB_ItemLargess[i].timestamp = time()
            ChatThrottleLib:SendAddonMessage("NORMAL","GB_IL_UPDATE", GB_ItemLargessToString(i),"GUILD")
            return 
        end
    end
        
    table.insert(GB_ItemLargess, {timestamp=time(),item=item,balance=value}) 
    ChatThrottleLib:SendAddonMessage("NORMAL","GB_IL_UPDATE", GB_ItemLargessToString(#GB_ItemLargess),"GUILD")
end

function GB_DelItemFromLargessList()
    if GB_ItemLargess == nil then
        GB_ItemLargess = {}
    end
    table.remove(GB_ItemLargess, GB_ItemLargessCurrentEntry)
end

--drag and drop item balance
function GB_ItemLargessIconOnClick()
    local auctionPrice, vendorPrice, gbhPrice
    local typ, data, subType = GetCursorInfo()
    if typ == "item" then
        local tex = GetItemIcon(data)
        GB_ItemLargessIconButtonIcon:SetTexture(tex)        
        ClearCursor()
        local name, link, quality,  _, _, _, _, _, _, _, vendorPrice  = GetItemInfo(data)
        GB_CurrentItemLargessIconItem = link
        --GB_CurrentItemLargessIconItem = data
        GB_ItemLargessFrame_AddItemName_String:SetText(name)
        local r,g,b = GetItemQualityColor(quality)
        GB_ItemLargessFrame_AddItemName_String:SetTextColor(r,g,b,1)  
        
        --check auction price
        local _,_,_,gotauc,_,_,_ = GetAddOnInfo("Auctionator")
        if gotauc then
            auctionPrice = GetAuctionBuyout(link)
        end
        if auctionPrice == nil then
            auctionPrice = 0
        end
        
        --check vendor price                                        
        if vendorPrice == nil then
            vendorPrice = 0
        end
        
        --use higher price
        if auctionPrice > vendorPrice then
            gbhPrice = auctionPrice
        else
            gbhPrice =  vendorPrice       
        end
        
        --change money to new item value
        MoneyInputFrame_SetCopper(GB_ItemLargessMoneyFrame, gbhPrice)
    end
end

--auto add guild bank items to item list
function GB_ImportGuildBankItems(discount)
    local tab,slot,gbhPrice,link,name,gbhDiscount,quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice
    
    if discount == nil or discount == "" then
        gbhDiscount = 0   
    else
        gbhDiscount = discount
    end
    
    for tab = 1, GetNumGuildBankTabs() do
        for slot = 1, GB_GBNUMSLOTS do
            --get item link from GB slot
            item = nil
            item = GetGuildBankItemLink(tab, slot)
            if item ~=nil then
                name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice= GetItemInfo(item)
                --check auction price
                local _,_,_,gotauc,_,_,_ = GetAddOnInfo("Auctionator")
                if gotauc then
                    auctionPrice = GetAuctionBuyout(link)
                    auctionPrice = tonumber(auctionPrice)
                end
                if auctionPrice == nil then
                    auctionPrice = 0
                end
                
                --check vendor price                                        
                if vendorPrice == nil then
                    vendorPrice = 0
                end
                
                --use higher price
                if auctionPrice > vendorPrice then
                    gbhPrice = auctionPrice
                else
                    gbhPrice =  vendorPrice       
                end
                gb_debug(name..":"..vendorPrice..":"..auctionPrice..":"..gbhPrice..":"..gbhDiscount)
                GB_AddItemToLargessList(link, floor(gbhPrice-gbhPrice*gbhDiscount))                
            end
        end
    end
end

function GB_EnterItemLargessListButton(self)
    --GB_ItemLargessEntryOnClick(self:GetParent())
    GameTooltip_SetDefaultAnchor(GameTooltip,UIParent)
    GameTooltip:ClearLines()
    --if GB_CurrentItemLargessIconItem ~= nil then
        -- change this --------------------v
        GameTooltip:SetHyperlink(self:GetParent().data)
        GameTooltip:Show()
    --end
end
 
function GB_LeaveItemLargessListButton()
    GameTooltip:Hide()
end

function GB_CreateItemLargessView()
   local i,frame,textString,moneyFrame   
   
   --GB_UIFrame:SetScript("OnShow",GBH_UIShow)   
   GB_ItemLargessScrollFrame:EnableMouse()
   GB_ItemLargessScrollFrame:EnableMouseWheel(1)   
   GB_ItemLargessScrollFrame:SetScript("OnShow",GB_ItemLargessFrameUpdate) 
   GB_ItemLargessFrame:SetScript("OnUpdate",function() GB_ItemLargessListUpdate() end)
   GB_ItemLargessScrollFrame:Show()     
   
   --List Entry Frames (faux scroll frames)
   for i = 0,GB_NUM_ITEMLARGESS_ENTRIES-1 do       
      frame = CreateFrame("Button","GBH_ItemLargessEntry"..i,GB_ItemLargessScrollFrame,"GBH_ItemLargessEntryTemplate")
      frame:SetPoint("TOPLEFT",0,-i*28)  
      --_G["GBH_ItemLargessEntry"..i.."_ItemLargess"]:SetScale(.9)
      frame:Show() 
   end 
   --GB_ListEntryNormalTexture = frame:GetNormalTexture()
   GB_ItemLargessScrollFrame:SetPoint("TOPLEFT",15,-100) 
   GB_ItemLargessCurrentEntry = 0
   --MoneyFrame_Update(GB_RosterMoneyFrame, 0); 
   GB_ItemLargessListUpdate()
   
end  

function GB_ItemLargessListUpdate()
    local i,dataOffset,offset,n,m,r,g,b
    local moneyFrame,textString,entryFrame,iconButton,iconTexture
    
    n = #GB_ItemLargess    
    FauxScrollFrame_Update(GB_ItemLargessScrollFrame,n,GB_NUM_ITEMLARGESS_ENTRIES,28,nil,nil,nil,nil,nil,nil,true);
    offset = FauxScrollFrame_GetOffset(GB_ItemLargessScrollFrame);
       
       for i = 0,GB_NUM_ITEMLARGESS_ENTRIES-1 do
          dataOffset = offset + i + 1 
          iconButton = _G["GBH_ItemLargessEntry"..i.."_Icon"]
          iconTexture = _G["GBH_ItemLargessEntry"..i.."_Icon_Texture"]
          textString = _G["GBH_ItemLargessEntry"..i.."_ItemName"]
          moneyFrame = _G["GBH_ItemLargessEntry"..i.."_ItemLargess"]          
          entryFrame = _G["GBH_ItemLargessEntry"..i]     
          if dataOffset <= n then 
            -- set icon texture
            local tex = GetItemIcon(GB_ItemLargess[dataOffset].item)
            iconTexture:SetTexture(tex)            
            --set item money
            MoneyFrame_Update(moneyFrame, GB_ItemLargess[dataOffset].balance);             
            --set item name
            local name, link, quality = GetItemInfo(GB_ItemLargess[dataOffset].item)
            textString:SetText(name)             
            --GB_CurrentItemLargessIconItem = link
            textString:SetText(name)
            if quality then
                r,g,b = GetItemQualityColor(quality)
                textString:SetTextColor(r,g,b,1)
            end
            
            --set current index
            entryFrame.index = dataOffset  
            entryFrame.data = GB_ItemLargess[dataOffset].item
            if GB_ItemLargessCurrentEntry == dataOffset then
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

function GB_ItemLargessEntryOnClick(self)
    GB_ItemLargessCurrentEntry = self.index
    --GB_Message(self.index)   
    local tex = GetItemIcon(self.data)
    GB_ItemLargessIconButtonIcon:SetTexture(tex) 
    local name, link, quality = GetItemInfo(self.data)
    GB_CurrentItemLargessIconItem = link
    GB_ItemLargessFrame_AddItemName_String:SetText(name)
    local r,g,b = GetItemQualityColor(quality)
    GB_ItemLargessFrame_AddItemName_String:SetTextColor(r,g,b,1) 
    MoneyInputFrame_SetCopper(GB_ItemLargessMoneyFrame, GB_ItemLargess[self.index].balance)   
end

function GB_ItemLargessListOnClick()
    --not sure what to with this yet
end

function GB_SortByItem(a,b)
    local aname = GetItemInfo(a.item)
    local bname = GetItemInfo(b.item)
	
    if GB_ITEM_SORT then  
        return aname > bname
    else      
        return aname < bname
    end
end

function GB_SortByItemLargess(a,b)
    if GB_ITEM_LARGESS_SORT then
        return tonumber(a.balance) > tonumber(b.balance)
    else
       return tonumber(a.balance) < tonumber(b.balance)
    end
end

function GB_SortByGuildieLargess(a,b)
    if GB_SORT_GUILDIE_LARGESS then
        --return GB_AuditData[a.name].balance > GB_AuditData[b.name].balance
        return a.balance > b.balance
    else
       --return GB_AuditData[a.name].balance < GB_AuditData[b.name].balance
       return a.balance < b.balance
    end
end

function GB_SortByGuildie(a,b)
    if GB_SORT_GUILDIE then
        return a.name > b.name
    else
        return a.name < b.name
    end
end



