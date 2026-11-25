return {
 sha256='70f29ff2870171601333272f64a1b7f8040de3c137f336b7afcc97ec679951ad',
 check=function(mem)
  local expected='Secret of Mana (Esp) '
  for i=1,#expected do if mem.readbyte(0xC0FFC0+i-1)~=expected:byte(i) then return false end end
  return mem.readbyte(0xC0FFD5)==0x21 and mem.readbyte(0xC0FFDE)==0xFC and mem.readbyte(0xC0FFDF)==0x51
 end
}
