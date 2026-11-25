-- Potos dialogue identities, from this ROM's map records and event text.
local names={
 [131]={[0x10C]='Viejo',[0x10E]='Timothy',[0x107]='Habitante del oeste',[0x108]='Habitante del sur',
        [0x109]='Habitante de la plaza',[0x10B]='Habitante junto a la salida'},
 [257]={[0x10A]='Habitante de la casa',[0x115]='Habitante de la casa',[0x300]='Comerciante',
        [0x10F]='Habitante de la casa del sur',[0x110]='Habitante de la casa del sur',[0x111]='Viajero'},
 [258]={[0x114]='Viejo',[0x115]='Habitante 1',[0x116]='Habitante 2',[0x117]='Habitante 3',
        [0x118]='Habitante 4',[0x119]='Habitante 5'},
 [259]={[0x320]='Posadero'}
}
local entries={
 [88]={[0x10A]=true,[0x115]=true},[89]={[0x300]=true},
 [91]={[0x10F]=true,[0x110]=true,[0x111]=true}
}
local api={}
function api.supported(s,w)
 return s.map==131 or (s.map==257 or s.map==258 or s.map==259) and (w(0x7ECD08)==131 or s.map==258 and w(0x7ECD08)==258)
end
function api.references(s,b,w)
 local refs={}
 if not s.field or not api.supported(s,w) then return refs end
 local allowed=s.map==257 and entries[w(0x7E010E)] or nil
 for slot=3,11 do
  local a=0x7EE000+slot*512
  local event=w(a+0x3E)%4096
  local name=names[s.map][event]
  if s.map==258 and ((w(0x7E010E)==102)~=(event==0x119)) then name=nil end
  -- NPCs here leave the monster-id byte E1E7 at zero. Their map-local talk
  -- event is the observed identity; treating zero as Rabite would be wrong.
  if b(a)==1 and name and (s.map~=257 or allowed and allowed[event]) then
   local h,other=b(s.base+0x0B)%4,b(a+0x0B)%4
   refs[#refs+1]={key='persona:'..s.map..':'..event..':'..slot,name=name,x=w(a+2),y=w(a+4),kind='person',slot=slot,event=event,
    samePlane=math.floor(b(a+0x0B)/128)==math.floor(b(s.base+0x0B)/128) and not (h==1 and other==2 or h==2 and other==1),
    note=event==0x10C and 'Acércate caminando al Viejo para iniciar la conversación por contacto. Esta conversación inicia una escena.'
     or 'Acércate, mira hacia la persona y pulsa B para hablar.'}
  end
  -- Fixed map chest: this is not an enemy drop (E1B1 remains zero).
  -- Map 258's native object record binds actor EB to event 680.
  if s.map==258 and w(0x7E010E)==102 and b(a)==1 and event==0x680 and b(a+0x180)==0xEB then
   refs[#refs+1]={key='cofre-sotano-viejo',name='Cofre del sótano',x=w(a+2),y=w(a+4),kind='interactive',slot=slot,event=event,
    samePlane=math.floor(b(a+0x0B)/128)==math.floor(b(s.base+0x0B)/128),
    note='Acércate, mira hacia el cofre y pulsa B para abrirlo. Su contenido no se anuncia antes de abrirlo.'}
  end
 end
 table.sort(refs,function(a,c)
  if (a.name=='Viejo')~=(c.name=='Viejo') then return a.name=='Viejo' end
  return a.key<c.key
 end)
 return refs
end
function api.guidance(s,w)
 if s.map==131 then
  if s.story<=5 then return 'Para continuar, selecciona al Viejo de la plaza y acércate caminando hasta él. Su conversación se activa por contacto e inicia una escena.' end
  if s.story==6 then return 'Busca la casa del Viejo para continuar la historia.' end
  return 'La salida sureste del pueblo permite continuar el viaje.'
 elseif s.map==259 then return 'Posada de Potos. Selecciona al posadero para conversar. La salida vuelve al pueblo.'
 elseif s.map==258 then
  if w(0x7E010E)==102 then return 'Sótano de la casa del Viejo. Las escaleras vuelven a la planta principal.' end
  return 'Casa del Viejo. Puedes seleccionar a las personas presentes, las escaleras y la salida al pueblo.'
 elseif s.map==257 then return 'Interior de Potos. Puedes seleccionar a las personas presentes y la salida al pueblo.' end
end
return api
