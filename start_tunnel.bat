@echo off
echo ========================================
echo   DEMARRAGE TUNNEL HTTPS NGROK
echo ========================================
echo.

echo Vérification que ngrok est installé...
ngrok version >nul 2>&1
if errorlevel 1 (
    echo ERREUR: ngrok n'est pas installé !
    echo Exécutez d'abord : setup_ngrok.bat
    pause
    exit /b 1
)

echo.
echo Vérification que le serveur Phoenix tourne sur le port 4001...
netstat -an | findstr ":4001" >nul
if errorlevel 1 (
    echo ATTENTION: Le serveur Phoenix ne semble pas tourner sur le port 4001
    echo Démarrez d'abord le serveur avec : mix phx.server
    echo.
    echo Voulez-vous continuer quand même ? (O/N)
    set /p choice=
    if /i "%choice%" neq "O" exit /b 1
)

echo.
echo ========================================
echo   DEMARRAGE DU TUNNEL HTTPS
echo ========================================
echo.
echo Le tunnel va démarrer et afficher une URL HTTPS
echo Cette URL sera accessible depuis n'importe quelle machine
echo.
echo Appuyez sur Ctrl+C pour arrêter le tunnel
echo.

ngrok http 4001

echo.
echo Tunnel arrêté.
pause 