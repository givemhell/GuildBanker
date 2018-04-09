function GB_ActionQueueInit()
   GB_ActionQueue = {}
   if GB_Timer == nil then
      GB_Timer = CreateFrame("Frame")       
      GB_Timer:SetScript("OnUpdate", GB_ActionQueueUpdate)
   end
   
end

function GB_ActionQueueUpdate()
   if #GB_ActionQueue == 0 then 
      GB_Timer:Hide()
      return 
   end 
   if time() >= GB_ActionQueue[1].ts then 
      RunScript(GB_ActionQueue[1].script)
      table.remove(GB_ActionQueue, 1)
   end
end

function GB_ActionQueueAdd(script, delay)
   table.insert(GB_ActionQueue, {ts=time()+delay, script=script})
   table.sort(GB_ActionQueue, GB_ActionSort)
   GB_Timer:Show()
end

function GB_ActionSort(a,b)
   return a.ts < b.ts
end



