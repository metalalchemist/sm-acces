-- Conservative normal-attack forecast, with ROM-measured profiles by weapon type.
return function(geometry,profiles)
 return function(s,enemy,b,w)
  local profile=profiles[b(s.base+0x68)]
  if not profile or b(s.base+0x1A)~=0 or b(s.base+0x1B)~=0
   or b(s.base+0x19B)~=0 or b(s.base+0x1C)~=0 or b(s.base+0x60)~=0 or b(s.base+0x0A)~=0 then return nil end
  local body=geometry.box(b,w,0x7EE000+enemy.slot*512,0xC8)
  if not body then return false end
  return geometry.covered(profile,b(s.base+0x10),s.x,s.y,body)
 end
end
