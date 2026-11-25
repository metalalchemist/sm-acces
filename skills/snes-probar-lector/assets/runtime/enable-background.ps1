param([Parameter(Mandatory=$true)][string]$EmulatorFolder)
$ErrorActionPreference='Stop'
if(-not ('SnesTestMenu' -as [type])){Add-Type @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public class SnesTestMenu {
 public static int FoundCount=0;
 public delegate bool EnumProc(IntPtr h,IntPtr p);
 [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc cb,IntPtr p);
 [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h,out uint p);
 [DllImport("user32.dll")] public static extern IntPtr GetMenu(IntPtr h);
 [DllImport("user32.dll")] public static extern IntPtr GetSubMenu(IntPtr h,int pos);
 [DllImport("user32.dll")] public static extern int GetMenuItemCount(IntPtr h);
 [DllImport("user32.dll")] public static extern uint GetMenuItemID(IntPtr h,int pos);
 [DllImport("user32.dll")] public static extern uint GetMenuState(IntPtr h,uint id,uint flags);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern int GetMenuString(IntPtr h,uint id,StringBuilder s,int n,uint flags);
 [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr h,uint msg,IntPtr w,IntPtr l);
 public static void Walk(IntPtr win,IntPtr menu) {
  for(int i=0;i<GetMenuItemCount(menu);i++) {
   var s=new StringBuilder(256);GetMenuString(menu,(uint)i,s,256,0x400);
   string label=s.ToString().Replace("&","");
   if(label.IndexOf("Background Input",StringComparison.OrdinalIgnoreCase)>=0) {
    FoundCount++;
    uint id=GetMenuItemID(menu,i); Console.WriteLine(label+" id="+id);
    if((GetMenuState(menu,id,0)&8)==0) SendMessage(win,0x111,(IntPtr)id,IntPtr.Zero);
   }
   IntPtr sub=GetSubMenu(menu,i);if(sub!=IntPtr.Zero)Walk(win,sub);
  }
 }
}
'@
}
$taskExe=Join-Path (Resolve-Path -LiteralPath $EmulatorFolder).Path 'snes9x.exe'
$taskFolder=Split-Path -Parent $taskExe
$taskOwner=Get-Content -LiteralPath (Join-Path $taskFolder 'owner.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$taskSession=Get-Content -LiteralPath (Join-Path $taskFolder 'active.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$taskProject=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'project.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if($taskOwner.kind -ne 'snes-test-runtime' -or $taskOwner.root -ne $PSScriptRoot -or $taskOwner.project -ne $taskProject.project_id){throw 'La copia no pertenece a este proyecto de pruebas'}
$taskProcesses=@(Get-Process -Name snes9x | Where-Object Path -eq $taskExe)
if($taskProcesses.Count -ne 1){throw 'Se requiere una copia aislada unica'}
if($taskProcesses[0].Id -ne $taskSession.processId -or $taskProcesses[0].StartTime.ToUniversalTime().Ticks -ne $taskSession.startTicks){throw 'La identidad del proceso ya no coincide'}
$taskId=$taskProcesses[0].Id
[SnesTestMenu]::FoundCount=0
[SnesTestMenu]::EnumWindows({param($h,$p) $owner=0; [void][SnesTestMenu]::GetWindowThreadProcessId($h,[ref]$owner); if($owner -eq $taskId){$menu=[SnesTestMenu]::GetMenu($h);if($menu -ne [IntPtr]::Zero){[SnesTestMenu]::Walk($h,$menu)}}; return $true},[IntPtr]::Zero)
if([SnesTestMenu]::FoundCount -eq 0){throw 'El menu de la copia de pruebas aun no esta disponible'}
