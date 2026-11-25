"""Reuse only the verified emulator-console UI helper, with Mana's own identity."""
from pathlib import Path

root=Path(__file__).resolve().parent
original=(root.parent/'chrono-access/recargar-lector.ps1').read_text(encoding='utf-8-sig')
helper=original[original.index('Add-Type -TypeDefinition'):original.index('$taskEmulator =')]
helper=helper.replace('ChronoLuaWindows','ManaLuaWindows')
footer=r'''
$root=$PSScriptRoot
$session=Get-Content -LiteralPath (Join-Path $root 'player/session.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if($session.kind -ne 'sm-access-play' -or $session.root -ne $root){throw 'Sesion ajena a Mana'}
$play=Get-Process -Id $session.processId -ErrorAction Stop
$exe=Join-Path $root 'player/snes9x.exe'
if($play.Path -ne $exe -or $play.StartTime.ToUniversalTime().Ticks -ne $session.startTicks){throw 'La sesion de Mana cambio'}
$allowed=@((Join-Path $root 'lector-snes9x.lua'),(Join-Path $root 'player/game.lua'))
$buttons=@()
foreach($window in [ManaLuaWindows]::Windows($play.Id)){
 $children=[ManaLuaWindows]::Children($window)
 $matches=@($children|Where-Object {
  if([ManaLuaWindows]::Class($_) -ne 'Edit'){return $false}
  $text=[ManaLuaWindows]::Text($_).Trim('"').Replace('/','\')
  if($text -eq 'game.lua'){$text=Join-Path $root 'player/game.lua'}
  $text -in $allowed
 })
 if($matches.Count){$buttons+=@($children|Where-Object {
  [ManaLuaWindows]::Class($_) -eq 'Button' -and [ManaLuaWindows]::Text($_).Replace('&','').Trim() -match '^(Re.?start|Re.?run|Run|Reload)( Script)?$'
 })}
}
if($buttons.Count -ne 1){throw 'No se encontro una consola Lua unica del lector. No se cargo ni reinicio la partida.'}
$path=Join-Path $root 'reader.log'
$before=if(Test-Path -LiteralPath $path){[IO.File]::ReadAllText($path).Length}else{0}
[ManaLuaWindows]::Click($buttons[0])
for($attempt=0;$attempt -lt 100;$attempt++){
 Start-Sleep -Milliseconds 50
 if(Test-Path -LiteralPath $path){
  $text=[IO.File]::ReadAllText($path)
  if($text.Length -ge $before -and $text.Substring($before).Contains('START Mana reader')){
   Write-Output 'Recarga de Mana confirmada en reader.log. No se reinicio ni cargo una partida.';return
  }
 }
}
throw 'La consola recibio la recarga, pero no se confirmo el lector. No se cargo ninguna partida.'
'''
footer='\n'.join('  $text=[ManaLuaWindows]::Text($_).Trim([char]34).Replace([char]47,[char]92)' if line.strip().startswith('$text=[ManaLuaWindows]::Text') else line for line in footer.splitlines())
(root/'recargar-lector.ps1').write_text("$ErrorActionPreference='Stop'\n"+helper+footer,encoding='utf-8-sig')
test_footer=footer.replace("'player/session.json'","'test/emulator/active.json'")
test_footer=test_footer.replace('$root=$PSScriptRoot','$root=Split-Path -Parent $PSScriptRoot')
test_footer=test_footer.replace("if($session.kind -ne 'sm-access-play' -or $session.root -ne $root){throw 'Sesion ajena a Mana'}",
 "if($session.case -ne 'walls03-check'){throw 'Caso de prueba distinto'}")
test_footer=test_footer.replace("'player/snes9x.exe'","'test/emulator/snes9x.exe'")
test_footer=test_footer.replace("'player/game.lua'","'test/emulator/game.lua'")
test_footer=test_footer.replace("'lector-snes9x.lua'","'test/walls03.lua'")
test_footer=test_footer.replace("'reader.log'","'test/walls03-check/reader.log'")
(root/'test/reload-walls03.ps1').write_text("$ErrorActionPreference='Stop'\n"+helper+test_footer,encoding='utf-8-sig')
print('Mana reload helper created with its own process/session guard')
