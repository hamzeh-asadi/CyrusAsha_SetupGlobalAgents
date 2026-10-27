@echo off

REM ==============================================================================
REM Global AI Agent Configurator for Windows
REM File: CyrusAsha_SetupGlobalAgents.cmd
REM Version: 1.0.0
REM ==============================================================================
REM Creator / سازنده:
REM   https://github.com/hamzeh-asadi
REM   https://t.me/Asadi_hamzeh
REM ==============================================================================

setlocal

title Global AI Agent Configurator

cd /d "%~dp0"

if not exist "%~dp0CyrusAsha_GlobalAgents.ps1" (

    echo [ERROR] CyrusAsha_GlobalAgents.ps1 was not found next to this file.

    pause

    exit /b 1

)

REM Remove the "downloaded from internet" mark, then run the script for this run only.

powershell.exe -NoProfile -Command "Unblock-File -LiteralPath '%~dp0CyrusAsha_GlobalAgents.ps1'" >nul 2>&1

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0CyrusAsha_GlobalAgents.ps1" %*

set EXITCODE=%ERRORLEVEL%

echo.

if %EXITCODE% NEQ 0 (echo [ERROR] Setup finished with exit code %EXITCODE%.) else (echo [DONE] Setup finished.)

pause

exit /b %EXITCODE%
