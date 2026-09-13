@echo off

:: Get the directory of this batch file
setlocal
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%\.."

:: Execute setup
Premake\Windows\premake5.exe --file=Build.lua vs2022
popd
pause