-- Observe the native terrain projection, not lack of motion or keyboard state.
return function()
 local pending,contacts={},{}
 local lastTime=-1000
 local api={}
 function api.before(actor,vx,vy,intentX,intentY)
  if actor==0 or actor==0x200 or actor==0x400 then
   pending[actor]={vx=vx,vy=vy,ix=intentX,iy=intentY}
  end
 end
 function api.after(actor,vx,vy)
  local p=pending[actor];pending[actor]=nil
  if not p then return end
  local axis
  if p.vx%128>0 and p.ix%128>0 and vx%128==0 then axis=p.ix>=128 and 'wall_left' or 'wall_right'
  elseif p.vy%128>0 and p.iy%128>0 and vy%128==0 then axis=p.iy>=128 and 'wall_up' or 'wall_down' end
  if axis then contacts[actor]=axis end
 end
 function api.reject(actor)
  local p=pending[actor];pending[actor]=nil
  if not p then return end
  if p.vx%128>0 and p.ix%128>0 then contacts[actor]=p.ix>=128 and 'wall_left' or 'wall_right'
  elseif p.vy%128>0 and p.iy%128>0 then contacts[actor]=p.iy>=128 and 'wall_up' or 'wall_down' end
 end
 function api.tick(s,io)
  local actor=s.owner and s.owner*512
  local contact=actor and contacts[actor]
  contacts={};pending={}
  if not s.field or not contact then return end
  local b=io.b
  if b(s.base+0x1C)~=0 or b(s.base+0x60)~=0 or b(s.base+0x0A)~=0 then return end
  if io.time-lastTime<0.35 then return end
  lastTime=io.time
  local pan=contact=='wall_left' and -0.8 or contact=='wall_right' and 0.8 or 0
  io.cue('wall_hit',pan,0.65)
 end
 return api
end
