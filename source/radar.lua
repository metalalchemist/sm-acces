-- Read-only real-time companion to Chrono-style stable references.
return function(geometry)
 local api={}
 local folder=debug.getinfo(1,'S').source:sub(2):match('^(.*[/\\])') or ''
 local profiles={[0]=dofile(folder..'glove-boxes.lua'),[1]=dofile(folder..'sword-boxes.lua'),[3]=dofile(folder..'spear-boxes.lua')}
 local reach=dofile(folder..'reach.lua')(geometry,profiles)
 local map,slot,nextCue=nil,nil,0
 local previousReach
 local warnings,health={},{}
 function api.tick(s,io)
  if map~=s.map then map=s.map;slot=nil;warnings={};health={};nextCue=0 end
  if not s.field then warnings={};previousReach=nil;s.radarTarget=nil;return end
  local b,w,now=io.b,io.w,io.time
  local nearest,locked,chosen
  local freshWarnings={};local warning
  local desired=s.selectedMap==s.map and s.selectedReference or nil
  for _,enemy in ipairs(s.enemies or {}) do
   local a=0x7EE000+enemy.slot*512
   local hp=w(a+0x182)
   if hp>0 then health[enemy.slot]={hp=hp,id=enemy.id or 0,name=enemy.name}end
   local dx,dy=enemy.x-s.x,enemy.y-s.y
   local distance=math.sqrt(dx*dx+dy*dy)
   local id=enemy.id or 0
   local magic=id==4 and b(a+0x140)==0x44 and b(a+0x1C)==0x40 and b(a+0x170)==0x1E
    and b(a+0x1AD)==s.owner and w(a+0x20)<256 and w(a+0x22)-b(a+0x45)>=0 and w(a+0x22)-b(a+0x45)<224
   if magic and hp>0 then
    freshWarnings[enemy.slot]='magic'
    if warnings[enemy.slot]~='magic' and (not warning or distance<warning.distance)then warning={dx=dx,distance=distance,kind='magic'}end
   end
   if enemy.samePlane and hp>0 then
    local e={ref=enemy,dx=dx,dy=dy,distance=distance}
    if not nearest or distance<nearest.distance then nearest=e end
    if enemy.slot==slot and distance<=192 then locked=e end
    if desired==enemy.key then chosen=e end
    local incoming=geometry.overlaps(geometry.box(b,w,a,0xC0),geometry.box(b,w,s.base,0xC8))
    -- +11 is an animation index: animation 2 is also used by harmless hops.
    -- +140 is the native command; state +1C=80 marks the active swing.
    local supported=id==0 or id==2 or id==4 or id==6
    local bite=supported and b(a+0x140)==2 and b(a+0x1C)==0x80 and b(a+0x1AC)==s.owner and distance<=64
    if not magic and (incoming or bite)then
     freshWarnings[enemy.slot]='threat'
     if warnings[enemy.slot]~='threat' and (not warning or distance<warning.distance) then e.kind='threat';warning=e end
    end
   end
  end
  for previous,record in pairs(health) do
   local a=0x7EE000+previous*512
   if record.hp>0 and w(a+0x182)==0 and b(a+0x1E7)==record.id then
    io.say(record.name..' derrotado.',false,'enemy-defeated');health[previous]=nil
   end
  end
  warnings=freshWarnings
  local target=chosen or locked or nearest
  s.radarTarget=target and target.ref or nil
  if warning then
   io.cue(warning.kind=='magic' and 'boss_magic' or 'threat',math.max(-1,math.min(1,warning.dx/64)),0.55)
  end
  if not target then slot=nil;previousReach=nil;s.reach=nil;return end
  local changed=slot~=target.ref.slot
  if changed then nextCue=0;previousReach=nil end
  slot=target.ref.slot
  local inRange=reach(s,target.ref,b,w)
  s.reach=inRange
  if inRange~=previousReach then nextCue=0;previousReach=inRange end
  if inRange~=nil and target.distance<=128 and now>=nextCue then
   local closeness=1-math.min(1,target.distance/128)
   io.cue(inRange and 'range_in' or 'range_out',math.max(-1,math.min(1,target.dx/64)),0.18+0.20*closeness)
   nextCue=now+(inRange and 0.6 or 0.35+0.4*(1-closeness))
  end
 end
 return api
end
