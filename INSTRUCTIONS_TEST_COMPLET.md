# 🧪 INSTRUCTIONS TEST COMPLET - SPRINT 1 & 2

## 🎯 Test 1: Notifications (Sprint 1)

### Connexion Docteur
```
1. http://localhost:4001/users/log_in
   Email: doctor@example.com
   Password: Password123!

2. http://localhost:4001/appointments
   → Trouver RDV #6 (status: confirmed)
   → Cliquer "🎥 Appel Vidéo"
   
3. Vérifier les logs terminal:
   [info] Doctor ID: 2 ✅
   [info] Patient ID: 1 ✅
   [info] ✅ Doctor notification created
   [info] ✅ Patient notification created
```

### Connexion Patient (nouvel onglet)
```
4. http://localhost:4001/users/log_in
   Email: patient@example.com
   Password: Password123!

5. http://localhost:4001/notifications
   → DOIT voir: "🎥 Dr. ... vous appelle"
   → Bouton vert "REJOINDRE LA CONSULTATION" visible
   → Clic = rejoint la room
```

**Résultat attendu:** Patient reçoit notification avec lien cliquable

---

## 📎 Test 2: Upload Documents (Sprint 2)

### Étape 1: Accéder aux documents
```
1. Rester connecté comme doctor@example.com

2. http://localhost:4001/medical_records
   → Ouvrir un dossier (ex: premier de la liste)

3. Cliquer bouton "📎 Documents" (violet)
   → Devrait aller sur /medical_records/{id}/documents
   → Voir page vide "Aucun document"
```

### Étape 2: Upload un fichier
```
4. Cliquer "📤 Upload Document"
   → Formulaire avec zone drag & drop

5. Préparer un fichier test:
   - PDF (ex: un PDF quelconque)
   - OU Image JPG/PNG
   - OU fichier TXT

6. Glisser-déposer le fichier
   OU cliquer dans la zone pour sélectionner

7. Choisir type: "Prescription" (ou autre)

8. Optionnel: Ajouter description

9. Cliquer "📤 Upload Document"
```

### Étape 3: Vérifier upload
```
10. Devrait revenir à /medical_records/{id}
    → Flash message vert: "✅ Document uploadé"

11. Retourner sur "📎 Documents"
    → Voir la carte du document
    → Nom fichier affiché
    → Taille affichée
    → Date/heure
    → Email uploader
```

### Étape 4: Télécharger
```
12. Cliquer "⬇️ Télécharger"
    → Fichier se télécharge dans Downloads
    → Vérifier que c'est le bon fichier
```

### Étape 5: Détails
```
13. Cliquer sur la carte du document
    → Voir page détails
    → Métadonnées complètes
    → Preview si image
```

### Étape 6: Supprimer
```
14. Cliquer "🗑️" (icône poubelle)
    → Confirm dialog
    → Document supprimé
    → Retour à la liste vide
```

---

## ✅ CHECKLIST DE VALIDATION

### Sprint 1 - Notifications
- [ ] Logs montrent bon doctor_id (2)
- [ ] Logs montrent bon patient_id (1)
- [ ] Docteur reçoit notification
- [ ] Patient reçoit notification
- [ ] Notification patient contient lien
- [ ] Bouton vert "REJOINDRE" visible
- [ ] Clic bouton = rejoint consultation

### Sprint 2 - Upload Documents
- [ ] Bouton "📎 Documents" visible dans DME
- [ ] Page liste documents charge
- [ ] Formulaire upload s'affiche
- [ ] Drag & drop fonctionne
- [ ] Validation fichier (type, taille)
- [ ] Upload réussit
- [ ] Document apparaît dans liste
- [ ] Métadonnées correctes
- [ ] Téléchargement fonctionne
- [ ] Preview image si applicable
- [ ] Suppression fonctionne
- [ ] Permissions respectées

---

## 🐛 SI ERREUR

### Erreur 500
```
Vérifier logs terminal pour stack trace
```

### Page blanche
```
1. Vérifier que serveur tourne
2. mix phx.server si arrêté
3. Vider cache navigateur (Ctrl+Shift+Del)
```

### Upload échoue
```
1. Vérifier taille < 50MB
2. Vérifier extension autorisée
3. Vérifier permissions dossier priv/static/uploads
```

### Notification ne s'affiche pas
```
1. Vérifier user_id dans table notifications
2. Vérifier logs création notification
3. Rafraîchir page /notifications
```

---

## 📊 RAPPORT DE TEST

Après tests, noter:

### Sprint 1
```
✅ / ❌ : Notifications docteur
✅ / ❌ : Notifications patient
✅ / ❌ : Lien cliquable
✅ / ❌ : Rejoindre consultation
```

### Sprint 2
```
✅ / ❌ : Accès page documents
✅ / ❌ : Upload fichier
✅ / ❌ : Liste documents
✅ / ❌ : Téléchargement
✅ / ❌ : Suppression
```

---

**Bon test ! 🧪**

