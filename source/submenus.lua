-- Native game rings and loaded-game pages. Boot/name remains in menus.lua.
return function(data,say)
 local api={active=false}
 local observed,missing=false,100
 local previous,candidate,age,last=nil,nil,0,nil
 local candidateContext
 local gear,wasRing={},false
 local committed,detail
 local bit=data.bit
 local config={'Equipar armaduras','Objetivos','Estado','Niveles de armas y magia','Comportamiento','Controles','Ventana'}
 local categories={'Objetos','Magia','Opciones','Armas','Armadura de cabeza','Armadura de cuerpo','Accesorios'}
 local function speak(s,kind)last=s;say(s,true,kind or 'submenu')end
 function api.observe()observed=true;missing=0 end
 function api.repeatLast()if last then speak(last)end end
 function api.details(mem)
  detail={page=mem.readbyte(0x7EA202),owner=mem.readbyte(0x7E19FE),cursor=mem.readbyte(0x7EA211)}
 end
 function api.commit(mem,kind)
  local b=mem.readbyte
  if kind=='behavior' then committed={kind=kind,owner=b(0x7EA22B),grid=b(0x7EA136),charge=b(0x7EA211)}
  else
   local page=b(0x7EA202)
   -- The shared native writer also runs when Select exits after cancelling.
   -- A209 identifies the accepted callback, not a physical-key guess.
   local action=b(0x7EA209)
   if page==5 and (action==4 or action==7) or page==6 and action==7 then
    committed={kind=page==5 and 'window' or 'controls',bindings={b(0x7EA22F),b(0x7EA230),b(0x7EA231)}}
   end
  end
 end
 local function notifications(b,w)
  if committed then
   local c=committed;committed=nil
   if c.kind=='behavior' then
    if c.owner<=2 and b(0x7EA257+c.owner)==c.grid and b(0x7ECC7D+c.owner)==c.charge then speak('Comportamiento aplicado a '..data.person(b,c.owner)..'.','menu-result')end
   elseif b(0x7ECC6D)==c.bindings[1] and b(0x7ECC6E)==c.bindings[2] and b(0x7ECC6F)==c.bindings[3] then
    speak(c.kind=='window' and 'Configuración de ventana aplicada.' or 'Controles aplicados.','menu-result')
   end
  end
  local ring=b(0x7E007D)==1
  for owner=0,2 do
   local a=0x7EE000+512*owner
   if b(a)==1 and w(a+0x184)>0 then
    local old=gear[owner];local now={}
    for i=0,3 do now[i+1]=b(a+0x1E0+i)end
    if old and (ring or wasRing) and b(0x7E1847)==0 then
     for i=1,4 do if now[i]~=old[i] then
      local name
      if i==4 and now[i]<72 then name=data.name(b,w,0x32+now[i])
      elseif i<4 then name=now[i]==0 and 'sin pieza' or data.name(b,w,0x7A+now[i])end
      if name then speak(data.person(b,owner)..'. '..({'Cabeza','Cuerpo','Accesorio','Arma'})[i]..': '..name..'. Equipo actualizado.','equipment')end
     end end
    end
    gear[owner]=now
   else gear[owner]=nil end
  end
  wasRing=ring
 end
 local function levels(b,w,owner,page)
  local magic=page==8;local focus=bit(b(0x7EA212),8)
  local cursor=b(0x7EA211);local a=0x7EE000+512*owner
  if detail and (detail.page~=page or detail.owner~=owner or detail.cursor~=cursor or not focus)then detail=nil end
  local rows={}
  for i=0,7 do
   local present=magic and b(a+0x1C8+i)~=0 or not magic and b(0x7ECC54+i)~=255
   if present and (not focus or cursor==i) then
    local name=magic and data.name(b,w,0x2A+i) or data.weapon(b,w,i)
    if name then
     local level=data.level(b,a,i,magic)
     local progress=b(a+(magic and 0x1D0 or 0x1D8)+i)
     rows[#rows+1]=name..', nivel '..level..(not magic and progress<=99 and ', progreso '..progress or '')
    end
   end
  end
  local heading=magic and 'Niveles de magia' or 'Niveles de armas'
  if detail and not magic and cursor<8 then
   local name=data.weapon(b,w,cursor)
   if name then
    local types={'Guantes','Espada','Hacha','Lanza','Látigo','Arco','Bumerán','Jabalina'}
    return 'Detalles de '..name..'. Tipo: '..types[cursor+1]..'. Orbes '..(b(0x7ECFB0+cursor)+1)..' de '..(b(0x7ECFB8+cursor)+1)..'. Y vuelve.'
   end
  end
  return heading..'. '..data.person(b,owner)..'. '..(#rows>0 and table.concat(rows,'. ')..'.' or 'Sin entrada disponible.')..(focus and ' Selección activa. B muestra detalles; Y vuelve.' or ' B activa la selección. R cambia armas y magia cuando el personaje tiene magia.')
 end
 local function modal(b,w,page)
  local owner=b(0x7E19FE)
  if owner>2 or b(0x7EE000+owner*512)~=1 then return nil end
  api.selectedOwner=owner
  if page==7 then return 'Estado. '..data.status(b,w,owner)..' Dinero '..(w(0x7ECC6A)+65536*b(0x7ECC6C))..' GP. B cambia personaje; Y vuelve.'
  elseif page==8 or page==9 then return levels(b,w,owner,page)
  elseif page==4 then
   owner=b(0x7EA22B);api.selectedOwner=owner
   local grid,charge,count=b(0x7EA136),b(0x7EA211),b(0x7EA200)
   if owner>2 or grid>15 or count<1 or count>9 or charge>=count then return nil end
   local columns={'extremo izquierdo, máximo ataque','centro izquierdo, favorece ataque','centro derecho, favorece guardia','extremo derecho, máxima guardia'}
   local rows={'extremo superior, máximo acercamiento','centro superior, favorece acercarse','centro inferior, favorece alejarse','extremo inferior, máximo alejamiento'}
   local col,row=grid%4,math.floor(grid/4)
   local charging=charge==0 and 'La IA usa ataques normales sin esperar una carga especial.' or 'La IA puede cargar ataques especiales hasta ese nivel.'
   if count==1 then charging=charging..' Con el arma de este personaje solo está disponible el nivel 0.'end
   return 'Comportamiento de '..data.person(b,owner)..'. Horizontal: '..columns[col+1]..'. Ataque a guardia: '..(col+1)..' de 4, contando desde la izquierda. Vertical: '..rows[row+1]..'. Acercado a alejado: '..(row+1)..' de 4, contando desde arriba. Carga máxima: '..charge..' de '..(count-1)..'. '..charging..' '..(bit(b(0x7EA212),0x20) and 'Selecciona la carga con arriba o abajo. B aplica; Y vuelve a la cuadrícula.' or 'Cruceta cambia la cuadrícula. B pasa a la carga; Y vuelve.')
  elseif page==6 then
   local pad=b(0x7EA220);if pad>2 then return nil end
   local parts={};local functions={'Tu menú','Menú de aliados','Ataque','Correr'}
   local buttons={'Y','X','B','A'};local seen={}
   for i=0,3 do local value=b(0x7E9C00+i);if value>3 or seen[value] then return nil end;seen[value]=true;parts[#parts+1]=buttons[i+1]..': '..functions[value+1]end
   return 'Controles. Mando '..(pad+1)..'. '..table.concat(parts,'. ')..'. Mantén el botón a cambiar y pulsa izquierda o derecha; suelta para fijar. L o R cambia mando. Start aplica; Select cancela.'
  elseif page==5 then
   local index=b(0x7EA24E);if index>7 then return nil end
   local color=w(0x7EA23E+2*index);local style=b(0x7EA24F+index)
   if style>7 then return nil end
   return 'Ventana '..(index+1)..' de 8. Estilo '..(style+1)..' de 8. Rojo '..(color%32)..', verde '..(math.floor(color/32)%32)..', azul '..(math.floor(color/1024)%32)..', de 31. Arriba o abajo cambia ventana; izquierda o derecha cambia estilo. Mantén A para rojo, Y para verde o X para azul y usa izquierda o derecha. B aplica; Select cancela.'
  end
 end
 local function ring(b,w)
  local owner,category,cursor,count=b(0x7E1808),b(0x7E1809),b(0x7E180A),b(0x7E180B)
  if owner>2 then return nil end
  api.selectedOwner=owner
  if bit(b(0x7E1803),0x20) then
   local pointer=w(0x7E1822)
   if pointer<0x1812 or pointer>0x1818 or pointer%2~=0 then return nil end
   local actor=w(0x7E0000+pointer)
   if actor==65535 then return 'Objetivo: todos los personajes disponibles. B confirma; Y cancela.'end
   local slot=math.floor((actor%4096)/512)
   if actor>=0xE000 and actor<=0xE400 and actor%512==0 and slot<=2 then
    local a=0x7EE000+512*slot
    if b(a)~=1 then return nil end
    api.selectedOwner=slot
    return 'Objetivo: '..data.person(b,slot)..'. Vida '..w(a+0x182)..' de '..w(a+0x184)..'. B confirma el objeto; Y cancela.'
   end
   return nil
  end
  if b(0x7E1812)~=0 or category>6 or cursor>=count or count<1 or count>16 then return nil end
  -- The engine rotates remembered rings: cursor zero is not a fixed item.
  -- Read the published title rather than indexing an assumed option order.
  local label=data.text(b,0x7EA1A4,24)
  if not label or label=='' then return nil end
  local extra=''
  if category==2 and count==7 then
   local names={['Armaduras']=config[1],['Objetivo']=config[2],['Estado']=config[3],['Nivel Arma/Magia']=config[4],['Acciones']=config[5],['Editar control']=config[6],['Haz ventana']=config[7]}
   label=names[label];if not label then return nil end
  elseif category==0 then
   local owned={}
   for i=0,11 do local v=b(0x7ECC48+i);if v~=255 then owned[#owned+1]=math.floor(v/32)end end
   if #owned==count then extra=' Cantidad: '..owned[cursor+1]..'.'end
  elseif category>=3 then
   -- Equipment titles append a native comparison, not part of the name.
   label=label:gsub('%s+%d+%s*$','')
   local raw={}
   for i=20,32 do local g=b(0x7EA1A4+i);raw[#raw+1]=g==0xD0 and ' a ' or data.text(b,0x7EA1A4+i,1) or ''end
   local before,after=table.concat(raw):match('(%d+)%s+a%s+(%d+)')
   if before then extra=(category==3 and ' Ataque actual 'or' Defensa actual ')..before..'; con esta pieza '..after..'.'end
   if bit(w(0x7E18A0+2*cursor),0x4000)then extra=extra..' No disponible para este personaje.'end
   if bit(b(0x7E1803),0x40)then extra=extra..' Pieza seleccionada. Otro B confirma el cambio; Y cancela.'end
   if label=='Tirar' then extra=' Seleccionar Tirar prepara el descarte; no se ha descartado una pieza.'end
  end
  return data.person(b,owner)..'. '..categories[category+1]..'. '..label..'. '..(cursor+1)..' de '..count..'.'..extra
 end
 function api.tick(mem,shopActive)
  local b,w=mem.readbyte,mem.readword
  notifications(b,w)
  if observed then missing=0 else missing=missing+1 end;observed=false
  api.active=false;api.selectedOwner=nil
  local s
  if not shopActive and b(0x7E007D)==1 and b(0x7E1847)==0 then
   local page=b(0x7EA202)
   if missing<=3 and (page==4 or page==5 or page==6 or page==7 or page==8 or page==9) then
    api.active=true
    if not bit(b(0x7EA20A),0x80) and not bit(b(0x7EA20A),1) then s=modal(b,w,page)end
   else api.active=true;s=ring(b,w)end
  end
  if not api.active then previous=nil;candidate=nil;candidateContext=nil;last=nil;age=0;detail=nil;return end
  local context=table.concat({b(0x7E1808),b(0x7E1809),b(0x7E180A),b(0x7E180B),b(0x7E1812),missing<=3 and b(0x7EA202)or -1},':')
  if context~=candidateContext then candidateContext=context;candidate=nil;age=0;last=nil end
  if not s then candidate=nil;age=0;last=nil;return end
  if candidate==s then age=age+1 else candidate=s;age=1 end
  -- Personality values are live native selectors, not a delayed rendered title.
  local settle=missing<=3 and b(0x7EA202)==4 and 2 or 24
  if age>=settle and previous~=s then previous=s;speak(s)end
 end
 return api
end
