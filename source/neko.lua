-- ROM-local map279 object: type99, talk event D099 (low twelve bits099).
-- Read the live actor, never infer the shopkeeper from a sprite position.
local api={}
function api.supported(s,w)
 return s.map==279 and w(0x7ECD08)==132 and w(0x7E00C0)==512 and w(0x7E00C2)==384
end
function api.references(s,b,w)
 local refs={}
 if not s.field or not api.supported(s,w)then return refs end
 for slot=3,11 do
  local a=0x7EE000+slot*512
  if b(a)==1 and b(a+0x180)==0x99 and w(a+0x3E)%4096==0x99 then
   local h,other=b(s.base+0x0B)%4,b(a+0x0B)%4
   refs[#refs+1]={key='neko-persona:'..slot,name='Neko',kind='person',slot=slot,event=0x99,
    x=w(a+2),y=w(a+4),samePlane=math.floor(b(a+0x0B)/128)==math.floor(b(s.base+0x0B)/128) and not(h==1 and other==2 or h==2 and other==1),
    note='Acércate, mira hacia Neko y pulsa B para hablar.'}
  end
 end
 return refs
end
return api
