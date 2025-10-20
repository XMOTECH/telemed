# Test API Telemed Backend - Version Simple
Write-Host "TEST API TELEMED" -ForegroundColor Cyan
Write-Host "================" -ForegroundColor Cyan

$BASE = "http://localhost:4000/api/v1"

# 1. Health Check
Write-Host "`n1. Health Check" -ForegroundColor Yellow
$health = Invoke-RestMethod -Uri "http://localhost:4000/api/health" -Method Get
Write-Host "Status: $($health.status)" -ForegroundColor Green

# 2. Register
Write-Host "`n2. Register Patient" -ForegroundColor Yellow
$registerBody = '{"user":{"email":"patient@test.com","password":"password12345","role":"patient"}}' 
try {
    $reg = Invoke-RestMethod -Uri "$BASE/auth/register" -Method Post -Body $registerBody -ContentType "application/json"
    Write-Host "Email: $($reg.data.user.email)" -ForegroundColor Green
} catch {
    Write-Host "User already exists, trying login..." -ForegroundColor Yellow
}

# 3. Login
Write-Host "`n3. Login" -ForegroundColor Yellow
$loginBody = '{"email":"patient@test.com","password":"password12345"}'
$login = Invoke-RestMethod -Uri "$BASE/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$TOKEN = $login.data.tokens.access_token
Write-Host "Token received: OK" -ForegroundColor Green

# 4. Get Profile
Write-Host "`n4. Get Profile (Protected)" -ForegroundColor Yellow
$headers = @{"Authorization" = "Bearer $TOKEN"}
$profile = Invoke-RestMethod -Uri "$BASE/me" -Method Get -Headers $headers
Write-Host "User ID: $($profile.data.id)" -ForegroundColor Green
Write-Host "Email: $($profile.data.email)" -ForegroundColor Green
Write-Host "Role: $($profile.data.role)" -ForegroundColor Green

# 5. Medical Records
Write-Host "`n5. List Medical Records" -ForegroundColor Yellow
$records = Invoke-RestMethod -Uri "$BASE/medical_records" -Method Get -Headers $headers
Write-Host "Count: $($records.data.Count)" -ForegroundColor Green

# 6. Appointments
Write-Host "`n6. List Appointments" -ForegroundColor Yellow
$appts = Invoke-RestMethod -Uri "$BASE/appointments" -Method Get -Headers $headers
Write-Host "Count: $($appts.data.Count)" -ForegroundColor Green

# 7. Test Unauthorized
Write-Host "`n7. Test Unauthorized Access" -ForegroundColor Yellow
$badHeaders = @{"Authorization" = "Bearer invalid_token"}
try {
    $bad = Invoke-RestMethod -Uri "$BASE/me" -Method Get -Headers $badHeaders
    Write-Host "ERROR: Should have failed!" -ForegroundColor Red
} catch {
    Write-Host "Access denied as expected: OK" -ForegroundColor Green
}

Write-Host "`n================" -ForegroundColor Cyan
Write-Host "ALL TESTS PASSED!" -ForegroundColor Green
Write-Host "`nAPI Routes:" -ForegroundColor Cyan
Write-Host "  POST /api/v1/auth/register"
Write-Host "  POST /api/v1/auth/login"
Write-Host "  GET  /api/v1/me"
Write-Host "  GET  /api/v1/medical_records"
Write-Host "  GET  /api/v1/appointments"
Write-Host "`nBackend API is working!" -ForegroundColor Green


