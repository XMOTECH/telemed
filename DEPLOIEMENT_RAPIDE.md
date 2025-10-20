# ⚡ DÉPLOIEMENT RAPIDE - 10 MINUTES

**Guide ultra-rapide pour mettre Telemed en production sur Fly.io**

---

## 🎯 EN 5 COMMANDES

### 1️⃣ Installer Fly.io (PowerShell Admin)

```powershell
iwr https://fly.io/install.ps1 -useb | iex
```

### 2️⃣ Login

```bash
fly auth signup
```

### 3️⃣ Lancer l'app

```bash
cd "C:\Users\bmd tech\Desktop\Telemedcine et DME\telemed"
fly launch --no-deploy
```

**Répondre** :
- App name: `telemed-prod`
- Region: `cdg` (Paris)
- PostgreSQL: `Yes`
- Redis: `No`

### 4️⃣ Configurer secrets

```bash
fly secrets set SECRET_KEY_BASE="9GW5Wu3hOW7YUshKgN9ugP0UhMo2sfadpdMVQrdQyXptNvq1wpKvY4R4Ak3xqDB9"
```

### 5️⃣ Déployer

```bash
fly deploy
```

**Attendez 5-10 minutes...**

---

## ✅ APRÈS DÉPLOIEMENT (2 commandes)

### Setup DB + Admin

```bash
fly ssh console -C "/app/bin/telemed eval 'Telemed.Release.setup_production'"
```

### Ouvrir l'app

```bash
fly open
```

---

## 🎉 C'EST TOUT !

Votre app est maintenant live sur :

```
https://telemed-prod.fly.dev
```

**Login admin** :
```
Email: admin@telemed.fr
Password: Admin123!ChangeMe
```

**⚠️ CHANGEZ CE MOT DE PASSE !**

---

## 📋 CHECKLIST

- [ ] flyctl installé
- [ ] Compte Fly.io créé
- [ ] App lancée (`fly launch`)
- [ ] Secrets configurés
- [ ] Déployé (`fly deploy`)
- [ ] Migrations exécutées
- [ ] Admin créé
- [ ] App accessible
- [ ] Mot de passe admin changé

---

## 🆘 SI PROBLÈME

```bash
# Voir logs
fly logs

# Status
fly status

# Redémarrer
fly apps restart telemed-prod
```

---

**🚀 10 MINUTES → PRODUCTION ! 🚀**

