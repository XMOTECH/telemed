# 📖 GUIDE DÉPLOIEMENT ÉTAPE PAR ÉTAPE

**Durée** : 20-30 minutes  
**Niveau** : Débutant  
**Plateforme** : Fly.io (gratuit pour MVP)

---

## ✅ PRÉ-REQUIS

- [x] Application fonctionne en local ✅
- [x] Tests passent (19/19) ✅
- [x] Git installé ✅
- [ ] Compte Fly.io (gratuit)

---

## 🚀 ÉTAPE 1 : INSTALLER FLY.IO CLI (2 min)

### Windows (PowerShell **en tant qu'Administrateur**)

```powershell
iwr https://fly.io/install.ps1 -useb | iex
```

### Vérifier installation

```bash
fly version
```

**Résultat attendu** : `fly vX.X.X ...` ✅

---

## 🔐 ÉTAPE 2 : CRÉER COMPTE FLY.IO (3 min)

### Inscription

```bash
fly auth signup
```

Ou si vous avez déjà un compte :

```bash
fly auth login
```

**Suivre les instructions** dans le navigateur.

---

## 📦 ÉTAPE 3 : INITIALISER L'APPLICATION (5 min)

### Aller dans le dossier du projet

```bash
cd "C:\Users\bmd tech\Desktop\Telemedcine et DME\telemed"
```

### Lancer fly launch

```bash
fly launch --no-deploy
```

### Répondre aux questions

```
? Choose an app name: telemed-prod
? Choose a region: cdg (Paris, France)
? Would you like to set up a PostgreSQL database? Yes
? Select configuration: Development - Single node, 1x shared CPU, 256MB RAM, 1GB disk
? Would you like to set up an Upstash Redis database? No
```

**Résultat** : Fichiers `fly.toml` et `.dockerignore` créés ✅

---

## 🔑 ÉTAPE 4 : CONFIGURER LES SECRETS (3 min)

### Générer SECRET_KEY_BASE

```powershell
mix phx.gen.secret
```

**Copier** le résultat (64 caractères)

### Configurer dans Fly.io

```bash
fly secrets set SECRET_KEY_BASE="<votre_secret_copié>"
```

### Générer LIVE_VIEW_SIGNING_SALT (optionnel)

```powershell
mix phx.gen.secret 32
```

```bash
fly secrets set LIVE_VIEW_SIGNING_SALT="<votre_salt>"
```

### Vérifier secrets

```bash
fly secrets list
```

**Résultat attendu** :
```
NAME                      DIGEST           CREATED AT
SECRET_KEY_BASE          <hash>           XXs ago
LIVE_VIEW_SIGNING_SALT   <hash>           XXs ago
DATABASE_URL             <hash>           XXs ago (auto)
```

---

## 🏗️ ÉTAPE 5 : PREMIER DÉPLOIEMENT (10 min)

### Déployer l'application

```bash
fly deploy
```

**Ce qui se passe** :
1. Build Docker image (3-5 min)
2. Push vers Fly.io (1-2 min)
3. Démarrage app (30s)

**Attendez** le message : `✅ Deployment successful!`

---

## 🗄️ ÉTAPE 6 : SETUP BASE DE DONNÉES (2 min)

### Exécuter migrations + créer admin

```bash
fly ssh console -C "/app/bin/telemed eval 'Telemed.Release.setup_production'"
```

**Résultat attendu** :
```
🚀 Configuration production Telemed...

1️⃣  Exécution des migrations...
✅ Migrations terminées

2️⃣  Création compte administrateur...
✅ Compte administrateur créé avec succès !
   Email: admin@telemed.fr
   Mot de passe: Admin123!ChangeMe

⚠️  IMPORTANT: Changez ce mot de passe immédiatement !

3️⃣  Création comptes de démonstration...
✅ Compte doctor de démo créé
✅ Compte patient de démo créé

🎉 Configuration production terminée !
```

---

## 🌐 ÉTAPE 7 : ACCÉDER À L'APPLICATION (1 min)

### Ouvrir dans le navigateur

```bash
fly open
```

**Ou manuellement** :
```
https://telemed-prod.fly.dev
```

### URLs importantes

```
App:        https://telemed-prod.fly.dev
Login:      https://telemed-prod.fly.dev/users/log_in
Swagger:    https://telemed-prod.fly.dev/swaggerui
Health:     https://telemed-prod.fly.dev/api/health
```

---

## 🔒 ÉTAPE 8 : PREMIÈRE CONNEXION (2 min)

### 1. Aller sur la page de login

```
https://telemed-prod.fly.dev/users/log_in
```

### 2. Login avec admin

```
Email: admin@telemed.fr
Password: Admin123!ChangeMe
```

### 3. CHANGER LE MOT DE PASSE IMMÉDIATEMENT

1. Aller dans **Paramètres** ou **Profil**
2. Modifier le mot de passe
3. Choisir un mot de passe **fort** (20+ caractères)

---

## ✅ ÉTAPE 9 : VÉRIFICATION POST-DÉPLOIEMENT (5 min)

### Checklist validation

```
☐ App accessible via HTTPS ✅
☐ Page d'accueil charge ✅
☐ Login admin fonctionne ✅
☐ Dashboard accessible ✅
☐ Swagger UI fonctionne ✅
☐ Health endpoint OK ✅
☐ Pas d'erreurs dans logs ✅
```

### Vérifier health endpoint

```bash
curl https://telemed-prod.fly.dev/api/health
```

**Résultat attendu** :
```json
{
  "status": "ok",
  "database": "ok",
  "version": "1.0.0"
}
```

### Voir les logs

```bash
fly logs
```

**Rechercher** : Pas d'erreurs `[error]`

---

## 🎯 ÉTAPE 10 : CRÉER PREMIERS VRAIS UTILISATEURS (3 min)

### Via Swagger UI

1. Ouvrir : `https://telemed-prod.fly.dev/swaggerui`
2. **POST /auth/register** - Créer un doctor
3. **POST /auth/register** - Créer un patient
4. Tester le workflow complet !

---

## 🎊 FÉLICITATIONS ! VOUS ÊTES EN PRODUCTION !

```
╔════════════════════════════════════════════╗
║  🎉 TELEMED EN PRODUCTION !                ║
╠════════════════════════════════════════════╣
║                                             ║
║  URL:  https://telemed-prod.fly.dev        ║
║  SSL:  ✅ Automatique                      ║
║  DB:   ✅ PostgreSQL                       ║
║  Logs: fly logs                            ║
║                                             ║
║  STATUS: 🟢 LIVE                           ║
║                                             ║
╚════════════════════════════════════════════╝
```

---

## 🔄 MISES À JOUR FUTURES

### Déployer nouvelle version

```bash
# 1. Vérifier tests
mix test

# 2. Commit changements
git add .
git commit -m "Release v1.0.1"

# 3. Déployer
fly deploy
```

**Durée** : 3-5 minutes

---

## 📊 MONITORING

### Voir métriques

```bash
fly dashboard
```

### Alertes (optionnel)

Configurer dans : https://fly.io/dashboard/alerts

---

## 💰 COÛTS

**Gratuit pour** :
- 3 VMs 256MB
- 3GB PostgreSQL
- 160GB bandwidth/mois

**Parfait pour MVP !** 💚

**Si besoin upgrade** :
```bash
# 512MB RAM
fly scale memory 512

# 2 instances
fly scale count 2
```

---

## 🆘 AIDE

### Problème au déploiement ?

```bash
# Logs détaillés
fly logs --app telemed-prod

# Status
fly status

# Vérifier secrets
fly secrets list
```

### Support

- Doc: https://fly.io/docs/elixir/
- Forum: https://community.fly.io/
- Chat: Dans le dashboard Fly.io

---

## 🎯 PROCHAINES ÉTAPES RECOMMANDÉES

### Court terme (cette semaine)

1. ✅ **Changer mot de passe admin**
2. ✅ **Tester toutes les features** en prod
3. ✅ **Créer vrais utilisateurs** (doctors, patients)
4. ⏳ **Configurer domaine custom** (optionnel)
5. ⏳ **Setup monitoring** (Sentry, AppSignal)

### Moyen terme (ce mois)

6. ⏳ **Backup automatique** DB
7. ⏳ **CI/CD** (GitHub Actions)
8. ⏳ **Environnement staging**
9. ⏳ **Migration S3** pour uploads
10. ⏳ **Notifications email** (SendGrid/Mailgun)

---

**🎉 BRAVO ! VOTRE APP EST MAINTENANT EN PRODUCTION ! 🎉**

