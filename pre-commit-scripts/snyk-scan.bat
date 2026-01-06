@echo off
del "%~dp0..\logs\snyk.log" >nul 2>&1
snyk test --all-projects --json > "%~dp0..\logs\snyk.log" 2>&1
exit /b %errorlevel%
