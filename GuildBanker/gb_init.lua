function GB_Init()
   --set version string
   GB_VERSION = GetAddOnMetadata("GuildBanker", "version")
  
   if GB_Balance == nil then
      GB_Balance = 0
   end  
   if GB_Config == nil then
      GB_Config = {}
      GB_Config["channel"] = "GUILD"
   end 
   if GB_ItemPriceList == nil then
      GB_ItemPriceList = {}
   end
   if GB_ItemLargess == nil then
        GB_ItemLargess = {}
    end
    if GB_AuditHistory == nil then
        GB_AuditHistory = {}
    end
    if GB_AuditData == nil then
        GB_AuditData = {}
    end
    
   GB_CreateGUI()
   --GB_CreateFriendsTab()
   --GuildRoster()
   GB_ActionQueueInit()
   GB_CreateLargessView()
   GB_CreateItemLargessView()  
   GB_CreateAuditHistoryView()   
   
   SLASH_GB1 = "/gb"
   SlashCmdList["GB"] = GB_Commands;
      
   GB_MinOfficerRank = 0
   
   --set portrait icon
    SetPortraitToTexture(GB_ListFrameSkullnXBonesTexture,"interface\\icons\\inv_misc_coin_02")
   --SendAddonMessage("GBH_HL_SYNC_REQ",nil,"GUILD");
      
	GB_RosterBalanceFrame:SetScript("OnUpdate",function() GB_RosterLargessUpdate() end)	
	GB_AUDIT_DELAY = 20
	GB_VENDOR_LISTEN = false
	GB_ITEMVENDOR = 0
	GB_GBNUMSLOTS = 98
end  
