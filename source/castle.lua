-- Pandora castle: this ROM's live tile events and actors, not a route planner.
return function()
 local api={sizes={[264]={688,560},[265]={1392,768},[266]={384,496},[267]={304,400},[268]={256,384},[283]={1392,768}}}
 local function room(name,bounds,events,exits,attributeExit)
  return {name=name,bounds=bounds,events=events,exits=exits,attributeExit=attributeExit}
 end
 local main=room('Castillo de Pandora, vestíbulo y ala este',{64,80,688,560},{0x18A,0x18B,0x18D,0x18E,0x18F,0x190,0x191},{0x8D4,0x8D5,0x8D6,0x8D7})
 local gallery=room('Castillo de Pandora, galería superior',{704,96,1072,272},{0x18C,0x189},{0x8D8,0x8D9})
 local hall=room('Castillo de Pandora, pasillo del trono',{128,80,576,336},{},{0x8DA,0x8DB,0x8DC,0x8E0,0x8E1})
 local barracks=room('Castillo de Pandora, sala de los soldados',{128,400,288,640},{0x198,0x199,0x19A,0x19B},{},145)
 local kitchen=room('Castillo de Pandora, cocina',{752,448,912,672},{},{},265)
 local throne=room('Castillo de Pandora, salón del trono',{32,32,320,432},{0x180,0x181,0x182,0x183,0x184,0x185},{0x8DD,0x8E2})
 local guest=room('Castillo de Pandora, sala de Elman',{64,112,240,352},{0x192,0x193,0x194},{0x8E8})
 local bedroom=room('Castillo de Pandora, habitación del rey',{1024,384,1312,704},{0x1A2,0x1A3,0x195},{0x8E3,0x8E5})
 local treasury=room('Castillo de Pandora, sala del tesoro',{32,0,176,304},{},{0x8E4})
 local furniture={
  [gallery]={
   {name='Taburete occidental de la galería',x=840,y=136,tile=86},
   {name='Taburete central de la galería',x=856,y=136,tile=86},
   {name='Taburete oriental de la galería',x=872,y=136,tile=86},
   {name='Taburete separado de la galería',x=936,y=136,tile=86},
  },
  [barracks]={
   {name='Cama noroeste de los soldados',x=208,y=456,tile=30},
   {name='Cama noreste de los soldados',x=256,y=456,tile=30},
   {name='Cama suroeste de los soldados',x=208,y=568,tile=30},
   {name='Cama sureste de los soldados',x=256,y=568,tile=30},
  },
  [kitchen]={
   {name='Horno de la cocina',x=792,y=488,tile=140},
   {name='Chimenea de la cocina',x=856,y=472,tile=155},
   {name='Mesa oriental de la cocina',x=880,y=552,tile=110},
   {name='Mesa sur de la cocina',x=840,y=600,tile=110},
   {name='Barriles de la cocina',x=888,y=600,tile=110},
  },
  [bedroom]={
   {name='Cama doble del rey',x=1104,y=504,tile=29},
   {name='Mesa de la habitación del rey',x=1264,y=488,tile=95},
  },
 }
 local people={
  [0x18A]={0xBC,'Habitante del ala este'},[0x18B]={0xB7,'Guardia del vestíbulo'},
  [0x18D]={0xC6,'Habitante que habla del Árbol de Maná'},[0x18E]={0xC7,'Niño que espera a Dyluck'},
  [0x18F]={0xC8,'Habitante que habla de las ruinas'},[0x190]={0xC4,'Habitante que recuerda el ataque del Imperio'},
  [0x191]={0xC5,'Habitante que habla de las máscaras'},[0x18C]={0xB7,'Guardia de la galería'},[0x189]={0xBB,'Noble de la galería'},
  [0x180]={0xA0,'Jema'},[0x181]={0xBD,'Rey de Pandora'},[0x182]={0xBC,'Reina de Pandora'},[0x183]={0xBB,'Noble del salón del trono'},
  [0x184]={0xB7,'Guardia del salón del trono'},[0x185]={0xB7,'Soldado del salón del trono'},
  [0x192]={0xBB,'Elman'},[0x193]={0xC9,'Noble de la sala de Elman'},[0x194]={0xC0,'Hija de Elman'},
  [0x198]={0xB7,'Soldado que teme a la bruja'},[0x199]={0xB7,'Soldado que habla del batallón de Dyluck'},
  [0x19A]={0xB7,'Soldado que habla de los zombis'},[0x19B]={0xC4,'Habitante de la sala de soldados'},
  [0x1A2]={0xB7,'Guardia de la habitación del rey'},[0x1A3]={0xC5,'Habitante de la habitación del rey'},[0x195]={0xB7,'Guardia de la sala del tesoro'}
 }
 local labels={
  [0x8D4]={'Salida al patio del castillo',false},[0x8D5]={'Escaleras occidentales a la galería superior',true},
  [0x8D6]={'Escaleras orientales a la galería superior',true},[0x8D7]={'Escaleras del ala este al pasillo del trono',true},
  [0x8D8]={'Escaleras occidentales al vestíbulo',true},[0x8D9]={'Escaleras orientales al vestíbulo',true},
  [0x8DA]={'Escaleras al ala este',true},[0x8DB]={'Entrada al salón del trono, lado oeste',false},
  [0x8DC]={'Entrada al salón del trono, lado este',false},[0x8DD]={'Regreso al pasillo del trono',false},
  [0x8E0]={'Escaleras a la cocina',true},[0x8E1]={'Entrada a la sala de Elman',false},
  [0x8E2]={'Escaleras a la habitación del rey',true},[0x8E3]={'Escaleras a la sala del tesoro',true},
  [0x8E4]={'Escaleras de regreso a la habitación del rey',true},[0x8E5]={'Escaleras de regreso al salón del trono',true},
  [0x8E8]={'Regreso al pasillo del trono',false}
 }
 local function contains(r,x,y)return x>=r.bounds[1]and y>=r.bounds[2]and x<r.bounds[3]and y<r.bounds[4]end
 function api.context(s,w)
  local z=api.sizes[s.map];if not z or w(0x7E00C0)~=z[1]or w(0x7E00C2)~=z[2]then return end
  local parent=w(0x7ECD08);local entry=w(0x7E010E);local r
  if s.map==264 and(parent==145 or parent==265)and(entry==210 or entry==211 or entry==216 or entry==217 or entry==218)then r=main
  elseif s.map==265 and(parent==145 or parent==264 or parent==265 or parent==266 or parent==267)then
   if entry==213 or entry==214 then r=gallery
   elseif entry==223 then r=barracks
   elseif entry==224 then r=s.y>=400 and kitchen or hall
   elseif entry==215 or entry==221 or entry==232 then r=hall end
  elseif s.map==266 and(parent==265 or parent==283)and(entry==219 or entry==220 or entry==229)then r=throne
  elseif s.map==267 and parent==265 and entry==225 then r=guest
  elseif s.map==283 and(parent==266 or parent==268)and(entry==226 or entry==228)then r=bedroom
  elseif s.map==268 and parent==283 and entry==227 then r=treasury end
  if r and contains(r,s.x,s.y)then return r,r.name end
 end
 function api.supported(s,w)return api.context(s,w)~=nil end
 function api.references(s,b,w)
  local r=api.context(s,w);if not s.field or not r then return {}end
  local refs,groups={},{};local upper=b(s.base+11)>=128;local layer=upper and 0x7F4000 or 0x7F0000;local attrs=upper and 0x7FBC00 or 0x7FB800
  local header=0xC80000+w(0xC87000+s.map*2);local flags=b(header+3);local minimum=0xC0-flags%4;local first=math.floor(flags/4)%2
  local ep=0xC80000+w(0xC84000+s.map*2);local ending=0xC80000+w(0xC84002+s.map*2)
  local allowed={};for _,e in ipairs(r.exits)do allowed[e]=true end
  local function point(key,name,x,y,event,destination,stairs)
   local d=(x-s.x)^2+(y-s.y)^2;local g=groups[key]
   if not g or d<g.distance then groups[key]={key=key,name=name,x=x,y=y,kind='exit',event=event,destination=destination,stairs=stairs,distance=d,
    note='Se cruza caminando, sin B. La dirección directa no evita paredes, muebles ni personas.'}end
  end
  for y=math.floor(r.bounds[2]/16),math.floor((r.bounds[4]-1)/16)do for x=math.floor(r.bounds[1]/16),math.floor((r.bounds[3]-1)/16)do
   local tile=b(layer+y*128+x);local address=ep+2*(tile-minimum+first)
   if r.attributeExit and math.floor(b(attrs+4*tile+1)/16)%2==1 then
    point('castillo-retorno:'..r.name,r==kitchen and 'Escaleras de regreso al pasillo del trono' or 'Salida al patio del castillo',x*16+8,y*16+8,nil,r.attributeExit,r==kitchen)
   end
   if tile>=minimum and address<ending then local event=w(address);local label=allowed[event]and labels[event]
    if label then point('castillo-acceso:'..event,label[1],x*16+8,y*16+8,event,w(0xC83000+4*(event-0x800))%512,label[2])end
   end
  end end
  for _,g in pairs(groups)do refs[#refs+1]=g end
  table.sort(refs,function(a,c)return a.key<c.key end)
  local admitted={};for _,event in ipairs(r.events)do admitted[event]=true end
  local chestFlags={[0x683]=0xD3,[0x684]=0xD4,[0x685]=0xD5,[0x686]=0xD6}
  local chestNumber={[0x671]=1,[0x673]=2,[0x683]=3,[0x684]=4,[0x685]=5,[0x686]=6}
  for slot=3,11 do
   local a=0x7EE000+slot*512;local event=w(a+0x3E)%4096;local p=admitted[event]and people[event]
   local chest=r==treasury and chestNumber[event]and b(a+0x180)==0xEB and b(a+0x1C)==0 and(not chestFlags[event]or b(0x7ECF00+chestFlags[event])%2==0)
   local girl=r==hall and event==0 and b(a+0x180)==0x8B and contains(r,w(a+2),w(a+4))
   if b(a)==1 and contains(r,w(a+2),w(a+4))and(p and b(a+0x180)==p[1]or chest or girl)then
    local h,other=b(s.base+11)%4,b(a+11)%4
    refs[#refs+1]={key='castillo-actor:'..s.map..':'..event..':'..slot,name=chest and 'Cofre del tesoro '..chestNumber[event]or girl and 'Chica junto a la sala de Elman' or p[2],
     kind=chest and 'interactive'or'person',slot=slot,event=event,x=w(a+2),y=w(a+4),samePlane=math.floor(b(a+11)/128)==math.floor(b(s.base+11)/128)and not(h==1 and other==2 or h==2 and other==1),
     note=chest and 'Acércate, mira al cofre y pulsa B para abrirlo. El contenido se anuncia al abrir; no se anticipa.'or girl and 'Acercarte por el pasillo puede iniciar una escena. Su presencia y posición son las del juego.'or 'Acércate, mira hacia la persona y pulsa B para hablar. Puede iniciar una escena.'}
   end
  end
  for i,o in ipairs(furniture[r]or{})do
   if b(layer+math.floor(o.y/16)*128+math.floor(o.x/16))==o.tile then
    refs[#refs+1]={key='castillo-mueble:'..r.name..':'..i,name=o.name,kind='furniture',x=o.x,y=o.y,
     note='Mobiliario fijo comprobado en el plano nativo. Referencia de posición; no se ofrece como recogible ni se presupone una interacción. La dirección directa no evita obstáculos.'}
   end
  end
  return refs
 end
 return api
end
