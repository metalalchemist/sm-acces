$ErrorActionPreference='Stop'
$player=Join-Path $PSScriptRoot 'player'
$exe=Join-Path $player 'snes9x.exe'
$session=Get-Content -LiteralPath (Join-Path $player 'session.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if($session.kind -ne 'sm-access-play' -or $session.root -ne $PSScriptRoot){throw 'Sesion normal de otro proyecto'}
$playProcess=Get-Process -Id $session.processId -ErrorAction Stop
if($playProcess.Path -ne $exe -or $playProcess.StartTime.ToUniversalTime().Ticks -ne $session.startTicks){throw 'La identidad de la copia normal cambio'}
if(-not ('ManaPlayMenu' -as [type])){Add-Type @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public class ManaPlayMenu {
 public static int Confirmed;
 public static int Requested;
 public static int PauseConfirmed;
 public delegate bool EnumProc(IntPtr h,IntPtr p);
 [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc cb,IntPtr p);
 [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h,out uint p);
 [DllImport("user32.dll")] public static extern IntPtr GetMenu(IntPtr h);
 [DllImport("user32.dll")] public static extern IntPtr GetSubMenu(IntPtr h,int i);
 [DllImport("user32.dll")] public static extern int GetMenuItemCount(IntPtr h);
 [DllImport("user32.dll")] public static extern uint GetMenuItemID(IntPtr h,int i);
 [DllImport("user32.dll")] public static extern uint GetMenuState(IntPtr h,uint id,uint flags);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern int GetMenuString(IntPtr h,uint id,StringBuilder s,int n,uint flags);
 [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr h,uint msg,IntPtr w,IntPtr l);
 public static void Walk(IntPtr win,IntPtr menu) {
  SendMessage(win,0x117,menu,IntPtr.Zero);
  for(int i=0;i<GetMenuItemCount(menu);i++) {
   var s=new StringBuilder(256);GetMenuString(menu,(uint)i,s,256,0x400);
   string label=s.ToString().Replace("&","");
   bool background=label.IndexOf("Background",StringComparison.OrdinalIgnoreCase)>=0 && (label.IndexOf("Input",StringComparison.OrdinalIgnoreCase)>=0 || label.IndexOf("Hotkey",StringComparison.OrdinalIgnoreCase)>=0);
   bool pause=label.IndexOf("Pause When Inactive",StringComparison.OrdinalIgnoreCase)>=0;
   if(background || pause) {
    uint id=GetMenuItemID(menu,i);
    if((GetMenuState(menu,id,0)&8)!=0){SendMessage(win,0x111,(IntPtr)id,IntPtr.Zero);Requested++;}
    SendMessage(win,0x117,menu,IntPtr.Zero);
    if((GetMenuState(menu,id,0)&8)==0){if(pause)PauseConfirmed++;else Confirmed++;}
   }
   IntPtr sub=GetSubMenu(menu,i);if(sub!=IntPtr.Zero)Walk(win,sub);
  }
 }
}
'@}
[ManaPlayMenu]::Confirmed=0
[ManaPlayMenu]::Requested=0
[ManaPlayMenu]::PauseConfirmed=0
$playId=$playProcess.Id
[ManaPlayMenu]::EnumWindows({param($h,$p)
 $owner=0;[void][ManaPlayMenu]::GetWindowThreadProcessId($h,[ref]$owner)
 if($owner -eq $playId){$menu=[ManaPlayMenu]::GetMenu($h);if($menu -ne [IntPtr]::Zero){[ManaPlayMenu]::Walk($h,$menu)}}
 return $true
},[IntPtr]::Zero) | Out-Null
if([ManaPlayMenu]::Confirmed -lt 1){
 if([ManaPlayMenu]::Requested -gt 0){Write-Warning 'Se solicito desactivar controles en segundo plano, pero el menu no confirmo el cambio.';return}
 throw 'No se encontro Background Input en la copia normal'
}
if([ManaPlayMenu]::PauseConfirmed -lt 1){Write-Warning 'La continuidad al perder foco se aplicara al siguiente inicio.'}
Write-Output 'Controles en segundo plano desactivados para Secret of Mana.'
