# 📥 INSTALLATION FLY.IO - ÉTAPE PAR ÉTAPE

**Durée** : 2 minutes

---

## 🪟 WINDOWS : INSTALLATION

### ⚠️ IMPORTANT : PowerShell en Administrateur

1. **Clic droit** sur l'icône PowerShell
2. Sélectionner **"Exécuter en tant qu'administrateur"**
3. Cliquer **"Oui"** dans la fenêtre UAC

---

### 📥 Commande d'installation

Dans PowerShell (Admin), exécutez :

```powershell
iwr https://fly.io/install.ps1 -useb | iex
```

**Attendez** : Installation en cours... (30 secondes)

---

### ✅ Vérifier l'installation

```powershell
fly version
```

**Résultat attendu** :
```
fly vX.X.X windows/amd64 Commit: ...
```

---

### 🔄 Si commande `fly` non reconnue

1. **Fermer** PowerShell
2. **Rouvrir** PowerShell (Admin)
3. **Réessayer** : `fly version`

Ou ajouter au PATH manuellement :
```
C:\Users\<votre_user>\.fly\bin
```

---

## 🐧 LINUX / MAC : INSTALLATION

```bash
curl -L https://fly.io/install.sh | sh
```

Puis ajouter au PATH :
```bash
export FLYCTL_INSTALL="$HOME/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"
```

---

## ✅ INSTALLATION RÉUSSIE !

Une fois `fly version` qui fonctionne, vous êtes prêt ! 🎉

**Prochaine étape** :
```bash
fly auth signup
```

---

## 🆘 PROBLÈMES COURANTS

### "Execution Policy" sur Windows

Si erreur :
```
... n'est pas reconnu en tant que script ...
```

**Solution** :
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Puis réessayez l'installation.

---

### Permission refusée

**Solution** : Relancez PowerShell **en tant qu'Administrateur**

---

**📚 Plus d'aide** : https://fly.io/docs/hands-on/install-flyctl/

