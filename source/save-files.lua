-- Four native saved-game records; selection never performs a save/load.
return function(data,say)
 local api={active=false};local missing=100;local candidate,age,previous,last
 function api.observe()missing=0 end
 function api.repeatLast()if last then say(last,true,'save-file')end end
 function api.tick(mem)
  missing=missing+1
  local b,w=mem.readbyte,mem.readword
  local page,slot=b(0x7EA202),b(0x7EA211)
  api.active=missing<=4 and b(0x7E007D)==0 and b(0x7E00D0)==1 and (page==1 or page==10)
  local message
  if api.active and slot<4 and not data.bit(b(0x7EA20A),0x80) and not data.bit(b(0x7EA20A),1)then
   local validity=math.floor(b(0x7EA215)/4^slot)%4
   local description='Vacío.'
   if validity~=3 then
    local address=0x306003+slot*1024+(validity%2==1 and 4096 or 0)
    local name=data.text(b,address,12)
    description='Ocupado.'..(name and name~='' and ' '..name..'.'or '')
   end
   if page==1 then
    message='Archivos. Archivo '..(slot+1)..' de 4. '..description..' Arriba o abajo selecciona; B abre; Y vuelve.'
   else
    message='Confirmación de guardado. Archivo '..(slot+1)..' de 4. '..description..(validity~=3 and ' Se sobrescribirá esta partida.'or '')..' B guarda; Y vuelve sin guardar.'
   end
  end
  if not api.active then candidate=nil;previous=nil;last=nil;age=0;return end
  if not message then candidate=nil;last=nil;age=0;return end
  if candidate==message then age=age+1 else candidate=message;age=1;last=nil end
  if age>=12 and previous~=message then previous=message;last=message;say(message,true,'save-file')end
 end
 return api
end
