-- Read-only Sayans menu data. Addresses and name indices are ROM-specific.
return function(charset)
 local api={}
 function api.bit(v,n)return math.floor(v/n)%2==1 end
 function api.text(b,address,length)
  local parts={}
  for i=0,length-1 do
   local v=b(address+i);if v==0 then break end
   -- C9 confirmed against the native Traje Kunfú menu capture.
   local char=v==0xC9 and 'ú' or charset[v]
   if not char then return nil end
   parts[#parts+1]=char
  end
  return table.concat(parts):gsub('%s+',' '):match('^%s*(.-)%s*$')
 end
 function api.person(b,owner)
  local name=api.text(b,0x7ECC00+12*owner,12)
  return name and name~='' and name or 'Personaje '..(owner+1)
 end
 function api.name(b,w,index)
  if index<0 or index>0x14E then return nil end
  return api.text(b,0xCA0000+w(0xCA0800+2*index),32)
 end
 function api.weapon(b,w,kind)
  local v=b(0x7ECC54+kind)
  if v==255 or v%64>8 then return nil end
  return api.name(b,w,0x32+9*kind+v%64)
 end
 function api.level(b,base,index,magic)
  local value=b(base+(magic and 0x1C4 or 0x1C0)+math.floor(index/2))
  return index%2==0 and math.floor(value/16) or value%16
 end
 function api.status(b,w,owner)
  local a=0x7EE000+512*owner
  local exp=b(a+0x18D)+256*b(a+0x18E)+65536*b(a+0x18F)
  local threshold=b(a+0x17D)+256*b(a+0x17E)+65536*b(a+0x17F)
  local s=api.person(b,owner)..'. Nivel '..(b(a+0x181)+1)..'. Vida '..w(a+0x182)..' de '..w(a+0x184)..'.'
  if owner~=0 then s=s..' Magia '..b(a+0x186)..' de '..b(a+0x187)..'.'end
  s=s..' Experiencia '..exp..'.'
  if b(a+0x181)<98 and threshold>=exp then s=s..' Para el próximo nivel: '..(threshold-exp)..'.'end
  local labels={'Fuerza','Agilidad','Constitución','Inteligencia','Sabiduría'}
  for i,label in ipairs(labels)do s=s..' '..label..' '..b(a+0x187+i)..'.'end
  return s..' Ataque '..b(a+0x198)..'. Golpes '..b(a+0x197)..'. Defensa '..w(a+0x1A5)..'. Evasión '..b(a+0x1A4)..'. Defensa mágica '..w(a+0x1A8)..'.'
 end
 return api
end
