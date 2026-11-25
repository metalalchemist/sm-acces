-- Read-only opening-area observations. No guessed weapon radius is announced.
local function bit(v,n) return math.floor(v/n)%2==1 end
return function(geometry)
 local api={}
 local folder=debug.getinfo(1,'S').source:sub(2):match('^(.*[/\\])') or ''
 local radar=dofile(folder..'radar.lua')(geometry)
 local landmarks=dofile(folder..'landmarks.lua')()
 local pickups=dofile(folder..'pickups.lua')
 local village=dofile(folder..'village.lua')
 local exterior=dofile(folder..'exterior.lua')()
 local fieldEnemies=dofile(folder..'field-enemies.lua')
 local cannon=dofile(folder..'cannon.lua')
 local neko=dofile(folder..'neko.lua')
 local north=dofile(folder..'north.lua')
 local palace=dofile(folder..'palace.lua')
 local pandora=dofile(folder..'pandora.lua')()
 local castle=dofile(folder..'castle.lua')()
 local gaia=dofile(folder..'gaia.lua')()
 function api.tick(s,io)
  local b,w,say,cue,frame=io.b,io.w,io.say,io.cue,io.frame
  local map=w(0x7E00DC)
  local owner
  for i=0,2 do if bit(b(0x7E00D9),2^i) and b(0x7EE000+i*512)==1 then owner=i;break end end
  local base=0x7EE000+(owner or 0)*512
  local field=owner~=nil and w(base+0x184)>0 and b(0x7E00D0)==0 and b(0x7E007D)==0
   and b(0x7E00E4)==1 and b(0x7E00E6)==15 and b(0x7E00FF)==0 and not bit(b(0x7E00F1),128)
  local x,y=w(base+2),w(base+4)
  s.field=field;s.map=map;s.x=x;s.y=y;s.owner=owner;s.base=base
  s.references={}
  s.enemies={}
  local story=b(0x7ECF10)%16
  if s.story==0 and story==1 and map==128 then
   cue('interactive',0,0.45);say('Has extraído la espada.',false,'pickup')
  end
  s.story=story
  if field and gaia.supported(s,w)then
   local room,key=gaia.context(s,w)
   if s.announcedMap~=map or s.gaiaRoom~=key then say(room.name..'. Referencias a accesos, letreros, objetos y personas presentes.',false,'map');s.announcedMap=map;s.gaiaRoom=key end
   s.references=gaia.references(s,b,w,frame);s.enemies=gaia.enemies(s,b,w)
   if room.battle then
    for _,r in ipairs(pickups(s,b,w))do s.references[#s.references+1]=r end
    for _,r in ipairs(s.enemies)do s.references[#s.references+1]=r end
   end
   s.target=nil
   local healthKey=map..':'..base;local hp=w(base+0x182)
   if s.gaiaHealthKey==healthKey and s.hp and hp<s.hp then say('Has recibido daño. Vida '..hp..'.',false,'damage');cue('hit',0,0.35)end
   s.gaiaHealthKey=healthKey;s.hp=hp
  elseif field and castle.supported(s,w)then
   local room,key=castle.context(s,w)
   if s.announcedMap~=map or s.castleRoom~=key then say(room.name..'. Referencias a personas presentes, cofres y accesos.',false,'map');s.announcedMap=map;s.castleRoom=key end
   s.references=castle.references(s,b,w);s.target=nil;s.hp=nil
  elseif field and pandora.supported(s,w)then
   local room,key=pandora.context(s,w)
   if s.announcedMap~=map or s.pandoraRoom~=key then say(room.name..'. Referencias a personas presentes y accesos.',false,'map');s.announcedMap=map;s.pandoraRoom=key end
   s.references=pandora.references(s,b,w,frame);s.target=nil;s.hp=nil
  elseif field and (map==137 or map==139) and palace.supported(s,w)then
   if s.announcedMap~=map then say(map==137 and 'Vestíbulo del Palacio de Agua.' or 'Palacio de Agua. Referencias a pulsadores, personas presentes y salidas.',false,'map');s.announcedMap=map end
   s.references=landmarks(s,b,w,frame)
   for _,r in ipairs(palace.references(s,b,w))do s.references[#s.references+1]=r end
   s.target=nil;s.hp=nil
  elseif field and north.supported(s,w) then
   if s.announcedMap~=map then say(map==19 and 'Camino del norte. Referencias al oficial, soldados, letrero y salidas.' or 'Zona de Jema. Referencias a Jema presente y a los accesos.',false,'map');s.announcedMap=map end
   s.references=landmarks(s,b,w,frame)
   for _,r in ipairs(north.references(s,b,w))do s.references[#s.references+1]=r end
   if map==136 then for _,r in ipairs(palace.references(s,b,w))do s.references[#s.references+1]=r end end
   s.target=nil;s.hp=nil
  elseif field and neko.supported(s,w) then
   if s.announcedMap~=279 then say('Casa de Neko. Referencias a Neko y a la salida.',false,'map');s.announcedMap=279 end
   s.references=landmarks(s,b,w,frame)
   for _,r in ipairs(neko.references(s,b,w))do s.references[#s.references+1]=r end
   s.target=nil;s.hp=nil
  elseif field and map==132 then
   if s.announcedMap~=132 then say('Neko. Referencias a la casa y a la salida al camino de Potos.',false,'map');s.announcedMap=132 end
   s.references=landmarks(s,b,w,frame);s.target=nil;s.hp=nil
  elseif field and map==159 then
   if s.announcedMap~=159 then say('Zona del cañón. Referencias al cañonero, las escaleras y el regreso al camino.',false,'map');s.announcedMap=159 end
   s.references=cannon(s,b,w);s.target=nil;s.hp=nil
  elseif field and map==16 then
   if s.announcedMap~=16 then say('Camino exterior de Potos. Referencias de salidas, letreros y enemigos identificados.',false,'map');s.announcedMap=16 end
   s.references=exterior(s,b,w,frame);s.enemies=fieldEnemies(s,b,w)
   for _,item in ipairs(pickups(s,b,w))do s.references[#s.references+1]=item end
   for _,enemy in ipairs(s.enemies)do s.references[#s.references+1]=enemy end
   s.target=nil
   local hp=w(base+0x182)
   if s.hp and hp<s.hp then say('Has recibido daño. Vida '..hp..'.',false,'damage');cue('hit',0,0.35)end
   s.hp=hp
  elseif field and (map==128 or map==129 or map==130 or village.supported(s,w)) then
   if map~=s.announcedMap then
    say(map==128 and (story==0 and 'Cascadas de Potos. Busca la espada antes de salir.' or 'Cascadas de Potos. La salida al bosque está al este.') or map==129 and 'Bosque al sur de las cascadas. Referencias hacia las cascadas y hacia Potos por los puentes.' or map==130 and 'Río y puentes de Potos.' or map==131 and 'Pueblo de Potos.' or 'Interior de Potos.',false,'map')
    s.announcedMap=map
   end
   local hp=w(base+0x182)
   if s.hp and hp<s.hp then say('Has recibido daño. Vida '..hp..'.',false,'damage');cue('hit',0,0.35) end
   s.hp=hp
   local target
   if map==128 and story==0 then
    for slot=3,11 do
     local a=0x7EE000+slot*512
     if b(a)==1 and b(a+0x1E7)==0xD8 then
      target={name='Espada clavada',x=w(a+2),y=w(a+4),slot=slot,kind='interactive'};break
     end
    end
   elseif map==128 and story>=1 then
    target={name='Salida al bosque',x=760,y=808,slot=-1,kind='exit'}
   elseif map==129 or map==130 then
    local nearest
    for slot=3,5 do
     local a=0x7EE000+slot*512
     if b(a)==1 and b(a+0x1E7)==0 and w(a+0x182)>0 then
      local ax,ay=w(a+2),w(a+4);local dist=(ax-x)^2+(ay-y)^2
      local h,eh=b(base+0x0B)%4,b(a+0x0B)%4
      local ref={key='conejo:'..slot,name='Conejo '..(slot-2),x=ax,y=ay,slot=slot,kind='enemy',
       samePlane=math.floor(b(base+0x0B)/128)==math.floor(b(a+0x0B)/128) and not (h==1 and eh==2 or h==2 and eh==1)}
      s.references[#s.references+1]=ref;s.enemies[#s.enemies+1]=ref
      if not nearest or dist<nearest then
       nearest=dist;target={name='Conejo',x=ax,y=ay,slot=slot,kind='enemy'}
      end
     end
    end
   end
   if map==128 then
    if target and target.kind=='interactive' then s.references[#s.references+1]={key='espada',name=target.name,x=target.x,y=target.y,
     note='Para recogerla, acércate por el norte, mira al sur y pulsa B.'} end
   end
   local exits=landmarks(s,b,w,frame)
   local items=pickups(s,b,w)
   for i=#items,1,-1 do table.insert(s.references,1,items[i]) end
   -- Exits come first in the selector, so exploration does not start on a rabbit.
   for i=#exits,1,-1 do table.insert(s.references,1,exits[i]) end
   if village.supported(s,w) then
    local people=village.references(s,b,w)
    for _,person in ipairs(people) do s.references[#s.references+1]=person end
    -- At first arrival, make the plot contact the first usable reference.
    if map==131 and story<=5 then
     for i,r in ipairs(s.references) do if r.event==0x10C then table.remove(s.references,i);table.insert(s.references,1,r);break end end
    elseif map==131 and story==6 then
     for i,r in ipairs(s.references) do if r.key=='casa-viejo' then table.remove(s.references,i);table.insert(s.references,1,r);break end end
    elseif map==131 then
     for i,r in ipairs(s.references) do if r.key=='salida-sureste' then table.remove(s.references,i);table.insert(s.references,1,r);break end end
    end
    local key=map..':'..story..':'..w(0x7E010E)
    if s.villageHint~=key then say(village.guidance(s,w),false,'guidance');s.villageHint=key end
   end
   s.target=target
  else
   s.target=nil;s.hp=nil;s.gauge=nil
   if field and s.uncoveredMap~=map then
    say('Este mapa aún no tiene referencias de objetos o salidas. Los diálogos siguen activos.',false,'coverage')
    s.uncoveredMap=map
   end
  end
  radar.tick(s,{b=b,w=w,time=io.time or frame/60,say=say,cue=cue})
  if s.target and s.target.kind=='enemy' then s.target=s.radarTarget end
 end
 return api
end
