-- Play entry point: only reads game state. Test input drivers are never loaded here.
local source=debug.getinfo(1,'S').source:sub(2)
local root=assert(source:match('^(.*[/\\])'))
local reader=dofile(root..'source/reader.lua')({root=root,diagnostics=true,bossPractice=true})
emu.registerafter(reader.tick)
emu.registerexit(reader.close)
reader.say('Secret of Mana access.',true,'startup')
