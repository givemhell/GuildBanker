GB_SEC_PER_HR = 3600
GB_SEC_PER_DAY = 24*GB_SEC_PER_HR
GB_SEC_PER_MO = 30.41*GB_SEC_PER_DAY
GB_SEC_PER_YR = 12*GB_SEC_PER_MO
GB_DO_AUDIT = false
GB_ROSTER_UPDATED = false
GB_BANKLOG_UPDATED = false
GB_GuildMates = {}
GB_SUPER_ADMIN = 2
GB_ADMIN = 1
GB_USER = 0
GB_PURGE_AGE_CLAIMED = GB_SEC_PER_MO --prune the hit list age
GB_PURGE_AGE_DEL = GB_SEC_PER_DAY*7 --prune the hit list age

function GB_DoAudit()        
   GB_AuditInit() 
   GB_AuditLoad()   
   
   GB_AuditBank()
   GB_AuditBankTabs()  
   
   GB_AuditSave()   
   GB_DO_AUDIT = false   
   GB_BANKLOG_UPDATED = false
   --GB_GUILDBANK_TEXT = {}
   --GB_GUILD_BANK_TEXT_UPDATED = false
   GB_Message("Audit complete.")
end	

function GB_AuditInit()  
    if GB_AuditData["last"] == nil then
        GB_AuditData["last"] = {}
        GB_AuditData["last"].t0 = ""
        GB_AuditData["last"].n0 = ""
        GB_AuditData["last"].a0 = 0
        GB_AuditData["last"].y0 = 0
        GB_AuditData["last"].m0 = 0
        GB_AuditData["last"].d0 = 0
        GB_AuditData["last"].h0 = 0
        GB_AuditData["last"].c0 = 0
        GB_AuditData["last"].ts0 = 0    
    end
        
    --init item audit data
    local tab
    for tab = 1,GetNumGuildBankTabs() do
        if GB_AuditData["last"..tab] == nil then
            GB_AuditData["last"..tab] = {}
            GB_AuditData["last"..tab].t0 = ""
            GB_AuditData["last"..tab].n0 = ""
            GB_AuditData["last"..tab].i0 = ""
            GB_AuditData["last"..tab].s0 = 0
            GB_AuditData["last"..tab].y0 = 0
            GB_AuditData["last"..tab].m0 = 0
            GB_AuditData["last"..tab].d0 = 0
            GB_AuditData["last"..tab].h0 = 0
            GB_AuditData["last"..tab].c0 = 0
            GB_AuditData["last"..tab].ts0 = 0
        end
    end
    
    if GB_GuildMates == nil then
        return
    end
   
    local i,name
    local gnum = #GB_GuildMates
   
    for i = 1,gnum do
        name = GB_GuildMates[i].name     
       GB_AuditData[name] = {}      
       GB_AuditData[name].balance = 0
       GB_AuditData[name].class = GB_GuildMates[i].class
    end   
end

function GB_AuditBank()
    if not CanEditGuildTabInfo(1) then
       GB_Message("You do not have permission to audit the guild bank.")
       return
    end
   
    local typ, name, amount, y, m, d, h
	local num = GetNumGuildBankMoneyTransactions()
	local i,ts,allnew,lasttrans
    local nonew = true
   
    --GB_LoadLastAudit()   
    if GB_AuditData["last"].t0 == "" then      
       -- if we don't have a last audit, they're all new
       allnew = true
    else
       -- we've got audit data, let's use it
       allnew = false
    end   
	
    for i = 1,num do    
      lasttrans = GB_IsTransactionNew(i)
		if allnew or lasttrans==true then		         
         typ, name, amount, y, m, d, h = GetGuildBankMoneyTransaction(i)           
         --name = GB_GetFullName(name)
         name = GB_GetFullNameNoSpaces(name)
		 if not (name == nil) then  --ignore nil transactions
            nonew = false
            if typ == "deposit" then
               GB_Message("New Transaction: "..name..":"..typ..":"..GBL_CopperToGold(amount))           
               if GB_AuditData[name] then                
                  GB_AuditData[name].balance = GB_AuditData[name].balance + amount
               end
            elseif typ == "withdraw" or typ == "repair" then               
               GB_Message("New Transaction: "..name..":"..typ..":"..GBL_CopperToGold(amount), "red")
               if GB_AuditData[name] then
                  GB_AuditData[name].balance = GB_AuditData[name].balance - tonumber(amount)
               end
            end     
            GB_UpdateLastTransaction(i)  
             --Add an entry to Audit History
             local timestamp = GB_GetTransactionTimeStamp(y, m, d, h)
            table.insert(GB_AuditHistory, {typ=typ, name=name, class=GB_AuditData[name].class, amount=amount, year=y, timestamp=timestamp, source=0})
         end
		else 
         if lasttrans == 2 then
            allnew = true
         end           
      end
	end  
   if nonew then
      GB_Message("No new guild bank transactions.")
   end      
   --GB_SaveLastAudit()
   GB_DO_AUDIT = false
   GB_ROSTER_UPDATED = false
   GB_BANKLOG_UPDATED = false   
end

function GB_GetTransactionTimeStamp(y,m,d,h)
   local t = time()
   t = t-y*GB_SEC_PER_YR-m*GB_SEC_PER_MO-d*GB_SEC_PER_DAY-h*GB_SEC_PER_HR
   return t
end

function GB_AuditLoad()
   local gnum = #GB_GuildMates
   local name,note
   local i,name,s,e,sign,balance
   
   for i = 1,gnum do      
      name = GB_GuildMates[i].name
      note = GB_GuildMates[i].note
      s,e,balance = string.find(note,"::GBL:L(.?%d*)::")
      
      if balance == nil then
         --deprecated
         s,e,balance = string.find(note,"::GBH:L(.?%d*)::")  
         GB_AuditData[name].balance = tonumber(balance)           
      end  
      
      --
      -- insert more backwards compatibility here as needed
      -- 
      
      if balance == nil then
         balance = 0
      end  
      
      GB_AuditData[name].balance = tonumber(balance)  
      GB_GuildMates[i].note = "::GBL:L"..balance.."::"
   end
end

function GB_AuditSave()
   local gnum = #GB_GuildMates
   local name,note
   local i,s,e,balance
   local gl,n 
   
   for i = 1,gnum do         
      name = GB_GuildMates[i].name
      note = GB_GuildMates[i].note
      balance = GB_AuditData[name].balance      
      GB_AuditForce(i,balance)
      if note == nil then
         note = "::GBL:L"..balance.."::"
      else
         gl,n = string.gsub(note,"::GBL:L.?%d*::","::GBL:L"..balance.."::")  
         if n == 1 then
            GuildRosterSetOfficerNote(i,gl)
         else
            GuildRosterSetOfficerNote(i,note.."::GBL:L"..balance.."::")
         end
      end      
   end
end

--self works fine, but could be simpler
--need to guarante guild info text is latest
function GB_IsTransactionNew(i)
   --should change self function name to 
   --GBL_IsTranscationLastAudit
	local t0 = GB_AuditData["last"].t0
	local n0 = GB_AuditData["last"].n0
	local a0 = GB_AuditData["last"].a0
	local y0 = GB_AuditData["last"].y0
	local m0 = GB_AuditData["last"].m0
	local d0 = GB_AuditData["last"].d0
	local h0 = GB_AuditData["last"].h0	
	local c0 = GB_AuditData["last"].c0
	local ts0 = GB_AuditData["last"].ts0
	local ti,ni,ai,yi,mi,di,hi = GetGuildBankMoneyTransaction(i)
    ni = GB_GetFullNameNoSpaces(ni)
   if ni == nil then
      return true
   end
   --local ts0 = GB_GetTransactionTimeStamp(y0,m0,d0,h0)
   local tsi = GB_GetTransactionTimeStamp(yi,mi,di,hi)
   local ci   
   
   if t0 == "" then return true end
   --upper bounds of temporal certaintly (definately new)
   if tsi > (ts0 + 3600) then
      return true
   end
   --lower bounds of temporal certainty (definately old)
   if tsi < (ts0 -3600) then
      return false
   end
   
   --we couldn't tell by our timestamp alone
   --check other transaction parameters
	if not (ni == n0) then
      return false
   end
	if not (ti == t0) then 
      return false
   end
	if not (ai == a0) then 
      return false 
   end
   
   -- transactioni == transaction0 at self point
   -- could we have reached the last saved transaction?
   -- how many have we had within the zone of temporal uncertainty?
   ci = GB_CntSimTrans(i)     
   
   if ci == c0 then
      --self is the last audit transaction
      return 2
   end
   
   if ci > c0 then 
      --looks like we've got a new one, self means the rest must be new too      
		GB_AuditData["last"].c0 = c0 + 1
		return true
	else 
		return false 
	end 
end

function GB_UpdateLastTransaction(i)
	local ti,ni,ai,yi,mi,di,hi = GetGuildBankMoneyTransaction(i)
	ni = GB_GetFullNameNoSpaces(ni)
   if ni == nil then
      return
   end
	local tsi = GB_GetTransactionTimeStamp(yi,mi,di,hi)
	
	GB_AuditData["last"].t0 = ti
	GB_AuditData["last"].n0 = ni
	GB_AuditData["last"].a0 = ai
	GB_AuditData["last"].y0 = yi
	GB_AuditData["last"].m0 = mi
	GB_AuditData["last"].d0 = di
	GB_AuditData["last"].h0 = hi
    GB_AuditData["last"].c0 = GB_CntSimTrans(i)
    GB_AuditData["last"].ts0 = tsi
   
end

function GB_CntSimTrans(i)
	local j
	local c = 0
	local ti,ni,ai,yi,mi,di,hi = GetGuildBankMoneyTransaction(i)
    ni = GB_GetFullNameNoSpaces(ni)
   if ni == nil then
      return 0
   end
	local tj,nj,aj,yj,mj,dj,hj
   local si,sj 
   
	for j = 1,i-1 do      
		tj,nj,aj,yj,mj,dj,hj = GetGuildBankMoneyTransaction(j)
        nj = GB_GetFullNameNoSpaces(nj)
      if not (nj == nil) then
         si = ti..ni..ai..yi..mi..di..hi 
         sj = tj..nj..aj..yj..mj..dj..hj
         if ( si == sj ) then
            c = c + 1
         end
      end
	end	
	return c
end

function GB_AuditForce(i)
    local name,_,_,_,_,_,_,_,online = GetGuildRosterInfo(i)
    if name == GB_GetFullNameNoSpaces("player") then
        GB_Balance = GB_AuditData[name].balance
    elseif online then
        ChatThrottleLib:SendAddonMessage("ALERT", "GB_FORCE", tostring(GB_AuditData[name].balance), "WHISPER", name)
    end
end

