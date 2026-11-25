param(
    [ValidateSet('Prepare','Start','Stop','Cleanup')][string]$Action='Prepare',
    [string]$Case,
    [string]$Script,
    [string]$Instance='shared',
    [switch]$Temporary,
    [switch]$WaitForExit,
    [switch]$PrepareOnly
)
$ErrorActionPreference='Stop'
$testRoot=$PSScriptRoot
$projectRoot=[IO.Path]::GetFullPath((Join-Path $testRoot '..'))
$manifestPath=Join-Path $testRoot 'project.json'
if(-not(Test-Path -LiteralPath $manifestPath)){throw 'Falta tests/project.json; crea primero el proyecto con nuevo-proyecto.py'}
$manifest=Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
if($manifest.schema -ne 1 -or $manifest.project_id -notmatch '^[a-z0-9][a-z0-9-]*$'){throw 'Identidad o version de manifiesto no valida'}
if($manifest.profile -ne 'snes9x-lua-1.63-windows'){throw 'Este gestor requiere el perfil Snes9x Lua 1.63 para Windows'}
function Project-File($Value){
    if([string]::IsNullOrWhiteSpace($Value)){throw 'Completa rom_path, emulator_dir y config_template en tests/project.json'}
    if([IO.Path]::IsPathRooted($Value)){return [IO.Path]::GetFullPath($Value)}
    return [IO.Path]::GetFullPath((Join-Path $projectRoot $Value))
}
$sharedRoot=Join-Path $testRoot 'emulator'
$tempRoot=Join-Path $testRoot 'emulator-temp'
$runtimeNames=@('snes9x.exe','lua51.dll','lua5.1.dll','Valid.Ext')
$sourceRoot=$null
$utf8=[Text.UTF8Encoding]::new($false)
function Write-Json($Path,$Value){[IO.File]::WriteAllText($Path,($Value|ConvertTo-Json -Depth 8),$utf8)}
function Assert-TestPath($Path){
    $full=[IO.Path]::GetFullPath($Path)
    $prefix=[IO.Path]::GetFullPath($testRoot)+[IO.Path]::DirectorySeparatorChar
    if($full -ne $testRoot -and -not $full.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw 'Ruta fuera de las pruebas de este proyecto'}
    $current=$full
    while($current -and $current.Length -ge $testRoot.Length){
        if(Test-Path -LiteralPath $current){
            if((Get-Item -LiteralPath $current -Force).Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'No se opera una ruta de pruebas con enlaces de directorio'}
        }
        if($current -eq $testRoot){break}
        $current=Split-Path -Parent $current
    }
    return $full
}
function Lua-String($Value){
    $equals=''
    while($Value.Contains(']'+$equals+']')){$equals+='='}
    return '['+$equals+'['+$Value+']'+$equals+']'
}
function Assert-NoLinks {
    $pending=New-Object 'System.Collections.Generic.Stack[string]'
    $pending.Push($testRoot)
    while($pending.Count){
        foreach($entry in Get-ChildItem -LiteralPath $pending.Pop() -Force){
            if($entry.Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Enlace dentro de tests: no se modificara el destino'}
            if($entry.PSIsContainer){$pending.Push($entry.FullName)}
        }
    }
}
function Read-Inputs {
    $script:sourceRoot=Project-File $manifest.emulator_dir
    $script:romSource=Project-File $manifest.rom_path
    $script:configTemplate=Project-File $manifest.config_template
    if($manifest.rom_sha256 -notmatch '^[a-fA-F0-9]{64}$'){throw 'Falta un SHA-256 de ROM valido en project.json'}
    if((Get-FileHash -LiteralPath $romSource).Hash -ne $manifest.rom_sha256){throw 'ROM diferente de la identificada en este proyecto'}
    if(-not(Test-Path -LiteralPath $configTemplate -PathType Leaf)){throw 'Falta la configuracion base del emulador'}
}
function Management-Lock {
    for($attempt=0;$attempt -lt 100;$attempt++){
        try{return [IO.File]::Open((Join-Path $testRoot 'emulator-management.lock'),[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)}
        catch [IO.IOException]{Start-Sleep -Milliseconds 100}
    }
    throw 'Otra operacion de pruebas sigue usando el bloqueo'
}
function Runtime-Path($Id){
    if($Id -eq 'shared'){return $sharedRoot}
    if($Id -notmatch '^tmp-[a-f0-9]{12}$'){throw 'Identificador temporal no valido'}
    return Join-Path $tempRoot $Id
}
function Prepare-Shared {
    Read-Inputs
    [void](Assert-TestPath $sharedRoot)
    if(Test-Path -LiteralPath $sharedRoot){[void](Owned-Session $sharedRoot)}
    New-Item -ItemType Directory -Force -Path $sharedRoot | Out-Null
    if(-not(Test-Path -LiteralPath (Join-Path $sharedRoot 'owner.json'))){
        if(@(Get-ChildItem -LiteralPath $sharedRoot -Force).Count){throw 'La carpeta del emulador no esta vacia ni pertenece al gestor'}
        Write-Json (Join-Path $sharedRoot 'owner.json') @{kind='snes-test-runtime';project=$manifest.project_id;root=$testRoot;temporary=$false}
    }
    foreach($name in $runtimeNames){
        $src=Join-Path $sourceRoot $name; $dst=Join-Path $sharedRoot $name
        if(-not(Test-Path -LiteralPath $src)){throw "Falta $src"}
        if(Test-Path -LiteralPath $dst){
            if((Get-FileHash -LiteralPath $src).Hash -ne (Get-FileHash -LiteralPath $dst).Hash){throw "Binario compartido diferente: $name"}
        }else{Copy-Item -LiteralPath $src -Destination $dst}
    }
    $base=Join-Path $sharedRoot 'base.conf'
    if(-not(Test-Path -LiteralPath $base)){
        Copy-Item -LiteralPath $configTemplate -Destination $base
    }
}
function Owned-Session($Folder){
    [void](Assert-TestPath $Folder)
    $ownerPath=Join-Path $Folder 'owner.json'
    if(-not(Test-Path -LiteralPath $ownerPath)){throw "Carpeta sin marca de pruebas: $Folder"}
    $owner=Get-Content -LiteralPath $ownerPath -Raw | ConvertFrom-Json
    if($owner.kind -ne 'snes-test-runtime' -or $owner.project -ne $manifest.project_id -or $owner.root -ne $testRoot){throw 'La instancia pertenece a otro proyecto o no tiene propietario valido'}
    $path=Join-Path $Folder 'active.json'
    if(Test-Path -LiteralPath $path){return Get-Content -LiteralPath $path -Raw | ConvertFrom-Json}
    return $null
}
function Session-Process($Folder,$Session){
    if(-not $Session -or $Session.processId -eq 0){return $null}
    $p=Get-Process -Id $Session.processId -ErrorAction SilentlyContinue
    if(-not $p){return $null}
    $expected=Join-Path $Folder 'snes9x.exe'
    if($p.Path -ne $expected -or $p.StartTime.ToUniversalTime().Ticks -ne $Session.startTicks){
        throw 'El PID registrado pertenece a otra ejecucion; no se operara ese proceso'
    }
    return $p
}
function Finish-Session($Folder,[switch]$Stop){
    if(-not(Test-Path -LiteralPath $Folder)){return}
    $s=Owned-Session $Folder
    if($Folder -ne $sharedRoot -and -not $s){throw 'Falta la sesion temporal; no se borra su contenido'}
    $p=Session-Process $Folder $s
    if($p){
        if(-not $Stop){return}
        # Hidden windows have no MainWindowHandle; close their real menu window
        # so Snes9x can flush SRAM before its temporary runtime is retired.
        if(-not ('SnesTestClose' -as [type])){Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class SnesTestClose {
 public delegate bool EnumProc(IntPtr h,IntPtr p);
 [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc cb,IntPtr p);
 [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h,out uint p);
 [DllImport("user32.dll")] static extern IntPtr GetMenu(IntPtr h);
 [DllImport("user32.dll")] static extern bool PostMessage(IntPtr h,uint m,IntPtr w,IntPtr l);
 public static void Close(uint id){EnumWindows(delegate(IntPtr h,IntPtr ignored){
  uint owner;GetWindowThreadProcessId(h,out owner);
  if(owner==id && GetMenu(h)!=IntPtr.Zero)PostMessage(h,0x10,IntPtr.Zero,IntPtr.Zero);
  return true;
 },IntPtr.Zero);}
}
'@
        }
        [SnesTestClose]::Close($p.Id)
        if(-not $p.WaitForExit(3000)){
            $p.Kill()
            if(-not $p.WaitForExit(5000)){throw 'El emulador de pruebas no termino al cerrarlo'}
        }
    }
    if($s){
        if($s.case -notmatch '^[a-z0-9][a-z0-9-]*$' -or $s.case -in @('emulator','emulator-temp')){throw 'Caso de sesion no valido'}
        $archive=[IO.Path]::GetFullPath($s.archive)
        $allowed=[IO.Path]::GetFullPath((Join-Path $testRoot $s.case))+[IO.Path]::DirectorySeparatorChar
        if(-not $archive.StartsWith($allowed,[StringComparison]::OrdinalIgnoreCase)){throw 'Archivo de sesion fuera del caso'}
        New-Item -ItemType Directory -Force -Path $archive | Out-Null
        $prefix=[IO.Path]::GetFullPath($Folder)+[IO.Path]::DirectorySeparatorChar
        $entries=@(Get-ChildItem -LiteralPath $Folder -Recurse -Force)
        if($entries|Where-Object {$_.Attributes -band [IO.FileAttributes]::ReparsePoint}){throw 'No se limpia una instancia con enlaces de directorio'}
        foreach($file in $entries|Where-Object {-not $_.PSIsContainer}){
            $relative=$file.FullName.Substring($prefix.Length)
            if($relative -in $runtimeNames){continue}
            $dest=Join-Path $archive $relative
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
            Copy-Item -LiteralPath $file.FullName -Destination $dest -Force
            if((Get-FileHash -LiteralPath $file.FullName).Hash -ne (Get-FileHash -LiteralPath $dest).Hash){throw 'Copia de evidencia incompleta'}
        }
        if($Folder -eq $sharedRoot){Remove-Item -LiteralPath (Join-Path $Folder 'active.json')}
    }
    if($Folder -ne $sharedRoot){
        $resolved=(Resolve-Path -LiteralPath $Folder).Path
        $allowed=[IO.Path]::GetFullPath($tempRoot)+[IO.Path]::DirectorySeparatorChar
        if(-not $resolved.StartsWith($allowed,[StringComparison]::OrdinalIgnoreCase)){throw 'Instancia temporal fuera del directorio autorizado'}
        $owner=Get-Content -LiteralPath (Join-Path $resolved 'owner.json') -Raw | ConvertFrom-Json
        if(-not $owner.temporary){throw 'No se borra una instancia permanente'}
        [void](Assert-TestPath $resolved)
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
[void](Assert-TestPath $testRoot)
Assert-NoLinks
$lock=Management-Lock
$waitProcess=$null;$waitFolder=$null
try {
    if($Action -eq 'Prepare'){Prepare-Shared;Write-Output $sharedRoot;return}
    if($Action -eq 'Cleanup'){
        if(Test-Path -LiteralPath $tempRoot){
            foreach($dir in Get-ChildItem -LiteralPath $tempRoot -Directory){
                if($dir.Name -match '^tmp-[a-f0-9]{12}$'){Finish-Session $dir.FullName}
            }
        }
        Write-Output 'Instancias temporales cerradas archivadas y retiradas.';return
    }
    if($Action -eq 'Stop'){
        Finish-Session (Runtime-Path $Instance) -Stop
        Write-Output "Instancia $Instance cerrada; evidencias conservadas.";return
    }
    Prepare-Shared
    if($Case -notmatch '^[a-z0-9][a-z0-9-]*$' -or $Case -in @('emulator','emulator-temp')){throw 'Nombre de caso no valido'}
    $scriptPath=(Resolve-Path -LiteralPath (Join-Path $testRoot $Script)).Path
    if(-not $scriptPath.StartsWith($testRoot+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase) -or
       [IO.Path]::GetExtension($scriptPath) -ne '.lua'){throw 'El guion debe ser un Lua dentro de test'}
    $caseRoot=Join-Path $testRoot $Case
    [void](Assert-TestPath $caseRoot)
    New-Item -ItemType Directory -Force -Path $caseRoot | Out-Null
    $folders=@($sharedRoot)
    if(Test-Path -LiteralPath $tempRoot){$folders+=@(Get-ChildItem -LiteralPath $tempRoot -Directory|ForEach-Object FullName)}
    foreach($folder in $folders){
        $s=Owned-Session $folder
        $running=Session-Process $folder $s
        $unmanaged=@(Get-Process -Name snes9x -ErrorAction SilentlyContinue|Where-Object {$_.Path -eq (Join-Path $folder 'snes9x.exe')})
        if($unmanaged.Count -gt 0 -and -not $running){throw "Emulador de pruebas abierto sin sesion registrada: $folder"}
        if($running -and ($s.case -eq $Case -or ($folder -eq $sharedRoot -and -not $Temporary))){throw 'Instancia o datos del caso ocupados; no se cambia el ensayo abierto'}
        if(-not $running -and $s){Finish-Session $folder}
    }
    if($Temporary){$Instance='tmp-'+[guid]::NewGuid().ToString('N').Substring(0,12)}else{$Instance='shared'}
    $runtime=Runtime-Path $Instance
    [void](Assert-TestPath $runtime)
    New-Item -ItemType Directory -Force -Path $runtime | Out-Null
    $archive=Join-Path $caseRoot ('sessions/'+(Get-Date -Format 'yyyyMMdd-HHmmss-fff')+'-'+$Instance)
    $session=[pscustomobject]@{case=$Case;script=$scriptPath;archive=$archive;processId=0;startTicks=0;instance=$Instance;configSource=$null}
    Write-Json (Join-Path $runtime 'owner.json') @{kind='snes-test-runtime';project=$manifest.project_id;root=$testRoot;temporary=[bool]$Temporary}
    Write-Json (Join-Path $runtime 'active.json') $session
    if($Temporary){foreach($name in $runtimeNames+@('base.conf')){Copy-Item -LiteralPath (Join-Path $sharedRoot $name) -Destination $runtime}}
    $configSource=Join-Path $caseRoot 'snes9x.conf'
    if(-not(Test-Path -LiteralPath $configSource)){$configSource=Join-Path $sharedRoot 'base.conf'}
    $session.configSource=$configSource
    $config=[IO.File]::ReadAllText($configSource)
    $settings=@{Mute='TRUE';PauseWhenInactive='FALSE';'Input:Background'='ON';'Dir:Lock'='TRUE'}
    $optional=@('Dir:Screenshots','Dir:Movies','Dir:SPCs','Dir:Bios','Dir:SatData','Dir:Lock')
    foreach($pair in @(@('Dir:Savestates','Saves'),@('Dir:SRAM','Saves'),@('Dir:Roms','Roms'),@('Dir:Cheats','Cheats'),@('Dir:Patches','Patches'),@('Dir:Screenshots','Screenshots'),@('Dir:Movies','Movies'),@('Dir:SPCs','SPCs'),@('Dir:Bios','BIOS'),@('Dir:SatData','SatData'))){
        $dir=Join-Path $caseRoot $pair[1];[void](Assert-TestPath $dir);New-Item -ItemType Directory -Force -Path $dir | Out-Null
        $settings[$pair[0]]=$dir
    }
    foreach($key in $settings.Keys){
        $pattern='(?m)^(\s*'+[regex]::Escape($key)+'\s*=\s*)[^\r\n#]+'
        if(-not [regex]::IsMatch($config,$pattern)){
            if($key -in $optional){$config+="`r`n"+$key+' = '+$settings[$key]+"`r`n";continue}
            throw "Falta opcion: $key"
        }
        $value=$settings[$key]
        $config=[regex]::Replace($config,$pattern,{param($m)$m.Groups[1].Value+$value+' '}.GetNewClosure())
    }
    [IO.File]::WriteAllText((Join-Path $runtime 'snes9x.conf'),$config,[Text.Encoding]::ASCII)
    # Run a verified copy of the ROM, never the player's source file.
    $romFolder=Join-Path $runtime 'Roms';[void](Assert-TestPath $romFolder)
    New-Item -ItemType Directory -Force -Path $romFolder | Out-Null
    $rom=Join-Path $romFolder 'game.sfc'
    Copy-Item -LiteralPath $romSource -Destination $rom -Force
    if((Get-FileHash -LiteralPath $rom).Hash -ne $manifest.rom_sha256){throw 'La copia de la ROM no coincide'}
    # Execute the exact entry source archived with this session, not a mutable path.
    $frozenScript=Join-Path $runtime 'executed-script.lua'
    Copy-Item -LiteralPath $scriptPath -Destination $frozenScript -Force
    if((Get-FileHash -LiteralPath $frozenScript).Hash -ne (Get-FileHash -LiteralPath $scriptPath).Hash){throw 'El guion cambio durante la captura'}
    $auto='-- SNES_ACCESS_AUTORUN ISOLATED TEST ONLY'+"`r`n"+
        'SNES_TEST_PROJECT='+(Lua-String $manifest.project_id)+"`r`n"+
        'SNES_PROJECT_ROOT='+(Lua-String ($projectRoot.Replace('\','/')+'/'))+"`r`n"+
        'SNES_TEST_OUTPUT='+(Lua-String ($caseRoot.Replace('\','/')+'/'))+"`r`n"+
        'dofile('+(Lua-String $frozenScript.Replace('\','/'))+')'+"`r`n"
    [IO.File]::WriteAllText((Join-Path $runtime 'game.lua'),$auto,$utf8)
    Write-Json (Join-Path $runtime 'input-hashes.json') @{project=$manifest.project_id;rom=$manifest.rom_sha256;script=(Get-FileHash -LiteralPath $frozenScript).Hash;sourceScript=$scriptPath;executedScript=$frozenScript;config=(Get-FileHash -LiteralPath $configSource).Hash}
    Write-Json (Join-Path $runtime 'active.json') $session
    if(-not $PrepareOnly){
        $p=Start-Process -FilePath (Join-Path $runtime 'snes9x.exe') -WorkingDirectory $runtime -ArgumentList ('"'+$rom+'" -lua') -WindowStyle Hidden -PassThru
        $session.processId=$p.Id;$session.startTicks=$p.StartTime.ToUniversalTime().Ticks
        Write-Json (Join-Path $runtime 'active.json') $session
        try{
            for($attempt=0;$attempt -lt 20;$attempt++){
                try{& (Join-Path $testRoot 'enable-background.ps1') -EmulatorFolder $runtime | Out-Null;break}
                catch{if($attempt -eq 19){throw};Start-Sleep -Milliseconds 200}
            }
        }catch{Finish-Session $runtime -Stop;throw}
        if($Temporary -or $WaitForExit){$waitProcess=$p;$waitFolder=$runtime}
    }
    $session|ConvertTo-Json -Compress
} finally {$lock.Dispose()}
if($waitProcess){
    $waitProcess.WaitForExit()
    $lock=Management-Lock
    try{Finish-Session $waitFolder}finally{$lock.Dispose()}
}
