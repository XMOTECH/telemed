# 🎯 WORKFLOW SWAGGER VISUEL - Guide Complet

**URL Swagger**: http://localhost:4001/swaggerui  
**Durée**: 5 minutes  
**Niveau**: Débutant

---

## 📸 WORKFLOW EN IMAGES (Conceptuel)

### ÉTAPE 1: Ouvrir Swagger UI

```
┌─────────────────────────────────────────────────────────┐
│  🏥 Telemed API - Télémédecine & DME  v1.0             │
│  http://localhost:4001/swaggerui                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Servers: [Development ▼] http://localhost:4001/api/v1  │
│                                                          │
│  [Authorize 🔒]  ← Cliquer ici plus tard                │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  🔐 Authentication                                │  │
│  │  ├─ POST /api/v1/auth/register  ← COMMENCER ICI  │  │
│  │  ├─ POST /api/v1/auth/login                       │  │
│  │  ├─ POST /api/v1/auth/refresh                     │  │
│  │  └─ POST /api/v1/auth/forgot_password             │  │
│  ├────────────────────────────────────────────────────┤
│  │  👤 Users                                          │  │
│  │  ├─ GET  /api/v1/me                               │  │
│  │  └─ PUT  /api/v1/me                               │  │
│  ├────────────────────────────────────────────────────┤
│  │  📋 Medical Records                                │  │
│  │  ├─ GET  /api/v1/medical_records                  │  │
│  │  ├─ POST /api/v1/medical_records                  │  │
│  │  └─ ...                                            │  │
│  ├────────────────────────────────────────────────────┤
│  │  📅 Appointments                                   │  │
│  │  ├─ GET  /api/v1/appointments                     │  │
│  │  ├─ POST /api/v1/appointments                     │  │
│  │  └─ ...                                            │  │
│  └────────────────────────────────────────────────────┘
└─────────────────────────────────────────────────────────┘
```

---

### ÉTAPE 2: Créer un Compte (Register)

```
┌─────────────────────────────────────────────────────────┐
│  🔐 Authentication                                       │
│  ├─ POST /api/v1/auth/register   [Développer ▼]        │
└─────────────────────────────────────────────────────────┘

Cliquer sur "POST /api/v1/auth/register" pour développer:

┌─────────────────────────────────────────────────────────┐
│  POST /api/v1/auth/register                             │
│  🔐 Inscription utilisateur                              │
│                                                          │
│  Créer un nouveau compte utilisateur sur la plateforme.  │
│                                                          │
│  Rôles disponibles:                                     │
│  - patient: Utilisateur standard                        │
│  - doctor: Professionnel de santé                       │
│  - admin: Administrateur                                │
│                                                          │
│  [Try it out]  ← CLIQUER ICI                            │
│                                                          │
│  Request body (application/json)                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │ {                                                 │  │
│  │   "user": {                                       │  │
│  │     "email": "patient@telemed.fr",               │  │
│  │     "password": "MotDePasse123!",   ← Modifier   │  │
│  │     "role": "patient",                           │  │
│  │     "first_name": "Jean",                        │  │
│  │     "last_name": "Dupont"                        │  │
│  │   }                                               │  │
│  │ }                                                 │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  [Execute]  ← CLIQUER ICI POUR ENVOYER                  │
└─────────────────────────────────────────────────────────┘
```

---

### ÉTAPE 3: Voir la Réponse

```
┌─────────────────────────────────────────────────────────┐
│  Server response                                         │
│                                                          │
│  Code: 201  Description: ✅ Compte créé avec succès     │
│                                                          │
│  Response body  [Download ▼]                            │
│  ┌──────────────────────────────────────────────────┐  │
│  │ {                                                 │  │
│  │   "data": {                                       │  │
│  │     "user": {                                     │  │
│  │       "id": 1,                                    │  │
│  │       "email": "patient@telemed.fr",             │  │
│  │       "role": "patient"                          │  │
│  │     },                                            │  │
│  │     "tokens": {                                   │  │
│  │       "access_token": "eyJhbGciOi...",  ← COPIER │  │
│  │       "refresh_token": "eyJhbGciOi...",          │  │
│  │       "token_type": "Bearer",                    │  │
│  │       "expires_in": 3600                         │  │
│  │     }                                             │  │
│  │   }                                               │  │
│  │ }                                                 │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ✅ ACTION: COPIER le "access_token" complet            │
│     (tout le texte: eyJhbGciOiJ...)                     │
└─────────────────────────────────────────────────────────┘
```

---

### ÉTAPE 4: Autoriser avec le Token

```
┌─────────────────────────────────────────────────────────┐
│  Haut de page:                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │  Servers ▼  [Authorize 🔒]  ← CLIQUER ICI      │    │
│  └────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘

Popup s'ouvre:

┌─────────────────────────────────────────────────────────┐
│  Available authorizations                               │
│                                                          │
│  bearer (http, Bearer)                                  │
│  Authentification JWT via header Authorization          │
│                                                          │
│  Format: Authorization: Bearer {access_token}           │
│                                                          │
│  Value: ┌─────────────────────────────────────────┐    │
│         │ Bearer eyJhbGciOiJIUzI1NiIsInR5c...    │    │
│         └─────────────────────────────────────────┘    │
│         ↑ COLLER ICI (avec "Bearer " devant!)          │
│                                                          │
│  [Authorize]  ← CLIQUER                                 │
│  [Close]                                                │
└─────────────────────────────────────────────────────────┘

Après clic sur Authorize:

┌─────────────────────────────────────────────────────────┐
│  bearer (http, Bearer)                                  │
│  ✅ Authorized                                          │
│  [Logout]  [Close]  ← CLIQUER Close                     │
└─────────────────────────────────────────────────────────┘
```

---

### ÉTAPE 5: Tester Endpoint Protégé

Maintenant tous les endpoints avec 🔒 sont accessibles !

```
┌─────────────────────────────────────────────────────────┐
│  👤 Users                                                │
│  ├─ GET /api/v1/me  🔒  [Développer ▼]                  │
└─────────────────────────────────────────────────────────┘

Après développement:

┌─────────────────────────────────────────────────────────┐
│  GET /api/v1/me                                         │
│  👤 Profil utilisateur courant                           │
│                                                          │
│  Récupère les informations du compte connecté           │
│                                                          │
│  [Try it out]  ← CLIQUER                                │
│                                                          │
│  Parameters: (aucun)                                    │
│                                                          │
│  [Execute]  ← CLIQUER                                   │
└─────────────────────────────────────────────────────────┘

Réponse:

┌─────────────────────────────────────────────────────────┐
│  Code: 200  ✅ Profil récupéré                          │
│                                                          │
│  {                                                       │
│    "data": {                                            │
│      "id": 1,                                           │
│      "email": "patient@telemed.fr",                    │
│      "role": "patient",                                │
│      "first_name": "Jean",                             │
│      "last_name": "Dupont"                             │
│    }                                                    │
│  }                                                       │
│                                                          │
│  ✅ C'EST BON ! L'authentification fonctionne !         │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 WORKFLOW COMPLET ILLUSTRÉ

### Scénario: Patient prend un RDV

```
┌──────────────┐
│ 1. REGISTER  │ POST /api/v1/auth/register
└──────┬───────┘        ↓
       │           {user: {email, password, role: "patient"}}
       │                ↓
       │           ✅ 201 Created
       │                ↓
       │           {"data": {"tokens": {"access_token": "..."}}}
       │                ↓
       ↓           COPIER access_token
┌──────────────┐
│ 2. AUTHORIZE │ Cliquer 🔒 en haut
└──────┬───────┘        ↓
       │           Coller: Bearer {access_token}
       │                ↓
       │           Cliquer "Authorize"
       │                ↓
       │           ✅ Authorized
       │                ↓
       ↓           Cliquer "Close"
┌──────────────┐
│ 3. GET /me   │ GET /api/v1/me
└──────┬───────┘        ↓
       │           Try it out → Execute
       │                ↓
       │           ✅ 200 OK
       │                ↓
       │           {"data": {"id": 1, "email": "..."}}
       │                ↓
       ↓           ✅ Auth fonctionne !
┌──────────────┐
│ 4. CREATE    │ POST /api/v1/appointments
│   APPT       │        ↓
└──────┬───────┘ {appointment: {doctor_id: 2, scheduled_at: "..."}}
       │                ↓
       │           Try it out → Execute
       │                ↓
       │           ✅ 201 Created
       │                ↓
       │           {"data": {"id": 1, "status": "pending"}}
       │                ↓
       ↓           ✅ RDV créé !
┌──────────────┐
│ 5. LIST      │ GET /api/v1/appointments
│   APPTS      │        ↓
└──────┬───────┘ Try it out → Execute
       │                ↓
       │           ✅ 200 OK
       │                ↓
       │           {"data": [{"id": 1, "status": "pending", ...}]}
       │                ↓
       ↓           ✅ Voir tous ses RDV !
┌──────────────┐
│ 6. NOTIFS    │ GET /api/v1/notifications
└──────┬───────┘        ↓
       │           Try it out → Execute
       │                ↓
       │           ✅ 200 OK
       │                ↓
       │           {"data": [{"title": "RDV créé", ...}]}
       │                ↓
       ↓           ✅ Toutes les notifications !
┌──────────────┐
│   SUCCESS!   │ Workflow complet testé ✅
└──────────────┘
```

---

## 🎨 INTERFACE SWAGGER - ZONES CLÉS

```
┌────────────────────────────────────────────────────────────┐
│  Telemed API                                    [🔒]     │ ← Zone 1: Authorize
├────────────────────────────────────────────────────────────┤
│                                                             │
│  Servers: [Development ▼]  http://localhost:4001/api/v1   │ ← Zone 2: Serveur
│                                                             │
│  ┌──────────────────────────────────────────────────────┐ │
│  │ 🔐 Authentication                          [Filter] │ │ ← Zone 3: Sections (tags)
│  └──────────────────────────────────────────────────────┘ │
│  │                                                        │
│  ├─ POST /api/v1/auth/register                          │ ← Zone 4: Endpoints
│  │  🔐 Inscription utilisateur                           │
│  │  [Développer pour voir détails]                      │
│  │                                                        │
│  ├─ POST /api/v1/auth/login                             │
│  │  🔑 Connexion utilisateur                             │
│  │                                                        │
│  ┌──────────────────────────────────────────────────────┐ │
│  │ 👤 Users                                    🔒       │ │
│  └──────────────────────────────────────────────────────┘ │
│  │                                                        │
│  ├─ GET /api/v1/me                              🔒      │ ← Zone 5: Auth requis
│  │  👤 Profil utilisateur courant                        │
│  │                                                        │
│  ┌──────────────────────────────────────────────────────┐ │
│  │ 📋 Medical Records                          🔒       │ │
│  └──────────────────────────────────────────────────────┘ │
│  │                                                        │
│  ├─ GET  /api/v1/medical_records                🔒      │
│  ├─ POST /api/v1/medical_records                🔒      │
│  │                                                        │
└────────────────────────────────────────────────────────────┘
                        │
                        ↓ Scroll en bas
                        │
┌────────────────────────────────────────────────────────────┐
│  Schemas                                                   │ ← Zone 6: Modèles données
│  ├─ RegisterRequest                                       │
│  ├─ LoginRequest                                          │
│  ├─ AuthResponse                                          │
│  ├─ MedicalRecordResponse                                 │
│  └─ AppointmentResponse                                   │
└────────────────────────────────────────────────────────────┘
```

---

## 📋 CHECKLIST WORKFLOW

### Pour tester un endpoint protégé

```
Checklist complète:

1. ☐ Ouvrir http://localhost:4001/swaggerui

2. ☐ Créer compte:
   - Développer "POST /auth/register"
   - "Try it out"
   - Modifier JSON (email unique!)
   - "Execute"
   - Vérifier 201 Created

3. ☐ Copier token:
   - Dans la réponse
   - Copier "access_token"
   - (tout le texte eyJhbG...)

4. ☐ Autoriser:
   - Cliquer 🔒 "Authorize" (en haut)
   - Coller: Bearer {token}
   - "Authorize"
   - Vérifier ✅ Authorized
   - "Close"

5. ☐ Tester endpoint:
   - Exemple: GET /me
   - "Try it out"
   - "Execute"
   - Vérifier 200 OK

✅ Si toutes les étapes OK → Workflow validé !
```

---

## 💡 ASTUCES VISUELLES

### Repérer rapidement

| Symbole | Signification |
|---------|---------------|
| 🔒 | Endpoint protégé (auth requise) |
| 🟢 POST | Créer une ressource |
| 🔵 GET | Lire/Récupérer données |
| 🟡 PUT | Modifier ressource |
| 🔴 DELETE | Supprimer ressource |
| ✅ 200/201 | Succès |
| ⚠️ 422 | Erreur validation |
| ❌ 401 | Non authentifié |
| 🔒 403 | Permissions insuffisantes |

---

## 🎯 WORKFLOW PAR RÔLE

### 👤 PATIENT

```
1. Register (role: "patient")
   ↓
2. Authorize
   ↓
3. GET /me                        ✅
4. POST /appointments             ✅ Créer RDV
5. GET /appointments              ✅ Voir ses RDV
6. GET /medical_records           ✅ Voir ses DME
7. POST /medical_records          ❌ Interdit (403)
8. GET /notifications             ✅
```

### 👨‍⚕️ DOCTOR

```
1. Register (role: "doctor")
   ↓
2. Authorize
   ↓
3. GET /me                        ✅
4. POST /medical_records          ✅ Créer DME
5. GET /medical_records           ✅ Voir DME patients
6. POST /appointments             ✅
7. POST /appointments/:id/confirm ✅ Confirmer RDV
8. GET /notifications             ✅
```

### 👑 ADMIN

```
1. Login (role: "admin")
   ↓
2. Authorize
   ↓
3. Tous les endpoints          ✅ Accès complet
```

---

## 🔄 CYCLE DE VIE TOKEN

```
Register/Login
     ↓
┌────────────────┐
│  access_token  │ Valide 1h
└────────┬───────┘
         │
         ├─→ GET /me              ✅ OK
         ├─→ POST /appointments   ✅ OK
         ├─→ GET /medical_records ✅ OK
         │
         ↓ Après 1h...
         │
┌────────────────┐
│  401 Error     │ Token expiré
└────────┬───────┘
         │
         ↓
POST /auth/refresh
avec refresh_token
         ↓
┌────────────────┐
│ Nouveau token  │ Valide 1h
└────────┬───────┘
         │
         ├─→ Réutiliser endpoints  ✅
         │
         ↓ Répéter...
```

---

## 📊 COMPARAISON RÉPONSES

### ✅ Succès (200, 201)

```
Code: 200 OK
{
  "data": {
    "id": 1,
    "email": "patient@telemed.fr",
    ...
  }
}

🟢 Fond vert dans Swagger
✅ Données retournées
```

### ⚠️ Erreur Validation (422)

```
Code: 422 Unprocessable Entity
{
  "error": {
    "message": "Erreur de validation",
    "details": {
      "email": ["has already been taken"],
      "password": ["should be at least 12 character(s)"]
    }
  }
}

🟡 Fond jaune/orange
⚠️ Vérifier données envoyées
```

### ❌ Erreur Auth (401)

```
Code: 401 Unauthorized
{
  "error": {
    "message": "Authentification requise"
  }
}

🔴 Fond rouge
❌ Token manquant ou invalide
→ Solution: Re-autoriser 🔒
```

### 🔒 Erreur Permissions (403)

```
Code: 403 Forbidden
{
  "error": {
    "message": "Seuls les médecins peuvent créer des DME"
  }
}

🔴 Fond rouge
🔒 Rôle insuffisant
→ Solution: Utiliser compte avec bon rôle
```

---

## 🎮 RACCOURCIS UTILES

### Dans Swagger UI

| Action | Raccourci |
|--------|-----------|
| Ouvrir recherche | `/` |
| Execute requête | `Ctrl + Enter` |
| Fermer modal | `Esc` |
| Copier réponse | Clic droit sur JSON |
| Expand all | Cliquer "Expand Operations" |
| Collapse all | Cliquer "Collapse Operations" |

### Navigation rapide

```
# Aller directement à une section
http://localhost:4001/swaggerui#/Authentication
http://localhost:4001/swaggerui#/Medical%20Records
http://localhost:4001/swaggerui#/Appointments
```

---

## 📚 EXEMPLES WORKFLOWS MÉTIER

### Workflow 1: Consultation Patient

```
Jour 1:
  1. Patient register
  2. Patient login → token
  3. POST /appointments (doctor_id: 2, scheduled_at: demain 14h)
  4. GET /notifications → "RDV créé, en attente confirmation"

Jour 1 (plus tard):
  5. Doctor login → token doctor
  6. GET /appointments → Voir nouveau RDV (status: pending)
  7. POST /appointments/1/confirm → Confirmer
  8. GET /notifications → "RDV confirmé"

Jour 2 (jour du RDV):
  9. Patient: GET /notifications → "RDV aujourd'hui à 14h"
  10. Doctor: GET /appointments/1 → Détails du RDV

Après consultation:
  11. Doctor: POST /medical_records → Créer compte-rendu SOAP
  12. Patient: GET /medical_records → Voir compte-rendu
```

---

### Workflow 2: Upload Document Médical

```
1. Doctor login → token

2. POST /medical_records
   → Créer DME patient
   → Récupérer ID (ex: 5)

3. Via Web UI (pas Swagger):
   → http://localhost:4001/medical_records/5
   → Cliquer "📎 Documents"
   → Upload ordonnance PDF

4. GET /medical_records/5
   → Voir DME avec documents liés

5. Patient login → token

6. GET /medical_records
   → Voir son DME

7. Via Web UI:
   → Télécharger ordonnance
```

---

## 🔍 DEBUG DANS SWAGGER

### Voir la requête cURL

Après "Execute", Swagger affiche :

```
Curl
┌──────────────────────────────────────────────────────┐
│ curl -X POST "http://localhost:4001/api/v1/auth/..  │
│   -H "accept: application/json" \                   │
│   -H "Content-Type: application/json" \             │
│   -d '{...}'                                        │
└──────────────────────────────────────────────────────┘

[Copy to clipboard]  ← Copier pour utiliser dans terminal
```

### Voir headers de réponse

```
Response headers
┌──────────────────────────────────────────────────────┐
│ content-type: application/json; charset=utf-8        │
│ cache-control: max-age=0, private, must-revalidate  │
│ x-request-id: FkTp8qKr_gvdU-8AAABh                  │
└──────────────────────────────────────────────────────┘
```

---

## ✅ VALIDATION COMPLÈTE

### Test tous les endpoints (20 min)

```
☐ Authentication
  ├─ ☐ POST /auth/register (patient)
  ├─ ☐ POST /auth/register (doctor)
  ├─ ☐ POST /auth/login
  ├─ ☐ POST /auth/refresh
  └─ ☐ POST /auth/forgot_password

☐ Users
  ├─ ☐ GET  /me
  └─ ☐ PUT  /me

☐ Medical Records
  ├─ ☐ GET  /medical_records (patient)
  ├─ ☐ GET  /medical_records (doctor)
  ├─ ☐ POST /medical_records (doctor)
  ├─ ☐ GET  /medical_records/:id
  ├─ ☐ PUT  /medical_records/:id
  └─ ☐ DELETE /medical_records/:id (admin)

☐ Appointments
  ├─ ☐ GET  /appointments
  ├─ ☐ POST /appointments
  ├─ ☐ GET  /appointments/:id
  ├─ ☐ POST /appointments/:id/confirm (doctor)
  └─ ☐ POST /appointments/:id/cancel

☐ Notifications
  ├─ ☐ GET  /notifications
  └─ ☐ PUT  /notifications/:id/read

☐ Health
  └─ ☐ GET  /health
```

---

## 🎯 BONNES PRATIQUES

### 1. Toujours tester dans cet ordre

```
1. Endpoints publics d'abord (auth)
2. Récupérer token
3. Autoriser
4. Endpoints protégés ensuite
```

### 2. Utiliser des données réalistes

```
❌ Mauvais:
email: "test@test.com"
nom: "Test Test"

✅ Bon:
email: "jean.dupont@telemed.fr"
nom: "Jean Dupont"
age: 45
```

### 3. Vérifier les codes de statut

```
201 = Créé (POST réussi)
200 = OK (GET/PUT réussi)
204 = No Content (DELETE réussi)
401 = Non authentifié
403 = Interdit (permissions)
404 = Non trouvé
422 = Erreur validation
```

### 4. Lire les descriptions

Chaque endpoint a :
- Summary (résumé court)
- Description (détails complets)
- Exemples
- Permissions
- Codes d'erreur

---

## 🎊 CONCLUSION

Swagger UI Telemed vous offre :

✅ **Interface interactive** pour tester l'API  
✅ **Documentation auto-générée** toujours à jour  
✅ **Exemples concrets** pour chaque endpoint  
✅ **Authentification intégrée** (un token pour tout)  
✅ **Export cURL** pour automatisation  
✅ **Schémas de données** complets  

**Accès**: http://localhost:4001/swaggerui

---

**Prêt à explorer l'API ! 🚀**

