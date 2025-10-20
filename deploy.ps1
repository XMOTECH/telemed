# Script de déploiement automatique Telemed pour Windows PowerShell
# Usage: .\deploy.ps1

Write-Host "`n🚀 DÉPLOIEMENT TELEMED EN PRODUCTION`n" -ForegroundColor Green

# Vérifier que flyctl est installé
Write-Host "1️⃣  Vérification flyctl..." -ForegroundColor Cyan
if (!(Get-Command fly -ErrorAction SilentlyContinue)) {
    Write-Host "❌ flyctl n'est pas installé." -ForegroundColor Red
    Write-Host "   Installez-le avec: iwr https://fly.io/install.ps1 -useb | iex" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ flyctl installé`n" -ForegroundColor Green

# Vérifier authentification Fly.io
Write-Host "2️⃣  Vérification authentification Fly.io..." -ForegroundColor Cyan
$flyAuth = fly auth whoami 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Pas connecté à Fly.io" -ForegroundColor Red
    Write-Host "   Connectez-vous avec: fly auth login" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Connecté à Fly.io: $flyAuth`n" -ForegroundColor Green

# Vérifier que les tests passent
Write-Host "3️⃣  Exécution des tests..." -ForegroundColor Cyan
$testResult = mix test test/telemed/ 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Certains tests ont échoué. Voulez-vous continuer ? (y/N)" -ForegroundColor Yellow
    $continue = Read-Host
    if ($continue -ne "y" -and $continue -ne "Y") {
        Write-Host "❌ Déploiement annulé" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Tests passent`n" -ForegroundColor Green
}

# Demander confirmation
Write-Host "`n📋 RÉSUMÉ DÉPLOIEMENT`n" -ForegroundColor Yellow
Write-Host "   App: telemed-prod"
Write-Host "   Région: Paris (cdg)"
Write-Host "   Base de données: PostgreSQL"
Write-Host "   SSL: Automatique"
Write-Host ""
Write-Host "Confirmer le déploiement ? (y/N)" -ForegroundColor Yellow
$confirm = Read-Host

if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "`n❌ Déploiement annulé`n" -ForegroundColor Red
    exit 0
}

# Déployer
Write-Host "`n4️⃣  Déploiement en cours...`n" -ForegroundColor Cyan
fly deploy

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ DÉPLOIEMENT RÉUSSI !`n" -ForegroundColor Green
    
    Write-Host "📝 Prochaines étapes:`n" -ForegroundColor Cyan
    Write-Host "   1. Exécuter migrations:"
    Write-Host "      fly ssh console -C `"/app/bin/telemed eval 'Telemed.Release.setup_production'`"`n"
    Write-Host "   2. Ouvrir l'app:"
    Write-Host "      fly open`n"
    Write-Host "   3. Login admin:"
    Write-Host "      Email: admin@telemed.fr"
    Write-Host "      Password: Admin123!ChangeMe"
    Write-Host "      ⚠️  CHANGEZ CE MOT DE PASSE !`n"
    
    Write-Host "🎉 TELEMED EST EN PRODUCTION ! 🎉`n" -ForegroundColor Green
} else {
    Write-Host "`n❌ Erreur lors du déploiement`n" -ForegroundColor Red
    Write-Host "   Voir les logs: fly logs`n" -ForegroundColor Yellow
    exit 1
}

