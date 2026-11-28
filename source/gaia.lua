-- Sayans-ROM Gaia/Kippo sectors. Native events, presence and terrain only.
return function()
 local api={sizes={[23]={1536,1664},[25]={1536,1536},[168]={640,768},[73]={800,1280},[280]={1024,768},[281]={512,384},[284]={800,1280},[285]={640,1520},[286]={960,1600},[287]={800,1280},[289]={480,480}}}
 local folder=debug.getinfo(1,'S').source:sub(2):match('^(.*[/\\])')or''
 local data=dofile(folder..'menu-data.lua')(dofile(folder..'charset.lua'))
 local furniture=dofile(folder..'gaia-furniture.lua')
 local function room(key,name,bounds,events,people,attributeExit,battle)
  return {key=key,name=name,bounds=bounds,events=events,people=people or{},attributeExit=attributeExit,battle=battle}
 end
 local rooms={
  road=room('gaia-road','Camino oeste de Pandora, desvíos a Gaia y Kippo',{0,0,1536,1664},{0x85D,0x818,0x819,0x602},{},nil,true),
  outside=room('gaia-outside','Ombligo Gaia, exterior',{0,0,1536,1536},{0x816,0x817,0x836,0x820,0x609},{},nil,true),
  town=room('kipo-town','Pueblo de Kippo',{0,0,640,768},{0x861,0x862,0x863,0x864,0x81B},{0x220,0x221,0x222}),
  family=room('kipo-family','Kippo, casa de la familia de Dyluck',{96,96,352,336},{},{0x225,0x226},168),
  house=room('kipo-main','Kippo, casa con escaleras, planta principal',{448,80,704,336},{0x87A,0x87C},{0x224}),
  upper=room('kipo-upper','Kippo, casa con escaleras, planta superior',{784,96,928,304},{0x87B},{0x223}),
  shop=room('kipo-shop','Tienda de Kippo',{576,432,800,688},{},{0x303},168),
  inn=room('kipo-inn','Posada de Kippo',{0,0,512,384},{0x88F},{0x321}),
  neko=room('gaia-neko','Cueva de Neko en el Ombligo Gaia',{480,880,752,1120},{0x81A},{0x1D7}),
  firstLow=room('gaia-first-low','Gaia, primera caverna, tramo inferior',{288,720,608,1168},{0x837,0x780},{},nil,true),
  firstHigh=room('gaia-first-high','Gaia, primera caverna, tramo superior',{128,128,512,544},{0x848,0x781},{},nil,true),
  secondHigh=room('gaia-second-high','Gaia, segunda caverna, tramo superior',{144,96,288,480},{0x781},{},nil,true),
  secondMiddle=room('gaia-second-middle','Gaia, segunda caverna, tramo intermedio',{176,560,592,1008},{0x849,0x780,0x781},{},nil,true),
  secondLow=room('gaia-second-low','Gaia, segunda caverna, tramo inferior',{96,1040,512,1440},{0x84E,0x8F0,0x780},{},nil,true),
  deepUpper=room('gaia-deep-upper','Subterráneo de Gaia, tramo alto antes del Pueblo Enano',{224,96,752,448},{0x84F,0x781},{},nil,true),
  deepLower=room('gaia-deep-lower','Subterráneo de Gaia, tramo bajo, salidas al Pueblo Enano',{0,368,960,1600},{0x780,0x8F2,0x8F4},{},nil,true),
  village=room('gaia-dwarf-village','Pueblo de Enanos, aldea y cinco salidas',{0,0,800,720},{0x8FC,0x8FE,0x8FA,0x8F8,0x948,0x781},{0x1C0,0x1C1,0x1C2,0x1C3,0x1C4}),
  villageDeep=room('gaia-dwarf-deep','Pueblo de Enanos, tramo inferior y regresos al subterráneo',{0,720,800,1280},{0x780,0x8F3,0x8F5}),
  chest=room('gaia-side-room','Gaia, sala lateral del cofre',{128,144,352,384},{0x8F1},{},nil,true)
 }
 local labels={
  [0x85D]={'Camino al Ombligo Gaia'},[0x818]={'Desvío hacia el pueblo de Kippo'},[0x819]={'Regreso a Pandora'},
  [0x602]={'Letrero del cruce: Ombligo Gaia y pueblo de Kippo','signpost'},
  [0x816]={'Camino hacia el Bosque Encantado',nil,'El siguiente tramo todavía no tiene referencias.'},
  [0x817]={'Entrada a la cueva de Neko'},[0x836]={'Entrada a las cavernas de Gaia'},[0x820]={'Regreso al camino de Pandora y Kippo'},
  [0x609]={'Letrero: Bosque Encantado y Ombligo Gaia','signpost'},
  [0x861]={'Casa de la familia de Dyluck'},[0x862]={'Casa con escaleras de Kippo'},[0x863]={'Posada de Kippo'},[0x864]={'Tienda de Kippo'},
  [0x81B]={'Salida de Kippo al camino de Gaia y Pandora'},[0x87A]={'Escaleras a la planta superior',true,'Se accede desde el este caminando hacia el oeste.'},
  [0x87B]={'Escaleras a la planta principal',true,'Se accede desde el oeste caminando hacia el este.'},
  [0x87C]={'Regreso al pueblo de Kippo'},[0x88F]={'Salida de la posada al pueblo de Kippo'},[0x81A]={'Salida de Neko al exterior de Gaia'},
  [0x837]={'Salida de la caverna al exterior de Gaia'},[0x848]={'Paso a la segunda caverna de Gaia'},[0x849]={'Regreso a la primera caverna de Gaia'},
  [0x780]={'Escaleras al tramo superior',true,'Acércate desde el sur y camina al norte; el motor cambia de tramo y altura.'},
  [0x781]={'Escaleras al tramo inferior',true,'Acércate desde el norte y camina al sur; el motor cambia de tramo y altura.'},
  [0x84E]={'Continuación hacia el subterráneo de Gaia',nil,'En el mapa siguiente hay referencias de las salidas y de las escaleras internas.'},
  [0x84F]={'Regreso a la segunda caverna de Gaia'},
  [0x8F0]={'Entrada a la sala lateral del cofre'},[0x8F1]={'Regreso a la segunda caverna de Gaia'},
  [0x8F2]={'Acceso oeste al Pueblo de Enanos',nil,'Dos casillas contiguas. Comparte destino con la otra salida: ambas llevan al Pueblo de Enanos.'},
  [0x8F4]={'Acceso este al Pueblo de Enanos',nil,'Dos casillas contiguas. Comparte destino con la otra salida: ambas llevan al Pueblo de Enanos.'},
  [0x8FC]={'Salida a la casa del herrero Pedro',nil,'Casilla nativa del extremo noroeste. Dentro está Pedro, el herrero. Se cruza caminando, sin B.'},
  [0x8FE]={'Salida norte central de la aldea',nil,'Casilla de salida nativa al norte del pueblo. Se cruza caminando, sin B.'},
  [0x8FA]={'Salida noreste de la aldea',nil,'Casilla de salida nativa al noreste del pueblo. Se cruza caminando, sin B.'},
  [0x8F8]={'Salida norte desde la plaza de la aldea',nil,'Casilla de salida nativa junto a la plaza. Se cruza caminando, sin B.'},
  [0x948]={'Entrada al AGUJERO',nil,'Dos casillas contiguas en el lado oeste. Jema y el viejo dicen en sus textos que los ladrones entraron por aquí; dentro hay una criatura. Se cruza caminando, sin B.'},
  [0x8F3]={'Regreso oeste al subterráneo de Gaia',nil,'Dos casillas contiguas. Devuelve al tramo bajo del mapa 286, por el acceso oeste.'},
  [0x8F5]={'Regreso este al subterráneo de Gaia',nil,'Dos casillas contiguas. Devuelve al tramo bajo del mapa 286, por el acceso este.'}
 }
 local people={
  [0x220]={0xC5,'Habitante de la entrada de Kippo'},[0x221]={0xC4,'Habitante que conoce el Ombligo Gaia'},[0x222]={0xC8,'Niño de Kippo'},
  [0x223]={0xC6,'Habitante de la planta superior'},[0x224]={0xCE,'Dueño de la casa con escaleras'},
  [0x225]={0xC9,'Habitante de la casa de Dyluck'},[0x226]={0xCA,'Familiar de Dyluck'},
  [0x303]={0xCF,'Comerciante de Kippo'},[0x321]={0xCF,'Posadero de Kippo'},[0x1D7]={0x99,'Neko de la cueva de Gaia'},
  [0x1C0]={0x9A,'Enano que da la bienvenida al pueblo'},[0x1C1]={0x9A,'Enano que habla del niño duende'},
  [0x1C2]={0x9A,'Enano que oye los estruendos al cavar'},[0x1C3]={0x9A,'Enano que comenta los terremotos'},
  [0x1C4]={0x9A,'Enano que recuerda el Palacio Subterráneo'}
 }
 local function inside(r,x,y)return x>=r.bounds[1]and y>=r.bounds[2]and x<r.bounds[3]and y<r.bounds[4]end
 function api.context(s,w)
  local z=api.sizes[s.map];if not z or w(0x7E00C0)~=z[1]or w(0x7E00C2)~=z[2]then return end
  local parent,entry=w(0x7ECD08),w(0x7E010E);local r
  if s.map==23 then r=rooms.road elseif s.map==25 then r=rooms.outside elseif s.map==168 then r=rooms.town
  elseif s.map==280 and(parent==168 or parent==280)then
   if entry==97 then r=rooms.family elseif entry==98 or entry==123 then r=rooms.house elseif entry==122 then r=rooms.upper elseif entry==100 then r=rooms.shop end
  elseif s.map==281 and parent==168 and entry==99 then r=rooms.inn
  elseif s.map==73 and parent==25 and entry==23 then r=rooms.neko
  elseif s.map==284 and(parent==25 or parent==285)and(entry==54 or entry==73)then r=s.y<640 and rooms.firstHigh or rooms.firstLow
  elseif s.map==285 and((parent==284 or parent==289)and(entry==72 or entry==241)or parent==286 and entry==79)then
   r=s.y<544 and rooms.secondHigh or s.y<1040 and rooms.secondMiddle or rooms.secondLow
  elseif s.map==286 and(parent==285 or parent==287)then
   local upper=s.y<368 or(s.y<448 and(s.x<384 or s.x>=528))
   r=upper and rooms.deepUpper or rooms.deepLower
  elseif s.map==287 then
   r=s.y<720 and rooms.village or rooms.villageDeep
  elseif s.map==289 and parent==285 and entry==240 then r=rooms.chest end
  if r and inside(r,s.x,s.y)then return r,r.key end
 end
 function api.supported(s,w)return api.context(s,w)~=nil end
 local cacheKey,cacheFrame,groups=nil,-1000,{}
 function api.references(s,b,w,frame)
  local r,key=api.context(s,w);if not s.field or not r then return{}end
  local upper=b(s.base+11)>=128;local layer=upper and 0x7F4000 or 0x7F0000;local attrs=upper and 0x7FBC00 or 0x7FB800
  local identity=key..':'..tostring(upper);frame=frame or 0
  if identity~=cacheKey or frame-cacheFrame>=30 then
   cacheKey=identity;cacheFrame=frame;groups={}
   local allowed={};for _,e in ipairs(r.events)do allowed[e]=true end
   local header=0xC80000+w(0xC87000+s.map*2);local flags=b(header+3);local minimum=0xC0-flags%4;local first=math.floor(flags/4)%2
   local ep=0xC80000+w(0xC84000+s.map*2);local ending=0xC80000+w(0xC84002+s.map*2)
   local function add(event,label,x,y,target)
    local k='gaia33:'..key..':'..tostring(event);local g=groups[k]
    if not g then g={key=k,name=label[1],kind=label[2]=='signpost'and'signpost'or'exit',stairs=label[2]==true,event=event,destination=target,points={},note=label[3]};groups[k]=g end
    g.points[#g.points+1]={x=x*16+8,y=y*16+8}
   end
   for y=math.floor(r.bounds[2]/16),math.floor((r.bounds[4]-1)/16)do for x=math.floor(r.bounds[1]/16),math.floor((r.bounds[3]-1)/16)do
    local tile=b(layer+y*128+x)
    if r.attributeExit and math.floor(b(attrs+4*tile+1)/16)%2==1 then add('return',{'Regreso al pueblo de Kippo'},x,y,168)end
    local a=ep+2*(tile-minimum+first)
    if tile>=minimum and a<ending then local e=w(a);if allowed[e]then add(e,labels[e],x,y,e>=0x800 and w(0xC83000+4*(e-0x800))%512 or(e==0x780 or e==0x781)and s.map or nil)end end
   end end
  end
  local refs={}
  for _,g in pairs(groups)do
   local point,distance;for _,p in ipairs(g.points)do local d=(p.x-s.x)^2+(p.y-s.y)^2;if not distance or d<distance then point=p;distance=d end end
   refs[#refs+1]={key=g.key,name=g.name,kind=g.kind,stairs=g.stairs,event=g.event,destination=g.destination,x=point.x,y=point.y,
    note=(g.note and g.note..' 'or'')..(g.kind=='signpost'and'Acércate, mira hacia el letrero y pulsa B para leer.'or'Se cruza caminando, sin B. La dirección directa no evita obstáculos.')}
  end
  table.sort(refs,function(a,c)return a.key<c.key end)
  local admitted={};for _,e in ipairs(r.people)do admitted[e]=true end
  for slot=3,11 do
   local a=0x7EE000+slot*512;local e=w(a+0x3E)%4096;local p=admitted[e]and people[e]
   local chest=r==rooms.chest and e==0x687 and b(a+0x180)==0xEB and b(a+0x1C)==0
   if b(a)==1 and inside(r,w(a+2),w(a+4))and(p and b(a+0x180)==p[1]or chest)then
    local h,other=b(s.base+11)%4,b(a+11)%4
    refs[#refs+1]={key='gaia33-actor:'..s.map..':'..e..':'..slot,name=chest and'Cofre de la sala lateral de Gaia'or p[2],kind=chest and'interactive'or'person',slot=slot,event=e,x=w(a+2),y=w(a+4),
     samePlane=math.floor(b(a+11)/128)==math.floor(b(s.base+11)/128)and not(h==1 and other==2 or h==2 and other==1),
     note=chest and'Acércate, mira hacia el cofre y pulsa B para abrirlo. El contenido se anuncia al abrirlo.'or'Acércate, mira hacia la persona y pulsa B para hablar. Puede abrir un menú o iniciar una escena.'}
   end
  end
  for i,o in ipairs(furniture[r.key]or{})do
   local cell=math.floor(o.y/16)*128+math.floor(o.x/16)
   if b(0x7F0000+cell)==o.lower and b(0x7F4000+cell)==o.upper then
    refs[#refs+1]={key='gaia33-object:'..r.key..':'..i,name=o.name,kind='furniture',x=o.x,y=o.y,
     note='Mobiliario fijo identificado en el plano nativo. Referencia de posición; no se ofrece como recogible ni se presupone una interacción.'}
   end
  end
  -- The fixed skull in the upper second cave is a weapon switch, not an actor.
  -- Its lower metatile is checked live so no look-alike is announced elsewhere.
  if r==rooms.secondHigh then
   local cell=math.floor(152/16)*128+math.floor(248/16)
   if b(0x7F0000+cell)==0x30 then
    refs[#refs+1]={key='gaia33:skull-switch',name='Calavera interruptor de la segunda caverna',kind='switch',x=248,y=152,samePlane=true,
     note='Está fija en la pared. Golpéala una vez con el arma: el agua enfría la lava. Después baja por las escaleras y cruza el paso enfriado; no necesita B ni se activa al caminar.'}
   end
  end
  if r==rooms.deepLower then
   local cell=math.floor(512/16)*128+math.floor(720/16)
   if b(0x7F0000+cell)==0x19 then
    refs[#refs+1]={key='gaia35:skull-switch-east',name='Segunda calavera interruptor del subterráneo',kind='switch',x=720,y=512,samePlane=true,
     note='Está fija en la pared, al final de la cornisa este tras derrotar al Niño Goblin. Golpéala una vez con el arma: la plataforma cae y desbloquea el camino al Pueblo de Enanos. No necesita B ni se activa al caminar.'}
   end
  end
  -- The 0x30 tile near (456,1240) in map 285 lower only resembles the real
  -- switch at (248,152). Striking it does nothing; the native feature here is
  -- the 780 staircase at (440,1224)/(456,1224), already listed from events.
  return refs
 end
 function api.enemies(s,b,w)
  local r=api.context(s,w);local refs={};if not s.field or not r or not r.battle then return refs end
  local admitted={[0]=true,[1]=true,[2]=true,[4]=true,[6]=true,[8]=true,[10]=true}
  for slot=3,11 do
   local a=0x7EE000+slot*512;local id=b(a+0x1E7)
   if b(a)==1 and b(a+0x44)<128 and admitted[id]and b(a+0x180)==id and w(a+0x182)>0 and w(a+0x184)>0 and inside(r,w(a+2),w(a+4))then
    local name=data.name(b,w,0xCF+id)
    if name then local h,other=b(s.base+11)%4,b(a+11)%4
     refs[#refs+1]={key='gaia33-enemy:'..s.map..':'..slot..':'..id,name=name..' '..(slot-2),kind='enemy',slot=slot,id=id,x=w(a+2),y=w(a+4),
      samePlane=math.floor(b(a+11)/128)==math.floor(b(s.base+11)/128)and not(h==1 and other==2 or h==2 and other==1)}
    end
   end
  end
  return refs
 end
 return api
end
