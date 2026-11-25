-- Native two-answer dialogue selector, including inn/save confirmations.
-- Read-only; selection is not proof that any action was confirmed.
return function(charset,say)
 local api={active=false};local candidate,age,previous,last
 local function decode(b,address,length)
  local parts={}
  for i=0,length-1 do
   local glyph=b(address+i)
   if glyph==0 or glyph==0xCB or glyph==0xCC then return nil end
   if not charset[glyph] then return nil end
   parts[#parts+1]=charset[glyph]
  end
  return table.concat(parts):gsub('%s+',' '):match('^%s*(.-)%s*$')
 end
 function api.repeatLast()if last then say(last,true,'choice')end end
 function api.tick(mem)
  local b=mem.readbyte;local message
  if b(0x7E007D)==0 and b(0x7E00D0)==0x81 and b(0x7E1D00)==0x11 and b(0x7E1D1B)==2 then
   local first,second,ending=b(0x7EA1D7),b(0x7EA1D8),b(0x7EA1D9)
   if first<second and second<ending and ending<=32 then
    local a=decode(b,0x7EA1A4+first,second-first)
    local c=decode(b,0x7EA1A4+second,ending-second)
    local cursor=b(0x7EA173)
    -- Choice labels come from the rendered dialogue, including Neko's
    -- ¡Claro!/Realmente no. The shop observer owns Com/Vende.
    if a and a~='' and c and c~='' and not(a=='Com' and c=='Vende') and (cursor==first or cursor==second) then
     local label=cursor==first and a or c
     if a=='Dorm' and c=='Comp' then label=cursor==first and 'Dormir' or 'Comprar' end
     message='Diálogo. '..label..' seleccionado. Izquierda o derecha cambia; B confirma.'
    end
   end
  end
  api.active=message~=nil
  if not message then candidate=nil;previous=nil;last=nil;age=0;return end
  if candidate==message then age=age+1 else candidate=message;age=1;last=nil end
  if age>=4 and previous~=message then previous=message;last=message;say(message,true,'choice')end
 end
 return api
end
