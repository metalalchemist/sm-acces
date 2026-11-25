-- Map 16's ordinary monster records; NPCs/effects never enter the combat list.
local names={[0]='Conejo',[2]='Hongo',[4]='Planta',[6]='Goblin pequeño'}
return function(s,b,w)
 local refs={}
 if not s.field or s.map~=16 or w(0x7E00C0)~=1120 or w(0x7E00C2)~=1856 then return refs end
 for slot=3,11 do
  local a=0x7EE000+slot*512;local id=b(a+0x1E7)
  -- C0:F8B3 skips ordinary combat AI when +44 has bit 7 (scene actor).
  if b(a)==1 and b(a+0x44)<128 and names[id] and b(a+0x180)==id and w(a+0x182)>0 and w(a+0x184)>0 then
   local h,other=b(s.base+0x0B)%4,b(a+0x0B)%4
   refs[#refs+1]={key='enemigo16:'..slot..':'..id,name=names[id]..' '..(slot-2),id=id,x=w(a+2),y=w(a+4),slot=slot,kind='enemy',
    samePlane=math.floor(b(a+0x0B)/128)==math.floor(b(s.base+0x0B)/128) and not(h==1 and other==2 or h==2 and other==1)}
  end
 end
 return refs
end
