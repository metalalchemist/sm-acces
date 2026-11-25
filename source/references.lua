-- Stable selection of observed references. One map tile is 16 world pixels.
return function()
 local selected,map
 local api={}
 local function available(s)
  if map~=s.map then selected=nil;map=s.map;s.selectedReference=nil;s.selectedMap=s.map end
  return s.references or {}
 end
 local function indexOf(list,key)
  for i,r in ipairs(list) do if r.key==key then return i end end
 end
 function api.cycle(s,delta)
  if not s.field then return 'Selección suspendida durante la escena o el menú.' end
  local list=available(s)
  if #list==0 then selected=nil;return 'No hay referencias compatibles en este mapa.' end
  local index=indexOf(list,selected)
  if index then index=(index-1+delta)%#list+1 else index=delta<0 and #list or 1 end
  selected=list[index].key
  s.selectedReference=selected;s.selectedMap=s.map
  return api.describe(s)..' '..index..' de '..#list..'.'
 end
 local function amount(pixels)
  local n=math.floor(math.abs(pixels)/16*10+0.5)/10
  return string.format('%g',n):gsub('%.',',')
 end
 function api.describe(s)
  if not s.field then return 'Orientación suspendida durante la escena o el menú.' end
  local list=available(s)
  if #list==0 then selected=nil;return 'No hay referencias compatibles en este mapa.' end
  local index=indexOf(list,selected)
  if selected and not index then selected=nil;return 'La referencia seleccionada ya no está disponible. Elige otra con Control F5 o F6.' end
  if not index then index=1;selected=list[index].key end
  s.selectedReference=selected;s.selectedMap=s.map
  local r=list[index];local dx,dy=r.x-s.x,r.y-s.y
  local parts={}
  if math.abs(dy)>=4 then parts[#parts+1]=amount(dy)..(dy<0 and ' al norte' or ' al sur') end
  if math.abs(dx)>=4 then parts[#parts+1]=amount(dx)..(dx<0 and ' al oeste' or ' al este') end
  local text=r.name..'. '..(#parts==0 and 'A tu lado.' or table.concat(parts,', ')..'. En casillas.')
  if r.note then text=text..' '..r.note end
  if r.kind=='enemy' then
   local dir=math.abs(dx)>math.abs(dy) and (dx<0 and 'oeste' or 'este') or (dy<0 and 'norte' or 'sur')
   text=text..' El radar sigue a este enemigo. Mira al '..dir..'.'
   if not r.samePlane then text=text..' Está en otra capa o altura.' end
  end
  return text
 end
 return api
end
