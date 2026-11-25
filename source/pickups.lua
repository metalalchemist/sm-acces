-- Native dropped-chest marker from C04203: E1B1=80, level=0, max HP=0.
-- An active EA actor alone is NOT evidence of loot; F9 is still dying.
return function(s,b,w)
 local refs={}
 if not s.field then return refs end
 for slot=3,11 do
  local a=0x7EE000+slot*512
  if b(a)==1 and b(a+0x1E7)~=0xF9 and b(a+0x181)==0 and w(a+0x184)==0
   and b(a+0x1B1)==0x80 and b(a+0x1C8)<=8 and b(a+0x60)==0 then
   refs[#refs+1]={key='recogible:'..slot..':'..b(a+0x1CA),name='Cofre de recompensa '..(#refs+1),
    x=w(a+2),y=w(a+4),slot=slot,kind='interactive',
    samePlane=math.floor(b(a+0x0B)/128)==math.floor(b(s.base+0x0B)/128),
    note='Acércate y examínalo con B. Puede contener una trampa; no se conoce el contenido antes de abrirlo.'}
  end
 end
 return refs
end
