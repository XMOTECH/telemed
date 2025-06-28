# 🏥 Guide de Déploiement - Plateforme Télémédecine

## 🚀 Déploiement Rapide

### Option 1 : Script automatique (Windows)
```bash
# Double-cliquez sur deploy.bat ou exécutez :
deploy.bat
```

### Option 2 : Commandes manuelles
```bash
# 1. Compiler les assets
mix assets.deploy

# 2. Compiler l'application
mix compile

# 3. Démarrer en mode production
MIX_ENV=prod mix phx.server
```

## 🌐 Accès à l'application

### Sur la machine serveur :
- **Page d'accueil** : http://localhost:4001
- **Test caméra** : http://localhost:4001/test-camera
- **Consultation vidéo** : http://localhost:4001/video
- **Dossiers médicaux** : http://localhost:4001/medical_records

### Sur le réseau local :
- **Page d'accueil** : http://192.168.43.248:4001
- **Test caméra** : http://192.168.43.248:4001/test-camera
- **Consultation vidéo** : http://192.168.43.248:4001/video

## 🔧 Configuration requise

### Base de données PostgreSQL
```bash
# Vérifier que PostgreSQL est démarré
# Créer la base de données si nécessaire
createdb telemed_dev
```

### Variables d'environnement
```bash
# Clé secrète (générée automatiquement par le script)
SECRET_KEY_BASE=your_secret_key_here_but_make_it_longer_than_64_bytes_for_production_use_only_and_keep_it_secret

# Port du serveur
PORT=4001
```

## 🛡️ Sécurité et Pare-feu

### Windows Firewall
1. **Ouvrir le port 4001** :
   - Panneau de configuration → Système et sécurité → Pare-feu Windows
   - Paramètres avancés → Règles de trafic entrant
   - Nouvelle règle → Port → TCP → 4001 → Autoriser la connexion

### Antivirus
- **Autoriser** l'application Phoenix dans votre antivirus
- **Désactiver temporairement** l'antivirus si nécessaire pour les tests

## 📱 Test de la consultation vidéo

### Test local (même machine)
1. **Onglet 1** : http://localhost:4001/video
2. **Onglet 2** : http://localhost:4001/video
3. **Rejoindre la salle** sur les deux onglets
4. **Démarrer l'appel** sur les deux onglets

### Test réseau (deux machines)
1. **Machine 1** : http://192.168.43.248:4001/video
2. **Machine 2** : http://192.168.43.248:4001/video
3. **Rejoindre la salle** sur les deux machines
4. **Démarrer l'appel** sur les deux machines

## 🔍 Diagnostic des problèmes

### Si WebRTC ne fonctionne pas :
1. **Vérifier** : http://192.168.43.248:4001/test-camera
2. **Autoriser** l'accès à la caméra dans le navigateur
3. **Vérifier** que le pare-feu autorise le port 4001
4. **Tester** avec différents navigateurs (Chrome, Edge, Firefox)

### Si la connexion réseau échoue :
1. **Vérifier** l'adresse IP : `ipconfig` dans le terminal
2. **Tester** la connectivité : `ping 192.168.43.248`
3. **Vérifier** que les deux machines sont sur le même réseau

## 📊 Monitoring

### Logs du serveur
```bash
# Voir les logs en temps réel
tail -f log/prod.log
```

### Statut de l'application
- **Dashboard** : http://localhost:4001/dev/dashboard (mode dev uniquement)

## 🚨 Dépannage

### Erreur "Port déjà utilisé"
```bash
# Trouver le processus qui utilise le port
netstat -ano | findstr :4001

# Tuer le processus
taskkill /PID <PID> /F
```

### Erreur de base de données
```bash
# Vérifier la connexion PostgreSQL
psql -U xmotechs -d telemed_dev

# Créer la base si elle n'existe pas
createdb -U xmotechs telemed_dev
```

### Erreur WebRTC
- **Utiliser** `localhost:4001` au lieu de l'IP pour les tests locaux
- **Vérifier** les permissions caméra dans le navigateur
- **Tester** avec le diagnostic : `/test-camera`

## 📞 Support

En cas de problème :
1. **Consulter** les logs du serveur
2. **Tester** la page de diagnostic : `/test-camera`
3. **Vérifier** la connectivité réseau
4. **Redémarrer** le serveur si nécessaire

# Guide de Déploiement Fly.io

## Prérequis

1. **Compte Fly.io** : Créez un compte sur [fly.io](https://fly.io)
2. **Fly CLI** : Installez la CLI Fly.io
3. **GitHub** : Votre code doit être sur GitHub

## Installation de Fly CLI

### Windows (avec winget)
```bash
winget install Fly.Flyctl
```

### Ou téléchargement manuel
1. Allez sur https://fly.io/docs/hands-on/install-flyctl/
2. Téléchargez la version Windows
3. Extrayez et ajoutez au PATH

## Configuration

### 1. Connexion à Fly.io
```bash
fly auth login
```

### 2. Créer l'application
```bash
fly apps create telemed
```

### 3. Configurer la base de données PostgreSQL
```bash
fly postgres create telemed-db
fly postgres attach telemed-db --app telemed
```

### 4. Configurer les variables d'environnement
```bash
fly secrets set SECRET_KEY_BASE="jwDy6tsLLls3FnoNJj5RGxOwnaNyyr0jPrMLqJi1SrZHfTnYtXufgJJSPItcmeR5"
fly secrets set PHX_HOST="telemed.fly.dev"
fly secrets set POOL_SIZE="10"
```

### 5. Déployer l'application
```bash
fly deploy
```

## Variables d'environnement importantes

- `SECRET_KEY_BASE` : Clé secrète pour Phoenix (générée avec `mix phx.gen.secret`)
- `PHX_HOST` : Nom de domaine de votre application
- `DATABASE_URL` : URL de la base de données (configurée automatiquement)
- `POOL_SIZE` : Taille du pool de connexions à la base de données

## Commandes utiles

### Voir les logs
```bash
fly logs
```

### Ouvrir l'application
```bash
fly open
```

### Redémarrer l'application
```bash
fly apps restart telemed
```

### Voir le statut
```bash
fly status
```

## Dépannage

### Problèmes courants

1. **Erreur de build** : Vérifiez que tous les assets sont compilés
2. **Erreur de base de données** : Vérifiez que la DB est attachée
3. **Erreur de port** : Vérifiez que le port 8080 est configuré

### Logs détaillés
```bash
fly logs --all
```

## Mise à jour

Pour mettre à jour l'application :

1. Poussez vos changements sur GitHub
2. Exécutez `fly deploy`

## Configuration HTTPS

Fly.io configure automatiquement HTTPS pour votre domaine.

## Monitoring

Accédez au dashboard Fly.io pour :
- Surveiller les performances
- Voir les logs en temps réel
- Gérer les variables d'environnement
- Configurer les alertes 