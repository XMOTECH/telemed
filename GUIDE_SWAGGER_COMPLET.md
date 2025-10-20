# 📚 GUIDE SWAGGER UI COMPLET - Telemed API

**Version**: 1.0  
**Date**: 19 octobre 2025  
**URL Swagger**: http://localhost:4001/swaggerui

---

## 🚀 DÉMARRAGE RAPIDE (2 MINUTES)

### 1. Démarrer le serveur
```bash
mix phx.server
```

### 2. Ouvrir Swagger UI
```
http://localhost:4001/swaggerui
```

### 3. Workflow d'authentification

```
┌────────────────────────────────────────┐
│  WORKFLOW COMPLET TELEMED API          │
└────────────────────────────────────────┘

Étape 1: REGISTER (Créer compte)
  ↓ POST /api/v1/auth/register
  ↓ Body: { "user": { "email", "password", "role" } }
  ↓
  ✅ Réponse: { "data": { "user": {...}, "tokens": {...} } }
  ↓ Copier "access_token"

Étape 2: AUTHORIZE (Cliquer cadenas 🔒)
  ↓ Cliquer "Authorize" en haut à droite
  ↓ Entrer: Bearer {access_token}
  ↓ Cliquer "Authorize"
  ↓
  ✅ Vous êtes authentifié !

Étape 3: TESTER ENDPOINTS PROTÉGÉS
  ↓ GET /api/v1/me (profil)
  ↓ GET /api/v1/medical_records (DME)
  ↓ POST /api/v1/appointments (RDV)
  ↓
  ✅ Toutes les requêtes marchent !
```

---

## 📖 WORKFLOW DÉTAILLÉ ÉTAPE PAR ÉTAPE

### 🔹 ÉTAPE 1: Créer un Compte Patient

#### Dans Swagger UI

1. Cliquer sur **"Authentication"** (section verte)
2. Cliquer sur **"POST /api/v1/auth/register"**
3. Cliquer **"Try it out"**
4. Modifier le JSON exemple :

```json
{
  "user": {
    "email": "patient.test@telemed.fr",
    "password": "MonMotDePasse123!",
    "role": "patient",
    "first_name": "Jean",
    "last_name": "Dupont"
  }
}
```

5. Cliquer **"Execute"**
6. Vérifier réponse **201 Created** :

```json
{
  "data": {
    "user": {
      "id": 1,
      "email": "patient.test@telemed.fr",
      "role": "patient",
      ...
    },
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiIs...",  ← COPIER CECI
      "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
      "token_type": "Bearer",
      "expires_in": 3600
    }
  }
}
```

7. **COPIER** le `access_token` (tout le texte après les guillemets)

---

### 🔹 ÉTAPE 2: S'Authentifier dans Swagger

1. Cliquer sur **"Authorize" 🔒** (bouton en haut à droite)

2. Fenêtre popup s'ouvre :
   ```
   Available authorizations
   
   bearer (http, Bearer)
   Value: [_____________]
   ```

3. Coller :
   ```
   Bearer eyJhbGciOiJIUzI1NiIs...
   ```
   ⚠️ **Important** : Bien mettre "Bearer " (avec espace) avant le token !

4. Cliquer **"Authorize"**

5. Fenêtre affiche : ✅ **"Authorized"**

6. Cliquer **"Close"**

🎉 **Vous êtes maintenant authentifié pour tous les endpoints protégés !**

---

### 🔹 ÉTAPE 3: Tester les Endpoints Protégés

#### A. Récupérer son profil

1. Section **"Users"** → **GET /api/v1/me**
2. "Try it out" → "Execute"
3. Réponse **200 OK** :

```json
{
  "data": {
    "id": 1,
    "email": "patient.test@telemed.fr",
    "role": "patient",
    "first_name": "Jean",
    "last_name": "Dupont"
  }
}
```

✅ **Succès ! L'auth fonctionne !**

---

#### B. Créer un Rendez-vous

1. Section **"Appointments"** → **POST /api/v1/appointments**
2. "Try it out"
3. Modifier le JSON :

```json
{
  "appointment": {
    "doctor_id": 2,
    "scheduled_at": "2025-10-25T14:00:00Z",
    "notes": "Consultation de suivi pour hypertension"
  }
}
```

4. "Execute"
5. Réponse **201 Created** :

```json
{
  "data": {
    "id": 1,
    "patient_id": 1,
    "doctor_id": 2,
    "scheduled_at": "2025-10-25T14:00:00Z",
    "status": "pending",
    "notes": "Consultation de suivi pour hypertension"
  }
}
```

✅ **Rendez-vous créé !**

---

#### C. Lister ses Rendez-vous

1. Section **"Appointments"** → **GET /api/v1/appointments**
2. "Try it out" → "Execute"
3. Réponse **200 OK** avec liste

```json
{
  "data": [
    {
      "id": 1,
      "scheduled_at": "2025-10-25T14:00:00Z",
      "status": "pending",
      ...
    }
  ]
}
```

---

### 🔹 ÉTAPE 4: Tester en tant que Médecin

#### A. Créer compte docteur

1. Refaire **POST /api/v1/auth/register** avec :

```json
{
  "user": {
    "email": "doctor.test@telemed.fr",
    "password": "MotDePasseDoctor123!",
    "role": "doctor",
    "first_name": "Dr. Marie",
    "last_name": "Martin"
  }
}
```

2. Copier le nouveau `access_token`

3. **Re-Authorize** avec le token du doctor (🔒 → Logout → Re-authorize)

---

#### B. Créer un DME (réservé médecins)

1. Section **"Medical Records"** → **POST /api/v1/medical_records**
2. "Try it out"
3. JSON complet SOAP :

```json
{
  "medical_record": {
    "user_id": 1,
    "nom": "Jean Dupont",
    "age": 45,
    "category": "consultation",
    "priority": "normal",
    "soap_subjective": "Patient se plaint de maux de tête persistants depuis 3 jours. Intensité 7/10.",
    "soap_objective": "Tension: 130/85 mmHg, Température: 37.2°C, Pouls: 75 bpm. Pas de raideur nuque.",
    "soap_assessment": "Probable céphalée de tension. Pas de signe neurologique.",
    "soap_plan": "Paracétamol 1g 3x/jour x 5j. Revoir si aggravation.",
    "tags": ["céphalée", "suivi", "prescription"]
  }
}
```

4. "Execute"
5. Réponse **201 Created**

✅ **DME créé avec structure SOAP complète !**

---

#### C. Lister les DME de ses patients

1. **GET /api/v1/medical_records**
2. "Execute"
3. Voir tous les DME des patients du médecin

```json
{
  "data": [
    {
      "id": 1,
      "nom": "Jean Dupont",
      "soap": {
        "subjective": "Maux de tête...",
        "objective": "Tension: 130/85...",
        "assessment": "Céphalée de tension",
        "plan": "Paracétamol 1g..."
      },
      ...
    }
  ]
}
```

---

### 🔹 ÉTAPE 5: Rafraîchir le Token (après 1h)

Votre `access_token` expire après **1 heure**. Pour continuer :

1. Section **"Authentication"** → **POST /api/v1/auth/refresh**
2. "Try it out"
3. Body :

```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

4. "Execute"
5. Réponse avec nouveau `access_token`
6. **Re-Authorize** avec le nouveau token

✅ **Session prolongée de 1h !**

---

## 🎯 ENDPOINTS DISPONIBLES

### 🔐 Authentication (Publics)

| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| POST | `/api/v1/auth/register` | Créer un compte | ❌ |
| POST | `/api/v1/auth/login` | Se connecter | ❌ |
| POST | `/api/v1/auth/refresh` | Rafraîchir token | ❌ |
| POST | `/api/v1/auth/forgot_password` | Mot de passe oublié | ❌ |

### 👤 Users (Protégés)

| Méthode | Endpoint | Description | Rôle |
|---------|----------|-------------|------|
| GET | `/api/v1/me` | Profil courant | Tous |
| PUT | `/api/v1/me` | Modifier profil | Tous |

### 📋 Medical Records (Protégés)

| Méthode | Endpoint | Description | Rôle |
|---------|----------|-------------|------|
| GET | `/api/v1/medical_records` | Liste DME | Tous |
| POST | `/api/v1/medical_records` | Créer DME | Doctor |
| GET | `/api/v1/medical_records/:id` | Afficher DME | Patient/Doctor |
| PUT | `/api/v1/medical_records/:id` | Modifier DME | Doctor |
| DELETE | `/api/v1/medical_records/:id` | Supprimer DME | Admin/Doctor |
| GET | `/api/v1/patients/:id/medical_records` | DME d'un patient | Doctor/Admin |

### 📅 Appointments (Protégés)

| Méthode | Endpoint | Description | Rôle |
|---------|----------|-------------|------|
| GET | `/api/v1/appointments` | Liste RDV | Tous |
| POST | `/api/v1/appointments` | Créer RDV | Tous |
| GET | `/api/v1/appointments/:id` | Afficher RDV | Patient/Doctor |
| PUT | `/api/v1/appointments/:id` | Modifier RDV | Patient/Doctor |
| DELETE | `/api/v1/appointments/:id` | Supprimer RDV | Patient/Doctor |
| POST | `/api/v1/appointments/:id/confirm` | Confirmer RDV | Doctor |
| POST | `/api/v1/appointments/:id/cancel` | Annuler RDV | Tous |

### 🔔 Notifications (Protégés)

| Méthode | Endpoint | Description | Rôle |
|---------|----------|-------------|------|
| GET | `/api/v1/notifications` | Liste notifications | Tous |
| PUT | `/api/v1/notifications/:id/read` | Marquer lu | Tous |

### ❤️ Health (Public)

| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| GET | `/api/health` | Health check | ❌ |

---

## 💡 EXEMPLES PAR SCÉNARIO

### Scénario 1: Patient crée un RDV

```bash
# 1. S'inscrire
POST /api/v1/auth/register
{
  "user": {
    "email": "patient@test.com",
    "password": "Password123!",
    "role": "patient"
  }
}

# 2. Se connecter
POST /api/v1/auth/login
{
  "email": "patient@test.com",
  "password": "Password123!"
}
→ Copier access_token

# 3. Créer RDV
POST /api/v1/appointments
Authorization: Bearer {access_token}
{
  "appointment": {
    "doctor_id": 2,
    "scheduled_at": "2025-10-25T14:00:00Z",
    "notes": "Consultation générale"
  }
}

# 4. Voir ses RDV
GET /api/v1/appointments
Authorization: Bearer {access_token}
```

---

### Scénario 2: Médecin crée un DME

```bash
# 1. Se connecter en tant que médecin
POST /api/v1/auth/login
{
  "email": "doctor@example.com",
  "password": "Password123!"
}
→ Copier access_token

# 2. Créer DME avec structure SOAP
POST /api/v1/medical_records
Authorization: Bearer {access_token}
{
  "medical_record": {
    "user_id": 1,
    "nom": "Jean Dupont",
    "age": 45,
    "category": "consultation",
    "priority": "normal",
    "soap_subjective": "Maux de tête depuis 3j",
    "soap_objective": "TA: 130/85, T°: 37.2°C",
    "soap_assessment": "Céphalée de tension probable",
    "soap_plan": "Paracétamol 1g x3/j pendant 5j",
    "tags": ["céphalée", "prescription"]
  }
}

# 3. Lister DME de ses patients
GET /api/v1/medical_records

# 4. Voir un DME spécifique
GET /api/v1/medical_records/1
```

---

### Scénario 3: Confirmer un RDV (médecin)

```bash
# 1. Auth doctor (voir scénario 2)

# 2. Lister RDV en attente
GET /api/v1/appointments
→ Trouver RDV avec status: "pending"

# 3. Confirmer le RDV
POST /api/v1/appointments/1/confirm
Authorization: Bearer {access_token}

# 4. Vérifier statut changé
GET /api/v1/appointments/1
→ Status devrait être "confirmed"
```

---

## 🔑 GESTION DES TOKENS

### Cycle de vie d'un token

```
Register/Login
  ↓
access_token (1h) + refresh_token (30j)
  ↓
Utiliser access_token pour toutes les requêtes
  ↓
Après 1h → 401 Unauthorized
  ↓
POST /api/v1/auth/refresh avec refresh_token
  ↓
Nouveau access_token (1h)
  ↓
Répéter...
```

### Exemple refresh

```json
// Requête
POST /api/v1/auth/refresh
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}

// Réponse
{
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI...",  ← Nouveau token
    "user": { ... }
  }
}
```

---

## 🎨 FEATURES SWAGGER UI

### Fonctionnalités disponibles

1. **Documentation interactive**
   - Tous les endpoints documentés
   - Exemples pour chaque requête
   - Schémas de données

2. **Try it out**
   - Tester directement dans le navigateur
   - Voir les réponses en temps réel
   - Modifier les paramètres facilement

3. **Models** (en bas de page)
   - Voir tous les schémas de données
   - Structures complètes
   - Exemples JSON

4. **Authorization**
   - Authentification JWT intégrée
   - Un seul token pour tous les endpoints
   - Logout facile

5. **Filtres et recherche**
   - Filtrer par tag (Authentication, Appointments, etc.)
   - Rechercher un endpoint
   - Groupement logique

---

## 🧪 TESTS AVEC SWAGGER

### Test complet workflow patient

```
✅ 1. Register patient
    POST /auth/register
    → 201 Created

✅ 2. Login
    POST /auth/login  
    → 200 OK + tokens

✅ 3. Authorize
    🔒 → Coller token

✅ 4. Get profil
    GET /me
    → 200 OK

✅ 5. Créer RDV
    POST /appointments
    → 201 Created

✅ 6. Liste RDV
    GET /appointments
    → 200 OK

✅ 7. Notifications
    GET /notifications
    → 200 OK
```

### Test complet workflow médecin

```
✅ 1. Register doctor
    POST /auth/register (role: "doctor")

✅ 2. Login doctor

✅ 3. Authorize

✅ 4. Créer DME
    POST /medical_records
    → 201 Created

✅ 5. Lister DME patients
    GET /medical_records
    → 200 OK

✅ 6. Confirmer RDV
    POST /appointments/:id/confirm
    → 200 OK

✅ 7. Modifier DME
    PUT /medical_records/:id
    → 200 OK
```

---

## 🐛 TROUBLESHOOTING

### Erreur 401 Unauthorized

**Symptôme**:
```json
{
  "error": {
    "message": "Authentification requise"
  }
}
```

**Solutions**:
1. Vérifier que vous avez cliqué "Authorize" 🔒
2. Vérifier format: `Bearer {token}` (avec espace)
3. Token expiré ? → Refresh
4. Re-login si refresh_token expiré

---

### Erreur 403 Forbidden

**Symptôme**:
```json
{
  "error": {
    "message": "Accès interdit"
  }
}
```

**Cause**: Permissions insuffisantes

**Exemples**:
- Patient essaie de créer un DME → **Réservé aux doctors**
- Patient essaie de confirmer un RDV → **Réservé aux doctors**
- User non-admin essaie d'accéder à tout → **Réservé aux admins**

**Solution**: Utiliser un compte avec le bon rôle

---

### Erreur 422 Unprocessable Entity

**Symptôme**:
```json
{
  "error": {
    "message": "Erreur de validation",
    "details": {
      "email": ["has already been taken"]
    }
  }
}
```

**Cause**: Données invalides

**Solutions**:
- Vérifier champs requis
- Vérifier formats (email, date-time, etc.)
- Vérifier contraintes (min/max, enum, etc.)

---

## 📊 SCHÉMAS DE DONNÉES

### User
```json
{
  "id": 1,
  "email": "patient@telemed.fr",
  "role": "patient",
  "first_name": "Jean",
  "last_name": "Dupont",
  "confirmed_at": "2025-10-19T10:00:00Z",
  "inserted_at": "2025-10-19T10:00:00Z"
}
```

### Medical Record (DME)
```json
{
  "id": 1,
  "nom": "Jean Dupont",
  "age": 45,
  "category": "consultation",
  "priority": "normal",
  "status": "active",
  "soap": {
    "subjective": "Symptômes patient",
    "objective": "Observations médicales",
    "assessment": "Diagnostic",
    "plan": "Plan de traitement"
  },
  "tags": ["tag1", "tag2"],
  "patient_id": 1,
  "doctor_id": 2,
  "consultation_date": "2025-10-19T14:00:00Z"
}
```

### Appointment
```json
{
  "id": 1,
  "patient_id": 1,
  "doctor_id": 2,
  "scheduled_at": "2025-10-25T14:00:00Z",
  "status": "confirmed",
  "notes": "Consultation de suivi",
  "inserted_at": "2025-10-19T10:00:00Z"
}
```

---

## 🔗 LIENS UTILES

### URLs importantes
- **Swagger UI**: http://localhost:4001/swaggerui
- **OpenAPI JSON**: http://localhost:4001/api/openapi
- **Health Check**: http://localhost:4001/api/health
- **App Web**: http://localhost:4001

### Collections tierces
- **Postman**: `Telemed_API.postman_collection.json`
- **Insomnia**: Importer via OpenAPI JSON
- **Bruno**: Importer collection

### Générateurs de code
```bash
# Générer client JavaScript
openapi-generator-cli generate -i http://localhost:4001/api/openapi -g javascript -o ./client-js

# Générer client Python
openapi-generator-cli generate -i http://localhost:4001/api/openapi -g python -o ./client-python

# Générer client TypeScript/Axios
openapi-generator-cli generate -i http://localhost:4001/api/openapi -g typescript-axios -o ./client-ts
```

---

## ✅ CHECKLIST VALIDATION

### Avant de partir en production

- [ ] Tester tous les endpoints dans Swagger
- [ ] Valider workflow Register → Login → Endpoints
- [ ] Tester avec différents rôles (patient, doctor, admin)
- [ ] Vérifier messages d'erreur
- [ ] Tester refresh token
- [ ] Documenter cas d'usage spécifiques
- [ ] Exporter collection Postman à jour
- [ ] Générer clients API si nécessaire

---

## 🎯 RACCOURCIS CLAVIER SWAGGER

| Touche | Action |
|--------|--------|
| `/` | Focus recherche |
| `Ctrl+Enter` | Execute request |
| `Esc` | Fermer modals |

---

## 💡 ASTUCES PRO

### 1. Garder le token à portée
```
Créer une note avec le token pour copier/coller rapide:

access_token: eyJhbGciOiJIUzI1NiIs...
refresh_token: eyJhbGciOiJIUzI1NiIs...
```

### 2. Utiliser plusieurs onglets
```
Onglet 1: Swagger patient
Onglet 2: Swagger doctor
→ Tester interactions entre rôles
```

### 3. Bookmarker les URLs
```
http://localhost:4001/swaggerui#/Authentication
http://localhost:4001/swaggerui#/Medical%20Records
http://localhost:4001/swaggerui#/Appointments
```

### 4. Exporter les requêtes
Swagger permet d'exporter en cURL:
```
Try it out → Execute → Copier le cURL
```

---

## 📚 WORKFLOW RECOMMANDÉ

### Pour développeurs

```
1. Ouvrir Swagger UI
2. Tester un endpoint
3. Vérifier la réponse
4. Si erreur → Debug code
5. Si OK → Copier exemple dans doc
6. Répéter pour chaque endpoint
```

### Pour QA/Testeurs

```
1. Import Postman collection
2. Run tests automatisés
3. Vérifier dans Swagger UI manuellement
4. Reporter bugs
```

### Pour clients API

```
1. Lire documentation Swagger
2. Tester endpoints dans UI
3. Générer client code (openapi-generator)
4. Intégrer dans app
```

---

## 🎉 CONCLUSION

Swagger UI Telemed vous permet de :
- ✅ Tester l'API sans écrire de code
- ✅ Comprendre tous les endpoints
- ✅ Voir exemples concrets
- ✅ Debugger rapidement
- ✅ Générer documentation automatiquement

**Accès**: http://localhost:4001/swaggerui

---

**Bonne découverte de l'API Telemed ! 🚀**

