-- Pandora-local ROM records and native room sectors. No path or input synthesis.
return function()
 local api={}
 api.sizes={[144]={1024,1152},[145]={768,896},[261]={1280,1472},[262]={512,384},[263]={896,384}}
 local rooms={
  [107]={map=263,name='Casa de Elman, planta principal',bounds={64,32,480,320},events={[0x148]=true}},
  [114]={map=263,name='Casa de Elman, planta principal',bounds={64,32,480,320},events={[0x148]=true}},
  [113]={map=263,name='Casa de Elman, planta superior',bounds={544,64,832,288},events={[0x149]=true,[0x14A]=true,[0x14B]=true}},
  [108]={map=261,name='Tienda de objetos de Pandora',bounds={992,480,1168,656},events={[0xDB]=true},attributeExit=true},
  [109]={map=262,name='Posada de Pandora',bounds={0,0,512,384},events={[0xDC]=true}},
  [110]={map=261,name='Casa de la familia de Pandora',bounds={64,768,480,1024},events={[0x150]=true,[0x151]=true,[0x152]=true,[0x153]=true},attributeExit=true},
  [111]={map=261,name='Comercio del este de Pandora',bounds={128,1200,336,1408},events={[0xDA]=true},attributeExit=true},
  [112]={map=261,name='Casa de Phanna, planta principal',bounds={528,768,880,1056},events={[0x155]=true,[0x14E]=true}},
  [120]={map=261,name='Casa de Phanna, planta principal',bounds={528,768,880,1056},events={[0x155]=true,[0x14E]=true}},
  [119]={map=261,name='Casa de Phanna, planta superior',bounds={528,1152,816,1376},events={[0x157]=true}},
  [116]={map=261,name='Casa del suroeste de Pandora',bounds={544,96,960,352},events={[0x154]=true},attributeExit=true}
 }
 local town={name='Pueblo de Pandora',bounds={0,0,1024,1152}}
 local castle={name='Patio del castillo de Pandora',bounds={0,0,768,896}}
 local doors={
  [0x812]={key='pandora-salida-oeste',name='Salida oeste de Pandora, camino hacia Gaia y Kippo',order=1},
  [0x839]={key='pandora-salida-norte',name='Salida norte al camino de Potos',order=2},
  [0x81E]={key='pandora-salida-sur',name='Salida sur hacia las ruinas',order=3},
  [0x84C]={key='pandora-castillo',name='Entrada al patio del castillo de Pandora',order=4},
  [0x86C]={key='pandora-tienda-objetos',name='Tienda de objetos de Pandora',order=5},
  [0x86D]={key='pandora-posada',name='Posada de Pandora',order=6},
  [0x86F]={key='pandora-comercio-este',name='Comercio del este de Pandora',order=7},
  [0x86B]={key='pandora-casa-elman',name='Casa de Elman',order=8},
  [0x870]={key='pandora-casa-phanna',name='Casa de Phanna',order=9},
  [0x86E]={key='pandora-casa-familia',name='Casa de la familia, al sureste',order=10},
  [0x874]={key='pandora-casa-suroeste',name='Casa del suroeste de Pandora',order=11}
 }
 local people={
  [0x140]={type=0xB7,name='Guardia de la entrada de Pandora'},
  [0x141]={type=0xC4,name='Habitante de Pandora 1'},[0x142]={type=0xC5,name='Habitante de Pandora 2'},
  [0x143]={type=0xBC,name='Habitante de Pandora 3'},[0x144]={type=0xCA,name='Habitante de Pandora 4'},
  [0x145]={type=0xB7,name='Soldado junto al castillo'},[0x146]={type=0xA6,name='Phanna'},
  [0x147]={type=0xB7,name='Guardia de la entrada de Pandora'},
  [0x148]={type=0xC5,name='Habitante de la casa de Elman'},[0x149]={type=0xBB,name='Elman'},
  [0x14A]={type=0x8B,name='Chica de la casa de Elman'},[0x14B]={type=0x8B,name='Chica que busca a Dyluck'},
  [0x150]={type=0xC4,name='Habitante de la casa familiar 1'},[0x151]={type=0xC5,name='Habitante de la casa familiar 2'},
  [0x152]={type=0xC7,name='Habitante de la casa familiar 3'},[0x153]={type=0xC8,name='Habitante de la casa familiar 4'},
  [0x154]={type=0xC4,name='Habitante de la casa del suroeste'},
  [0x155]={type=0xC9,name='Habitante de la casa de Phanna'},[0x14E]={type=0xCA,name='Habitante en silencio de la casa de Phanna'},
  [0x157]={type=0xA6,name='Habitante que conoce las ruinas'},
  [0xDB]={type=0xCF,name='Comerciante de objetos'},[0xDA]={type=0xCF,name='Comerciante del este'},
  [0xDC]={type=0xCF,name='Posadero de Pandora'}
 }
 function api.context(s,w)
  local size=api.sizes[s.map]
  if not size or w(0x7E00C0)~=size[1]or w(0x7E00C2)~=size[2]then return nil end
  if s.map==144 then return town,'144' elseif s.map==145 then return castle,'145' end
  local entry=w(0x7E010E);local room=rooms[entry];local parent=w(0x7ECD08)
  if room and room.map==s.map and(parent==144 or parent==s.map)then return room,s.map..':'..entry end
 end
 function api.supported(s,w)return api.context(s,w)~=nil end
 local cacheKey,lastScan,groups=nil,-1000,{}
 function api.references(s,b,w,frame)
  local room,id=api.context(s,w);if not s.field or not room then return {}end
  local upper=b(s.base+0x0B)>=128
  local key=id..':'..tostring(upper)..':'..b(0x7ECF12)
  if key~=cacheKey or frame-lastScan>=30 then
   cacheKey=key;lastScan=frame;groups={}
   local header=0xC80000+w(0xC87000+s.map*2);local flags=b(header+3)
   local first=math.floor(flags/4)%2;local minimum=0xC0-flags%4
   local ep=0xC80000+w(0xC84000+s.map*2);local ending=0xC80000+w(0xC84002+s.map*2)
   local layer=upper and 0x7F4000 or 0x7F0000;local attrs=upper and 0x7FBC00 or 0x7FB800
   local function add(label,x,y,event,target)
    local group=groups[label.key]
    if not group then group={key=label.key,name=label.name,order=label.order or 1,kind='exit',destination=target,event=event,points={},note=label.note};groups[label.key]=group end
    group.points[#group.points+1]={x=x*16+8,y=y*16+8}
   end
   for y=math.floor(room.bounds[2]/16),math.floor((room.bounds[4]-1)/16)do for x=math.floor(room.bounds[1]/16),math.floor((room.bounds[3]-1)/16)do
    local tile=b(layer+y*128+x)
    if room.attributeExit and math.floor(b(attrs+4*tile+1)/16)%2==1 then add({key='pandora-regreso-pueblo',name='Regreso al pueblo de Pandora'},x,y,nil,144)end
    local address=ep+2*(tile-minimum+first)
    if tile>=minimum and address<ending then
     local event=w(address);local label
     if s.map==144 then label=doors[event]
     elseif s.map==145 then
      if event==0x84D then label={key='pandora-regreso-pueblo',name='Regreso al pueblo de Pandora'}
      elseif event==0x8D2 or event==0x8D3 or event==0x8DF then label={key='pandora-castillo-puerta:'..event,name='Puerta del castillo '..(event==0x8D2 and 'oeste' or event==0x8D3 and 'este' or 'central'),order=2,note=event==0x8DF and 'Entrada a la sala de los soldados del castillo.'or'Entrada al vestíbulo del castillo.'}end
     elseif event==0x879 or event==0x873 or event==0x80F then label={key='pandora-regreso-pueblo',name='Regreso al pueblo de Pandora'}
     elseif event==0x877 then label={key='pandora-phanna-subir',name='Escaleras a la planta superior de la casa de Phanna',order=2}
     elseif event==0x878 then label={key='pandora-phanna-bajar',name='Escaleras a la planta principal de la casa de Phanna',order=2}
     elseif event==0x871 then label={key='pandora-elman-subir',name='Escaleras a la planta superior de la casa de Elman',order=2,note='Se accede desde el este caminando hacia el oeste; no necesita B.'}
     elseif event==0x872 then label={key='pandora-elman-bajar',name='Escaleras a la planta principal de la casa de Elman',order=2,note='Se accede desde el oeste caminando hacia el este; no necesita B.'}end
     if label then add(label,x,y,event,w(0xC83000+4*(event-0x800))%512)end
    end
   end end
  end
  local refs={}
  for _,g in pairs(groups)do
   local point,distance
   for _,p in ipairs(g.points)do local d=(p.x-s.x)^2+(p.y-s.y)^2;if not distance or d<distance then point=p;distance=d end end
   refs[#refs+1]={key=g.key,name=g.name,kind=g.kind,destination=g.destination,event=g.event,x=point.x,y=point.y,order=g.order,
    note=(g.note or 'Se cruza caminando, sin B.')..' La dirección directa no evita obstáculos.'}
  end
  table.sort(refs,function(a,c)if a.order~=c.order then return a.order<c.order end;return a.key<c.key end)
  for slot=3,11 do
   local a=0x7EE000+slot*512;local event=w(a+0x3E)%4096;local p=people[event]
   local allowed=s.map==144 and event>=0x140 and event<=0x147 or room.events and room.events[event]
   if allowed and p and b(a)==1 and b(a+0x180)==p.type then
    local h,other=b(s.base+0x0B)%4,b(a+0x0B)%4
    local note='Acércate, mira hacia la persona y pulsa B para hablar. Puede iniciar una escena.'
    if event==0xDA and b(0x7ECF12)%16<9 then note=note..' Por la historia, este comerciante todavía responde con silencio en lugar de vender.'end
    refs[#refs+1]={key='pandora-persona:'..s.map..':'..event..':'..slot,name=p.name,kind='person',slot=slot,event=event,x=w(a+2),y=w(a+4),
     samePlane=math.floor(b(a+0x0B)/128)==math.floor(b(s.base+0x0B)/128)and not(h==1 and other==2 or h==2 and other==1),note=note}
   end
  end
  return refs
 end
 return api
end
