function GB_AddLargess(amount)     
   amount = tonumber(amount)
   GB_Balance = GB_Balance + amount;
   local msg = "Your guild bank balance has increased by "..GBL_CopperToGold(amount);
   GB_Message(msg, "green")
   if GB_Balance >= 0 then
      GB_Message("Current Balance: "..GBL_CopperToGold(GB_Balance),"green");
   else
      GB_Message("Current Balance: "..GBL_CopperToGold(GB_Balance),"red");
   end
   if GB_GuildBalanceFrame then
      MoneyFrame_Update(GB_GuildBalanceFrame, GB_Balance);
   end
end

function GB_SubLargess(amount) 
   amount = tonumber(amount) 
   GB_Balance = GB_Balance - amount;
   local msg = "Your guild bank balance has decreased by "..GBL_CopperToGold(amount);
   GB_Message(msg,"red");
   msg = "Current Balance: "..GBL_CopperToGold(GB_Balance)
   if GB_Balance >= 0 then
        GB_Message(msg,"green")
   else
        GB_Message(msg,"red")
   end
   if GB_GuildBalanceFrame then
      MoneyFrame_Update(GB_GuildBalanceFrame, GB_Balance);
   end
end

function GB_Message(msg,color)   
   if (color == nil) or (color == "GREEN") or (color == "green") then 
      --default color is green
      DEFAULT_CHAT_FRAME:AddMessage(msg, 0, 1, 0);
   elseif (color == "RED") or (color == "red") then
      --here's red
      DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 0, 0);
   elseif (color == "sys") then
      --yellow?
      DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 1, 0);
   elseif (color == "rep") then
      DEFAULT_CHAT_FRAME:AddMessage(msg, GetMessageTypeColor("CHAT_MSG_COMBAT_FACTION_CHANGE"));
   end   
end

function GBL_CopperToGold(copper)
   local gp,sp,cp,gsp;    
   gp = floor(tonumber(copper)/10000);
   sp = abs(floor(mod(tonumber(copper),10000)/100));   
   cp = abs(mod(mod(tonumber(copper),10000),100));    
   gsp = tostring(gp).."g "..tostring(sp).."s "..tostring(cp).."c";
   return gsp;
end

function GBL_GetGBCut()  
    if GB_GuildBankText == nil then
        QueryGuildBankText(1)
        return 0
    end
    if GB_GuildBankText[1] == nil or GB_GuildBankText[1] == "" then
        return tonumber(0)
    end
    local s,e,cut,a2,a3,a4,a5 = string.find(GB_GuildBankText[1],"<GBL:C0><(.+)><(.+)><(.+)><(.+)><(.+)><(.+)></C>")
    if cut then
       return cut   
    else
       return tonumber(0)
    end
end

function GB_SetGBCut(cut)
   if not CanEditGuildTabInfo(1) then
      GB_Message("You do not have permission to edit guild bank tab:1 info.")
      return
   end
   
   if GB_GuildBankText == nil then
        GB_Message("You must open the guild bank to set the guild bank cut.")
        QueryGuildBankText(1)
        return 0
   end
   
   local ginfo = GB_GuildBankText[1]
   if ginfo == nil then
      ginfo = ""
   end
   
   local gbc,n = string.gsub(ginfo,"<GBL:C0><?%d*>","<GBL:C0><"..cut..">")  
   if n == 1 then       
      --SetGuildBankText(1, gbc)
      GB_GuildBankText[1] = gbc
   else  
      --do this only if bank text has other stuff in it
      --SetGuildBankText(1, ginfo.."<GBL:C0><"..cut..">")
      GB_GuildBankText[1] = ginfo.."<GBL:C0><"..cut..">"
   end
   QueryGuildBankText(1)
end

function GB_SetLargess(name, amount)
   if not CanEditOfficerNote() then 
      GB_Message("You do not have permission to edit officer notes.")
      return
   end
   
   local i,gnum
   
   GB_AuditInit()
   GB_AuditLoad()  
   
   if name == "all" then
      gnum = #GB_GuildMates
      for i = 1,gnum do
         GB_AuditData[GB_GuildMates[i].name].balance = tonumber(amount)
      end
   else
      GB_AuditData[name].balance = tonumber(amount)
   end
   
   GB_AuditSave()
end

function GB_ModLargess(name, amount)
   if not CanEditOfficerNote() then 
      GB_Message("You do not have permission to edit officer notes.")
      return
   end
   
   local i,gnum
   
   GB_AuditInit()
   GB_AuditLoad()  
   
   if name == "all" then
      gnum = #GB_GuildMates
      for i = 1,gnum do         
         GB_AuditData[GB_GuildMates[i].name].balance = GB_AuditData[GB_GuildMates[i].name].balance + tonumber(amount)         
      end
   else
      GB_AuditData[name].balance = GB_AuditData[name].balance + tonumber(amount)      
   end
   
   GB_AuditSave()
end   

function GB_GuildLargessReport()
   if not CanViewOfficerNote() then
      GB_Message("You do not have permission to view officer notes.")
      return
   end  
   local i,name,balance
   GB_AuditInit()
   GB_AuditLoad()
   GB_Message("-------------------------------")
   GB_Message("Guild Balance Report")
   GB_Message("-------------------------------")
   
   for i = 1,#GB_GuildMates do
      name = GB_GuildMates[i].name
      balance = GB_AuditData[name].balance
      if balance < 0 then
         GB_Message(name..": "..GBL_CopperToGold(balance),"red")
      else
         GB_Message(name..": "..GBL_CopperToGold(balance),"green")
      end
   end
end

function GB_AuditPrep()
    local i
   if GB_GetAdminLevel() < GB_SUPER_ADMIN then
      GB_Message("You do not have permission to perform audits.")
      return
   end   
   GB_Message("Guild Bank audit pending...")
   if not GB_BANKLOG_UPDATED then
      GB_Message("Guild Bank Money Log update required.")
   end
   if not GB_ROSTER_UPDATED then
      GB_Message("Guild Roster update required.")
   end 
   --[[if not GB_GUILD_BANK_TEXT_UPDATED then
        GB_Message("Guild Bank Text update required.")
   end]]--
        
   GB_DO_AUDIT = true
   for i = 1,GetNumGuildBankTabs() do
        QueryGuildBankText(i)
    end
   QueryGuildBankLog(MAX_GUILDBANK_TABS+1)   
   GuildRoster()
end

function GB_InitGBItemList()
    local i,tab
    tab = GetCurrentGuildBankTab()
    GB_TabItemList = {}
    for i = 1,GB_GBNUMSLOTS do
        GB_TabItemList[i] = {}
        GB_TabItemList[i].link = GetGuildBankItemLink(tab,i)
        GB_TabItemList[i].count = select(2,GetGuildBankItemInfo(tab,i))
    end
end

function GB_HasGBTabChanged()
    local i,j,tab,link1,link2,cnt1,cnt2   
    tab = GetCurrentGuildBankTab()
    for i = 1,GB_GBNUMSLOTS do
        if GB_TabItemList[i].link ~= GetGuildBankItemLink(tab,i) then
            link1 = GB_TabItemList[i].link
            link2 = GetGuildBankItemLink(tab,i)
            cnt1 = 0
            cnt2 = 0
            --count items from old list in case of move
            for j = 1,GB_GBNUMSLOTS do
                if GB_TabItemList[j].link == link1 then
                    cnt1 = cnt1 + GB_TabItemList[j].count
                end
            end
            --count items in current tab
            for j = 1,GB_GBNUMSLOTS do
                if GetGuildBankItemLink(tab,j) == link1 then                
                    cnt2 = cnt2 + select(2,GetGuildBankItemInfo(tab,j))
                end
            end
            if cnt1 ~= cnt2 then
                return true
            end
            --count items from old list in case of move
            for j = 1,GB_GBNUMSLOTS do
                if GB_TabItemList[j].link == link2 then
                    cnt1 = cnt1 + GB_TabItemList[j].count
                end
            end
            --count items in current tab
            for j = 1,GB_GBNUMSLOTS do
                if GetGuildBankItemLink(tab,j) == link2 then                
                    cnt2 = cnt2 + select(2,GetGuildBankItemInfo(tab,j))
                end
            end
            if cnt1 ~= cnt2 then
                return true
            end
        end
    end
    return false
end
