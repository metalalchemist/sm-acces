local function signed(n) return n>=128 and n-256 or n end
local function box(b,w,actor,offset)
 local width,height=b(actor+offset+2),b(actor+offset+3)
 if width==0 or height==0 then return nil end
 return {x=w(actor+2)+signed(b(actor+offset)),y=w(actor+4)+signed(b(actor+offset+1)),width=width,height=height}
end
local function overlaps(a,b)
 return a~=nil and b~=nil and 2*math.abs(a.x-b.x)<a.width+b.width and 2*math.abs(a.y-b.y)<a.height+b.height
end
local function covered(profiles,facing,x,y,target)
 local count=0
 for _,profile in ipairs(profiles) do
  if profile.facing==facing then
   count=count+1;local reachable=false
   for _,v in ipairs(profile.boxes) do
    if overlaps({x=x+v[1],y=y+v[2],width=v[3],height=v[4]},target) then reachable=true;break end
   end
   if not reachable then return false end
  end
 end
 return count==(profiles.variantCount or 3) and true or nil
end
return {box=box,overlaps=overlaps,covered=covered}
