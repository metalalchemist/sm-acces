$ErrorActionPreference='Stop'
$exe=Join-Path $PSScriptRoot 'player/snes9x.exe'
$session=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'player/session.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if($session.kind -ne 'sm-access-play' -or $session.root -ne $PSScriptRoot){throw 'Sesion ajena a Secret of Mana'}
$play=Get-Process -Id $session.processId -ErrorAction Stop
if($play.Path -ne $exe -or $play.StartTime.ToUniversalTime().Ticks -ne $session.startTicks){throw 'La identidad de la copia de Mana cambio'}
if(-not ('ManaWindow' -as [type])){Add-Type @'
using System;
using System.Runtime.InteropServices;
public class ManaWindow {
 public delegate bool EnumProc(IntPtr h,IntPtr p);
 [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc f,IntPtr p);
 [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h,out uint p);
 [DllImport("user32.dll")] public static extern IntPtr GetMenu(IntPtr h);
 [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr h,int n);
 [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
 [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr h);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern bool SetWindowText(IntPtr h,string text);
 [DllImport("user32.dll",EntryPoint="GetWindowLongPtrW")] public static extern IntPtr GetWindowLongPtr(IntPtr h,int index);
 [DllImport("user32.dll",EntryPoint="SetWindowLongPtrW")] public static extern IntPtr SetWindowLongPtr(IntPtr h,int index,IntPtr value);
 [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h,IntPtr after,int x,int y,int w,int height,uint flags);
 [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a,uint b,bool attach);
 [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
 public static IntPtr Found=IntPtr.Zero;
 public static void Show(IntPtr h) {
  long style=GetWindowLongPtr(h,-20).ToInt64();
  SetWindowLongPtr(h,-20,new IntPtr((style & ~0x80L)|0x40000L));
  SetWindowPos(h,IntPtr.Zero,0,0,0,0,0x37);
  SetWindowText(h,"Secret of Mana - lector accesible");
  ShowWindowAsync(h,9);ShowWindowAsync(h,5);
  uint ignored;uint foreground=GetWindowThreadProcessId(GetForegroundWindow(),out ignored);
  uint current=GetCurrentThreadId();bool attached=false;
  try {
   if(foreground!=current)attached=AttachThreadInput(current,foreground,true);
   BringWindowToTop(h);SetForegroundWindow(h);
  } finally {if(attached)AttachThreadInput(current,foreground,false);}
 }
}
'@}
[ManaWindow]::Found=[IntPtr]::Zero
$playId=$play.Id
[ManaWindow]::EnumWindows({param($h,$unused)
 $owner=0;[void][ManaWindow]::GetWindowThreadProcessId($h,[ref]$owner)
 if($owner -eq $playId -and [ManaWindow]::GetMenu($h) -ne [IntPtr]::Zero){[ManaWindow]::Found=$h;return $false}
 return $true
},[IntPtr]::Zero) | Out-Null
$window=[ManaWindow]::Found
if($window -eq [IntPtr]::Zero){throw 'La ventana principal de Mana aun no esta disponible'}
[ManaWindow]::Show($window)
for($attempt=0;$attempt -lt 20 -and -not [ManaWindow]::IsWindowVisible($window);$attempt++){Start-Sleep -Milliseconds 50}
if(-not [ManaWindow]::IsWindowVisible($window)){throw 'No se confirmo que la ventana de Mana este visible'}
$foreground=[ManaWindow]::GetForegroundWindow() -eq $window
$styles=[ManaWindow]::GetWindowLongPtr($window,-20).ToInt64()
$altTab=($styles -band 0x40000) -ne 0 -and ($styles -band 0x80) -eq 0
Write-Output "Mana visible. PID $playId. Ventana $window. Primer plano: $foreground. Estilo Alt-Tab: $altTab."
