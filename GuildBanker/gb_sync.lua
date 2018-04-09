--Item Balance Table Sync
function GB_IL_DoSync(sender)   
    local i,n
    if GB_ItemLargess == nil then  
        GB_ItemLargess={};
    end        
    n = #GB_ItemLargess        
    for  i = 1, n do        
      msg = GB_ItemLargessToString(i)
      
      gb_debug("Send: "..msg)      
      
      --ChatThrottleLib:SendAddonMessage("NORMAL","GBH_HL_UPDATE",msg,"WHISPER",sender);
      ChatThrottleLib:SendAddonMessage("BULK","GB_IL_UPDATE",msg,"GUILD");
    end
end    

function GB_IL_DoUpdate(msg)  
    local timestamp, item, balance, i, s, e
  
    timestamp, balance, item = string.split(",", msg)      
    i = GB_InItemLargess(item)
  
    if i == nil then
        table.insert(GB_ItemLargess,{timestamp=timestamp, item=item, balance=balance});  
        GB_ItemLargessListUpdate()
        
        gb_debug("New: "..msg) 
        
    elseif (tonumber(timestamp) > tonumber(GB_ItemLargess[i].timestamp)) then
        GB_ItemLargess[i].timestamp = timestamp
        GB_ItemLargess[i].item = item
        GB_ItemLargess[i].balance = balance
        
        gb_debug("Update: "..msg)
        
    end    
end

function GB_InItemLargess(item)
    local i   
    
    for i = 1, #GB_ItemLargess do
        if item == GB_ItemLargess[i].item then
            --return the index of item
            return i
        end
    end
    
    return nil
end    

function GB_ItemLargessToString(i)
    local timestamp = GB_ItemLargess[i].timestamp
    local item = GB_ItemLargess[i].item
    local balance = GB_ItemLargess[i].balance
    
    return timestamp..","..balance..","..item
end