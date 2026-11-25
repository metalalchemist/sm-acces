-- Experimental passive directions for the first map. Never presses a button.
return function()
 local path,index,blocked={},1,{}
 local map,goal,story
 local lastInstruction
 local api={}
 function api.clear() path={};index=1;lastInstruction=nil end
 function api.build(s,mem,avoid)
  if not s.field or s.map~=128 then return 'La ruta experimental está disponible en las cascadas de Potos, con el personaje libre.' end
  local b,w=mem.readbyte,mem.readword
  local currentStory=b(0x7ECF10)%16
  if map~=s.map or story~=currentStory or not avoid then blocked={} end
  if avoid and path[index] then blocked[path[index].x..':'..path[index].y]=true end
  map,story=s.map,currentStory
  goal=story==0 and {x=31,y=58,name='espada'} or {x=47,y=50,name='salida al bosque'}
  local layer=b(s.base+0x0B)>=128 and 0x7F4000 or 0x7F0000
  local attrs=layer==0x7F4000 and 0x7FBC00 or 0x7FB800
  local sx,sy=math.floor(s.x/16),math.floor(s.y/16)
  local function key(x,y,h) return x..':'..y..':'..h end
  local start={x=sx,y=sy,h=b(s.base+0x0B)%4}
  local queue={start};local q=1;local seen={[key(sx,sy,start.h)]=true};local found
  while q<=#queue and q<=20000 do
   local node=queue[q];q=q+1
   if node.x==goal.x and node.y==goal.y then found=node;break end
   for _,delta in ipairs({{1,0},{0,1},{-1,0},{0,-1}}) do
    local x,y=node.x+delta[1],node.y+delta[2]
    if x>=0 and y>=0 and x<56 and y<82 and not blocked[x..':'..y] then
     local tile=b(layer+y*128+x);local a,a2=b(attrs+4*tile),b(attrs+4*tile+2)
     local kind=a%8;local cut=story>=1 and (a2==0xC1 or a2==0xC8)
     local shape=math.floor(a2/16)==1 and a2%8>=4
     local bad=(kind==1 and node.h==2) or (kind==2 and node.h==1)
     local eventBlocked=story==0 and (tile==0xC0 or tile==0xC1)
     if not eventBlocked and (kind~=3 or cut) and not bad and not shape then
      local h=kind<3 and kind or node.h;local k=key(x,y,h)
      if not seen[k] then
       seen[k]=true;queue[#queue+1]={x=x,y=y,h=h,cut=cut,prev=node}
      end
     end
    end
   end
  end
  api.clear()
  if not found then return 'No encontré una ruta con los pasos permitidos. Control F4 reinicia el cálculo; Control F7 consulta la dirección directa.' end
  while found.prev do table.insert(path,1,found);found=found.prev end
  if #path==0 then return 'Estás junto a la '..goal.name..'.' end
  lastInstruction=api.describe(s)
  return 'Ruta experimental hacia la '..goal.name..'. Sigue las indicaciones; Control F8 evita un paso que no puedas cruzar. '..lastInstruction
 end
 function api.describe(s)
  local p=path[index]
  if not p then return 'Fin de la ruta.' end
  local dx,dy=p.x-math.floor(s.x/16),p.y-math.floor(s.y/16)
  local dir=math.abs(dx)>math.abs(dy) and (dx<0 and 'oeste' or 'este') or (dy<0 and 'norte' or 'sur')
  if p.cut then return 'Maleza al '..dir..'. Mira hacia ella y pulsa B para cortarla.' end
  return 'Avanza al '..dir..'.'
 end
 function api.tick(s,say)
  if not s.field then return end
  if s.map~=map then api.clear();return end
  if s.story~=story then api.clear();return end
  local p=path[index]
  if p and math.abs(s.x-(p.x*16+8))<=5 and math.abs(s.y-(p.y*16+8))<=5 then
   repeat index=index+1;p=path[index] until not p or math.floor(s.x/16)~=p.x or math.floor(s.y/16)~=p.y
   local nextMessage=api.describe(s)
   if p and nextMessage~=lastInstruction then say(nextMessage,true,'route');lastInstruction=nextMessage
   elseif not p then say('Llegaste al punto de la '..goal.name..'.',false,'route') end
  end
 end
 return api
end
