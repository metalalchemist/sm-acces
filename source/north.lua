-- Local ROM object records: map19 AC/120 and B7/121,122;
-- map136 A0/123. Scene actors remain conversable people, not monsters.
local api={}
local sizes={[19]={768,704},[136]={960,1024}}
local profiles={
 [19]={[0x120]={type=0xAC,name='Mayor Dyluck'},[0x121]={type=0xB7,name='Soldado'},[0x122]={type=0xB7,name='Soldado sobre la bruja Elinee'}},
 [136]={[0x123]={type=0xA0,name='Jema'}}
}
function api.supported(s,w)
 local size=sizes[s.map]
 return size and w(0x7E00C0)==size[1] and w(0x7E00C2)==size[2] or false
end
function api.references(s,b,w)
 local refs={}
 if not s.field or not api.supported(s,w)then return refs end
 for slot=3,11 do
  local a=0x7EE000+slot*512;local event=w(a+0x3E)%4096;local p=profiles[s.map][event]
  if b(a)==1 and p and b(a+0x180)==p.type then
   local name=p.name
   if p.type==0xB7 then name=name..' '..(slot-3) end
   local h,other=b(s.base+0x0B)%4,b(a+0x0B)%4
   refs[#refs+1]={key='norte-persona:'..s.map..':'..slot..':'..event,name=name,kind='person',slot=slot,event=event,
    x=w(a+2),y=w(a+4),samePlane=math.floor(b(a+0x0B)/128)==math.floor(b(s.base+0x0B)/128) and not(h==1 and other==2 or h==2 and other==1),
    note='Acércate con cuidado: esta persona puede iniciar una escena. La dirección directa no evita obstáculos.'}
  end
 end
 return refs
end
return api
