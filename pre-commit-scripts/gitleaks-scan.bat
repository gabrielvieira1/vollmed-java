@echo off
del "%~dp0..\logs\gitleaks.log" >nul 2>&1
docker run --rm -v "%~dp0..\:/scan" zricethezav/gitleaks:latest detect --source /scan --no-git --verbose > "%~dp0..\logs\gitleaks.log" 2>&1
exit /b %errorlevel%
