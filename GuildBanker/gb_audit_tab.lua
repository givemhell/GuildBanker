GB_ItemPriceList = {}

function GB_AuditBankTabs()  
    
    if not CanEditGuildInfo() then
        GB_Message("You do not have permission to audit the guild bank.")
        return
	end
   
    local ntabs, tab, typ, name, itemLink, amount, y, m, d, h
    ntabs = GetNumGuildBankTabs()

    for tab = 1, ntabs do
        local num = GetNumGuildBankTransactions(tab)
		local i,ts,allnew,lasttrans
        local nonew = true
   
        --GB_LoadLastTabAudit(tab)   

        if GB_AuditData["last"..tab].t0 == "" then           
            -- if we don't have a last audit, they're all new
            allnew = true
        else
            -- we've got audit data, let's use it
            allnew = false
        end 
        
        GB_Message("Tab:"..tab)
        
        for i = 1,num do    
            lasttrans = GB_IsTabTransactionNew(tab,i)
            if allnew or lasttrans==true then		                        
                typ, name, itemLink, count, tab1, tab2, y, m, d, h = GetGuildBankTransaction(tab, i) 
				name = GB_GetFullNameNoSpaces(name)
                amount = count*GB_GetItemLargess(itemLink)
               
                if not (name == nil) then  --ignore nil transactions
                    nonew = false                   
                    if typ == "deposit" then
                        GB_Message("New Transaction: "..name..":"..typ..":"..itemLink..":"..GBL_CopperToGold(amount))
                        --local gbcut = GBL_GetGBCut()
                        if GB_AuditData[name] then
                            GB_AuditData[name].balance = GB_AuditData[name].balance + amount
                        end
                    elseif typ == "withdraw" then
                       GB_Message("New Transaction: "..name..":"..typ..":"..itemLink..":"..GBL_CopperToGold(amount), "red")                       
                       if GB_AuditData[name] then
                          GB_AuditData[name].balance = GB_AuditData[name].balance - tonumber(amount)
                       end
                    end     
                    GB_UpdateLastTabTransaction(tab,i)  
                    --Add an entry to Audit History
                    local timestamp = GB_GetTransactionTimeStamp(y, m, d, h)                    
                    table.insert(GB_AuditHistory, {typ=typ, name=name, itemLink=itemLink, count=count, amount=amount, timestamp=timestamp, source=tab})
                end
            elseif lasttrans == 2 then
                 allnew = true
            end         
        end  
        --GB_SaveLastTabAudit(tab)  
        if nonew then
            GB_Message("No new guild bank transactions.")
        end 
    end    
    
    --SetGuildInfoText(GB_GuildInfoText)
    GuildRoster()           
    
    GB_DO_AUDIT = false
    GB_ROSTER_UPDATED = false
    GB_BANKLOG_UPDATED = false
end

function GB_IsTabTransactionNew(tab,i)
   --should change self function name to 
   --GBL_IsTranscationLastAudit
	local t0 = GB_AuditData["last"..tab].t0
	local n0 = GB_AuditData["last"..tab].n0
	local i0 = GB_AuditData["last"..tab].i0  --item name
    local s0 = GB_AuditData["last"..tab].s0  --stack count
	local y0 = GB_AuditData["last"..tab].y0
	local m0 = GB_AuditData["last"..tab].m0
	local d0 = GB_AuditData["last"..tab].d0
	local h0 = GB_AuditData["last"..tab].h0	
	local c0 = GB_AuditData["last"..tab].c0
	local ts0 = GB_AuditData["last"..tab].ts0
    local ti, ni, ii, si, tab1, tab2, yi, mi, di, hi = GetGuildBankTransaction(tab, i)
    ni = GB_GetFullNameNoSpaces(ni)
    ii = GetItemInfo(ii)
   if ni == nil then
      return true
   end
   
   local tsi = GB_GetTransactionTimeStamp(yi,mi,di,hi)
   local ci   
      
    if t0 == "" then 
        return true 
    end
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
	if not (ii == i0) then 
      return false 
   end
   if not (si == s0) then
        return false
    end
   
   -- transactioni == transaction0 at self point
   -- could we have reached the last saved transaction?
   -- how many have we had within the zone of temporal uncertainty?
   ci = GB_CntSimTabTrans(tab,i)     
   
   if ci == c0 then
      --self is the last audit transaction
      return 2
   end
   
   if ci > c0 then 
      --looks like we've got a new one, self means the rest must be new too      
		GB_AuditData["last"..tab].c0 = c0 + 1
		return true
	else 
		return false 
	end 
end

function GB_CntSimTabTrans(tab, i)
	local j
	local c = 0
	local ti,ni,ii,si,tab1,tab2,yi,mi,di,hi = GetGuildBankTransaction(tab, i)
	ni = GB_GetFullNameNoSpaces(ni)
    ii = GetItemInfo(ii)
   if ni == nil then
      return 0
   end
	local tj,nj,ij,sj,yj,mj,dj,hj
   local stri,strj 
   
	for j = 1,i-1 do      
		tj,nj,ij,sj,tab1,tab2,yj,mj,dj,hj = GetGuildBankTransaction(tab, j)
		nj = GB_GetFullNameNoSpaces(nj)
        ij = GetItemInfo(ij)
      if not (nj == nil) then
         stri = ti..ni..ii..si..yi..mi..di..hi 
         strj = tj..nj..ij..sj..yj..mj..dj..hj
         if ( stri == strj ) then
            c = c + 1
         end
      end
	end	
	return c
end

function GB_UpdateLastTabTransaction(tab,i)
	local ti,ni,ii,si,tab1,tab2,yi,mi,di,hi = GetGuildBankTransaction(tab, i)
	ni = GB_GetFullNameNoSpaces(ni)
    ii = GetItemInfo(ii)
   if ni == nil then
      return
   end
	local tsi = GB_GetTransactionTimeStamp(yi,mi,di,hi)
	
	GB_AuditData["last"..tab].t0 = ti
	GB_AuditData["last"..tab].n0 = ni
	GB_AuditData["last"..tab].i0 = ii
    GB_AuditData["last"..tab].s0 = si
	GB_AuditData["last"..tab].y0 = yi
	GB_AuditData["last"..tab].m0 = mi
	GB_AuditData["last"..tab].d0 = di
	GB_AuditData["last"..tab].h0 = hi
    GB_AuditData["last"..tab].c0 = GB_CntSimTabTrans(tab,i)
    GB_AuditData["last"..tab].ts0 = tsi
   
end

function GB_GetItemLargess(item) 
    local name, link, quality, iLevel,  reqLevel, class, subclass, maxStack,  equipSlot, texture, vendorPrice = GetItemInfo(item)
    local auctionPrice
    
    --check price table first
    local i    
    for i = 1, #GB_ItemLargess do
        if GB_ItemLargess[i].item == link then
            return GB_ItemLargess[i].balance
        end
    end        
    
    --check for auction price
    local _,_,_,gotauc,_,_,_ = GetAddOnInfo("Auctionator")
    --if gotauc then
    if GetAuctionBuyout ~= nil then
        auctionPrice = GetAuctionBuyout(item)
    end
    if auctionPrice == nil then
        auctionPrice = 0
    end
    
    --check vendor price
    if vendorPrice == nil then
        vendorPrice = 0
    end
    
    --use higher price
    --if auctionPrice > vendorPrice then
    --    return auctionPrice
    --else
        return vendorPrice       
    --end
end
