@echo off
echo ========================================
echo   DEPLOIEMENT PLATEFORME TELEMEDECINE
echo ========================================
echo.

echo 1. Compilation des assets...
call mix assets.deploy

echo.
echo 2. Compilation de l'application...
call mix compile

echo.
echo 3. Génération de la clé secrète...
set SECRET_KEY_BASE=your_secret_key_here_but_make_it_longer_than_64_bytes_for_production_use_only_and_keep_it_secret

echo.
echo 4. Démarrage du serveur en mode production...
echo.
echo ========================================
echo   SERVEUR ACCESSIBLE SUR:
echo   - Local: http://localhost:4001
echo   - Reseau: http://%COMPUTERNAME%:4001
echo   - IP: http://192.168.43.248:4001
echo ========================================
echo.

set MIX_ENV=prod
set PORT=4001
call mix phx.server 