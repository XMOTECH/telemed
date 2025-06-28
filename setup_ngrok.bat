@echo off
echo ========================================
echo   CONFIGURATION NGROK POUR TELEMEDECINE
echo ========================================
echo.

echo 1. Téléchargement de ngrok...
powershell -Command "Invoke-WebRequest -Uri 'https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip' -OutFile 'ngrok.zip'"

echo.
echo 2. Extraction de ngrok...
powershell -Command "Expand-Archive -Path 'ngrok.zip' -DestinationPath '.' -Force"

echo.
echo 3. Suppression du fichier zip...
del ngrok.zip

echo.
echo 4. Test de ngrok...
ngrok version

echo.
echo ========================================
echo   NGROK INSTALLE AVEC SUCCES !
echo ========================================
echo.
echo Pour démarrer le tunnel HTTPS :
echo 1. Assurez-vous que le serveur Phoenix tourne sur le port 4001
echo 2. Exécutez : ngrok http 4001
echo 3. Utilisez l'URL HTTPS fournie par ngrok
echo.
echo Exemple d'URL : https://abc123.ngrok.io
echo.
pause 