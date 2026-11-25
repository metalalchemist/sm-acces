-- Experimental first-boss adapter; ROM signature and native actor identity gated.
return function(geometry,profiles)
 local api={};local previous,early,gauge,hp,rangeTime,lastReach
 local function bit(v,n)return math.floor(v/n)%2==1 end
 local function signed(v)return v>=128 and v-256 or v end
 function api.compatible(b)
  local checks={[0xC2377A]={0xDD,0x7A,0x00,0xF0},[0xC23D98]={0xA6,0x87,0x20,0x41,0x3A}}
  for address,bytes in pairs(checks)do for i,v in ipairs(bytes)do if b(address+i-1)~=v then return false end end end
  return true
 end
 function api.tick(s,io)
  local b,w,cue=io.b,io.w,io.cue;local a=0x7EE600
  local present=s.map==260 and b(a)==1 and b(a+0x180)==0x57 and w(a+0xB4)==0x3D48
  if not present then previous=nil;early=nil;hp=nil;rangeTime=nil;lastReach=nil;return end
  local health=w(a+0x182)
  if health==0 then
   if hp and hp>0 then io.say('Hormiga derrotada.',false,'boss-result')end
   hp=health;previous=nil;early=nil;return
  end
  hp=health
  if not s.field then previous=nil;early=nil;gauge=nil;return end
  s.references[#s.references+1]={key='hormiga',name='Hormiga',x=w(a+0x2B),y=w(a+0x32),slot=3,kind='enemy',samePlane=w(a+0x66)==0,
   note='Referencia directa al jefe. No es una ruta ni una indicación de esquiva segura.'}
  local now=io.time or 0
  local state,mode=b(a+0x7A),w(a+0x82)
  local dx,dy=s.x-w(a+0x2B),s.y-w(a+0x32)
  local pan=math.max(-1,math.min(1,-dx/160))
  local counter,threshold=w(a+0xAD),w(a+0x2D)
  if threshold>0 and counter<threshold-8 then early=false end
  -- A soft pre-alert describes a pending decision, not a chosen attack.
  local movement=state==0 or state==4 or state==5 or state==6 or state==0x0D
  if not early and mode==1 and movement and threshold>0 and counter>=threshold-6 and math.abs(dx)+math.abs(dy)<=80 and dy>=0 then
   early=true;cue('boss_prepare',pan,0.35)
  end
  if state~=previous then
   if state==7 then cue(w(a+0xB0)==0xD0BA and'boss_projectile'or'boss_claw',pan,0.55)
   elseif state==10 or state==11 then cue('boss_claw',pan,0.55)
   elseif state==0x10 then cue('boss_projectile',pan,0.55)
   elseif state==8 or state==0x13 then cue('boss_magic',pan,0.45)end
   previous=state
  end
  local current=w(s.base+0x182)
  if gauge and current<gauge then io.say('Has recibido daño. Vida '..current..'.',false,'damage');cue('hit',0,0.35)end
  gauge=current
  -- Deliberately smaller than the C2 boss hurt box: conservative sword forecast.
  if b(s.base+0x1E4)==1 and b(s.base+0x1A)==0 and b(s.base+0x1B)==0 and b(s.base+0x1C)==0 and w(a+0x66)==0 then
   local offset=b(a+0xCA)>0 and 0xC8 or 0xCC
   local width,height=b(a+offset+2),b(a+offset+3)
   local reach=false
   if width>0 and height>0 then
    reach=geometry.covered(profiles,b(s.base+0x10),s.x,s.y,{x=w(a+0x2B)+signed(b(a+offset)),y=w(a+0x32)+signed(b(a+offset+1)),width=width,height=height})
   end
   if reach~=lastReach or not rangeTime or now-rangeTime>=0.9 then cue(reach and'range_in'or'range_out',pan,0.28);rangeTime=now;lastReach=reach end
  end
 end
 return api
end
