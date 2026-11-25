-- SM_ACCESS_PLAY_AUTORUN: no test driver
local source=debug.getinfo(1,'S').source:sub(2)
local root=assert(source:match('^(.*[/\\])'))
dofile(root..'../lector-snes9x.lua')
