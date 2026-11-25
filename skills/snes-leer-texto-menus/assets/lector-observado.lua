-- Supply a game-specific adapter; this file has no universal SNES addresses.
return function(memory, say, log, adapter)
 assert(type(adapter.address)=='number' and type(adapter.read)=='function')
 assert(type(adapter.signature)=='table' and #adapter.signature>0)
 for i, expected in ipairs(adapter.signature)do
  if memory.readbyte(adapter.address+i-1)~=expected then
   log('Lector no disponible: firma incompatible.')
   return function()end
  end
 end
 local observed, pending=false,nil
 local context,key,missing=nil,nil,0
 local limit=adapter.missingFrames or 6
 assert(limit>=1)
 memory.registerexec(adapter.address,1,function()
  observed=true
  -- Return a fresh, small snapshot. Do not speak, yield or perform I/O here.
  pending=adapter.read(memory)
 end)
 return function()
  if observed and pending then
   local s=pending
   missing=0
   if s.context~=nil and s.key~=nil and type(s.text)=='string' and s.text~='' then
    if s.context~=context or s.key~=key then
     say(s.text,s.interrupt~=false)
     context,key=s.context,s.key
    end
   end
  else
   missing=missing+1
   if missing>=limit then context,key=nil,nil end
  end
  observed,pending=false,nil
 end
end
