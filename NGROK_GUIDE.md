# 🌐 Guide ngrok - Solution HTTPS pour WebRTC

## 🎯 **Pourquoi ngrok ?**

Les navigateurs modernes bloquent WebRTC sur HTTP via IP pour des raisons de sécurité. ngrok crée un tunnel HTTPS qui contourne cette limitation.

## 🚀 **Installation et configuration**

### **Étape 1 : Installer ngrok**
```bash
# Double-cliquez sur le fichier
setup_ngrok.bat
```

Ou manuellement :
```bash
# Télécharger ngrok
powershell -Command "Invoke-WebRequest -Uri 'https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip' -OutFile 'ngrok.zip'"

# Extraire
powershell -Command "Expand-Archive -Path 'ngrok.zip' -DestinationPath '.' -Force"

# Nettoyer
del ngrok.zip
```

### **Étape 2 : Démarrer le serveur Phoenix**
```bash
# Dans un premier terminal
cd telemed
mix phx.server
```

### **Étape 3 : Démarrer le tunnel ngrok**
```bash
# Dans un second terminal
cd telemed
start_tunnel.bat
```

Ou manuellement :
```bash
ngrok http 4001
```

## 📋 **Résultat attendu**

Après avoir lancé `ngrok http 4001`, vous verrez :

```
Session Status                online
Account                       (Plan: Free)
Version                       3.x.x
Region                        United States (us)
Latency                       51ms
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://abc123.ngrok.io -> http://localhost:4001
```

## 🌐 **Accès à l'application**

### **URLs disponibles :**
- **Page d'accueil** : `https://abc123.ngrok.io/`
- **Test caméra** : `https://abc123.ngrok.io/test-camera`
- **Consultation vidéo** : `https://abc123.ngrok.io/video`
- **Dossiers médicaux** : `https://abc123.ngrok.io/medical_records`

### **Test de la consultation vidéo :**

#### **Test entre deux machines :**
1. **Machine 1** : `https://abc123.ngrok.io/video`
2. **Machine 2** : `https://abc123.ngrok.io/video`
3. **Rejoindre la salle** sur les deux machines
4. **Démarrer l'appel** sur les deux machines

#### **Test entre deux onglets :**
1. **Onglet 1** : `https://abc123.ngrok.io/video`
2. **Onglet 2** : `https://abc123.ngrok.io/video`
3. **Rejoindre la salle** sur les deux onglets
4. **Démarrer l'appel** sur les deux onglets

## 🔧 **Avantages de cette solution**

- ✅ **HTTPS automatique** : WebRTC fonctionne parfaitement
- ✅ **Accès global** : Accessible depuis n'importe où
- ✅ **Pas de configuration réseau** : Fonctionne derrière un pare-feu
- ✅ **URL stable** : Même URL tant que ngrok tourne
- ✅ **Interface web** : http://127.0.0.1:4040 pour surveiller le trafic

## ⚠️ **Limitations**

- **URL change** : L'URL change à chaque redémarrage de ngrok
- **Limite de connexions** : Version gratuite limitée
- **Tunnel public** : L'URL est publique (pour les tests uniquement)

## 🛡️ **Sécurité**

- **Pour les tests uniquement** : Ne pas utiliser en production
- **URL publique** : N'importe qui avec l'URL peut accéder
- **Pas de données sensibles** : Utilisez des données de test uniquement

## 🔍 **Dépannage**

### **ngrok ne démarre pas :**
```bash
# Vérifier l'installation
ngrok version

# Réinstaller si nécessaire
setup_ngrok.bat
```

### **Erreur "tunnel not found" :**
- Redémarrer ngrok
- Vérifier que le serveur Phoenix tourne sur le port 4001

### **WebRTC ne fonctionne toujours pas :**
- Vérifier que vous utilisez l'URL HTTPS de ngrok
- Autoriser l'accès à la caméra dans le navigateur
- Tester avec différents navigateurs

## 📊 **Monitoring**

### **Interface web ngrok :**
- **URL** : http://127.0.0.1:4040
- **Fonctionnalités** : Logs, requêtes, statistiques

### **Logs du serveur :**
```bash
# Voir les logs en temps réel
tail -f log/dev.log
```

## 🎯 **Workflow recommandé**

1. **Démarrer le serveur** : `mix phx.server`
2. **Démarrer ngrok** : `ngrok http 4001`
3. **Copier l'URL HTTPS** fournie par ngrok
4. **Tester l'application** avec cette URL
5. **Partager l'URL** avec les autres participants

## 🚨 **Arrêt propre**

1. **Arrêter ngrok** : `Ctrl+C` dans le terminal ngrok
2. **Arrêter Phoenix** : `Ctrl+C` dans le terminal Phoenix

---

**Note :** Cette solution est parfaite pour les tests et démonstrations. Pour la production, utilisez un vrai certificat SSL et un domaine. 