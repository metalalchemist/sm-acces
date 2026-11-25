-- Only the isolated manager defines these values. Never run in normal play.
assert(type(SNES_TEST_PROJECT)=='string' and type(SNES_PROJECT_ROOT)=='string')
assert(type(SNES_TEST_OUTPUT)=='string' and SNES_TEST_OUTPUT:sub(1,#SNES_PROJECT_ROOT)==SNES_PROJECT_ROOT)
local out=SNES_TEST_OUTPUT
local frames=0
-- Prevent the test copy from reacting to the player's normal keyboard/gamepad.
emu.registerbefore(function()
 joypad.set(1,{A=false,B=false,X=false,Y=false,L=false,R=false,
  up=false,down=false,left=false,right=false,start=false,select=false})
end)
emu.registerafter(function()
 frames=frames+1
 if frames==120 then
  local f=assert(io.open(out..'smoke.txt','w'))
  f:write('PASS project=',SNES_TEST_PROJECT,' frames=',frames,'\n')
  f:close()
  local ram=assert(io.open(out..'smoke-ram.bin','wb'))
  for offset=0,131071,256 do
   ram:write(string.char(unpack(memory.readbyterange(0x7E0000+offset,256))))
  end
  ram:close()
  if gui and gui.gdscreenshot then
   local shot=assert(io.open(out..'smoke.gd','wb'))
   shot:write(gui.gdscreenshot());shot:close()
  end
 end
end)
