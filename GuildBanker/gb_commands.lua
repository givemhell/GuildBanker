function GB_Commands(args)  
   local s,e,cmd,arg1,arg2,arg3,arg4 = string.find(args,"(%a*)%s?([.?%a%d]*)%s?([.?%a%d]*)%s?([.?%a%d-?]*)%s?([.?%a%d-?]*)")    
   
   --debug
   if cmd == "debug" then
      if arg1 == "on" then
         GB_Config["debug"] = true
         GB_Message("GB: debug on")
      elseif arg1 == "off" then
         GB_Config["debug"] = false
         GB_Message("GB: debug off")
      end    

    --show the GUI
    elseif cmd == "show" then
        GB_ToggleHitList()        
      
   --set guild bank balance cut
   elseif cmd == "cut" then
      GB_SetGBCut(arg1)   
      
   --resync hit list
   elseif cmd == "sync" then       
      ChatThrottleLib:SendAddonMessage("ALERT","GB_IL_SYNC_REQ", "", "GUILD"); 
      
   --balance commands
   elseif cmd == "balance" then
      if arg1 == "" then
         GB_Message("Your current guild Balance is "..GBL_CopperToGold(GB_Balance))
      elseif arg1 == "report" then
         GB_GuildLargessReport()
      elseif arg1 == "set" then
         GB_SetLargess(arg2,arg3)
      elseif arg1 == "mod" then
         GB_ModLargess(arg2,arg3)
      end   
      
   --audit commands
   elseif cmd == "audit" then
      if arg1 == "reset" then
         --GBH_AuditData = nil
      elseif arg1 == "print" then
         --GBH_AuditPrint()
      elseif arg1 == "" then 
         GB_AuditPrep()
     elseif arg1 == "list" then
        GB_AuditHistoryList()
     elseif arg1 == "clear" then        
        GB_ClearAuditHistory()
     end 
	 
   --version
   elseif cmd == "version" then
      GB_Message("Guild Banker v"..GB_VERSION);
     
    --set UI scale
    elseif cmd == "scale" then
        if arg1 ~= nil then
            GB_Config["scale"] = arg1
            GB_ListFrame:SetScale(arg1)
        end
        
    --guild bank item import
    elseif cmd == "gbimport" then
        GB_ImportGuildBankItems(arg1)
                 
    --set the minimum officer rank
    elseif cmd == "setminrank" then
        GB_SetMinOfficerRank(arg1)       
   
    --officer notes: save, load, list
    elseif cmd == "onotes" then
        if arg1 == "save" and arg2 ~= nil then
            GB_SaveOfficerNotes(arg2)
        elseif arg1 == "load" and arg2 ~= nil then
            GB_LoadOfficerNotes(arg2)
        elseif arg1 == "list" then
            GB_ListSavedOfficerNotes()
        else
            GB_Help(cmd)
        end
   
   --help
   elseif cmd == "help" then
      GB_Help(arg1)    
   else 
      GB_Help()
   end
end

function GB_GetAdminLevel()
   if CanEditOfficerNote() and CanEditGuildInfo() then
      return GB_SUPER_ADMIN
   elseif CanEditOfficerNote() then
      return GB_ADMIN
   else
      return GB_USER
   end   
end

function GB_AuditHistoryList()
    if GB_AuditHistory == nil then 
        return
    end
    
    local index
    
    GB_Message("Audit History...")
    
    for index = 1, #GB_AuditHistory do
        local name = GB_AuditHistory[index].name
        local typ = GB_AuditHistory[index].typ
        local timestamp = GB_AuditHistory[index].timestamp
        local source = GB_AuditHistory[index].source
        local amount = GB_AuditHistory[index].amount
        local itemLink = GB_AuditHistory[index].itemLink
        local amount = GB_AuditHistory[index].amount
        
		if itemLink ~= nil and itemLink ~= "" then
            if GB_AuditHistory[index].typ == "withdraw" then
                GB_Message(name .. ", " .. typ .. ", Tab: ".. source .. ", " .. itemLink .. ", " .. GBL_CopperToGold(amount) , "red")
            else
                GB_Message(name .. ", " .. typ .. ", Tab: " .. source .. ", " .. itemLink .. ", " .. GBL_CopperToGold(amount))
            end
        else
            if GB_AuditHistory[index].typ == "withdraw" or GB_AuditHistory[index].typ == "repair" then
                GB_Message(name .. ", " .. typ .. ", " .. GBL_CopperToGold(amount) , "red")
            else
                GB_Message(name .. ", " .. typ .. ", " .. GBL_CopperToGold(amount))
            end
        end
    end
end
    
function GB_SaveOfficerNotes(tag)
    if GB_OfficerNotes == nil then
        GB_OfficerNotes = {}
    end
    
    if GB_GuildMates == nil then
        GuildRoster()
        GB_Message("Please open the guild roster.")
        return;
    end
    
    local timestamp = time()    
    local onotes = {}    
    table.insert(GB_OfficerNotes, {tag=tag, timestamp=timestamp, onotes=onotes})
    local i
    local n = #GB_OfficerNotes
    
    for i = 1,#GB_GuildMates do
        table.insert(GB_OfficerNotes[n].onotes, {name=GB_GuildMates[i].name, note=GB_GuildMates[i].note})
        GB_Message(GB_GuildMates[i].name.. ":" .. GB_GuildMates[i].note)
    end
    
    GB_Message("Saved officer notes as: " .. tag)
end

function GB_LoadOfficerNotes(tag)
    if GB_OfficerNotes == nil then
        GB_Message("There are no saved officer notes.")
        return;
    end
    
    local onotes = {}
    local i
    local n = #GB_OfficerNotes
    
    for i = 1,n do
        if GB_OfficerNotes[i].tag == tag then
            onotes = GB_OfficerNotes[i].onotes
            break
        end
    end
    
    if onotes == {} then
        GB_Message("There are no saved officer notes named: "..tag)
        return
    end
    
    if GB_GuildMates == nil then
        GuildRoster()
        GB_Message("Please open the guild roster.")
        return;
    end
    
    local gnum = #GB_GuildMates        
    local numnotes = #onotes
    local j
    
    for i = 1,gnum do
       for j = 1,numnotes do
           if GB_GuildMates[i].name == onotes[j].name then
                GuildRosterSetOfficerNote(i,onotes[j].note)
                GB_Message(GB_GuildMates[i].name.. ":" .. onotes[j].note)
                break
           end
       end           
    end
    GB_Message("Loaded officer notes: " .. tag)
    GuildRoster()
end

function GB_ListSavedOfficerNotes()
    if GB_OfficerNotes == nil then
        GB_Message("There are no saved officer notes.")
        return;
    end
    
    local n = #GB_OfficerNotes
    local i
    
    GB_Message("Saved officer notes...")
    
    for i = 1,n do
        GB_Message(GB_OfficerNotes[i].tag.." "..SecondsToTime(time()-GB_OfficerNotes[i].timestamp).." ago")
    end
end    

function GB_SetMinOfficerRank(mor) 
    if not CanEditGuildInfo() then
        GB_Message("You do not have permission to change guild info.")
        return
    end
    
    local ginfo, n = string.gsub(GB_GuildInfoText,"<GBH><MinOfficerRank=.+></GBH>", "<GBH><MinOfficerRank="..mor.."></GBH>") 
    
    if n == 1 then  
       --found GBH parameter string in guild info      
       GB_GuildInfoText = ginfo 
    else    
       --did not find GBH parameter string
       GB_Message("Adding GBH parameter string to guild info text now.")
       GB_GuildInfoText = ginfo.."<GBH><MinOfficerRank="..mor.."></GBH>"
    end      
   
    SetGuildInfoText(GB_GuildInfoText)    
end