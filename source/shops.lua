-- Sayans shop observer: native rendered labels, prices and committed mutations.
-- Read only. All speech is emitted by tick, never by a CPU hook.
return function(charset,say)
 local api={active=false}
 local previous,candidate,age,last,pending,cancelled
 local function bit(v,n)return math.floor(v/n)%2==1 end
 local function decode(b,address,length)
  local parts={}
  for i=0,length-1 do
   local glyph=b(address+i)
   if glyph==0 then break end
   if glyph==0xCB or glyph==0xCC then parts[#parts+1]=' '
   elseif charset[glyph] then parts[#parts+1]=charset[glyph]
   else return nil end
  end
  return table.concat(parts):gsub('%s+',' '):match('^%s*(.-)%s*$')
 end
 local function inventory(b)
  local parts={}
  for a=0x7ECC30,0x7ECC53 do parts[#parts+1]=string.char(b(a))end
  return table.concat(parts)
 end
 local function speak(s)last=s;say(s,true,'shop')end
 function api.cancel()cancelled=true end
 function api.repeatLast()if last then speak(last)end end
 function api.tick(mem)
  local b,w=mem.readbyte,mem.readword
  local money=w(0x7ECC6A)+65536*b(0x7ECC6C)
  local mode=b(0x7E1847)
  local ring=b(0x7E007D)==1 and (mode==1 or mode==2)
  local choice
  -- 58/5A produce the cursor stops; A173 is the current native stop.
  if not ring and b(0x7E007D)==0 and b(0x7E00D0)==0x81 and b(0x7E1D00)==0x11 and b(0x7E1D1B)==2 then
   local first,second,ending=b(0x7EA1D7),b(0x7EA1D8),b(0x7EA1D9)
   if first<second and second<ending and ending<=32 then
    local a=decode(b,0x7EA1A4+first,second-first)
    local c=decode(b,0x7EA1A4+second,ending-second)
    if a=='Com' and c=='Vende' then
     local cursor=b(0x7EA173)
     if cursor==first then choice='Comprar' elseif cursor==second then choice='Vender'end
    end
   end
  end
  api.active=ring or choice~=nil
  if cancelled then
   if pending then speak((pending.mode==1 and 'Compra' or 'Venta')..' cancelada.')end
   pending=nil;cancelled=false
  end
  if pending and money~=pending.money and inventory(b)~=pending.inventory then
   if pending.mode==1 and money<pending.money or pending.mode==2 and money>pending.money then
    speak((pending.mode==1 and 'Compra realizada. ' or 'Venta realizada. ')..'Dinero: '..money..' GP.')
   end
   pending=nil
  end
  if not api.active then previous=nil;candidate=nil;pending=nil;age=0;return end
  local key,message
  if choice then
   key='choice:'..choice..':'..money
   message='Tienda. '..choice..' seleccionado. Dinero: '..money..' GP.'
  else
   local cursor,count=b(0x7E180A),b(0x7E180B)
   if b(0x7E1812)~=0 or count<1 or count>12 or cursor>=count then candidate=nil;age=0;return end
   local title=decode(b,0x7EA1A4,33)
   if not title or title=='' then candidate=nil;age=0;return end
   local confirming=bit(b(0x7E1803),0x40)
   local notice=bit(b(0x7E1804),0x40)
   if confirming then
    -- The mark precedes the prompt renderer by ~16 native frames.
    if title~='¿Sí?' then candidate=nil;age=0;return end
    if not pending then pending={mode=mode,money=money,inventory=inventory(b),label=api.selection}end
    key='confirm:'..mode..':'..cursor..':'..title
    message=(mode==1 and 'Confirmar compra' or 'Confirmar venta')..(pending.label and ' de '..pending.label or '')..'. '..title..' B confirma. Y cancela.'
   elseif notice and not title:match('%d+GP$') then
    key='notice:'..mode..':'..title..':'..money
    message=title
   else
    if title:match('^%d+GP$') then candidate=nil;age=0;return end
    pending=nil
    title=title:gsub('(%d+)GP','%1 GP')
    local quantity
    if mode==1 then
     local id=b(0xD80000+w(0x7E183C)+cursor)
     if id>=0xBA and id<=0xC5 then
      quantity=0
      for i=0,11 do local v=b(0x7ECC48+i);if v~=255 and v%32==id-0xBA then quantity=math.floor(v/32)end end
     end
    elseif b(0x7E1809)==0 then
     local owned={}
     for i=0,11 do local v=b(0x7ECC48+i);if v~=255 then owned[#owned+1]=math.floor(v/32)end end
     if #owned==count then quantity=owned[cursor+1]end
    end
    local stock=quantity and ' Cantidad en tu inventario: '..quantity..'.' or ''
    api.selection=title
    key='row:'..mode..':'..cursor..':'..count..':'..title..':'..money
    key=key..':'..tostring(quantity)
    message=(mode==1 and 'Comprar. ' or 'Vender. ')..title..'. '..(cursor+1)..' de '..count..'.'..stock..' Dinero: '..money..' GP.'
   end
  end
  if key==candidate then age=age+1 else candidate=key;age=1 end
  -- Cursor and title publish separately. Wait out the measured 16-frame gap.
  if age>=24 and key~=previous then previous=key;speak(message)end
 end
 return api
end
