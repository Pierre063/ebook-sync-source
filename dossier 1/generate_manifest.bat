@echo off
REM Ce fichier .bat suppose que le script PowerShell "GenerateManifest.ps1" est dans le même dossier.

echo.
echo ===========================================
echo   Demarrage de la generation du Manifeste
echo ===========================================
echo.

REM %~dp0 est une variable qui represente le chemin complet du dossier ou se trouve ce fichier .bat
set "ScriptPath=%~dp0GenerateManifest.ps1"

REM Lance le script PowerShell avec les options suivantes :
REM -NoProfile : Ne charge pas le profil utilisateur (plus rapide)
REM -ExecutionPolicy Bypass : Permet d'executer le script sans probleme de restriction de securite
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%ScriptPath%"

echo.
echo ===========================================
echo   Processus termine.
echo ===========================================
echo.
pause