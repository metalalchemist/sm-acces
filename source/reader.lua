-- Secret of Mana Sayans ROM profile. No controller input and no memory writes.
return function(opts)
 local root=assert(opts.root)
 local out=opts.output or root
 local mem=opts.memory or memory
 local frame=0
 local diagnosticTime=-1000
 local function b(a) return mem.readbyte(a) end
 local function w(a) return b(a)+256*b(a+1) end
 local function log(s)
  local f=io.open(out..'reader.log','a');if f then f:write(frame,'\t',s,'\n');f:close() end
 end
 assert(dofile(root..'source/profile.lua').check(mem),'ROM incompatible con el perfil español de Secret of Mana')
 local voice,audio
 local closed=false
 local hooks={}
 local function hook(address,signature,fn)
  for i,v in ipairs(signature) do
   if b(address+i-1)~=v then log(string.format('INCOMPATIBLE %06X',address));return false end
  end
  if opts.hook then opts.hook(address,fn) else mem.registerexec(address,1,fn) end
  hooks[#hooks+1]=address;return true
 end
 local function say(text,interrupt,kind)
  log((kind or 'speech')..'\t'..text)
  if opts.say then opts.say(text,interrupt,kind)
  elseif voice then local ok,err=pcall(voice.speak,text,interrupt~=false);if not ok then log('VOICE ERROR '..tostring(err)) end end
 end
 if not opts.muted then
  local ok,result=pcall(function()
   local module=assert(package.loadlib(root..'runtime/chrono_prism_v2.dll','luaopen_chrono_prism'))()
   log('Voice backend '..tostring(module.init()));return module
  end)
  if ok then voice=result else log('VOICE UNAVAILABLE '..tostring(result)) end
 end
 -- Audio uses the existing Lua 5.1 native mixer, with no game-specific addresses.
 if not opts.muted or opts.testAudio then
  local candidateAudio
  local ok,result=pcall(function()
   local module=assert(package.loadlib(root..'runtime/mana_audio_full.dll','luaopen_chrono_audio'))()
   candidateAudio=module
   module.init()
   for i,name in ipairs({'item','enemy','bell_timing','object_hit','sign','wall_hit','door','wall_up','wall_down','wall_left','wall_right','range_in','range_out','furniture','person','charge_step','charge_max','boss_prepare','boss_claw','boss_projectile','boss_magic','signpost','teleporte','stairs'}) do module.load(i-1,root..'runtime/sounds/'..name..'.wav') end
   return module
  end)
  if ok then audio=result else
   if candidateAudio then pcall(candidateAudio.shutdown)end
   log('AUDIO UNAVAILABLE '..tostring(result))
  end
 end
 local function cue(name,pan,volume)
  log('cue\t'..name)
  if opts.cue then opts.cue(name,pan,volume) end
  local ids={interactive=0,enemy=1,ready=2,hit=3,threat=4,wall_hit=5,exit=6,range_in=11,range_out=12,cuttable=13,charge_step=15,charge_max=16,boss_prepare=17,boss_claw=18,boss_projectile=19,boss_magic=20}
  if audio and ids[name] then
   local slot=name=='wall_hit' and 7 or (name=='range_in' or name=='range_out') and 14 or name=='cuttable' and 15 or ids[name]>=15 and ids[name]+2 or ids[name]
   audio.set(slot,ids[name],opts.muted and 0 or 1,pan or 0,false)
  end
 end
 local charset=dofile(root..'source/charset.lua')
 local text=dofile(root..'source/text.lua')(charset,say,log)
 local menus=dofile(root..'source/menus.lua')(charset,say,log)
 local shops=dofile(root..'source/shops.lua')(charset,say)
 local choices=dofile(root..'source/choices.lua')(charset,say)
 local panels=dofile(root..'source/submenus.lua')(dofile(root..'source/menu-data.lua')(charset),say)
 local saveFiles=dofile(root..'source/save-files.lua')(dofile(root..'source/menu-data.lua')(charset),say)
 hook(0xC07E62,{0xE2,0x20,0xA9,0x02,0x0C,0x03,0x18},shops.cancel)
 local function observeMenus()menus.observe();panels.observe();saveFiles.observe()end
 hook(0xC0281E,{0x48,0xA9,0x7E,0x48,0xAB,0xA9,0x01},observeMenus)
 hook(0xC020A7,{0xDA,0x5A,0x8B,0x48,0x08,0xE2,0x20},observeMenus)
 hook(0xC76CA7,{0xA9,0x00,0xEB,0xAD,0x2B,0xA2},function()panels.commit(mem,'behavior')end)
 hook(0xC76FA7,{0xA2,0x03,0x00,0xBD,0x2E,0xA2},function()panels.commit(mem,'bindings')end)
 hook(0xC76401,{0xAD,0x02,0xA2,0xC9,0x08},function()panels.details(mem)end)
 local textEnabled=hook(0xC017CE,{0x9D,0xA4,0xA1,0xE8,0xEE,0xCE,0xA1},function()
  if b(0x7E007D)~=1 then
   local glyph=mem.getregister('a')%256
   local override=menus.inName(mem) and (glyph==0xB1 and 'W' or glyph==0x97 and 'w') or nil
   text.observe(glyph,mem.getregister('x'),override)
  end
 end)
 if textEnabled then
  hook(0xC012BE,{0x9C,0x5F,0xA1,0x9C,0x5E,0xA1},text.boundary)
  hook(0xC00611,{0xA9,0x00,0xEB,0xAD,0x5E,0xA1},text.boundary)
  hook(0xC00F6C,{0xA9,0x50,0x8D,0x70,0xA1},text.boundary)
 end
 local model={}
 local game=opts.model or dofile(root..'source/game.lua')(dofile(root..'source/geometry.lua'))
 local weapons=dofile(root..'source/weapon-feedback.lua')()
 local mantis=opts.bossPractice and dofile(root..'source/mantis.lua')(dofile(root..'source/geometry.lua'),dofile(root..'source/sword-boxes.lua'))or nil
 if mantis and not mantis.compatible(b)then log('INCOMPATIBLE Mantis profile');mantis=nil end
 local navigation=dofile(root..'source/navigation.lua')()
 local references=dofile(root..'source/references.lua')()
 local collisions=dofile(root..'source/collisions.lua')()
 local terrain=dofile(root..'source/terrain.lua')()
 local cuttable=dofile(root..'source/cuttable.lua')(dofile(root..'source/geometry.lua'),dofile(root..'source/sword-boxes.lua'),terrain)
 local proximityTime=-1000
 local switchSound=false
 local function proximity(s,now)
  local enabled=s.field and s.base and b(s.base+0x0A)==0 and b(s.base+0x1C)==0 and b(s.base+0x60)==0
  if enabled and now-proximityTime<0.2 then return end
  proximityTime=now
  local walls=enabled and terrain.scan(s,b,w) or {}
  for i,dir in ipairs({'up','down','left','right'}) do
   local distance=walls[dir]
   local volume=distance and 1.0*(0.08+0.92*(1-distance/48)^1.5) or 0
   local pan=dir=='left' and -0.8 or dir=='right' and 0.8 or 0
   -- Slots 8..11 never interrupt collision slot 7 or item/enemy slots 0..6.
   if audio then audio.set(7+i,6+i,opts.muted and 0 or volume,pan,true) end
   if opts.proximity then opts.proximity(dir,distance,volume,pan) end
  end
  local exit
  local item
  local itemDistance
  for _,r in ipairs(s.references or {}) do
   if r.kind=='exit' then
    local nearer=exit and(r.key:find('castillo',1,true)==1 or r.key:find('gaia33:',1,true)==1)and (r.x-s.x)^2+(r.y-s.y)^2<(exit.x-s.x)^2+(exit.y-s.y)^2
    if not exit or s.selectedReference==r.key or s.selectedReference~=exit.key and nearer then exit=r end
   end
   if (r.kind=='interactive' or r.key=='espada') and r.samePlane~=false then
    local distance=(r.x-s.x)^2+(r.y-s.y)^2
    if not item or s.selectedReference==r.key or s.selectedReference~=item.key and distance<itemDistance then item=r;itemDistance=distance end
   end
  end
  for i,key in ipairs({item and item.key or '',exit and exit.key or ''}) do
   local volume,pan=0,0
   if enabled then
    for _,r in ipairs(s.references or {}) do
     if r.key==key then
      local dx,dy=r.x-s.x,r.y-s.y;local distance=math.sqrt(dx*dx+dy*dy)
      if distance<=64 then volume=1.0*(0.08+0.92*(1-distance/64)^1.5);pan=math.max(-1,math.min(1,dx/64)) end
     end
    end
   end
   if audio then audio.set(11+i,i==1 and 0 or exit and exit.stairs and 23 or 6,opts.muted and 0 or volume,pan,true) end
  end
  local person
  for _,r in ipairs(s.references or {}) do
   if r.kind=='person' and r.samePlane~=false and (not person or s.selectedReference==r.key) then person=r end
  end
  local personVolume,personPan=0,0
  if enabled and person then
   local dx,dy=person.x-s.x,person.y-s.y;local distance=math.sqrt(dx*dx+dy*dy)
   if distance<=64 then personVolume=1.0*(0.08+0.92*(1-distance/64)^1.5);personPan=math.max(-1,math.min(1,dx/64)) end
  end
  if audio then audio.set(16,14,opts.muted and 0 or personVolume,personPan,true) end
  local sign,signDistance
  for _,r in ipairs(s.references or {})do
   if r.kind=='signpost' and r.samePlane~=false then
    local d=(r.x-s.x)^2+(r.y-s.y)^2
    if not sign or s.selectedReference==r.key or s.selectedReference~=sign.key and d<signDistance then sign=r;signDistance=d end
   end
  end
  local signVolume,signPan=0,0
  if enabled and sign then
   local dx,dy=sign.x-s.x,sign.y-s.y;local distance=math.sqrt(dx*dx+dy*dy)
   if distance<=64 then signVolume=0.08+0.92*(1-distance/64)^1.5;signPan=math.max(-1,math.min(1,dx/64))end
  end
  if audio then audio.set(5,21,opts.muted and 0 or signVolume,signPan,true)end
  local button,best
  if enabled then for _,r in ipairs(s.references or {})do
   if r.kind=='switch' and r.samePlane~=false then
    local d=(r.x-s.x)^2+(r.y-s.y)^2
    if not button or r.key==s.selectedReference or button.key~=s.selectedReference and d<best then button=r;best=d end
   end
  end end
  local switchVolume,switchPan=0,0
  if button and best<=64*64 then switchVolume=0.08+0.92*(1-math.sqrt(best)/64)^1.5;switchPan=math.max(-1,math.min(1,(button.x-s.x)/64))end
  if audio and (button or switchSound)then audio.set(23,22,opts.muted and 0 or switchVolume,switchPan,true)end
  switchSound=button~=nil
  if opts.switchProximity then opts.switchProximity(button and button.key,switchVolume,switchPan)end
 end
 hook(0xC0D74F,{0xE2,0x20,0xC2,0x10,0xA9,0x7F},function()
  -- The party-window routine leaves X on the last companion. DP10 owns this move.
  local actor=w(0x7E0010)
  if actor<=0x400 and actor%512==0 then
   collisions.before(actor,b(0x7E001E),b(0x7E001F),b(0x7EE006+actor),b(0x7EE007+actor))
  end
 end)
 hook(0xC0D890,{0xE2,0x20,0xE0,0x00,0x06},function()
  collisions.after(w(0x7E0010),b(0x7E001E),b(0x7E001F))
 end)
 hook(0xC0D7B0,{0x60,0xC2,0x20,0x64,0x1E,0x38,0x60},function()
  collisions.reject(w(0x7E0010))
 end)
 local previousKeys={}
 local function pressed(keys,name) return keys[name] and not previousKeys[name] end
 local function tick()
  if closed then return end
  frame=frame+1
  text.tick()
  shops.tick(mem)
  choices.tick(mem)
  saveFiles.tick(mem)
  panels.tick(mem,shops.active)
  menus.tick(mem,shops.active or panels.active or saveFiles.active)
  if mantis and w(0x7E00DC)==260 then model.uncoveredMap=260 end
  game.tick(model,{b=b,w=w,say=say,cue=cue,log=log,frame=frame,time=audio and audio.now() or frame/60})
  weapons.tick(model,{b=b,cue=cue})
  if mantis then mantis.tick(model,{b=b,w=w,say=say,cue=cue,time=audio and audio.now()or frame/60})end
  collisions.tick(model,{b=b,cue=cue,time=audio and audio.now() or frame/60})
  local now=audio and audio.now() or frame/60
  cuttable(model,{b=b,w=w,time=now,cue=cue})
  proximity(model,now)
  if opts.diagnostics and now-diagnosticTime>=1 then
   diagnosticTime=now
   local f=io.open(root..'estado-actual.txt','w')
   if f then
    f:write(os.date('!%Y-%m-%dT%H:%M:%SZ'),' map=',model.map or -1,' x=',model.x or -1,' y=',model.y or -1,
     ' field=',tostring(model.field),' facing=',model.base and b(model.base+0x10) or -1,' story=',model.story or -1,'\n')
    for _,r in ipairs(model.references or {}) do f:write(r.key,' ',r.name,' x=',r.x,' y=',r.y,'\n') end
    f:close()
   end
  end
  navigation.tick(model,say)
  local keys=input and input.get and input.get() or {}
  local ctrl=(keys.control or keys.leftcontrol or keys.rightcontrol) and not keys.alt and not keys.shift
  if ctrl and pressed(keys,'F1') then
   if saveFiles.active then saveFiles.repeatLast()elseif choices.active then choices.repeatLast()elseif shops.active then shops.repeatLast()elseif panels.active then panels.repeatLast()else text.repeatLast()end
  end
  if ctrl and pressed(keys,'F9') then
   if model.field then
    say('Abre el menú del juego antes de consultar la guía de sonidos.',true,'sound-guide')
   elseif audio and audio.guide then
    local entries=dofile(root..'source/sound-catalog.lua')
    audio.guide(entries)
   else say('La guía de sonidos necesita el módulo de audio activo.',true,'sound-guide') end
  end
  if ctrl and pressed(keys,'F5') then say(references.cycle(model,-1),true,'selection') end
  if ctrl and pressed(keys,'F6') then say(references.cycle(model,1),true,'selection') end
  if ctrl and pressed(keys,'F7') then say(references.describe(model),true,'orientation') end
  if ctrl and pressed(keys,'F4') then say(navigation.build(model,mem,false),true,'route') end
  if ctrl and pressed(keys,'F8') then say(navigation.build(model,mem,true),true,'route') end
  if ctrl and pressed(keys,'F3') and model.field then say(weapons.describe(model,b),true,'weapon')end
  if ctrl and pressed(keys,'F2') then
   local base=panels.selectedOwner and 0x7EE000+512*panels.selectedOwner or model.base or 0x7EE000
   if b(base)==1 and w(base+0x184)>0 then say('Vida '..w(base+0x182)..' de '..w(base+0x184)..'. Magia '..b(base+0x186)..' de '..b(base+0x187)..'.',true,'status') end
  end
  previousKeys=keys
 end
 log('START Mana reader 01 '..os.date('!%Y-%m-%dT%H:%M:%SZ')..' text='..tostring(textEnabled)..' muted='..tostring(opts.muted))
 return {tick=tick,text=text,cue=cue,say=say,log=log,model=model,audioActive=audio~=nil,
 close=function()
  if closed then return end;closed=true;text.close()
  if not opts.hook then for _,a in ipairs(hooks) do mem.registerexec(a,1,nil) end end
  if audio then audio.shutdown() end;if voice then voice.shutdown() end
  log('STOP Mana reader')
 end}
end
