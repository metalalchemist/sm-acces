-- Mana terrain only: first map, 16-pixel tiles, 128-byte native row stride.
-- Predict straight clearance; native corner sliding/ramp deflection is not a route.
return function()
 local api={}
 local folder=debug.getinfo(1,'S').source:sub(2):match('^(.*[/\\])')or''
 local pandora=dofile(folder..'pandora.lua')()
 local castle=dofile(folder..'castle.lua')()
 local gaia=dofile(folder..'gaia.lua')()
 function api.diagonal(shape,x,y)
  if math.floor(shape/16)~=1 or shape%8<4 then return false end
  local kind=shape%8
  if kind==4 then return y>=x end
  if kind==5 then return x>=y end
  if kind==6 then return x+y<=15 end
  return x+y>=15
 end
 function api.scan(s,b,w)
  local dimensions={[16]={1120,1856},[19]={768,704},[159]={384,384},[128]={896,1312},[129]={1024,1152},[130]={640,768},[131]={832,832},[132]={768,640},[136]={960,1024},[137]={448,512},[139]={640,1152},[279]={512,384}}
  local expected=dimensions[s.map]or pandora.sizes[s.map]or castle.sizes[s.map]or gaia.sizes[s.map]
  if not s.field or not expected or not s.base then return {} end
  if pandora.sizes[s.map]and not pandora.supported(s,w)then return {}end
  if castle.sizes[s.map]and not castle.supported(s,w)then return {}end
  if gaia.sizes[s.map]and not gaia.supported(s,w)then return {}end
  if s.map==279 and w(0x7ECD08)~=132 then return {} end
  local width,height=w(0x7E00C0),w(0x7E00C2)
  if width~=expected[1] or height~=expected[2] then return {} end
  local floor=b(s.base+0x0B)
  local function tileAt(x,y,upper)
   -- Pandora's horizontal seam wraps natively; it is not a terrain wall.
   if s.map==144 then x=x%width end
   if x<0 or y<0 or x>=width or y>=height then return nil end
   local layer=upper and 0x7F4000 or 0x7F0000
   local attrs=upper and 0x7FBC00 or 0x7FB800
   local tile=b(layer+math.floor(y/16)*128+math.floor(x/16))
   local a=attrs+4*tile
   return {kind=b(a)%8,switch=math.floor(b(a)/8)%2==1,shape=b(a+2)}
  end
  local function blocked(x,y,state)
   local tile=tileAt(x,y,state.upper)
   if not tile then return true end
   return tile.kind==3 or tile.kind==1 and state.height==2 or tile.kind==2 and state.height==1
    or api.diagonal(tile.shape,x%16,y%16)
  end
  local result={}
  for _,dir in ipairs({{'up',0,-1,0,-4,{-6,0,6}}, {'down',0,1,0,4,{-6,0,6}},
                      {'left',-1,0,-6,0,{-4,0,4}}, {'right',1,0,6,0,{-4,0,4}}}) do
   local best
   local state={height=floor%4,upper=floor>=128,latch=math.floor(floor/8)%2==1}
   for d=0,48 do
    local cx,cy=s.x+dir[2]*d,s.y+dir[3]*d
    local centre=tileAt(cx,cy,state.upper)
    if not centre then best=d;break end
    -- The native centre switch bypasses the leading-edge test, then changes layer.
    if not centre.switch then
     for _,side in ipairs(dir[6]) do
      local x=cx+dir[4]+(dir[2]==0 and side or 0)
      local y=cy+dir[5]+(dir[3]==0 and side or 0)
      if blocked(x,y,state) then best=d;break end
     end
    end
    if best then break end
    if centre.switch then
     if not state.latch then state.upper=not state.upper;state.height=0 end
     state.latch=true
    else
     state.latch=false
     if centre.kind<3 then state.height=centre.kind end
    end
   end
   if best then result[dir[1]]=best end
  end
  return result
 end
 return api
end
