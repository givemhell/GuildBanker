function gb_debug(msg)
    if GB_Config == nil then
        return
    end
    if GB_Config["debug"] then
       ChatFrame1:AddMessage(msg,0,1,0);
    end
end
   