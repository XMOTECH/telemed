# 📚 Documentation API Telemed Backend

## 🚀 Démarrage Rapide

### 1. Démarrer le Serveur

```bash
mix phx.server
```

Le serveur démarre sur `http://localhost:4000`

---

## 📖 Documentation Interactive

### 🔷 Swagger UI (Recommandé)

Interface interactive pour tester l'API :

**URL** : http://localhost:4000/swaggerui

**Fonctionnalités** :
- ✅ Documentation complète de tous les endpoints
- ✅ Tester les requêtes directement dans le navigateur
- ✅ Voir les modèles de données (schemas)
- ✅ Authentification JWT intégrée

**Comment utiliser :**

1. Ouvrir http://localhost:4000/swaggerui
2. Tester `/auth/login` pour obtenir un token
3. Cliquer sur "Authorize" (cadenas) en haut à droite
4. Coller le token reçu
5. Tester les endpoints protégés !

---

### 🔷 OpenAPI Spec JSON

Spécification OpenAPI 3.0 brute :

**URL** : http://localhost:4000/api/openapi

Utilisable avec :
- Postman (Import OpenAPI)
- Insomnia
- Générateurs de code client (openapi-generator)

---

## 📮 Postman Collection

### Importation

**Fichiers fournis** :
- `Telemed_API.postman_collection.json` - Collection complète (50+ requêtes)
- `Telemed_Local.postman_environment.json` - Variables d'environnement

**Étapes** :

1. Ouvrir Postman Desktop
2. **Import** > Upload Files
3. Sélectionner les 2 fichiers JSON
4. Choisir l'environnement "Telemed Local" (coin supérieur droit)
5. C'est prêt ! 🎉

### Workflow Postman

#### 1️⃣ **Register Patient**
```
POST {{base_url}}/auth/register
```
✅ Crée automatiquement les variables `access_token`, `refresh_token`, `user_id`

#### 2️⃣ **Login**
```
POST {{base_url}}/auth/login
```
✅ Met à jour les tokens automatiquement

#### 3️⃣ **Tester Endpoints Protégés**

Tous les endpoints utilisent automatiquement le token de l'environnement !

```
GET {{base_url}}/me                      # Profil
GET {{base_url}}/medical_records         # DME
GET {{base_url}}/appointments            # RDV
```

---

## 🔐 Authentification JWT

### Workflow

```
1. Register/Login
   POST /api/v1/auth/register ou /login
   
   Response:
   {
     "data": {
       "user": {...},
       "tokens": {
         "access_token": "eyJhbGc...",  ← Utiliser celui-ci
         "refresh_token": "eyJhbGc...",
         "expires_in": 3600  (1 heure)
       }
     }
   }

2. Utiliser le Token
   Authorization: Bearer eyJhbGc...
   
3. Refresh quand expiré (après 1h)
   POST /api/v1/auth/refresh
   Body: {"refresh_token": "..."}
```

### Exemple cURL

```bash
# 1. Login
curl -X POST http://localhost:4000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "patient@test.com",
    "password": "password12345"
  }'

# 2. Utiliser le token
TOKEN="eyJhbGc..."  # Copier le token reçu

curl http://localhost:4000/api/v1/me \
  -H "Authorization: Bearer $TOKEN"
```

---

## 📋 Endpoints Principaux

### 🟢 Publics (sans auth)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/health` | Health check |
| POST | `/api/v1/auth/register` | Inscription |
| POST | `/api/v1/auth/login` | Connexion |
| POST | `/api/v1/auth/refresh` | Refresh token |
| POST | `/api/v1/auth/forgot_password` | Mot de passe oublié |

### 🔒 Protégés (auth requise)

#### 👤 User Profile

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/v1/me` | Profil courant |
| PUT | `/api/v1/me` | Modifier profil |

#### 📋 Medical Records (DME)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/v1/medical_records` | Liste DME |
| POST | `/api/v1/medical_records` | Créer DME (doctor) |
| GET | `/api/v1/medical_records/:id` | Afficher DME |
| PUT | `/api/v1/medical_records/:id` | Modifier DME (doctor) |
| DELETE | `/api/v1/medical_records/:id` | Supprimer DME (admin/doctor) |
| GET | `/api/v1/patients/:id/medical_records` | DME d'un patient (doctor/admin) |

#### 📅 Appointments (RDV)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/v1/appointments` | Liste RDV |
| POST | `/api/v1/appointments` | Créer RDV |
| GET | `/api/v1/appointments/:id` | Afficher RDV |
| PUT | `/api/v1/appointments/:id` | Modifier RDV |
| DELETE | `/api/v1/appointments/:id` | Supprimer RDV |
| POST | `/api/v1/appointments/:id/confirm` | Confirmer RDV (doctor) |
| POST | `/api/v1/appointments/:id/cancel` | Annuler RDV |

#### 🔔 Notifications

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/v1/notifications` | Liste notifications |
| PUT | `/api/v1/notifications/:id/read` | Marquer comme lu |

---

## 📊 Modèles de Données

### User

```json
{
  "id": 1,
  "email": "patient@test.com",
  "role": "patient",  // "patient", "doctor", "admin"
  "confirmed_at": "2025-10-18T10:00:00Z",
  "inserted_at": "2025-10-18T10:00:00Z",
  "updated_at": "2025-10-18T10:00:00Z"
}
```

### Medical Record (DME)

```json
{
  "id": 1,
  "nom": "Jean Dupont",
  "age": 45,
  "category": "consultation",  // "consultation", "exam", "treatment", etc.
  "priority": "normal",  // "low", "normal", "high", "urgent"
  "status": "active",
  "soap": {
    "subjective": "Patient se plaint de...",  // S
    "objective": "Tension: 130/85...",        // O
    "assessment": "Diagnostic probable...",   // A
    "plan": "Traitement prescrit..."          // P
  },
  "tags": ["hypertension", "suivi"],
  "consultation_date": "2025-10-18T14:00:00Z",
  "patient_id": 1,
  "doctor_id": 2,
  "inserted_at": "2025-10-18T14:00:00Z",
  "updated_at": "2025-10-18T14:30:00Z"
}
```

### Appointment (RDV)

```json
{
  "id": 1,
  "patient_id": 1,
  "doctor_id": 2,
  "scheduled_at": "2025-10-25T14:00:00Z",
  "status": "pending",  // "pending", "confirmed", "cancelled", "completed"
  "notes": "Consultation de suivi",
  "inserted_at": "2025-10-18T10:00:00Z",
  "updated_at": "2025-10-18T10:00:00Z"
}
```

---

## 🧪 Tests Automatisés

### Script PowerShell

```bash
powershell -ExecutionPolicy Bypass -File test_api_simple.ps1
```

Teste automatiquement :
- ✅ Health check
- ✅ Register
- ✅ Login
- ✅ Get profile
- ✅ List DME
- ✅ List appointments
- ✅ Unauthorized access (401)

---

## 🐛 Debugging

### Logs Serveur

```bash
# Démarrer avec logs détaillés
LOG_LEVEL=debug mix phx.server
```

### Erreurs Communes

#### 401 Unauthorized

```json
{
  "error": {"message": "unauthenticated"}
}
```

**Solution** : Token manquant ou expiré
- Vérifier header `Authorization: Bearer {token}`
- Refresh le token si expiré (>1h)

#### 403 Forbidden

```json
{
  "error": {"message": "Accès interdit"}
}
```

**Solution** : Permissions insuffisantes
- Patient ne peut pas créer de DME
- Seul doctor/admin peut confirmer RDV

#### 404 Not Found

```json
{
  "error": {"message": "Ressource non trouvée"}
}
```

**Solution** : ID invalide ou ressource supprimée

---

## 🔧 Configuration

### CORS

Origines autorisées (voir `router.ex`) :
- `http://localhost:3000` (React dev)
- `http://localhost:5173` (Vite dev)
- `https://app.telemed.fr` (production)

### JWT

Configuration (`config/config.exs`) :
- **Access token** : 1 heure
- **Refresh token** : 30 jours
- **Algorithme** : HS256

---

## 📞 Support

**Issues** : GitHub Issues  
**Email** : support@telemed.fr  
**Documentation** : http://localhost:4000/swaggerui

---

## ✅ Checklist Tests

- [ ] Health check fonctionne
- [ ] Register patient réussit
- [ ] Register doctor réussit
- [ ] Login retourne des tokens
- [ ] GET /me avec token fonctionne
- [ ] GET /me sans token échoue (401)
- [ ] Refresh token fonctionne
- [ ] Créer DME (doctor) réussit
- [ ] Créer DME (patient) échoue (403)
- [ ] Créer RDV réussit
- [ ] Confirmer RDV (doctor) réussit
- [ ] Liste notifications fonctionne

---

**🎉 Documentation Complète ! Backend API Production-Ready !**


