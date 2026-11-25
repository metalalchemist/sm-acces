param([switch]$PrepareOnly)
$ErrorActionPreference='Stop'
$root=$PSScriptRoot
$manifest=Get-Content -LiteralPath (Join-Path $root 'test/project.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if($manifest.project_id -ne 'sm-access'){throw 'Manifiesto de otro proyecto'}
function Resolve-ProjectPath([string]$value){
 if([IO.Path]::IsPathRooted($value)){return [IO.Path]::GetFullPath($value)}
 return [IO.Path]::GetFullPath((Join-Path $root $value))
}
$rom=Resolve-ProjectPath $manifest.rom_path
$emulatorDir=Resolve-ProjectPath $manifest.emulator_dir
$configTemplate=Resolve-ProjectPath $manifest.config_template
if(-not(Test-Path -LiteralPath $rom)){throw "Falta la ROM configurada en test/project.json: $rom"}
if((Get-FileHash -LiteralPath $rom).Hash -ne $manifest.rom_sha256){throw 'La ROM no coincide con la traduccion soportada'}
$player=Join-Path $root 'player'
$saves=Join-Path $root 'partidas'
$exe=Join-Path $player 'snes9x.exe'
$running=@(Get-Process -Name snes9x -ErrorAction SilentlyContinue | Where-Object {$_.Path -eq $exe})
if($running.Count){
 if(-not $PrepareOnly){& (Join-Path $root 'habilitar-controles.ps1');& (Join-Path $root 'mostrar-ventana.ps1')}
 Write-Output 'Secret of Mana ya esta abierto en su copia de juego.';return
}
New-Item -ItemType Directory -Force -Path $player,$saves | Out-Null
foreach($name in @('snes9x.exe','lua51.dll','lua5.1.dll','Valid.Ext')){
 $src=Join-Path $emulatorDir $name
 $dest=Join-Path $player $name
 if(-not(Test-Path -LiteralPath $dest)){
  if(-not(Test-Path -LiteralPath $src)){throw "Falta $name en player y en la fuente configurada: $src"}
  Copy-Item -LiteralPath $src -Destination $dest
 }elseif(Test-Path -LiteralPath $src){
  if((Get-FileHash -LiteralPath $dest).Hash -ne (Get-FileHash -LiteralPath $src).Hash){throw "Binario diferente en player: $name; no se sobrescribe"}
 }
}
$configPath=Join-Path $player 'snes9x.conf'
if(Test-Path -LiteralPath $configPath){$config=[IO.File]::ReadAllText($configPath)}
else{
 if(-not(Test-Path -LiteralPath $configTemplate)){throw "Falta snes9x.conf en player y la plantilla configurada: $configTemplate"}
 $config=[IO.File]::ReadAllText($configTemplate)
}
$settings=@{Mute='FALSE';PauseWhenInactive='FALSE';'Input:Background'='OFF';'Input:BackgroundKeyHotkeys'='OFF';'Dir:Lock'='TRUE'}
foreach($pair in @(@('Dir:SRAM',$saves),@('Dir:Savestates',$saves),@('Dir:Roms',(Join-Path $player 'Roms')),
 @('Dir:Cheats',(Join-Path $player 'Cheats')),@('Dir:Patches',(Join-Path $player 'Patches')),
 @('Dir:Screenshots',(Join-Path $root 'capturas')),@('Dir:Movies',(Join-Path $player 'Movies')),
 @('Dir:SPCs',(Join-Path $player 'SPCs')),@('Dir:Bios',(Join-Path $player 'BIOS')),@('Dir:SatData',(Join-Path $player 'SatData')))){
 New-Item -ItemType Directory -Force -Path $pair[1] | Out-Null
 $settings[$pair[0]]=$pair[1]
}
foreach($key in $settings.Keys){
 $pattern='(?m)^(\s*'+[regex]::Escape($key)+'\s*=\s*)[^\r\n#]+'
 $value=$settings[$key]
 if([regex]::IsMatch($config,$pattern)){$config=[regex]::Replace($config,$pattern,{param($m)$m.Groups[1].Value+$value+' '}.GetNewClosure())}
 else{$config+="`r`n$key = $value`r`n"}
}
[IO.File]::WriteAllText($configPath,$config,[Text.Encoding]::ASCII)
$game=Join-Path $player 'Roms/game.sfc'
if(-not(Test-Path -LiteralPath $game)){Copy-Item -LiteralPath $rom -Destination $game}
if((Get-FileHash -LiteralPath $game).Hash -ne $manifest.rom_sha256){throw 'ROM diferente en player/Roms; no se sustituye'}
$script=(Join-Path $root 'lector-snes9x.lua').Replace('\','/')
$auto='-- SM_ACCESS_PLAY_AUTORUN: no test driver'+"`r`ndofile([[$script]])`r`n"
[IO.File]::WriteAllText((Join-Path $player 'game.lua'),$auto,[Text.UTF8Encoding]::new($false))
if($PrepareOnly){Write-Output 'Copia de juego preparada. ROM verificada; partidas aisladas; no se ha iniciado el emulador.';return}
$readerLog=Join-Path $root 'reader.log'
$previousLength=if(Test-Path -LiteralPath $readerLog){(Get-Item -LiteralPath $readerLog).Length}else{0}
$p=Start-Process -FilePath $exe -WorkingDirectory $player -ArgumentList ('"'+$game+'" -lua') -WindowStyle Normal -PassThru
$session=@{kind='sm-access-play';root=$root;processId=$p.Id;startTicks=$p.StartTime.ToUniversalTime().Ticks}
[IO.File]::WriteAllText((Join-Path $player 'session.json'),($session|ConvertTo-Json),[Text.UTF8Encoding]::new($false))
for($attempt=0;$attempt -lt 20;$attempt++){
 $p.Refresh();if($p.HasExited){break}
 try{& (Join-Path $root 'mostrar-ventana.ps1');break}
 catch{if($attempt -eq 19){Write-Warning 'No se confirmo la ventana visible de Secret of Mana.'};Start-Sleep -Milliseconds 200}
}
for($attempt=0;$attempt -lt 24;$attempt++){
 if(Test-Path -LiteralPath $readerLog){
  $bytes=[IO.File]::ReadAllBytes($readerLog)
  if($bytes.Length -gt $previousLength){
   $fresh=[Text.Encoding]::UTF8.GetString($bytes,[int]$previousLength,$bytes.Length-[int]$previousLength)
   if($fresh.Contains('START Mana reader')){
    Write-Output 'Inicio nuevo del lector confirmado en reader.log.'
    if($fresh.Contains('VOICE UNAVAILABLE')){Write-Warning 'El lector inicio sin voz; revisa reader.log.'}
    $p.Refresh()
    if($p.HasExited){Write-Output 'El lector inicio y la sesion ya esta cerrada; disponible al siguiente inicio.'}
    else{& (Join-Path $root 'mostrar-ventana.ps1');Write-Output "Secret of Mana iniciado. PID $($p.Id). Partidas: $saves"}
    return
   }
  }
 }
 Start-Sleep -Milliseconds 250
}
throw 'El emulador inicio, pero falta confirmar el lector en reader.log. No se anuncia activacion.'
