-- Water Palace, first-visit switch scripts in this Sayans ROM.
-- Native events 6F0/A4, 6E9/A5, 6EA/A6 redraw their bridge pieces.
local api={}
local sizes={[136]={960,1024},[137]={448,512},[139]={640,1152}}
local buttons={
 [0x6F0]={key='palacio-pulsador-sur',name='Pulsador sur del Palacio de Agua',flag=0xA4},
 [0x6E9]={key='palacio-pulsador-oeste',name='Pulsador oeste del Palacio de Agua',flag=0xA5},
 [0x6EA]={key='palacio-pulsador-este',name='Pulsador este del Palacio de Agua',flag=0xA6}
}
function api.supported(s,w)
 local size=sizes[s.map]
 return size and w(0x7E00C0)==size[1] and w(0x7E00C2)==size[2] or false
end
function api.references(s,b,w)
 local refs={}
 if not s.field or not api.supported(s,w)then return refs end
 local early=b(0x7ECF50)%16==0
 if s.map==136 or s.map==139 then
  local header=0xC80000+w(0xC87000+s.map*2);local flags=b(header+3)
  local minimum=0xC0-flags%4;local first=math.floor(flags/4)%2
  local ep=0xC80000+w(0xC84000+s.map*2);local ending=0xC80000+w(0xC84002+s.map*2)
  local upper=b(s.base+0x0B)>=128;local layer=upper and 0x7F4000 or 0x7F0000
  local width,height=sizes[s.map][1],sizes[s.map][2]
  for y=0,height/16-1 do for x=0,width/16-1 do
   local tile=b(layer+y*128+x);local a=ep+2*(tile-minimum+first)
   if early and tile>=minimum and a<ending then
    local event=w(a);local button=s.map==139 and buttons[event]
    if button then
     local state=b(0x7ECF00+button.flag)%16
     local note=state==0 and 'Paso todavía sin desplegar.' or state<15 and 'Paso desplegado; volver a activar el pulsador puede retirarlo.' or 'El mecanismo está fijado en esta fase.'
     if event==0x6E9 and b(0x7ECF11)%16==7 then note='Este pulsador no responde durante la escena actual.'
     elseif event==0x6EA and b(0x7ECF11)%16==7 then note=note..' En la escena actual puede iniciar una secuencia con Jema.' end
     refs[#refs+1]={key=button.key,name=button.name,kind='switch',x=x*16+8,y=y*16+8,event=event,flag=button.flag,state=state,samePlane=true,
      note=note..' Se activa al acercarte caminando; no necesita B. La dirección directa no evita los abismos.'}
    elseif s.map==136 and(event==0x6E7 or event==0x6E8)then
     refs[#refs+1]={key='palacio-acceso:'..event,name=event==0x6E7 and 'Acceso oeste al Palacio de Agua' or 'Acceso este al Palacio de Agua',kind='exit',destination=137,
      x=x*16+8,y=y*16+8,note='Acércate desde el sur y entra caminando. No necesita B. La dirección directa no evita obstáculos.'}
    end
   end
  end end
 end
 if s.map==139 then
  for slot=3,11 do
   local a=0x7EE000+slot*512;local event=w(a+0x3E)%4096
   local name=event==0x130 and b(a+0x180)==0xA1 and 'Luka' or event==0x131 and b(a+0x180)==0xA0 and 'Jema'
   if b(a)==1 and name then
    refs[#refs+1]={key='palacio-persona:'..slot..':'..event,name=name,kind='person',slot=slot,event=event,x=w(a+2),y=w(a+4),
     samePlane=math.floor(b(a+0x0B)/128)==math.floor(b(s.base+0x0B)/128),
     note='Acércate con cuidado; puede iniciar una escena. B permite hablar si la escena no ha empezado.'}
   end
  end
 end
 return refs
end
return api
