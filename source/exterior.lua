-- First exterior after Potos. Native tile events, current collision layer.
return function()
 local cache,key,checked={},nil,-1000
 local signs={[0x600]=true,[0x601]=true,[0x606]=true,[0x607]=true,[0x608]=true}
 return function(s,b,w,frame)
  if not s.field or s.map~=16 or w(0x7E00C0)~=1120 or w(0x7E00C2)~=1856 then return {} end
  local upper=b(s.base+0x0B)>=128
  local identity=tostring(upper)
  if key~=identity or frame-checked>=30 then
   key=identity;checked=frame;cache={}
   local header=0xC80000+w(0xC87000+32);local flags=b(header+3)
   local minimum=0xC0-flags%4;local first=math.floor(flags/4)%2
   local ep=0xC80000+w(0xC84000+32);local ending=0xC80000+w(0xC84000+34)
   local layer=upper and 0x7F4000 or 0x7F0000
   for y=0,115 do for x=0,69 do
    local tile=b(layer+y*128+x);local address=ep+2*(tile-minimum+first)
    if tile>=minimum and address<ending then
     local event=w(address)
     if signs[event] or event>=0x800 and event<0xC00 then
      local group=cache[event]
      if not group then group={event=event,points={}};cache[event]=group end
      group.points[#group.points+1]={x=x*16+8,y=y*16+8}
     end
    end
   end end
  end
  local events={};for event in pairs(cache)do events[#events+1]=event end;table.sort(events)
  local refs={};local signNumber,exitNumber=0,0
  for _,event in ipairs(events)do
   local group=cache[event];local point,distance
   for _,p in ipairs(group.points)do local d=(p.x-s.x)^2+(p.y-s.y)^2;if not distance or d<distance then point=p;distance=d end end
   local r={key='exterior16:'..event,x=point.x,y=point.y,event=event,samePlane=true}
   if signs[event]then
    signNumber=signNumber+1;r.kind='signpost';r.name='Letrero '..signNumber
    if event==0x607 then r.name='Letrero Bienvenido a Neko' end
    if event==0x608 then r.name='Letrero Cuidado con goblins' end
    r.note='Acércate, mira hacia el letrero y pulsa B para leerlo.'
   else
    exitNumber=exitNumber+1;r.kind='exit';r.destination=w(0xC83000+4*(event-0x800))%512
    r.name=r.destination==131 and 'Camino hacia Potos' or 'Salida '..exitNumber..' del camino'
    if event==0x805 and r.destination==159 then r.name='Paso del este hacia el cañón' end
    if event==0x806 and r.destination==144 then r.name='Entrada a Pandora' end
    if event==0x905 and r.destination==132 then r.name='Entrada a Neko' end
    if event==0x83F and r.destination==19 then r.name='Salida norte del camino, al norte del letrero de Neko' end
    r.note='Paso de salida. La dirección directa no evita obstáculos.'
    if r.destination==131 and s.story>=11 then r.note=r.note..' Tras el destierro, el acceso a Potos puede estar bloqueado.'end
   end
   refs[#refs+1]=r
  end
  -- Native background bridge tiles at (53..54,47..49); collision remains
  -- on layer 1, height 2. Both approaches were crossed with native movement.
  local bridge=not upper
  for y=47,49 do
   for x=53,54 do
    local expected=(y==49 and 0x82 or 0x80)+(x-53)
    if b(0x7F4000+y*128+x)~=expected or b(0x7F0000+y*128+x)~=0 then bridge=false end
   end
  end
  if bridge then
   local otherHeight=b(s.base+0x0B)%4==1
   for _,point in ipairs({{key='puente-este-norte',name='Puente del camino al sur, extremo norte',y=744,dir='sur'},
                         {key='puente-este-sur',name='Puente del camino al sur, extremo sur',y=808,dir='norte'}})do
    refs[#refs+1]={key=point.key,name=point.name,x=864,y=point.y,kind='landmark',samePlane=not otherHeight,
     note='Desde este extremo se cruza caminando hacia el '..point.dir..'; no necesita B.'..
      (otherHeight and ' Está en otro nivel del terreno.'or '')..' La dirección directa no evita obstáculos.'}
   end
  end
  local order={exit=1,landmark=2,signpost=3}
  table.sort(refs,function(a,c)
   if order[a.kind]~=order[c.kind]then return order[a.kind]<order[c.kind]end
   if a.event and c.event then return a.event<c.event end
   return a.key<c.key
  end)
  return refs
 end
end
