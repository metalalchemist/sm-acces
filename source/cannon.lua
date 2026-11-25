-- Native cannon clearing reached by transition 5 from map 16.
return function(s,b,w)
 if not s.field or s.map~=159 or w(0x7E00C0)~=384 or w(0x7E00C2)~=384 then return {}end
 local refs={};local best,distance
 local upper=b(s.base+0x0B)>=128;local layer=upper and 0x7F4000 or 0x7F0000
 local header=0xC80000+w(0xC87000+318);local flags=b(header+3)
 local minimum=0xC0-flags%4;local first=math.floor(flags/4)%2
 local ep=0xC80000+w(0xC84000+318);local ending=0xC80000+w(0xC84000+320)
 for y=0,23 do for x=0,23 do
  local tile=b(layer+y*128+x);local a=ep+2*(tile-minimum+first)
  if tile>=minimum and a<ending and w(a)==0x868 then
   local px,py=x*16+8,y*16+8;local d=(px-s.x)^2+(py-s.y)^2
   if not distance or d<distance then best={x=px,y=py};distance=d end
  end
 end end
 if best then refs[#refs+1]={key='canon-regreso',name='Regreso al camino de Potos',x=best.x,y=best.y,kind='exit',destination=16,
  note='Se vuelve caminando por este paso. La dirección directa no evita obstáculos.'}end
 if not upper and b(0x7F0000+15*128+13)==0x67 and b(0x7F0000+11*128+13)==0x67 then
  refs[#refs+1]={key='canon-escaleras-pie',name='Paso hacia el cañón, pie de las escaleras',x=212,y=264,kind='landmark',
   note='Desde aquí sube caminando al norte. No necesita B. La dirección directa no evita obstáculos.'}
  refs[#refs+1]={key='canon-escaleras-arriba',name='Parte superior de las escaleras del cañón',x=212,y=168,kind='landmark',
   note='Desde aquí baja caminando al sur. No necesita B. La dirección directa no evita obstáculos.'}
 end
 local cannon
 for slot=3,11 do
  local a=0x7EE000+512*slot;local id=b(a+0x180)
  if b(a)==1 and id==0xCE and w(a+0x3E)%4096==0xCE then
   refs[#refs+1]={key='canonero',name='Cañonero',x=w(a+2),y=w(a+4),kind='person',slot=slot,
    samePlane=math.floor(b(a+0x0B)/128)==math.floor(b(s.base+0x0B)/128),note='Acércate, mira hacia él y pulsa B para hablar.'}
  elseif b(a)==1 and id>=0xD4 and id<=0xD6 and not cannon then
   cannon={key='canon',name='Cañón',x=w(a+2),y=w(a+4),kind='landmark',slot=slot,note='El viaje se acuerda hablando con el cañonero.'}
  end
 end
 if cannon then refs[#refs+1]=cannon end
 return refs
end
