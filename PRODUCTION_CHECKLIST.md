# ✅ CHECKLIST PRODUCTION - TELEMED

**Date**: 19 octobre 2025  
**Version**: 1.0.0

---

## 📋 PRÉ-DÉPLOIEMENT

### Code & Tests
- [x] Tests passent (19/19 = 100%)
- [x] Aucun bug connu
- [x] Features testées en local
- [x] Swagger validé
- [x] Upload documents testé
- [x] Consultations vidéo testées

### Fichiers configuration
- [x] `fly.toml` créé
- [x] `Dockerfile` créé
- [x] `.dockerignore` créé
- [x] `lib/telemed/release.ex` créé
- [x] `config/runtime.exs` configuré
- [x] `config/prod.exs` configuré

### Secrets générés
- [x] `SECRET_KEY_BASE` : `9GW5Wu3hOW7YUshKgN9ugP0UhMo2sfadpdMVQrdQyXptNvq1wpKvY4R4Ak3xqDB9`
- [ ] `LIVE_VIEW_SIGNING_SALT` : À générer
- [ ] `GUARDIAN_SECRET` : À générer (optionnel)

---

## 🚀 INSTALLATION INFRASTRUCTURE

### Fly.io CLI
- [ ] `flyctl` installé (`fly version`)
- [ ] Compte Fly.io créé
- [ ] Authentifié (`fly auth whoami`)

### Application initialisée
- [ ] `fly launch --no-deploy` exécuté
- [ ] App name choisi (ex: `telemed-prod`)
- [ ] Région sélectionnée (ex: `cdg` Paris)
- [ ] PostgreSQL activée

---

## 🔐 SECRETS CONFIGURATION

### Commandes à exécuter

```bash
# 1. SECRET_KEY_BASE
fly secrets set SECRET_KEY_BASE="9GW5Wu3hOW7YUshKgN9ugP0UhMo2sfadpdMVQrdQyXptNvq1wpKvY4R4Ak3xqDB9"

# 2. LIVE_VIEW_SIGNING_SALT
fly secrets set LIVE_VIEW_SIGNING_SALT="<générer avec: mix phx.gen.secret 32>"

# 3. PHX_HOST
fly secrets set PHX_HOST="telemed-prod.fly.dev"
```

### Vérification
- [ ] Secrets configurés (`fly secrets list`)
- [ ] `DATABASE_URL` présent (auto-créé par Fly)

---

## 🏗️ DÉPLOIEMENT

### Build & Deploy
- [ ] `fly deploy` exécuté
- [ ] Build réussi (5-10 min)
- [ ] App démarrée

### Post-déploiement
- [ ] Migrations exécutées
- [ ] Compte admin créé
- [ ] Comptes demo créés (optionnel)

---

## ✅ VALIDATION PRODUCTION

### Accessibilité
- [ ] `https://telemed-prod.fly.dev` accessible
- [ ] Page d'accueil charge
- [ ] SSL actif (🔒 dans navigateur)
- [ ] Pas d'erreurs console

### Endpoints
- [ ] `/api/health` → 200 OK
- [ ] `/swaggerui` → Charge
- [ ] `/users/log_in` → Page login
- [ ] `/api/openapi` → JSON OpenAPI

### Fonctionnalités
- [ ] Login admin fonctionne
- [ ] Register nouveau user via Swagger
- [ ] Login via Swagger + token
- [ ] GET /me fonctionne
- [ ] Créer appointment
- [ ] Créer medical record (doctor)
- [ ] Upload document (via UI web)
- [ ] Notifications visibles

---

## 🔒 SÉCURITÉ

### Mots de passe
- [ ] Mot de passe admin changé
- [ ] Comptes demo désactivés (ou passwords changés)

### Configuration
- [ ] HTTPS forcé (force_ssl active)
- [ ] CORS configuré
- [ ] Secrets ne sont pas dans Git
- [ ] `.env` dans `.gitignore`

### Headers sécurité
- [ ] HSTS actif
- [ ] CSP configurée (optionnel)
- [ ] X-Frame-Options
- [ ] X-Content-Type-Options

---

## 📊 MONITORING

### Logs
- [ ] `fly logs` accessible
- [ ] Pas d'erreurs `[error]`
- [ ] Métriques visibles (`fly dashboard`)

### Performance
- [ ] Temps réponse < 500ms
- [ ] Mémoire OK (< 80%)
- [ ] CPU OK (< 80%)

---

## 🗄️ BASE DE DONNÉES

### Configuration
- [ ] PostgreSQL connectée
- [ ] Migrations à jour
- [ ] Seeds exécutés (si nécessaire)

### Backup
- [ ] Stratégie backup définie
- [ ] Premier snapshot créé

---

## 📱 TESTS END-TO-END PRODUCTION

### Workflow Patient
- [ ] Register nouveau patient
- [ ] Login patient
- [ ] Voir dashboard
- [ ] Créer rendez-vous
- [ ] Voir notifications
- [ ] Voir DME (si existe)

### Workflow Doctor
- [ ] Register doctor
- [ ] Login doctor
- [ ] Créer DME pour patient
- [ ] Upload document médical
- [ ] Confirmer rendez-vous
- [ ] Démarrer consultation vidéo

### Workflow Admin
- [ ] Login admin
- [ ] Voir tous utilisateurs
- [ ] Voir tous DME
- [ ] Gérer permissions

---

## 🎯 POST-PRODUCTION (J+1)

### Communication
- [ ] Annoncer lancement
- [ ] Inviter beta testeurs
- [ ] Documentation utilisateur envoyée

### Monitoring continu
- [ ] Vérifier logs quotidiennement
- [ ] Surveiller erreurs
- [ ] Tracker performance

### Support
- [ ] Canal support défini
- [ ] Réponse aux questions
- [ ] Collecte feedback

---

## 🔄 MAINTENANCE RÉGULIÈRE

### Hebdomadaire
- [ ] Vérifier logs erreurs
- [ ] Backup DB
- [ ] Métriques performance

### Mensuel
- [ ] Mise à jour dépendances
- [ ] Review sécurité
- [ ] Optimisation performance

---

## 🎊 STATUT FINAL

```
[ ] 🟢 EN PRODUCTION - Tout fonctionne
[ ] 🟡 EN PRODUCTION - Avec warnings mineurs
[ ] 🔴 PROBLÈME - Nécessite intervention
```

---

**Date validation** : __________________

**Validé par** : __________________

---

**🚀 PRODUCTION READY ! 🚀**

