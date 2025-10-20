# 🏥 Plateforme de Télémédecine & DME

> Plateforme complète de télémédecine avec consultations vidéo WebRTC, gestion des rendez-vous, dossiers médicaux électroniques et authentification sécurisée.

[![Phoenix](https://img.shields.io/badge/Phoenix-1.7-orange.svg)](https://phoenixframework.org/)
[![Elixir](https://img.shields.io/badge/Elixir-1.14+-purple.svg)](https://elixir-lang.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## 🚀 Démarrage Rapide

### Installation
```bash
# 1. Installer les dépendances
mix deps.get
cd assets && npm install && cd ..

# 2. Créer et migrer la base de données
mix ecto.create && mix ecto.migrate

# 3. Peupler avec des données de test
mix run priv/repo/seeds.exs

# 4. Compiler les assets
mix assets.build

# 5. Démarrer le serveur
mix phx.server
```

### Accès
- **URL** : http://localhost:4001
- **Comptes test** : Voir [GUIDE_UTILISATION.md](./GUIDE_UTILISATION.md)

---

## ✨ Fonctionnalités

### 🔐 Authentification Complète
- Inscription / Connexion / Déconnexion
- Sessions persistantes (60 jours)
- Contrôle d'accès par rôle (RBAC)
- 3 rôles : **Patient**, **Docteur**, **Admin**

### 🎥 Consultations Vidéo WebRTC
- Vidéo peer-to-peer en temps réel
- Audio bidirectionnel
- Partage d'écran
- Chat intégré
- Contrôles intuitifs

### 📊 Dashboards Personnalisés
- **Patient** : RDV, dossiers, notifications
- **Docteur** : Patients, agenda, statistiques
- **Admin** : Vue d'ensemble, gestion système

### 📅 Gestion des Rendez-vous
- Prise de RDV en ligne
- Confirmation/Refus par le médecin
- Notifications automatiques
- Calendrier intégré

### 📄 Dossiers Médicaux Électroniques
- Création et consultation
- Association patient-docteur
- Historique complet
- Sécurisé et confidentiel

### 🔔 Système de Notifications
- Notifications en temps réel
- Badge de compteur
- Marquage lu/non lu
- Filtrage par type

---

## 🛠️ Stack Technique

### Backend
- **Phoenix 1.7** - Framework web Elixir
- **Ecto** - ORM pour PostgreSQL
- **Phoenix Channels** - WebSocket real-time
- **Bcrypt** - Hachage mots de passe

### Frontend
- **Tailwind CSS** - Framework CSS moderne
- **Alpine.js** - JavaScript léger (via Phoenix LiveView)
- **WebRTC** - Communication vidéo P2P
- **Phoenix LiveView** - Interactivité temps réel

### Infrastructure
- **PostgreSQL** - Base de données
- **Bandit** - Serveur HTTP/2
- **Fly.io** - Déploiement (optionnel)

---

## 📁 Structure du Projet

```
telemed/
├── lib/
│   ├── telemed/              # Logique métier
│   │   ├── accounts.ex       # Users & Auth
│   │   ├── appointments.ex   # Rendez-vous
│   │   ├── medical_records.ex # Dossiers
│   │   └── notifications.ex  # Notifications
│   └── telemed_web/          # Interface web
│       ├── channels/         # WebSocket
│       ├── controllers/      # Contrôleurs
│       ├── live/            # LiveViews
│       └── components/      # Composants UI
├── assets/
│   ├── js/                  # JavaScript
│   │   └── video_consultation.js  # WebRTC
│   └── css/                 # Styles
├── priv/
│   └── repo/
│       ├── migrations/      # Migrations DB
│       └── seeds.exs        # Données test
└── config/                  # Configuration
```

---

## 📚 Documentation

| Guide | Description |
|-------|-------------|
| [START_HERE.md](./START_HERE.md) | 🚀 Démarrage ultra-rapide |
| [GUIDE_UTILISATION.md](./GUIDE_UTILISATION.md) | 📱 Guide utilisateur |
| [PLATEFORME_COMPLETE.md](./PLATEFORME_COMPLETE.md) | 📖 Documentation technique |
| [GUIDE_CONSULTATION_VIDEO.md](./GUIDE_CONSULTATION_VIDEO.md) | 🎥 Guide WebRTC |
| [AUTHENTIFICATION_COMPLETE.md](./AUTHENTIFICATION_COMPLETE.md) | 🔐 Guide auth |
| [CHECKLIST_VERIFICATION.md](./CHECKLIST_VERIFICATION.md) | ✅ Tests |

---

## 🧪 Tests

```bash
# Lancer tous les tests
mix test

# Tests avec couverture
mix test --cover

# Tests spécifiques
mix test test/telemed_web/
```

---

## 🚀 Déploiement

### Fly.io (Recommandé)
```bash
# Installation flyctl
# https://fly.io/docs/hands-on/install-flyctl/

fly launch
fly deploy
```

### Docker
```bash
docker build -t telemed .
docker run -p 4000:4000 telemed
```

### Manuel
```bash
# Production
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release
```

---

## 🤝 Contribution

Les contributions sont bienvenues ! Veuillez :
1. Fork le projet
2. Créer une branche (`git checkout -b feature/ma-feature`)
3. Commit (`git commit -m 'Ajout feature'`)
4. Push (`git push origin feature/ma-feature`)
5. Ouvrir une Pull Request

---

## 📝 Changelog

### Version 1.0.0 (11 octobre 2025)
- ✅ Authentification complète avec RBAC
- ✅ Consultations vidéo WebRTC
- ✅ Dashboard patient/docteur/admin
- ✅ Gestion rendez-vous
- ✅ Dossiers médicaux électroniques
- ✅ Système de notifications
- ✅ Interface moderne sans branding Phoenix
- ✅ Composants réutilisables
- ✅ Documentation exhaustive

---

## 🐛 Support

En cas de problème :
1. Consulter [GUIDE_UTILISATION.md](./GUIDE_UTILISATION.md)
2. Vérifier [CHECKLIST_VERIFICATION.md](./CHECKLIST_VERIFICATION.md)
3. Consulter les logs : terminal `mix phx.server`
4. Ouvrir une issue sur GitHub

---

## 📄 License

MIT License - Voir [LICENSE](LICENSE) pour plus de détails

---

## 🙏 Remerciements

- **Phoenix Framework** - Framework web Elixir
- **Tailwind CSS** - Framework CSS
- **WebRTC** - Technologie de communication temps réel
- **Heroicons** - Icônes SVG

---

## 📞 Contact

Pour toute question ou suggestion :
- **Email** : support@telemed.example.com
- **Documentation** : [PLATEFORME_COMPLETE.md](./PLATEFORME_COMPLETE.md)

---

**Développé avec ❤️ pour la santé numérique**

---

## 🎯 Quick Links

- 🚀 [Démarrage Rapide](./START_HERE.md)
- 📖 [Documentation Complète](./PLATEFORME_COMPLETE.md)
- 🎥 [Guide Vidéo](./GUIDE_CONSULTATION_VIDEO.md)
- ✅ [Vérification](./CHECKLIST_VERIFICATION.md)
- 🔐 [Authentification](./AUTHENTIFICATION_COMPLETE.md)

---

**Version** : 1.0.0  
**Status** : ✅ Production Ready  
**Dernière MAJ** : 11 octobre 2025
