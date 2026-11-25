param([switch]$Verify,[string]$Case)
$ErrorActionPreference='Stop'
$root=$PSScriptRoot;$tests=Join-Path $root 'test'
if(-not $Case){$Case='hormiga12-practica-'+(Get-Date -Format 'yyyyMMdd-HHmmss')}
if($Case -notmatch '^hormiga12-[a-z0-9-]+$'){throw 'Caso de práctica no válido'}
$python=(Get-Command python -ErrorAction SilentlyContinue).Source
if(-not $python){$python=Join-Path $root 'venv/Scripts/python.exe'}
if(-not (Test-Path -LiteralPath $python)){throw 'No se encontro Python en PATH ni en venv/Scripts/python.exe del proyecto'}
$launched=$false
try {
 if(-not $Verify){Write-Output 'Preparando la practica aislada de la hormiga...'}
 & $python (Join-Path $tests 'prepare-hormiga12-practice.py') $Case | Out-Null
 if($LASTEXITCODE -ne 0){throw 'No se pudo preparar la copia aislada'}
 $playerConfig=Join-Path $root 'player/snes9x.conf'
 if(Test-Path -LiteralPath $playerConfig){Copy-Item -LiteralPath $playerConfig -Destination (Join-Path $tests ($Case+'/snes9x.conf'))}
 & (Join-Path $tests 'emulador-pruebas.ps1') -Action Start -Case $Case -Script hormiga12-practica.lua -PrepareOnly | Out-Null
 $runtime=Join-Path $tests 'emulator';$configPath=Join-Path $runtime 'snes9x.conf'
 $config=[IO.File]::ReadAllText($configPath)
 $mute=if($Verify){'TRUE'}else{'FALSE'};$skip=if($Verify){'1'}else{'200'}
 $config=[regex]::Replace($config,'(?m)^(\s*Mute\s*=\s*)[^\r\n#]+',('${1}'+$mute+' '))
 $config=[regex]::Replace($config,'(?m)^(\s*FrameSkip\s*=\s*)[^\r\n#]+',('${1}'+$skip+' '))
 $focusSettings=if($Verify){@{PauseWhenInactive='FALSE';'Input:Background'='ON';'Input:BackgroundKeyHotkeys'='ON'}}else{@{PauseWhenInactive='FALSE';'Input:Background'='OFF';'Input:BackgroundKeyHotkeys'='OFF'}}
 foreach($key in $focusSettings.Keys){
  $pattern='(?m)^(\s*'+[regex]::Escape($key)+'\s*=\s*)[^\r\n#]+'
  $value=$focusSettings[$key]
  if([regex]::IsMatch($config,$pattern)){$config=[regex]::Replace($config,$pattern,{param($m)$m.Groups[1].Value+$value+' '}.GetNewClosure())}
  else{$config+="`r`n$key = $value`r`n"}
 }
 [IO.File]::WriteAllText($configPath,$config,[Text.Encoding]::ASCII)
 if($Verify){$auto=Join-Path $runtime 'game.lua';[IO.File]::WriteAllText($auto,"SNES_PRACTICE_VERIFY=true`r`n"+[IO.File]::ReadAllText($auto),[Text.UTF8Encoding]::new($false))}
 $sessionPath=Join-Path $runtime 'active.json';$session=Get-Content -LiteralPath $sessionPath -Raw | ConvertFrom-Json
 $rom=Join-Path $runtime 'Roms/game.sfc'
 $p=Start-Process -FilePath (Join-Path $runtime 'snes9x.exe') -WorkingDirectory $runtime -ArgumentList ('"'+$rom+'" -lua') -WindowStyle Hidden -PassThru
 $session.processId=$p.Id;$session.startTicks=$p.StartTime.ToUniversalTime().Ticks
 [IO.File]::WriteAllText($sessionPath,($session|ConvertTo-Json -Depth 8),[Text.UTF8Encoding]::new($false));$launched=$true
 Start-Sleep -Milliseconds 800
 if($Verify){& (Join-Path $tests 'enable-background.ps1') -EmulatorFolder $runtime | Out-Null}
 & (Join-Path $tests 'hormiga12-window.ps1') -Action Load
 if(-not $Verify){& (Join-Path $tests 'hormiga12-window.ps1') -Action Show}
 $ready=Join-Path $tests ($Case+'/ready.txt')
 for($i=0;$i -lt 200 -and -not(Test-Path -LiteralPath $ready);$i++){Start-Sleep -Milliseconds 100}
 if(-not(Test-Path -LiteralPath $ready)){throw 'No se confirmó la carga aislada del encuentro'}
 if(-not $Verify){& (Join-Path $tests 'hormiga12-window.ps1') -Action Show;Write-Output 'Prueba lista, con el menú abierto. Control F9 explica los sonidos; Y empieza.'}
 else{Write-Output ('Verificación nativa iniciada en '+$Case)}
}catch{
 if($launched){& (Join-Path $tests 'emulador-pruebas.ps1') -Action Stop | Out-Null}
 throw
}
