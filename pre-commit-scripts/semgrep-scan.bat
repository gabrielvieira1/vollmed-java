@echo off
del "%~dp0..\logs\semgrep.log" >nul 2>&1
docker run --rm -v "%~dp0..\:/src" returntocorp/semgrep bash -c "semgrep --config=auto --json --error /src" > "%~dp0..\logs\semgrep.log" 2>NUL
exit /b %errorlevel%
