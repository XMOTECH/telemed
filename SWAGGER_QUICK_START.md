# ⚡ SWAGGER QUICK START - 5 MINUTES

**URL**: http://localhost:4001/swaggerui  
**Objectif**: Tester l'API en 5 minutes chrono ! ⏱️

---

## 🚀 LES 5 ÉTAPES MAGIQUES

### 1️⃣ OUVRIR SWAGGER (10 sec)

```
http://localhost:4001/swaggerui
```

---

### 2️⃣ REGISTER + COPIER TOKEN (60 sec)

1. Section **"🔐 Authentication"**
2. Cliquer **POST /api/v1/auth/register**
3. Cliquer **"Try it out"**
4. Copier-coller ceci :

```json
{
  "user": {
    "email": "test123@telemed.fr",
    "password": "MotDePasse123!",
    "role": "patient",
    "first_name": "Test",
    "last_name": "User"
  }
}
```

5. Cliquer **"Execute"**
6. Dans la réponse, **COPIER** le `access_token` (tout le texte après les guillemets)

---

### 3️⃣ AUTORISER (20 sec)

1. Cliquer **"Authorize 🔒"** (en haut à droite)
2. Coller :
   ```
   Bearer eyJhbGciOiJIUzI1NiIs...
   ```
   ⚠️ **IMPORTANT**: Bien mettre `Bearer ` (avec espace) avant le token !

3. Cliquer **"Authorize"**
4. Cliquer **"Close"**

✅ **Vous êtes authentifié !**

---

### 4️⃣ TESTER GET /me (30 sec)

1. Section **"👤 Users"**
2. Cliquer **GET /api/v1/me**
3. Cliquer **"Try it out"**
4. Cliquer **"Execute"**

✅ **Vous devriez voir vos infos !**

```json
{
  "data": {
    "id": 1,
    "email": "test123@telemed.fr",
    "role": "patient"
  }
}
```

---

### 5️⃣ CRÉER UN RDV (60 sec)

1. Section **"📅 Appointments"**
2. Cliquer **POST /api/v1/appointments**
3. Cliquer **"Try it out"**
4. Copier-coller :

```json
{
  "appointment": {
    "doctor_id": 2,
    "scheduled_at": "2025-10-25T14:00:00Z",
    "notes": "Test RDV via Swagger"
  }
}
```

5. Cliquer **"Execute"**

✅ **RDV créé !**

```json
{
  "data": {
    "id": 1,
    "status": "pending",
    "scheduled_at": "2025-10-25T14:00:00Z"
  }
}
```

---

## 🎉 FÉLICITATIONS !

Vous venez de :
- ✅ Créer un compte
- ✅ Vous authentifier
- ✅ Récupérer votre profil
- ✅ Créer un rendez-vous

**En moins de 5 minutes ! 🚀**

---

## 🎯 ALLER PLUS LOIN (5 min de plus)

### Tester d'autres endpoints

```
GET /api/v1/appointments      → Voir vos RDV
GET /api/v1/notifications     → Vos notifications
GET /api/v1/medical_records   → Vos DME (si vous en avez)
```

### Créer un compte doctor

```
1. Register avec role: "doctor"
2. Autoriser avec le nouveau token
3. POST /medical_records → Créer un DME
4. POST /appointments/:id/confirm → Confirmer un RDV
```

---

## 🐛 SI PROBLÈME

### Token ne marche pas ?

```
1. Vérifier format: Bearer {token}
2. Pas d'espace dans le token
3. Token complet copié
4. Re-autoriser si expiré (>1h)
```

### 401 Unauthorized ?

```
1. Cliquer 🔒 Authorize
2. Vérifier que ✅ Authorized
3. Re-login si besoin
```

### 403 Forbidden ?

```
Exemple: Patient essaie POST /medical_records
→ Réservé aux doctors !
→ Utiliser compte doctor
```

---

## 📚 RESSOURCES

- **Guide complet**: `GUIDE_SWAGGER_COMPLET.md`
- **Workflow visuel**: `WORKFLOW_SWAGGER_VISUEL.md`
- **API Doc**: `API_DOCUMENTATION.md`
- **Postman**: `Telemed_API.postman_collection.json`

---

**Bon test ! 🧪**

