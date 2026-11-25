@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0probar-hormiga.ps1"
if errorlevel 1 pause
