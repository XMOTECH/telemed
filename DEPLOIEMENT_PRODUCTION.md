# 🚀 GUIDE DÉPLOIEMENT PRODUCTION - TELEMED

**Date**: 19 octobre 2025  
**Plateforme recommandée**: Fly.io  
**Durée estimée**: 1-2 heures

---

## 📋 CHECKLIST PRÉ-DÉPLOIEMENT

### ✅ Code & Tests
- [x] Tests passent (19/19 = 100%)
- [x] Aucun bug connu
- [x] Features principales testées
- [x] Swagger validé

### ⏳ Configuration Production
- [ ] Variables d'environnement
- [ ] Secrets (DATABASE_URL, SECRET_KEY_BASE)
- [ ] Configuration prod optimisée
- [ ] Assets compilés

### ⏳ Base de données
- [ ] Migrations à jour
- [ ] Seeds optionnels (comptes admin)
- [ ] Backup strategy

### ⏳ Sécurité
- [ ] SSL/HTTPS (automatique avec Fly.io)
- [ ] CORS configuré
- [ ] Rate limiting activé
- [ ] Secrets sécurisés

---

## 🚀 OPTION 1 : FLY.IO (RECOMMANDÉ)

### Pourquoi Fly.io ?
- ✅ **Gratuit** pour petits projets (jusqu'à 3 VMs)
- ✅ **PostgreSQL** inclus gratuitement
- ✅ **SSL** automatique
- ✅ **Elixir/Phoenix** natif
- ✅ **Déploiement** en une commande
- ✅ **Région Europe** disponible

### Étape 1 : Installer flyctl

**Windows (PowerShell Admin)**:
```powershell
iwr https://fly.io/install.ps1 -useb | iex
```

**Linux/Mac**:
```bash
curl -L https://fly.io/install.sh | sh
```

### Étape 2 : Créer compte Fly.io

```bash
fly auth signup
# ou si déjà inscrit:
fly auth login
```

### Étape 3 : Initialiser l'app

```bash
cd C:\Users\bmd tech\Desktop\Telemedcine et DME\telemed
fly launch
```

Répondre aux questions :
- **App name**: `telemed-prod` (ou autre nom unique)
- **Region**: `cdg` (Paris) ou `fra` (Frankfurt)
- **PostgreSQL**: `Yes` ✅
- **Redis**: `No` (pas nécessaire pour l'instant)

### Étape 4 : Configurer les secrets

```bash
# Générer SECRET_KEY_BASE
mix phx.gen.secret

# Configurer les secrets
fly secrets set SECRET_KEY_BASE=<votre_secret_généré>
fly secrets set DATABASE_URL=<auto_configuré_par_fly>
```

### Étape 5 : Déployer

```bash
fly deploy
```

### Étape 6 : Exécuter les migrations

```bash
fly ssh console -C "/app/bin/telemed eval 'Telemed.Release.migrate'"
```

### Étape 7 : Créer compte admin

```bash
fly ssh console -C "/app/bin/telemed eval 'Telemed.Release.create_admin'"
```

### Étape 8 : Vérifier

```bash
fly open
```

Votre app est maintenant live sur : `https://telemed-prod.fly.dev` ! 🎉

---

## 🔧 CONFIGURATION PRODUCTION

### 1. Créer `config/prod.secret.exs`

```elixir
import Config

# Secrets configurés via variables d'environnement
config :telemed, TelemedWeb.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :telemed, Telemed.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
```

### 2. Mettre à jour `config/prod.exs`

```elixir
import Config

config :telemed, TelemedWeb.Endpoint,
  url: [host: System.get_env("PHX_HOST") || "telemed-prod.fly.dev", port: 443, scheme: "https"],
  http: [
    ip: {0, 0, 0, 0, 0, 0, 0, 0},
    port: String.to_integer(System.get_env("PORT") || "4000")
  ],
  check_origin: ["https://telemed-prod.fly.dev"],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :telemed, Telemed.Repo,
  ssl: true,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

config :logger, level: :info
```

### 3. Créer `lib/telemed/release.ex`

```elixir
defmodule Telemed.Release do
  @moduledoc """
  Tasks pour déploiement production
  """
  
  @app :telemed

  def migrate do
    load_app()
    
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def create_admin do
    load_app()
    
    {:ok, _} = Application.ensure_all_started(:telemed)
    
    Telemed.Accounts.register_user(%{
      email: "admin@telemed.fr",
      password: "Admin123!ChangeMe",
      role: "admin",
      first_name: "Admin",
      last_name: "Telemed"
    })
    
    IO.puts("✅ Admin créé: admin@telemed.fr / Admin123!ChangeMe")
    IO.puts("⚠️  CHANGEZ CE MOT DE PASSE IMMÉDIATEMENT !")
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
```

---

## 🔒 SÉCURITÉ PRODUCTION

### 1. Générer secrets

```bash
# SECRET_KEY_BASE (64 caractères)
mix phx.gen.secret

# GUARDIAN_SECRET_KEY
mix phx.gen.secret
```

### 2. Configurer CORS

Dans `config/prod.exs` :

```elixir
config :cors_plug,
  origin: ["https://telemed-prod.fly.dev", "https://www.telemed.fr"],
  max_age: 86400,
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
```

### 3. Rate Limiting

Ajouter dans `mix.exs` :

```elixir
{:hammer, "~> 6.1"}
```

---

## 📊 MONITORING

### 1. Logs Fly.io

```bash
# Voir les logs en temps réel
fly logs

# Logs avec filtre
fly logs --app telemed-prod
```

### 2. Métriques

```bash
# Voir les métriques
fly status
fly scale show
```

### 3. Health Checks

Fly.io vérifie automatiquement `/api/health`

---

## 🗄️ BASE DE DONNÉES

### Backup automatique (Fly.io)

```bash
# Créer snapshot
fly volumes snapshots create <volume_id>

# Lister snapshots
fly volumes snapshots list <volume_id>
```

### Accès direct PostgreSQL

```bash
# Console PostgreSQL
fly postgres connect -a <postgres_app_name>
```

---

## 🔄 MISE À JOUR PRODUCTION

### Déployer nouvelle version

```bash
git add .
git commit -m "Release v1.0.1"
mix test  # Vérifier tests
fly deploy
```

### Rollback si problème

```bash
fly releases
fly releases rollback <version>
```

---

## 📈 SCALING

### Augmenter ressources

```bash
# Voir config actuelle
fly scale show

# Augmenter RAM
fly scale memory 512

# Augmenter instances
fly scale count 2

# Augmenter DB
fly postgres update --memory 2gb
```

---

## 🎯 CHECKLIST POST-DÉPLOIEMENT

- [ ] App accessible via HTTPS
- [ ] Swagger fonctionne : `https://your-app.fly.dev/swaggerui`
- [ ] Login admin fonctionne
- [ ] Créer compte patient test
- [ ] Créer compte doctor test
- [ ] Tester upload document
- [ ] Vérifier logs (pas d'erreurs)
- [ ] Configurer monitoring
- [ ] Changer mot de passe admin
- [ ] Configurer backup DB automatique
- [ ] DNS custom (optionnel)

---

## 🌐 DOMAINE CUSTOM (OPTIONNEL)

### 1. Ajouter certificat SSL

```bash
fly certs add www.telemed.fr
```

### 2. Configurer DNS

Chez votre registrar (OVH, Namecheap, etc.) :

```
Type: CNAME
Name: www
Value: telemed-prod.fly.dev
TTL: 3600
```

---

## 💰 COÛTS FLY.IO

### Plan gratuit
- ✅ 3 VMs partagées (256MB RAM)
- ✅ 3GB PostgreSQL
- ✅ 160GB bandwidth/mois
- ✅ SSL automatique

**Parfait pour MVP et tests !**

### Upgrade si nécessaire
- 1GB RAM VM: ~$7/mois
- 10GB PostgreSQL: ~$10/mois
- Scaling automatique disponible

---

## 🆘 TROUBLESHOOTING

### App ne démarre pas

```bash
fly logs
# Vérifier SECRET_KEY_BASE configuré
fly secrets list
```

### Erreur base de données

```bash
# Vérifier connexion DB
fly postgres connect -a <postgres_app>
# Vérifier migrations
fly ssh console -C "/app/bin/telemed eval 'Telemed.Release.migrate'"
```

### Performance lente

```bash
# Augmenter ressources
fly scale memory 512
fly scale count 2
```

---

## 📚 RESSOURCES

- **Documentation Fly.io**: https://fly.io/docs/elixir/
- **Phoenix Deployment**: https://hexdocs.pm/phoenix/deployment.html
- **Support Fly.io**: https://community.fly.io/

---

## 🎉 RÉSUMÉ DÉPLOIEMENT

```bash
# Installation
iwr https://fly.io/install.ps1 -useb | iex

# Login
fly auth signup

# Initialisation
fly launch

# Configuration secrets
fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret)

# Déploiement
fly deploy

# Migrations
fly ssh console -C "/app/bin/telemed eval 'Telemed.Release.migrate'"

# Créer admin
fly ssh console -C "/app/bin/telemed eval 'Telemed.Release.create_admin'"

# Ouvrir app
fly open
```

**Durée totale** : 30-60 minutes

---

**🚀 Votre app Telemed sera en production ! 🚀**

