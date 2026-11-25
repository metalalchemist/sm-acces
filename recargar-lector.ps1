$ErrorActionPreference='Stop'
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
public static class ManaLuaWindows {
    private delegate bool EnumProc(IntPtr hwnd, IntPtr param);
    [DllImport("user32.dll")] private static extern bool EnumWindows(EnumProc proc, IntPtr param);
    [DllImport("user32.dll")] private static extern bool EnumChildWindows(IntPtr parent, EnumProc proc, IntPtr param);
    [DllImport("user32.dll")] private static extern uint GetWindowThreadProcessId(IntPtr hwnd, out uint pid);
    [DllImport("user32.dll")] private static extern IntPtr GetParent(IntPtr hwnd);
    [DllImport("user32.dll")] private static extern int GetDlgCtrlID(IntPtr hwnd);
    [DllImport("user32.dll", CharSet=CharSet.Unicode)] private static extern int GetWindowText(IntPtr hwnd, StringBuilder text, int count);
    [DllImport("user32.dll", CharSet=CharSet.Unicode)] private static extern int GetClassName(IntPtr hwnd, StringBuilder text, int count);
    [DllImport("user32.dll", SetLastError=true)] private static extern IntPtr SendMessageTimeout(IntPtr hwnd, uint msg, IntPtr wp, IntPtr lp, uint flags, uint timeout, out IntPtr result);
    [DllImport("user32.dll", EntryPoint="SendMessageTimeoutW", CharSet=CharSet.Unicode, SetLastError=true)] private static extern IntPtr ReadControlText(IntPtr hwnd, uint msg, IntPtr wp, StringBuilder text, uint flags, uint timeout, out IntPtr result);
    public static IntPtr[] Windows(uint pid) {
        var windows = new List<IntPtr>();
        EnumWindows(delegate(IntPtr hwnd, IntPtr ignored) {
            uint found; GetWindowThreadProcessId(hwnd, out found);
            if (found == pid) windows.Add(hwnd);
            return true;
        }, IntPtr.Zero);
        return windows.ToArray();
    }
    public static IntPtr[] Children(IntPtr parent) {
        var windows = new List<IntPtr>();
        EnumChildWindows(parent, delegate(IntPtr hwnd, IntPtr ignored) { windows.Add(hwnd); return true; }, IntPtr.Zero);
        return windows.ToArray();
    }
    public static string Text(IntPtr hwnd) {
        var text = new StringBuilder(4096); GetWindowText(hwnd, text, text.Capacity);
        if (text.Length == 0 && Class(hwnd) == "Edit") {
            IntPtr result; ReadControlText(hwnd, 0xD, new IntPtr(text.Capacity), text, 2, 1000, out result);
        }
        return text.ToString();
    }
    public static string Class(IntPtr hwnd) {
        var text = new StringBuilder(256); GetClassName(hwnd, text, text.Capacity); return text.ToString();
    }
    public static void Click(IntPtr hwnd) {
        IntPtr result;
        // BM_CLICK may do nothing when the Lua dialog is inactive. Deliver the
        // button's BN_CLICKED command directly, without stealing game focus.
        IntPtr parent = GetParent(hwnd);
        int id = GetDlgCtrlID(hwnd);
        if (parent == IntPtr.Zero || id <= 0)
            throw new InvalidOperationException("No se identifico la orden de recarga.");
        if (SendMessageTimeout(parent, 0x111, new IntPtr(id), hwnd, 2, 10000, out result) == IntPtr.Zero)
            throw new InvalidOperationException("La consola Lua no respondio. No se reinicio el juego.");
    }
}
'@

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
  $text=[ManaLuaWindows]::Text($_).Trim([char]34).Replace([char]47,[char]92)
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