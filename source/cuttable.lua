-- Sword-cuttable terrain only: C1 (sword), C8 (sword/axe); never C2 (axe).
return function(geometry,profiles,terrain)
 local nextCue,lastKey=0,nil
 local sizes={[128]={896,1312},[129]={1024,1152},[130]={640,768},[131]={832,832}}
 return function(s,io)
  local b,w=io.b,io.w
  local size=sizes[s.map]
  if not s.field or not size or w(0x7E00C0)~=size[1] or w(0x7E00C2)~=size[2]
   or b(s.base+0x68)~=1 or b(s.base+0x1C)~=0 or b(s.base+0x60)~=0 or b(s.base+0x0A)~=0
   or b(s.base+0x1A)~=0 or b(s.base+0x1B)~=0 or b(s.base+0x19B)~=0 then lastKey=nil;return end
  local floor=b(s.base+0x0B)
  local layer=floor>=128 and 0x7F4000 or 0x7F0000
  local attrs=floor>=128 and 0x7FBC00 or 0x7FB800
  local facing=b(s.base+0x10)
  local best,distance
  local function clear(x,y,tx,ty)
   local steps=math.ceil(math.sqrt((x-s.x)^2+(y-s.y)^2)/2)
   for i=1,steps do
    local px,py=s.x+(x-s.x)*i/steps,s.y+(y-s.y)*i/steps
    local cx,cy=math.floor(px/16),math.floor(py/16)
    if cx==tx and cy==ty then return true end
    local a=attrs+4*b(layer+cy*128+cx)
    local kind=b(a)%8
    if kind==3 or math.floor(b(a)/8)%2==1 or kind==1 and floor%4==2 or kind==2 and floor%4==1
     or terrain.diagonal(b(a+2),px%16,py%16) then return false end
   end
   return true
  end
  for ty=math.max(0,math.floor(s.y/16)-3),math.min(size[2]/16-1,math.floor(s.y/16)+3) do
   for tx=math.max(0,math.floor(s.x/16)-3),math.min(size[1]/16-1,math.floor(s.x/16)+3) do
    local tile=b(layer+ty*128+tx);local a=attrs+4*tile;local kind=b(a)%8
    if (b(a+2)==0xC1 or b(a+2)==0xC8) and not (kind==1 and floor%4==2 or kind==2 and floor%4==1) then
     local x,y=tx*16+8,ty*16+8;local dx,dy=x-s.x,y-s.y
     local front=facing==0 and dy<0 or facing==1 and dy>0 or facing==2 and dx>0 or facing==130 and dx<0
     local d=dx*dx+dy*dy
     if front and (not distance or d<distance) and clear(x,y,tx,ty)
      and geometry.covered(profiles,facing,s.x,s.y,{x=x,y=y,width=16,height=16}) then
      best=s.map..':'..layer..':'..tx..':'..ty..':'..tile;distance=d
     end
    end
   end
  end
  if best and (best~=lastKey or io.time>=nextCue) then io.cue('cuttable',facing==2 and 0.7 or facing==130 and -0.7 or 0,0.32);nextCue=io.time+0.9 end
  lastKey=best
 end
end
