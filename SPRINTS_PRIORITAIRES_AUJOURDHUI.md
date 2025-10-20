# 🎯 SPRINTS PRIORITAIRES - 19 OCTOBRE 2025

**Projet:** Plateforme Télémédecine & DME  
**État actuel:** Production-ready avec WebRTC Instant Consultation  
**Objectif aujourd'hui:** Améliorer et sécuriser

---

## 📊 ÉTAT DES LIEUX

### ✅ Fonctionnalités Opérationnelles

```
✓ Authentification RBAC (Patient/Doctor/Admin)
✓ DME avec structure SOAP
✓ Consultations vidéo WebRTC P2P
✓ Consultation instantanée (Magic Links)
✓ Phoenix Presence (tracking temps réel)
✓ Quality Monitor
✓ Gestion rendez-vous
✓ Notifications
✓ Dashboards personnalisés
✓ Chat temps réel
```

### ⚠️ Points à Améliorer Identifiés

```
1. Bug notification (patient ne reçoit pas les bonnes notifs)
2. Warnings qualité répétitifs
3. Pas de tests automatisés
4. Pas d'upload de fichiers
5. DME pourrait avoir timeline visuelle
6. Pas de prescriptions électroniques
7. Pas de paiements
```

---

## 🎯 SPRINTS PROPOSÉS POUR AUJOURD'HUI

### 🔴 **SPRINT 1: CORRIGER BUG NOTIFICATIONS** (2h) - URGENT

**Problème:** Patient ne reçoit pas toujours les bonnes notifications

**Actions:**
```
1. Vérifier les IDs dans les RDV (doctor_id vs patient_id)
2. Ajouter logs détaillés
3. Tester avec RDV créé correctement
4. Valider que chaque user reçoit SA notification
```

**Livrables:**
- [x] Script create_test_appointment.exs créé
- [ ] Logs de debug en place
- [ ] Test complet validé
- [ ] Documentation mise à jour

**Impact:** ⭐⭐⭐⭐⭐ (Bloquant pour utilisation)

---

### 🟠 **SPRINT 2: UPLOAD DE FICHIERS/DOCUMENTS** (3-4h) - HAUTE PRIORITÉ

**Objectif:** Permettre upload de documents médicaux (ordonnances, résultats, images)

**Stack recommandé:**
```elixir
# Option A: Local (simple pour démarrer)
- arc / arc_ecto (upload local)
- Stockage: priv/static/uploads

# Option B: Cloud (production-ready)
- ex_aws_s3 (AWS S3)
- waffle (abstraction upload)
```

**Actions:**
```
1. Créer migration medical_documents (1h)
2. Ajouter module Documents.ex (1h)
3. Controller upload avec validation (1h)
4. UI drag & drop (1h)
```

**Code à créer:**
```elixir
# Migration
create table(:medical_documents) do
  add :filename, :string
  add :file_path, :string
  add :content_type, :string
  add :file_size, :integer
  add :document_type, :string  # "prescription", "lab_result", "image"
  add :medical_record_id, references(:medical_records)
  add :uploaded_by_id, references(:users)
  timestamps()
end
```

**Livrables:**
- [ ] Table medical_documents
- [ ] Upload fonctionnel
- [ ] Preview images/PDF
- [ ] Tests upload

**Impact:** ⭐⭐⭐⭐ (Feature critique pour DME)

---

### 🟡 **SPRINT 3: TESTS AUTOMATISÉS** (2-3h) - IMPORTANTE

**Objectif:** Couvrir les fonctionnalités critiques par des tests

**Actions:**
```
1. Tests authentification (30min)
2. Tests InstantRoom GenServer (1h)
3. Tests Magic Links (30min)
4. Tests appointments CRUD (1h)
```

**Code à créer:**
```elixir
# test/telemed/video/instant_room_test.exs
defmodule Telemed.Video.InstantRoomTest do
  use Telemed.DataCase
  alias Telemed.Video.{InstantRoom, RoomSupervisor}
  
  test "démarre une consultation" do
    {:ok, pid, room_id, links} = 
      RoomSupervisor.start_instant_consultation(1, 2, 1)
    
    assert is_pid(pid)
    assert String.starts_with?(room_id, "instant_")
    assert Map.has_key?(links, :doctor_link)
    assert Map.has_key?(links, :patient_link)
  end
end
```

**Livrables:**
- [ ] Tests InstantRoom
- [ ] Tests Magic Links
- [ ] Tests Appointments
- [ ] Coverage > 60%

**Impact:** ⭐⭐⭐ (Qualité et confiance)

---

### 🟢 **SPRINT 4: AMÉLIORER UI CONSULTATION** (2-3h) - POLISH

**Objectif:** Rendre l'interface consultation encore plus belle et fluide

**Actions:**
```
1. Ajouter animations entrée/sortie (30min)
2. Améliorer responsive mobile (1h)
3. Ajouter indicateurs de qualité visuels (30min)
4. Bouton "Inverser caméras" (mobile) (30min)
5. Effets sonores (join/leave) (30min)
```

**Livrables:**
- [ ] Animations CSS
- [ ] UI mobile optimisée
- [ ] Indicateurs visuels
- [ ] Sons (optionnel)

**Impact:** ⭐⭐⭐ (UX/Polish)

---

### 🟢 **SPRINT 5: DME TIMELINE VISUELLE** (3-4h) - FEATURE

**Objectif:** Améliorer l'affichage des dossiers médicaux avec une timeline

**Actions:**
```
1. Créer composant Timeline (1h)
2. Grouper par date (1h)
3. Filtres par catégorie (1h)
4. Recherche full-text basique (1h)
```

**Livrables:**
- [ ] Composant <.timeline>
- [ ] Groupement par mois/année
- [ ] Filtres catégories
- [ ] Recherche

**Impact:** ⭐⭐⭐⭐ (UX DME)

---

## 📅 PLANNING SUGGÉRÉ AUJOURD'HUI

### Matinée (4h)

```
09:00 - 11:00  SPRINT 1: Corriger bug notifications ✅
11:00 - 13:00  SPRINT 2: Upload fichiers (partie 1)
```

### Après-midi (4h)

```
14:00 - 17:00  SPRINT 2: Upload fichiers (partie 2)
17:00 - 18:00  SPRINT 3: Tests automatisés (début)
```

**Total:** 8h de développement productif

---

## 🎯 RECOMMANDATION

**Je vous suggère de commencer dans cet ordre:**

### 1️⃣ **SPRINT 1** (2h) - URGENT ✅ 
Finir de corriger le bug notifications (on est presque là!)

### 2️⃣ **SPRINT 2** (4h) - HAUTE VALEUR
Upload de fichiers = Feature critique pour un DME complet

### 3️⃣ **SPRINT 3** (2h) - QUALITÉ
Tests pour sécuriser ce qu'on a

---

## ❓ QUELLE EST VOTRE PRIORITÉ ?

**Option A:** Focus bug notifications + upload fichiers (recommandé)

**Option B:** Focus tests + qualité code

**Option C:** Focus UI/UX (polish consultation)

**Option D:** Mix de tout (un peu de chaque)

---

**Qu'en pensez-vous ? Par quel sprint voulez-vous commencer ?** 🚀


