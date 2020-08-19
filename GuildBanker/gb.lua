GB_SET_GBCUT = false
GB_ITEMVENDOR = 0
GB_VENDOR_LISTEN = false

function GB_OnLoad(self)
    self:RegisterEvent("VARIABLES_LOADED"); 	
    self:RegisterEvent("PLAYER_LOGIN");
    self:RegisterEvent("PLAYER_ENTERING_WORLD");	
    self:RegisterEvent("CHAT_MSG_SYSTEM");
    self:RegisterEvent("CHAT_MSG_ADDON");		
	self:RegisterEvent("GUILDBANK_UPDATE_MONEY");
    self:RegisterEvent("GUILDBANKLOG_UPDATE");	
    self:RegisterEvent("GUILD_ROSTER_UPDATE");
    self:RegisterEvent("GUILDBANK_UPDATE_TABS");
    self:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED");
    self:RegisterEvent("GUILDBANKFRAME_CLOSED");
    self:RegisterEvent("GUILDBANKFRAME_OPENED");
    RegisterAddonMessagePrefix("GB_IL_SYNC_REQ")
    RegisterAddonMessagePrefix("GB_IL_UPDATE")
    RegisterAddonMessagePrefix("GB_FORCE")  
   
end

function GB_OnEvent(self, event, ...)    
    local arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9 = ...;
	local transt,name,amount,n,i,gbcut   
	gb_debug("Event: "..event)
    if event == "VARIABLES_LOADED" then 
        GB_ListFrame:RegisterForDrag("LeftButton")    
        GB_Init()
    elseif (event == "PLAYER_LOGIN") then
       GB_Message("[GB] Guild Banker "..GB_VERSION.." loaded", "sys")
       GB_Message("[GB] Type /gb help for a list of commands", "sys")
       
    elseif (event == "PLAYER_ENTERING_WORLD") then
        --GB_Init()
        GuildRoster()      
        if not CanViewOfficerNote() then
            GB_RosterBalanceFrame:Hide()
        else
        end         
		 
        GB_ActionQueueInit()
        GB_ActionQueueAdd([[ChatThrottleLib:SendAddonMessage("ALERT","GB_IL_SYNC_REQ","","GUILD")]], 10)
        if GB_Config["scale"] ~= nil then
            GB_ListFrame:SetScale(GB_Config["scale"])
        end
        --GBH_Purge()
        GuildRoster()  
    
	elseif (event == "GUILDBANK_UPDATE_MONEY") then
        GB_VENDOR_LISTEN = true 
		QueryGuildBankLog(MAX_GUILDBANK_TABS+1 )       
   
    elseif (event == "GUILDBANK_UPDATE_TABS") then
        --GB_Message("GUILDBANK_UPDATE_TABS")
     
    elseif (event == "GUILDBANKFRAME_OPENED") then   
        --GBTabFlags[GetCurrentGuildBankTab()] = 1
        GB_GuildBankOpen = true
     
    elseif (event == "GUILDBANKBAGSLOTS_CHANGED") then        
        if GB_GuildBankOpen == true then 
            local tab = GetCurrentGuildBankTab()
            gb_debug("GUILDBANKSLOTS_CHANGED:"..tab)
            if  GB_LastTab == nil then 
                GB_LastTab = 0
            end
            if GB_LastTab ~= tab then  
                GB_InitGBItemList()
            end
            GB_LastTab = tab            
            if GB_HasGBTabChanged() then
                gb_debug("GUILDBANKSLOTS REALLY CHANGED!!!")
                GB_ITEMVENDOR = tab
                --^ this was causing a client crash. need to prevent GB_HasGBTabChanged from returning true on first open of GB
                QueryGuildBankLog(tab) 
            end              
        end
    
    elseif (event == "GUILDBANKFRAME_CLOSED") then        
        GB_GuildBankOpen = false
        
    elseif (event == "GUILDBANKLOG_UPDATE") then      
		--GB_Message(event)
        --handle GB money transactions
        if GB_VENDOR_LISTEN == true then   
            if (GetNumGuildBankMoneyTransactions() == 0) then
                return
            end
            transt,name,amount = GetGuildBankMoneyTransaction(GetNumGuildBankMoneyTransactions())                 
            --name = GB_GetFullName(name)
            GB_VENDOR_LISTEN = false
            if transt == "deposit" then
                --gbcut = GBL_GetGBCut()
                --GB_AddLargess(amount-floor(gbcut*amount));  
                GB_AddLargess(amount)
            elseif transt == "withdraw" then
                GB_SubLargess(amount);
            end
        end  
        GB_BANKLOG_UPDATED = true
      
        --handle GB audits
        if GB_DO_AUDIT and GB_ROSTER_UPDATED then            
            GB_DoAudit()            
        end
      
        --handle GB tab transactions
        local tab = GetCurrentGuildBankTab()
        if GB_ITEMVENDOR == tab then 
            GB_ITEMVENDOR = 0
            if (GetNumGuildBankTransactions(tab) == 0) then
                return
            end
            local typ, name, itemLink, count, tab1, tab2, y, m, d, h = GetGuildBankTransaction(tab, GetNumGuildBankTransactions(tab))  
			--name = GB_GetFullName(name)
            --transaction must be relatively new
            if h > 0 or d > 0 or m > 0 or y > 0 then
                return
            end
            GB_Message("GB Transaction Tab:"..tab..":"..typ..":"..itemLink)
            amount = count*GB_GetItemLargess(itemLink)
            --gbcut = GBL_GetGBCut()
            if typ == "deposit" then                
                GB_AddLargess(amount)
            elseif typ == "withdraw" then
                GB_SubLargess(amount)
            end  
            GB_InitGBItemList()
        end  
      
    elseif (event == "GUILD_ROSTER_UPDATE") then
        --GB_Message("GUILD_ROSTER_UPDATE")
        local gnum = GetNumGuildMembers(true)
        local i,name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName
        
        GB_GuildMates = {}      
        for i = 1,gnum do
            name,rank,rankIndex,level,class,zone,note,officernote,online,status,classFileName = GetGuildRosterInfo(i) 
            table.insert(GB_GuildMates,{name=name,class=class,note=officernote,pnote=note})
        end  
       
        GB_GuildInfoText = GetGuildInfoText()   
        GB_ParseGuildInfoText()
        GB_ROSTER_UPDATED = true      
        GB_AuditInit()
        GB_AuditLoad()   
        GB_SetupLargessViewList()          
	
    --sync
    elseif (event == "CHAT_MSG_ADDON") then 
	
        if(arg1 == "GB_FORCE") then
            gb_debug("GBH_FORCE")
            GB_Balance = tonumber(arg2)
            MoneyFrame_Update(GB_GuildBalanceFrame, GB_Balance); 
        
        --item balance list
        elseif (arg1 == "GB_IL_SYNC_REQ") then             
            if arg4 ~= GB_GetFullName("player") then
                gb_debug("GB_IL_SYNC_REQ")
                GB_IL_DoSync(arg4);   
            end
            
        elseif (arg1 == "GB_IL_UPDATE") then                  
            if arg4 ~= GB_GetFullName("player") then
                gb_debug("GB_IL_UPDATE")
                GB_IL_DoUpdate(arg2);                
            end
        end
    end
end      

function GB_GetFullName(name)
   if name == nil then
        return
   end
   
   if name == "player" then
		name = UnitName("player")
   end
	
   local n, r = string.split("-", name)
   if r ~= nil then
      return name  
      
   else
      local realm = GetRealmName()
      return name.."-"..realm
   end     
end

function GB_GetFullNameNoSpaces(name)
    local num
    if name == nil then
        return
    end
    name = GB_GetFullName(name)
    name, num = gsub(name, " ", "")
    return name
end

function GB_GetNameNoRealm(name)
   local n, r
   
   if name == nil then
        return
   end
   
   if name == "player" then
		name = UnitName("player")
   end
	
   n, r = string.split("-", name)
   
   return n
end

function GB_ParseGuildInfoText()
    if GB_GuildInfoText == nil or GB_GuildInfoText == "" then
        return
    end
    
    local s,e,minoffrank = string.find(GB_GuildInfoText,"<GBH><MinOfficerRank=(.+)></GBH>")
    if minoffrank ~= nil then
        GB_MinOfficerRank = minoffrank
    end
end   

function GB_UnitIsInMyGuild(name)
	local i
	for i = 1, #GB_GuildMates do
		if GB_GuildMates[i].name == name then
			return true
		end
	end
	
	return false
end
	