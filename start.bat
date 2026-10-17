@echo off
chcp 65001 >nul
title Sub2API (Personal Edition)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start.ps1"
pause
