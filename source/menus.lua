-- Native boot/name page context is accepted only on frames observed in its renderer.
return function(charset,say,log)
 local observed=false
 local missing=100
 local previous,previousName,previousLetter,ringKey
 local function decodeTile(mem,tile)
  tile=tile%1024
  local offset=tile-0x58
  if offset<0 or offset%2~=0 or offset>0x100 then return nil end
  local glyph=mem.readbyte(0xC774B2+offset/2)
  if glyph==0x97 then return 'w' elseif glyph==0xB1 then return 'W' end
  return charset[glyph]
 end
 local function inspectName(mem)
  local b,w=mem.readbyte,mem.readword
  local x,y=b(0x7EA159),b(0x7EA15A)
  local row=math.floor(((y-0x48)%256)/8)*8
  local col=math.floor(((x-0x10)%256)/8)*2
  local letter=decodeTile(mem,w(0x7E9246+row*8+col))
  local count=b(0x7EA1CC)
  if count>6 then return nil end
  local parts={}
  for i=0,count-1 do
   local value=decodeTile(mem,w(0x7E90D2+2*i))
   if not value then return nil end
   parts[#parts+1]=value
  end
  if not letter then return nil end
  return letter,table.concat(parts),count
 end
 local config={'Equipar armadura','Objetivos','Estado','Niveles de armas y magia','Comportamiento','Controles','Ventana'}
 local weapons={'Guantes','Espada','Hacha','Lanza','Látigo','Arco','Bumerán','Jabalina'}
 local items={'Caramelo','Chocolate','Mermelada','Nuez mágica','Hierba medicinal','Copa de los deseos','Cuerda mágica','Tambor','Cinturón moguri','Martillo','Barril'}
 local api={observe=function() observed=true;missing=0 end}
 function api.inName(mem) return missing<=3 and mem.readbyte(0x7EA202)==3 end
 function api.tick(mem,shopActive)
  local b,w=mem.readbyte,mem.readword
  -- Loaded-game menus own this context, including their renderer callbacks.
  if shopActive then observed=false;missing=100;previous=nil;previousName=nil;previousLetter=nil;ringKey=nil;return end
  if observed then
   local page=b(0x7EA202)
   if page==0 then
    local cursor=b(0x7EA211)
    local labels={[0]='Empezar',[1]='Cargar'}
    local key='title:'..cursor
    if labels[cursor] and key~=previous then say('Inicio. '..labels[cursor]..'.',true,'menu');previous=key end
    previousName=nil;previousLetter=nil
   elseif page==3 and b(0x7EA20A)%2==0 then
    local letter,name,count=inspectName(mem)
    if count then
     if previous~='name' then say('Nombre del personaje. B añade una letra. Start confirma.',true,'menu');previous='name' end
     if name~=previousName then say('Nombre: '..(name=='' and 'vacío' or name)..'. '..count..' de 6 letras.',true,'name');previousName=name end
     if letter and letter~=previousLetter then say(letter==' ' and 'Espacio' or letter,true,'letter');previousLetter=letter end
    end
   else previous=nil;previousName=nil;previousLetter=nil end
  else
   missing=missing+1
   if missing>3 then previous=nil;previousName=nil;previousLetter=nil end
  end
  observed=false
  if shopActive then ringKey=nil;return end
  if b(0x7E007D)~=1 or b(0x7E1812)~=0 then ringKey=nil;return end
  local owner,category,cursor,count=b(0x7E1808),b(0x7E1809),b(0x7E180A),b(0x7E180B)
  if owner>2 or category>3 or count<1 or count>16 or cursor>=count then ringKey=nil;return end
  local label
  if category==2 and count==7 then label=config[cursor+1]
  elseif category==3 then
   local owned={}
   for i=0,7 do if b(0x7ECC54+i)~=255 then owned[#owned+1]=weapons[i+1] end end
   if #owned==count then label=owned[cursor+1] end
  elseif category==0 then
   local owned={}
   for i=0,11 do
    local value=b(0x7ECC48+i)
    if value~=255 then
     local id=value%32
     owned[#owned+1]=(items[id+1] or 'Objeto '..id)..', cantidad '..math.floor(value/32)
    end
   end
   if #owned==count then label=owned[cursor+1] end
  end
  local key=owner..':'..category..':'..cursor..':'..count..':'..tostring(label)
  if key~=ringKey then
   local cat=({'Objetos','Magia','Opciones','Armas'})[category+1]
   say('Personaje '..(owner+1)..'. '..cat..'. '..(label or 'Selección '..(cursor+1)..' de '..count)..'.',true,'ring')
   ringKey=key
  end
 end
 api.decodeTile=decodeTile
 return api
end
