-- Native direct transition tiles; destination identity is read from this ROM.
return function()
 local cachedKey,cached,scanFrame=nil,{},-1000
 local sizes={[19]={768,704},[128]={896,1312},[129]={1024,1152},[130]={640,768},[131]={832,832},[132]={768,640},[136]={960,1024},[137]={448,512},[139]={640,1152},[279]={512,384}}
 local entrances={
  [88]={'casa-oeste','Casa del oeste'},[89]={'tienda','Tienda'},
  [90]={'casa-viejo','Casa del Viejo'},[91]={'casa-sur','Casa del sur'},[92]={'posada','Posada'},
  [2]={'salida-sureste','Salida sureste del pueblo'}
 }
 local names={
  [19]={[16]={'norte-regreso-potos','Regreso al camino de Potos'},[136]={'norte-hacia-jema','Salida norte hacia la zona de Jema'}},
  [128]={[129]={'salida-bosque','Salida al bosque'}},
  [129]={[128]={'regreso-cascadas','Regreso a las cascadas'},[130]={'camino-potos','Camino al pueblo de Potos por los puentes'}},
  [130]={[129]={'regreso-bosque','Regreso al bosque y a las cascadas'},[131]={'entrada-potos','Entrada al pueblo de Potos'}},
  [131]={[130]={'regreso-cascadas','Camino de regreso a las cascadas'}},
  [132]={[16]={'neko-salida-este','Salida este de Neko al camino de Potos'},[279]={'neko-casa','Entrada a la casa de Neko'}},
  [279]={[132]={'neko-salida-casa','Salida de la casa de Neko'}},
  [136]={[19]={'jema-regreso-camino','Regreso al camino del oficial'},[109]={'jema-entrada-edificio','Entrada al edificio del norte'}},
  [137]={[139]={'palacio-entrada-interior','Entrada al interior del Palacio de Agua'},[136]={'palacio-regreso-exterior','Salida al exterior del Palacio de Agua'}},
  [139]={[137]={'palacio-salida-vestibulo','Salida al vestíbulo del Palacio de Agua'},[135]={'palacio-salida-lateral','Salida lateral del Palacio de Agua'}}
 }
 return function(s,b,w,frame)
  local size=sizes[s.map]
  if s.map==279 and w(0x7ECD08)~=132 then return {} end
  local inside=(s.map==257 or s.map==258 or s.map==259) and (w(0x7ECD08)==131 or s.map==258 and w(0x7ECD08)==258)
  local downstairs=s.map==258 and w(0x7E010E)==102
  if inside then
   size={w(0x7E00C0),w(0x7E00C2)}
   if size[1]<=0 or size[1]>2048 or size[2]<=0 or size[2]>2048 or size[1]%16~=0 or size[2]%16~=0 then return {} end
  end
  if not s.field or not size or w(0x7E00C0)~=size[1] or w(0x7E00C2)~=size[2] then return {} end
  local upper=b(s.base+0x0B)>=128
  local key=s.map..':'..tostring(upper)..':'..s.story..':'..w(0x7E010E)
  if key~=cachedKey or frame-scanFrame>=30 then
   cachedKey=key;scanFrame=frame;cached={}
   local header=0xC80000+w(0xC87000+s.map*2)
   local flags=b(header+3);local first=math.floor(flags/4)%2;local minimum=0xC0-flags%4
   local eventPtr=0xC80000+w(0xC84000+s.map*2)
   local endPtr=0xC80000+w(0xC84000+(s.map+1)*2)
   local layer=upper and 0x7F4000 or 0x7F0000
   local attrs=upper and 0x7FBC00 or 0x7FB800
   for y=0,size[2]/16-1 do for x=0,size[1]/16-1 do
    local tile=b(layer+y*128+x)
    if inside and s.map==257 and math.floor(b(attrs+4*tile+1)/16)%2==1 then
     local group=cached['salida-interior']
     if not group then group={key='salida-interior',name='Regreso al pueblo de Potos',kind='exit',destination=131,points={}};cached[group.key]=group end
     group.points[#group.points+1]={x=x*16+8,y=y*16+8}
    end
    local address=eventPtr+2*(tile-minimum+first)
    if tile>=minimum and address<endPtr then
     local event=w(address)
     local sign=s.map==19 and event==0x604
     if sign or event>=0x800 and event<0xC00 then
      local transition=event-0x800
      local target=not sign and w(0xC83000+transition*4)%512 or nil
      local label=s.map==131 and entrances[transition] or names[s.map] and names[s.map][target]
      if sign then label={'norte-letrero','Letrero del camino del norte'};target=nil end
      if inside and target==131 and not downstairs then label={'salida-interior','Regreso al pueblo de Potos'} end
      if inside and s.map==258 and transition==102 and not downstairs then label={'escaleras-sotano','Escaleras al sótano'} end
      if inside and s.map==258 and transition==103 and downstairs then label={'escaleras-planta','Escaleras a la planta principal'} end
      if label then
       local group=cached[label[1]]
       if not group then group={key=label[1],name=label[2],kind=sign and 'signpost' or 'exit',destination=target,transition=transition,points={}};cached[label[1]]=group end
       group.points[#group.points+1]={x=x*16+8,y=y*16+8}
      end
     end
    end
   end end
  end
  local refs={}
  for _,group in pairs(cached) do
   local closest,distance
   for _,point in ipairs(group.points) do
    local d=(point.x-s.x)^2+(point.y-s.y)^2
    if not distance or d<distance then closest=point;distance=d end
   end
   refs[#refs+1]={key=group.key,name=group.name,kind=group.kind,destination=group.destination,transition=group.transition,x=closest.x,y=closest.y,
    note=group.kind=='signpost' and 'Acércate, mira hacia el letrero y pulsa B para leerlo.' or 'Se cruza caminando por el paso. La dirección directa no evita obstáculos.'}
  end
  table.sort(refs,function(a,c)return a.key<c.key end)
  return refs
 end
end
