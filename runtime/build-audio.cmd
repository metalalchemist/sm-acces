@echo off
setlocal
cd /d "%~dp0"
if "%~1"=="" goto detect
call "%~1"
if errorlevel 1 exit /b 1
goto build
:detect
if defined VSINSTALLDIR if exist "%VSINSTALLDIR%VC\Auxiliary\Build\vcvars64.bat" (
 call "%VSINSTALLDIR%VC\Auxiliary\Build\vcvars64.bat"
 if errorlevel 1 exit /b 1
 goto build
)
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if exist "%VSWHERE%" (
 for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSINSTALL=%%i"
)
if defined VSINSTALL if exist "%VSINSTALL%\VC\Auxiliary\Build\vcvars64.bat" (
 call "%VSINSTALL%\VC\Auxiliary\Build\vcvars64.bat"
 if errorlevel 1 exit /b 1
 goto build
)
echo No se encontro Visual Studio Build Tools con el componente C++. 1>&2
echo Uso: build-audio.cmd "ruta\a\vcvars64.bat" 1>&2
exit /b 1
:build
cl /nologo /LD /MT /O2 /W4 /EHsc /std:c++17 chrono_audio.cpp /Fo:mana_audio_full.obj /link /OUT:mana_audio_full.dll /IMPLIB:mana_audio_full.lib
exit /b %errorlevel%
