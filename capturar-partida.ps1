# Read-only capture. No focus, controller input, pauses or state loads.
$ErrorActionPreference='Stop'
$exe=Join-Path $PSScriptRoot 'player/snes9x.exe'
$session=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'player/session.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$play=Get-Process -Id $session.processId -ErrorAction Stop
if($play.Path -ne $exe -or $play.StartTime.ToUniversalTime().Ticks -ne $session.startTicks){throw 'La sesion de Mana cambio'}
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
public class ManaCapture {
 public delegate bool EnumProc(IntPtr h,IntPtr p);
 [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc f,IntPtr p);
 [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h,out uint p);
 [DllImport("user32.dll")] static extern IntPtr GetMenu(IntPtr h);
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h,out Rect r);
 [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h,IntPtr dc,uint flags);
 public struct Rect {public int Left,Top,Right,Bottom;}
 public static IntPtr Find(uint pid) {
  IntPtr found=IntPtr.Zero;
  EnumWindows(delegate(IntPtr h,IntPtr unused){uint p;GetWindowThreadProcessId(h,out p);if(p==pid&&GetMenu(h)!=IntPtr.Zero){found=h;return false;}return true;},IntPtr.Zero);
  return found;
 }
}
'@
$window=[ManaCapture]::Find($play.Id)
if($window -eq [IntPtr]::Zero){throw 'No se encontro la ventana de Mana'}
$rect=New-Object ManaCapture+Rect
if(-not [ManaCapture]::GetWindowRect($window,[ref]$rect)){throw 'No se pudo medir la ventana'}
$bitmap=[Drawing.Bitmap]::new($rect.Right-$rect.Left,$rect.Bottom-$rect.Top)
$graphics=[Drawing.Graphics]::FromImage($bitmap)
$dc=$graphics.GetHdc()
try{$captured=[ManaCapture]::PrintWindow($window,$dc,2)}finally{$graphics.ReleaseHdc($dc)}
New-Item -ItemType Directory -Force -Path (Join-Path $PSScriptRoot 'evidence') | Out-Null
$output=Join-Path $PSScriptRoot 'evidence/partida-actual03.png'
try{if(-not $captured){throw 'No se pudo capturar la ventana'};$bitmap.Save($output,[Drawing.Imaging.ImageFormat]::Png)}
finally{$graphics.Dispose();$bitmap.Dispose()}
Write-Output $output
