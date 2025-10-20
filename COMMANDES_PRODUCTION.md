# ⚡ COMMANDES RAPIDES PRODUCTION

**Guide express pour déployer Telemed en production**

---

## 🚀 DÉPLOIEMENT INITIAL (10 MINUTES)

### 1. Installer Fly.io CLI

**Windows** (PowerShell Admin):
```powershell
iwr https://fly.io/install.ps1 -useb | iex
```

### 2. Login Fly.io

```bash
fly auth signup
# ou
fly auth login
```

### 3. Lancer l'app (depuis le dossier telemed)

```bash
cd "C:\Users\bmd tech\Desktop\Telemedcine et DME\telemed"
fly launch --no-deploy
```

**Répondre** :
- App name: `telemed-prod` (ou votre choix)
- Region: `cdg` (Paris)
- PostgreSQL: `Yes` ✅
- Upstash Redis: `No`

### 4. Générer secrets

```powershell
# Générer et copier le secret
mix phx.gen.secret

# Configurer dans Fly
fly secrets set SECRET_KEY_BASE="<le_secret_généré>"
```

### 5. Déployer

```bash
fly deploy
```

**Durée** : 5-10 minutes

### 6. Setup production (migrations + admin)

```bash
fly ssh console -C "/app/bin/telemed eval 'Telemed.Release.setup_production'"
```

### 7. Ouvrir l'app

```bash
fly open
```

**🎉 Votre app est live !** 🎉

---

## 🔑 IDENTIFIANTS PAR DÉFAUT

```
Admin:
Email: admin@telemed.fr
Password: Admin123!ChangeMe

Doctor Demo:
Email: doctor@telemed.fr
Password: Doctor123!Demo

Patient Demo:
Email: patient@telemed.fr
Password: Patient123!Demo
```

**⚠️ CHANGEZ LE MOT DE PASSE ADMIN IMMÉDIATEMENT !**

---

## 📊 COMMANDES UTILES

### Voir les logs
```bash
fly logs
```

### Status de l'app
```bash
fly status
```

### Ouvrir console SSH
```bash
fly ssh console
```

### Exécuter commande Elixir
```bash
fly ssh console -C "/app/bin/telemed eval 'IO.puts(\"Hello production!\")'"
```

### Exécuter migrations
```bash
fly ssh console -C "/app/bin/telemed eval 'Telemed.Release.migrate'"
```

### Redémarrer l'app
```bash
fly apps restart telemed-prod
```

---

## 🔄 MISE À JOUR

### Déployer nouvelle version

```bash
# Vérifier tests
mix test

# Déployer
fly deploy
```

### Rollback si problème

```bash
# Voir historique
fly releases

# Rollback
fly releases rollback <version>
```

---

## 📈 SCALING

### Augmenter mémoire
```bash
fly scale memory 1024
```

### Augmenter instances
```bash
fly scale count 2
```

### Voir config actuelle
```bash
fly scale show
```

---

## 🗄️ BASE DE DONNÉES

### Connexion PostgreSQL
```bash
fly postgres connect -a <postgres_app_name>
```

### Backup
```bash
fly volumes snapshots create <volume_id>
```

---

## 🆘 DÉPANNAGE RAPIDE

### App ne démarre pas

```bash
# Voir les logs
fly logs

# Vérifier secrets
fly secrets list

# Vérifier config
fly config show
```

### Erreur migrations

```bash
# Relancer migrations
fly ssh console -C "/app/bin/telemed eval 'Telemed.Release.migrate'"
```

### Reset complet (⚠️ ATTENTION)

```bash
# Détruire l'app
fly apps destroy telemed-prod

# Recommencer depuis le début
fly launch
```

---

## 🌐 URLS IMPORTANTES

```
App principale:     https://telemed-prod.fly.dev
Swagger UI:         https://telemed-prod.fly.dev/swaggerui
API Health:         https://telemed-prod.fly.dev/api/health
Login:              https://telemed-prod.fly.dev/users/log_in
```

---

## 💰 COÛTS

**Plan gratuit Fly.io** :
- ✅ 3 VMs (256MB) gratuites
- ✅ 3GB PostgreSQL gratuit
- ✅ 160GB bandwidth/mois

**Pour le MVP = 0€/mois !**

---

## 📚 AIDE

- Documentation: https://fly.io/docs/elixir/
- Support: https://community.fly.io/
- Status: https://status.fly.io/

---

**🚀 C'est tout ! Votre app est en production ! 🚀**

