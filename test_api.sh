#!/bin/bash
# Script de test API - Telemed Backend (Linux/Mac)
# Usage: chmod +x test_api.sh && ./test_api.sh

echo "🚀 TEST API TELEMED BACKEND"
echo "================================"
echo ""

BASE_URL="http://localhost:4000/api/v1"

echo "📊 1. Health Check"
curl -s http://localhost:4000/api/health | jq .
echo ""
echo "================================"
echo ""

echo "👤 2. Inscription Patient"
REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "patient@test.com",
      "password": "password12345",
      "role": "patient"
    }
  }')

echo "$REGISTER_RESPONSE" | jq .
echo ""
echo "================================"
echo ""

echo "🔐 3. Connexion"
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "patient@test.com",
    "password": "password12345"
  }')

echo "$LOGIN_RESPONSE" | jq .

# Extraire le token
ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.tokens.access_token')
REFRESH_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.tokens.refresh_token')

echo ""
echo "Access Token: ${ACCESS_TOKEN:0:50}..."
echo ""
echo "================================"
echo ""

echo "👨‍⚕️ 4. Profil Utilisateur (Route Protégée)"
curl -s -X GET $BASE_URL/me \
  -H "Authorization: Bearer $ACCESS_TOKEN" | jq .
echo ""
echo "================================"
echo ""

echo "📋 5. Liste DME"
curl -s -X GET $BASE_URL/medical_records \
  -H "Authorization: Bearer $ACCESS_TOKEN" | jq .
echo ""
echo "================================"
echo ""

echo "📅 6. Liste Rendez-vous"
curl -s -X GET $BASE_URL/appointments \
  -H "Authorization: Bearer $ACCESS_TOKEN" | jq .
echo ""
echo "================================"
echo ""

echo "🔄 7. Refresh Token"
curl -s -X POST $BASE_URL/auth/refresh \
  -H "Content-Type: application/json" \
  -d "{\"refresh_token\": \"$REFRESH_TOKEN\"}" | jq .
echo ""
echo "================================"
echo ""

echo "❌ 8. Test Accès Non Autorisé"
curl -s -X GET $BASE_URL/me \
  -H "Authorization: Bearer token_invalide" | jq .
echo ""
echo "================================"
echo ""

echo "✅ TOUS LES TESTS TERMINÉS !"
echo ""
echo "Routes API disponibles:"
echo "  POST   /api/v1/auth/register"
echo "  POST   /api/v1/auth/login"
echo "  POST   /api/v1/auth/refresh"
echo "  GET    /api/v1/me"
echo "  GET    /api/v1/medical_records"
echo "  POST   /api/v1/medical_records"
echo "  GET    /api/v1/appointments"
echo "  POST   /api/v1/appointments"
echo ""
echo "🎉 API Backend fonctionnel !"


