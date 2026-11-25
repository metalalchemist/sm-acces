-- Semantic text collector. Hooks call observe/boundary; speech happens only in tick.
return function(charset,say,log)
 local lines,line={},{}
 local lastX,lastFrame,lastSpeech=nil,0,nil
 local frame=0
 local boundary=false
 local unknown={}
 local closed=false
 local lastRaw
 local function finishLine()
  local raw=table.concat(line)
  local s=raw:gsub('%s+',' '):match('^%s*(.-)%s*$')
  if s and s~='' then
   local separator=lastRaw and (lastRaw:match('%s$') or raw:match('^%s')) and ' ' or ''
   lines[#lines+1]=separator..s;lastRaw=raw
  end
  line={};lastX=nil
 end
 local function flush()
  finishLine()
  if #lines>0 then
   local text=table.concat(lines)
   lastSpeech=text;say(text,false,'text');lines={};lastRaw=nil
  end
 end
 return {
 observe=function(glyph,x,override)
  if closed then return end
  if lastX and x<=lastX then finishLine() end
  if #line>=256 or #lines>=64 then flush();log('Text buffer bounded') end
  local s=override or charset[glyph]
  if not s then
   s=string.format('[%02X]',glyph)
   if not unknown[glyph] then unknown[glyph]=true;log('Unknown glyph '..s) end
  end
  line[#line+1]=s;lastX=x;lastFrame=frame
 end,
 boundary=function() boundary=true end,
 tick=function()
  frame=frame+1
  if boundary or (#line>0 or #lines>0) and frame-lastFrame>=48 then flush() end
  boundary=false
 end,
 repeatLast=function() if lastSpeech then say(lastSpeech,true,'repeat') end end,
 reset=function() lines={};line={};lastX=nil;boundary=false;lastRaw=nil end,
 close=function() closed=true;lines={};line={} end
 }
end
