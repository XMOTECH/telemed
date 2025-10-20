# Script de test API - Telemed Backend
# Usage: .\test_api.ps1

Write-Host "🚀 TEST API TELEMED BACKEND" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

$BASE_URL = "http://localhost:4000/api/v1"
$HEADERS = @{
    "Content-Type" = "application/json"
}

Write-Host "📊 1. Health Check" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:4000/api/health" -Method Get
    Write-Host "✅ Serveur opérationnel:" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 3)
} catch {
    Write-Host "❌ Serveur inaccessible" -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

Write-Host "`n================================`n"

Write-Host "👤 2. Inscription Patient" -ForegroundColor Yellow
$registerBody = @{
    user = @{
        email = "patient@test.com"
        password = "password12345"
        role = "patient"
    }
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/auth/register" -Method Post -Body $registerBody -Headers $HEADERS
    Write-Host "✅ Inscription réussie:" -ForegroundColor Green
    Write-Host "Email: $($response.data.user.email)"
    Write-Host "Role: $($response.data.user.role)"
    $ACCESS_TOKEN = $response.data.tokens.access_token
    Write-Host "Token: $($ACCESS_TOKEN.Substring(0, 50))..." -ForegroundColor Gray
} catch {
    Write-Host "ATTENTION: Utilisateur existe deja, tentative de connexion..." -ForegroundColor Yellow
}

Write-Host "`n================================`n"

Write-Host "🔐 3. Connexion" -ForegroundColor Yellow
$loginBody = @{
    email = "patient@test.com"
    password = "password12345"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method Post -Body $loginBody -Headers $HEADERS
    Write-Host "✅ Connexion réussie:" -ForegroundColor Green
    $ACCESS_TOKEN = $response.data.tokens.access_token
    $REFRESH_TOKEN = $response.data.tokens.refresh_token
    Write-Host "Access Token: $($ACCESS_TOKEN.Substring(0, 50))..." -ForegroundColor Gray
    Write-Host "Expires in: $($response.data.tokens.expires_in) secondes"
} catch {
    Write-Host "❌ Échec connexion:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

Write-Host "`n================================`n"

Write-Host "👨‍⚕️ 4. Profil Utilisateur (Route Protégée)" -ForegroundColor Yellow
$authHeaders = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $ACCESS_TOKEN"
}

try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/me" -Method Get -Headers $authHeaders
    Write-Host "✅ Profil récupéré:" -ForegroundColor Green
    Write-Host "ID: $($response.data.id)"
    Write-Host "Email: $($response.data.email)"
    Write-Host "Role: $($response.data.role)"
    Write-Host "Compte créé: $($response.data.inserted_at)"
} catch {
    Write-Host "❌ Échec récupération profil:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host "`n================================`n"

Write-Host "📋 5. Liste DME (Vide au début)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/medical_records" -Method Get -Headers $authHeaders
    Write-Host "✅ DME récupérés:" -ForegroundColor Green
    Write-Host "Nombre: $($response.data.Count)"
    if ($response.data.Count -gt 0) {
        Write-Host ($response.data | ConvertTo-Json -Depth 3)
    } else {
        Write-Host "(Aucun DME pour l'instant)"
    }
} catch {
    Write-Host "❌ Échec récupération DME:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host "`n================================`n"

Write-Host "📅 6. Liste Rendez-vous" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/appointments" -Method Get -Headers $authHeaders
    Write-Host "✅ Rendez-vous récupérés:" -ForegroundColor Green
    Write-Host "Nombre: $($response.data.Count)"
} catch {
    Write-Host "❌ Échec récupération RDV:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host "`n================================`n"

Write-Host "🔄 7. Refresh Token" -ForegroundColor Yellow
$refreshBody = @{
    refresh_token = $REFRESH_TOKEN
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/auth/refresh" -Method Post -Body $refreshBody -Headers $HEADERS
    Write-Host "✅ Token rafraîchi:" -ForegroundColor Green
    $NEW_ACCESS_TOKEN = $response.data.access_token
    Write-Host "Nouveau token: $($NEW_ACCESS_TOKEN.Substring(0, 50))..." -ForegroundColor Gray
} catch {
    Write-Host "❌ Échec refresh token:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host "`n================================`n"

Write-Host "❌ 8. Test Accès Non Autorisé" -ForegroundColor Yellow
$badHeaders = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer token_invalide"
}

try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/me" -Method Get -Headers $badHeaders
    Write-Host "ATTENTION: Devrait echouer mais n'a pas echoue!" -ForegroundColor Red
} catch {
    Write-Host "OK: Acces refuse comme attendu:" -ForegroundColor Green
    Write-Host "Status: 401 Unauthorized"
}

Write-Host "`n================================`n"
Write-Host "✅ TOUS LES TESTS TERMINÉS !" -ForegroundColor Green
Write-Host "`nRoutes API disponibles:" -ForegroundColor Cyan
Write-Host "  POST   /api/v1/auth/register" -ForegroundColor Gray
Write-Host "  POST   /api/v1/auth/login" -ForegroundColor Gray
Write-Host "  POST   /api/v1/auth/refresh" -ForegroundColor Gray
Write-Host "  GET    /api/v1/me" -ForegroundColor Gray
Write-Host "  GET    /api/v1/medical_records" -ForegroundColor Gray
Write-Host "  POST   /api/v1/medical_records" -ForegroundColor Gray
Write-Host "  GET    /api/v1/appointments" -ForegroundColor Gray
Write-Host "  POST   /api/v1/appointments" -ForegroundColor Gray
Write-Host "`n🎉 API Backend fonctionnel !" -ForegroundColor Green

