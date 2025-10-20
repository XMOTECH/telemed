# 🚀 Roadmap Stratégique - Plateforme SaaS Télémédecine & DME Conforme 2025

**Date**: 18 octobre 2025  
**Stack actuel**: Phoenix 1.7.21 / Elixir 1.14 / PostgreSQL  
**Objectif**: Plateforme SaaS sécurisée, conforme (ANS, HDS, RGPD), prédictive et scalable

---

## 📊 GAP ANALYSIS: État Actuel vs. Brainstorm 2025

### ✅ **DÉJÀ IMPLÉMENTÉ** (Fondations solides)

| Catégorie | Fonctionnalité | État | Qualité |
|-----------|---------------|------|---------|
| 🔐 **Sécurité** | Authentification multi-rôles (Patient/Doctor/Admin) | ✅ Opérationnel | ⭐⭐⭐⭐ |
| 🔐 **Sécurité** | Sessions sécurisées (Bcrypt, CSRF, 60j) | ✅ Opérationnel | ⭐⭐⭐⭐ |
| 🔐 **Sécurité** | RBAC (contrôle d'accès par rôle) | ✅ Opérationnel | ⭐⭐⭐⭐ |
| 🏥 **DME** | Structure SOAP (Subjective/Objective/Assessment/Plan) | ✅ Opérationnel | ⭐⭐⭐⭐ |
| 🏥 **DME** | Catégorisation, tags, priorités | ✅ Opérationnel | ⭐⭐⭐ |
| 🏥 **DME** | Attachements (JSON map) | ✅ Basique | ⭐⭐⭐ |
| 📹 **Télémédecine** | Consultations vidéo WebRTC (Phoenix Channels) | ✅ Opérationnel | ⭐⭐⭐ |
| 📹 **Télémédecine** | Chat intégré temps réel | ✅ Opérationnel | ⭐⭐⭐⭐ |
| 📹 **Télémédecine** | Partage d'écran | ✅ Opérationnel | ⭐⭐⭐ |
| 📅 **Gestion** | Système de RDV (Appointments) | ✅ Opérationnel | ⭐⭐⭐ |
| 🔔 **Notifications** | Système de notifications intégré | ✅ Opérationnel | ⭐⭐⭐ |

### ❌ **GAPS CRITIQUES** (Conformité 2025)

| Priorité | Gap Identifié | Impact | Effort | Référence Brainstorm |
|----------|---------------|--------|--------|---------------------|
| 🔴 **P0** | **Hébergement HDS** (obligatoire) | Légal | 2-3 mois | Sécurité §3 |
| 🔴 **P0** | **Intégration INS** (Identité Nationale Santé) | Conformité ANS | 1-2 mois | Sécurité §3 |
| 🔴 **P0** | **Chiffrement E2E** (AES-256/TLS 1.3) | Sécurité données | 3-4 sem | Sécurité §3 |
| 🔴 **P0** | **Logs immuables + traçabilité** | Audit RGPD | 2-3 sem | Sécurité §3 |
| 🟠 **P1** | **Intégration Mon espace santé** (API FHIR) | Interopérabilité | 2-3 mois | DME §2 |
| 🟠 **P1** | **Télésurveillance** (LATM/PECAN compatible) | Innovation | 1-2 mois | Télémédecine §1 |
| 🟠 **P1** | **Facturation SESAM-Vitale/SCOR** | Ops/Remboursement | 2-3 mois | Facturation §4 |
| 🟠 **P1** | **Pro Santé Connect** (auth pros) | UX Professionnels | 1 mois | Sécurité §3 |
| 🟡 **P2** | **IA prédictive** (risques, no-shows) | Différenciation | 2-4 mois | Innovations §5 |
| 🟡 **P2** | **Jumeaux numériques patients** | Innovation | 4-6 mois | DME §2 |
| 🟡 **P2** | **AR/VR pour examens** | Innovation | 3-6 mois | Télémédecine §1 |
| 🟢 **P3** | **Marketplace apps tierces** | Écosystème | 3-4 mois | Facturation §4 |

---

## 🎯 ROADMAP PAR PHASES (Méthode MVP Itérative)

### **PHASE 0: AUDIT & PRÉPARATION** (Budget: 10-20k€ | Durée: 1 mois)

**Objectif**: Établir la baseline de conformité et sécuriser les fondations

#### Actions Critiques
```elixir
# 1. Audit de sécurité complet
- Scan vulnérabilités (mix deps.audit, Sobelow)
- Audit RGPD (consentements, droit à l'oubli)
- Test penetration (embaucher cabinet spécialisé santé)
- Documentation architecture (diagrammes C4, flux données)

# 2. Setup environnement compliance
- Environnement HDS-ready (prestataire certifié: Scaleway Health, OVHcloud Healthcare)
- Logs centralisés (ELK/Loki avec rétention 3 ans RGPD)
- Sauvegarde chiffrée automatique (RPO <1h, RTO <4h)
- Procédures incident (CERT Santé)

# 3. Formation équipe
- Formation RGPD/HDS (5j)
- Workshop Phoenix Security (2j)
- Veille réglementaire ANS
```

#### Livrables
- ✅ Rapport d'audit sécurité
- ✅ Dossier d'architecture HDS
- ✅ Registre des traitements RGPD
- ✅ Plan de reprise d'activité (PRA)

---

### **PHASE 1: MVP CONFORME** (Budget: 80-120k€ | Durée: 4-6 mois)

**Objectif**: Plateforme certifiable ANS + HDS, testable avec 100 utilisateurs pilotes

#### 1.1 Sécurité Renforcée (2 mois)

##### A. Chiffrement End-to-End
```elixir
# Ajouter à mix.exs
{:cloak_ecto, "~> 1.3"}  # Chiffrement champs sensibles
{:guardian, "~> 2.3"}     # JWT pour API tierces

# Nouvelle migration
defmodule Telemed.Repo.Migrations.AddEncryptionToMedicalRecords do
  use Ecto.Migration
  
  def change do
    alter table(:medical_records) do
      add :encrypted_soap_subjective, :binary  # Chiffré AES-256-GCM
      add :encrypted_diagnosis, :binary
      add :encrypted_treatment_plan, :binary
      add :encryption_key_id, :string  # Rotation clés
    end
    
    # Conserver anciens champs pendant migration
    create index(:medical_records, [:encryption_key_id])
  end
end

# Schema avec Cloak
defmodule Telemed.MedicalRecords.MedicalRecord do
  use Ecto.Schema
  import Ecto.Changeset
  
  schema "medical_records" do
    # Champs chiffrés
    field :soap_subjective, Telemed.Encrypted.Binary
    field :diagnosis, Telemed.Encrypted.Binary
    field :treatment_plan, Telemed.Encrypted.Binary
    
    # ... reste des champs
  end
end

# Configuration Cloak (config/runtime.exs)
config :telemed, Telemed.Vault,
  ciphers: [
    default: {Cloak.Ciphers.AES.GCM, 
      tag: "AES.GCM.V1", 
      key: Base.decode64!(System.get_env("CLOAK_KEY"))}
  ]
```

##### B. Authentification Multicouche (INS + Pro Santé Connect)
```elixir
# Nouveau module lib/telemed/accounts/ins_integration.ex
defmodule Telemed.Accounts.INSIntegration do
  @moduledoc """
  Intégration avec l'Identité Nationale de Santé (INS)
  Référentiel ANS: https://esante.gouv.fr/produits-services/ins
  """
  
  alias Telemed.Accounts.User
  
  @doc """
  Vérifie et récupère l'INS d'un patient via téléservice INSi
  """
  def fetch_ins(user_params) do
    with {:ok, ins_data} <- call_insi_webservice(user_params),
         {:ok, validated} <- validate_ins_traits(ins_data) do
      {:ok, %{
        ins_number: validated.matricule_ins,
        ins_oid: "1.2.250.1.213.1.4.10",  # OID national
        identity_verified: true,
        verification_date: DateTime.utc_now()
      }}
    end
  end
  
  defp call_insi_webservice(params) do
    # Appel SOAP au téléservice INSi (TEST: https://ins-ref.oup.esante-si.infra-terr-2.asipsante.fr/)
    # Production: nécessite certificat client + authentification
    # TODO: Implémenter client SOAP avec certificat
    {:error, :not_implemented}
  end
end

# Migration pour stocker l'INS
defmodule Telemed.Repo.Migrations.AddInsToUsers do
  use Ecto.Migration
  
  def change do
    alter table(:users) do
      add :ins_number, :string  # Matricule INS (13 chiffres)
      add :ins_oid, :string  # OID du domaine
      add :ins_verified_at, :utc_datetime
      add :identity_traits, :map  # Traits d'identité (nom, prénom, date naissance, sexe)
    end
    
    create unique_index(:users, [:ins_number], where: "ins_number IS NOT NULL")
  end
end
```

##### C. Pro Santé Connect (OAuth2/OpenID Connect)
```elixir
# Ajouter à mix.exs
{:ueberauth, "~> 0.10"}
{:ueberauth_identity, "~> 0.4"}  # Fallback
# TODO: Créer adaptateur custom pour Pro Santé Connect

# Configuration (config/config.exs)
config :ueberauth, Ueberauth,
  providers: [
    pro_sante_connect: {Ueberauth.Strategy.ProSanteConnect, [
      client_id: System.get_env("PSC_CLIENT_ID"),
      client_secret: System.get_env("PSC_CLIENT_SECRET"),
      authorize_url: "https://auth.esw.esante.gouv.fr/auth",
      token_url: "https://auth.esw.esante.gouv.fr/token"
    ]}
  ]
```

##### D. Logs Immuables & Traçabilité
```elixir
# Nouveau module lib/telemed/audit_log.ex
defmodule Telemed.AuditLog do
  use Ecto.Schema
  import Ecto.Changeset
  
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "audit_logs" do
    field :event_type, :string  # access, modify, delete, export
    field :resource_type, :string  # medical_record, user, appointment
    field :resource_id, :integer
    field :actor_id, :integer  # User qui fait l'action
    field :actor_role, :string
    field :action_details, :map
    field :ip_address, :string
    field :user_agent, :string
    field :result, :string  # success, failure, partial
    field :hash_chain, :string  # SHA256 de l'entrée précédente (blockchain-like)
    
    timestamps(updated_at: false)  # Immutable, pas de update
  end
  
  @doc "Log toute action sensible (RGPD Art. 30)"
  def log_access(resource, actor, metadata \\ %{}) do
    %__MODULE__{}
    |> cast(%{
      event_type: "access",
      resource_type: resource.__struct__ |> to_string() |> String.split(".") |> List.last(),
      resource_id: resource.id,
      actor_id: actor.id,
      actor_role: actor.role,
      action_details: metadata,
      hash_chain: compute_hash_chain()
    }, [:event_type, :resource_type, :resource_id, :actor_id, :actor_role, :action_details, :hash_chain])
    |> Telemed.Repo.insert()
  end
  
  defp compute_hash_chain do
    # Récupère le hash du dernier log et chaîne avec le nouveau
    last_log = Telemed.Repo.one(from l in __MODULE__, order_by: [desc: l.inserted_at], limit: 1)
    previous_hash = if last_log, do: last_log.hash_chain, else: "genesis"
    :crypto.hash(:sha256, "#{previous_hash}#{DateTime.utc_now()}") |> Base.encode16()
  end
end

# Migration
defmodule Telemed.Repo.Migrations.CreateAuditLogs do
  use Ecto.Migration
  
  def change do
    create table(:audit_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_type, :string, null: false
      add :resource_type, :string, null: false
      add :resource_id, :integer
      add :actor_id, references(:users), null: false
      add :actor_role, :string
      add :action_details, :map
      add :ip_address, :inet
      add :user_agent, :text
      add :result, :string, default: "success"
      add :hash_chain, :string, null: false
      
      timestamps(updated_at: false)
    end
    
    create index(:audit_logs, [:resource_type, :resource_id])
    create index(:audit_logs, [:actor_id])
    create index(:audit_logs, [:inserted_at])
  end
end

# Plug pour tracer automatiquement
defmodule TelemedWeb.AuditLogPlug do
  import Plug.Conn
  alias Telemed.AuditLog
  
  def init(opts), do: opts
  
  def call(conn, _opts) do
    register_before_send(conn, fn conn ->
      if conn.assigns[:current_user] && sensitive_route?(conn) do
        AuditLog.log_access(
          extract_resource(conn),
          conn.assigns.current_user,
          %{
            ip: conn.remote_ip |> Tuple.to_list() |> Enum.join("."),
            user_agent: get_req_header(conn, "user-agent") |> List.first(),
            method: conn.method,
            path: conn.request_path
          }
        )
      end
      conn
    end)
  end
  
  defp sensitive_route?(conn) do
    conn.request_path =~ ~r{^/(medical_records|appointments|users/settings)}
  end
end
```

---

#### 1.2 DME Interopérable (2 mois)

##### A. Intégration FHIR (HL7 FHIR R4)
```elixir
# Ajouter à mix.exs
{:fhir_client, "~> 0.5"}  # Client FHIR

# Nouveau module lib/telemed/fhir/converter.ex
defmodule Telemed.FHIR.Converter do
  @moduledoc """
  Conversion entre schéma Telemed et FHIR R4
  Spec: https://www.hl7.org/fhir/
  """
  
  alias Telemed.MedicalRecords.MedicalRecord
  
  @doc "Convertit MedicalRecord vers ressource FHIR DocumentReference"
  def to_fhir_document_reference(%MedicalRecord{} = record) do
    %{
      "resourceType" => "DocumentReference",
      "id" => to_string(record.id),
      "status" => map_status(record.status),
      "type" => %{
        "coding" => [%{
          "system" => "http://loinc.org",
          "code" => map_loinc_code(record.category),
          "display" => record.category
        }]
      },
      "subject" => %{
        "reference" => "Patient/#{record.user_id}",
        "identifier" => %{
          "system" => "urn:oid:1.2.250.1.213.1.4.10",  # INS
          "value" => record.user.ins_number
        }
      },
      "date" => record.consultation_date || record.inserted_at,
      "author" => [%{
        "reference" => "Practitioner/#{record.doctor_id}"
      }],
      "content" => [
        %{
          "attachment" => %{
            "contentType" => "text/plain",
            "data" => Base.encode64(format_soap_content(record))
          }
        }
      ],
      "context" => %{
        "period" => %{
          "start" => record.consultation_date
        }
      }
    }
  end
  
  defp format_soap_content(record) do
    """
    SUBJECTIVE: #{record.soap_subjective || "N/A"}
    OBJECTIVE: #{record.soap_objective || "N/A"}
    ASSESSMENT: #{record.soap_assessment || "N/A"}
    PLAN: #{record.soap_plan || "N/A"}
    """
  end
  
  defp map_loinc_code(category) do
    # Mapping vers codes LOINC standards
    %{
      "consultation" => "34117-2",  # History and physical note
      "exam" => "34133-9",  # Summarization of encounter note
      "treatment" => "18776-5",  # Plan of care note
      "prescription" => "57833-6",  # Prescription for medication
      "followup" => "11506-3"  # Progress note
    }[category] || "34117-2"
  end
end

# API pour Mon espace santé
defmodule TelemedWeb.FHIRController do
  use TelemedWeb, :controller
  alias Telemed.FHIR.Converter
  
  @doc "Endpoint FHIR pour export vers Mon espace santé"
  def export_to_mes(conn, %{"record_id" => id}) do
    user = conn.assigns.current_user
    
    with {:ok, record} <- Telemed.MedicalRecords.get_record(id, user),
         :ok <- check_consent(user, :mes_export),
         fhir_doc <- Converter.to_fhir_document_reference(record),
         {:ok, _} <- push_to_mes(user.ins_number, fhir_doc) do
      json(conn, %{status: "success", message: "Document envoyé vers Mon espace santé"})
    else
      {:error, :no_consent} -> 
        conn |> put_status(403) |> json(%{error: "Consentement requis"})
      error -> 
        conn |> put_status(500) |> json(%{error: inspect(error)})
    end
  end
  
  defp push_to_mes(ins, fhir_doc) do
    # TODO: Appel API FHIR Mon espace santé (nécessite certificat + authorization)
    # Production: https://api.esw.esante.gouv.fr/fhir
    {:error, :not_implemented}
  end
end
```

##### B. Gestion des Consentements (RGPD)
```elixir
# Nouvelle table migrations
defmodule Telemed.Repo.Migrations.CreateConsents do
  use Ecto.Migration
  
  def change do
    create table(:consents) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :consent_type, :string, null: false  # data_processing, mes_sharing, research, marketing
      add :granted, :boolean, default: false
      add :granted_at, :utc_datetime
      add :revoked_at, :utc_datetime
      add :version, :string  # Version des CGU/politique
      add :ip_address, :inet
      add :metadata, :map
      
      timestamps()
    end
    
    create index(:consents, [:user_id, :consent_type])
    create unique_index(:consents, [:user_id, :consent_type, :version])
  end
end

# Schema
defmodule Telemed.Accounts.Consent do
  use Ecto.Schema
  import Ecto.Changeset
  
  schema "consents" do
    belongs_to :user, Telemed.Accounts.User
    field :consent_type, :string
    field :granted, :boolean
    field :granted_at, :utc_datetime
    field :revoked_at, :utc_datetime
    field :version, :string
    field :ip_address, :string
    field :metadata, :map
    
    timestamps()
  end
  
  @consent_types ~w(data_processing mes_sharing telemedicine research marketing)
  
  def changeset(consent, attrs) do
    consent
    |> cast(attrs, [:user_id, :consent_type, :granted, :version, :ip_address, :metadata])
    |> validate_required([:user_id, :consent_type, :granted])
    |> validate_inclusion(:consent_type, @consent_types)
    |> maybe_set_granted_at()
  end
  
  defp maybe_set_granted_at(changeset) do
    if get_change(changeset, :granted) == true do
      put_change(changeset, :granted_at, DateTime.utc_now())
    else
      changeset
    end
  end
end

# Context
defmodule Telemed.Accounts do
  alias Telemed.Accounts.Consent
  
  @doc "Vérifie si l'utilisateur a donné son consentement"
  def has_consent?(user, consent_type) do
    Consent
    |> where([c], c.user_id == ^user.id and c.consent_type == ^consent_type)
    |> where([c], c.granted == true and is_nil(c.revoked_at))
    |> Telemed.Repo.exists?()
  end
  
  @doc "Enregistre un consentement"
  def grant_consent(user, consent_type, metadata \\ %{}) do
    %Consent{}
    |> Consent.changeset(%{
      user_id: user.id,
      consent_type: consent_type,
      granted: true,
      version: "1.0",  # TODO: Gérer versions CGU
      metadata: metadata
    })
    |> Telemed.Repo.insert()
  end
  
  @doc "Révoque un consentement (droit RGPD)"
  def revoke_consent(user, consent_type) do
    from(c in Consent,
      where: c.user_id == ^user.id and c.consent_type == ^consent_type and c.granted == true
    )
    |> Telemed.Repo.update_all(set: [revoked_at: DateTime.utc_now()])
  end
end
```

---

#### 1.3 Télémédecine Enrichie (1.5 mois)

##### A. Enregistrement des consultations (Conformité)
```elixir
# Migration
defmodule Telemed.Repo.Migrations.AddRecordingToAppointments do
  use Ecto.Migration
  
  def change do
    alter table(:appointments) do
      add :recording_enabled, :boolean, default: false
      add :recording_url, :string  # Stockage sécurisé (S3-compatible HDS)
      add :recording_consent_given, :boolean
      add :recording_consent_date, :utc_datetime
      add :recording_duration_seconds, :integer
      add :recording_size_bytes, :bigint
    end
  end
end

# Intégration stockage (ex: MinIO HDS)
defmodule Telemed.Storage.Recordings do
  @moduledoc """
  Gestion des enregistrements de consultations
  Stockage: MinIO (compatible S3) avec chiffrement AES-256
  Rétention: 10 ans (obligations légales télémédecine)
  """
  
  @bucket "telemed-recordings-encrypted"
  
  def upload_recording(appointment_id, file_path) do
    with {:ok, consent} <- verify_recording_consent(appointment_id),
         {:ok, encrypted_file} <- encrypt_file(file_path),
         {:ok, _} <- ExAws.S3.put_object(@bucket, "#{appointment_id}.enc", encrypted_file) |> ExAws.request() do
      {:ok, generate_signed_url(appointment_id)}
    end
  end
  
  defp verify_recording_consent(appointment_id) do
    # Vérifier que patient ET médecin ont consenti
    {:ok, true}  # Simplifié
  end
end
```

##### B. Télésurveillance (LATM/PECAN)
```elixir
# Nouveau module pour objets connectés
defmodule Telemed.Monitoring.DeviceIntegration do
  @moduledoc """
  Intégration objets connectés médicaux (tensiomètres, glucomètres, etc.)
  Conformité: LATM (Liste des Actes et prestations de Télémédecine)
  """
  
  # TODO: Intégration API tierces (Withings, iHealth, etc.)
  # Format: HL7 FHIR Observation
  
  def receive_measurement(device_id, measurement_data) do
    %{
      "resourceType" => "Observation",
      "status" => "final",
      "code" => measurement_data.type,  # Ex: blood pressure (55284-4)
      "subject" => %{"reference" => "Patient/#{measurement_data.patient_id}"},
      "effectiveDateTime" => measurement_data.timestamp,
      "valueQuantity" => %{
        "value" => measurement_data.value,
        "unit" => measurement_data.unit
      }
    }
    |> store_observation()
    |> maybe_trigger_alert()
  end
end
```

---

#### 1.4 Facturation Automatisée (1 mois)

##### Intégration SESAM-Vitale (FSE - Feuille de Soins Électronique)
```elixir
# Migration
defmodule Telemed.Repo.Migrations.CreateBilling do
  use Ecto.Migration
  
  def change do
    create table(:billing_records) do
      add :appointment_id, references(:appointments), null: false
      add :patient_id, references(:users), null: false
      add :doctor_id, references(:users), null: false
      
      # Carte Vitale
      add :nir, :string  # Numéro Sécurité Sociale (crypté)
      add :amc_number, :string  # Numéro AMC (mutuelle)
      add :regime, :string  # Régime obligatoire
      
      # Acte
      add :ccam_code, :string  # Code CCAM (ex: TCY pour téléconsultation)
      add :amount_total, :decimal, precision: 10, scale: 2
      add :amount_am, :decimal, precision: 10, scale: 2  # Part AM (70%)
      add :amount_amc, :decimal, precision: 10, scale: 2  # Part mutuelle
      add :amount_patient, :decimal, precision: 10, scale: 2  # Reste à charge
      
      # FSE
      add :fse_number, :string
      add :fse_sent_at, :utc_datetime
      add :fse_status, :string  # pending, sent, accepted, rejected
      add :fse_response, :map
      
      timestamps()
    end
    
    create index(:billing_records, [:appointment_id])
    create index(:billing_records, [:fse_status])
  end
end

# Module facturation
defmodule Telemed.Billing do
  @moduledoc """
  Gestion facturation téléconsultation
  Nomenclature: CCAM (TCY - Téléconsultation)
  Taux remboursement: 70% AM (25€ → 17.50€)
  """
  
  alias Telemed.Billing.BillingRecord
  
  @telemedicine_rate Decimal.new("25.00")  # Tarif conventionné 2025
  @am_rate Decimal.new("0.70")  # 70% remboursé
  
  def create_invoice(appointment) do
    %BillingRecord{}
    |> BillingRecord.changeset(%{
      appointment_id: appointment.id,
      patient_id: appointment.patient_id,
      doctor_id: appointment.doctor_id,
      ccam_code: "TCY",
      amount_total: @telemedicine_rate,
      amount_am: Decimal.mult(@telemedicine_rate, @am_rate),
      amount_patient: Decimal.sub(@telemedicine_rate, Decimal.mult(@telemedicine_rate, @am_rate))
    })
    |> Telemed.Repo.insert()
  end
  
  @doc "Génère et envoie FSE via SCOR"
  def send_fse(billing_record) do
    # TODO: Intégration SCOR (nécessite carte CPS + logiciel agréé)
    {:error, :not_implemented}
  end
end
```

---

### **PHASE 2: INNOVATIONS & DIFFÉRENCIATION** (Budget: 100-150k€ | Durée: 4-6 mois)

**Objectif**: IA prédictive, télésurveillance avancée, UX exceptionnelle

#### 2.1 IA Prédictive (3 mois)

##### A. Prédiction No-Shows
```elixir
# Ajouter à mix.exs
{:scholar, "~> 0.3"}  # Machine Learning Elixir
{:nx, "~> 0.7"}  # Tenseurs numériques

# Module ML
defmodule Telemed.ML.NoShowPredictor do
  @moduledoc """
  Modèle de prédiction des rendez-vous manqués
  Features: historique patient, jour/heure, météo, délai booking
  """
  
  import Nx.Defn
  alias Scholar.Linear.LogisticRegression
  
  def train_model do
    # Récupérer données historiques
    data = fetch_historical_appointments()
    
    # Features engineering
    features = Nx.tensor(
      Enum.map(data, fn appt ->
        [
          days_until_appointment(appt),
          hour_of_day(appt),
          day_of_week(appt),
          patient_history_score(appt.patient_id),
          appointment_type_numeric(appt),
          weather_score(appt)  # API météo optionnelle
        ]
      end)
    )
    
    labels = Nx.tensor(Enum.map(data, & &1.was_no_show))
    
    # Entraîner modèle logistique
    model = LogisticRegression.fit(features, labels)
    
    # Sauvegarder
    File.write!("priv/ml_models/no_show_predictor.bin", :erlang.term_to_binary(model))
    model
  end
  
  @doc "Prédit probabilité de no-show pour un RDV"
  def predict_no_show(appointment) do
    model = load_model()
    features = extract_features(appointment)
    
    probability = LogisticRegression.predict_probability(model, features)
    
    cond do
      probability > 0.7 -> {:high_risk, probability}
      probability > 0.4 -> {:medium_risk, probability}
      true -> {:low_risk, probability}
    end
  end
  
  defp patient_history_score(patient_id) do
    # Calcule score basé sur historique (taux présence, annulations, etc.)
    stats = Telemed.Appointments.patient_statistics(patient_id)
    stats.attendance_rate
  end
end

# Rappels intelligents basés sur prédiction
defmodule Telemed.Notifications.SmartReminders do
  alias Telemed.ML.NoShowPredictor
  
  def schedule_reminders(appointment) do
    case NoShowPredictor.predict_no_show(appointment) do
      {:high_risk, prob} ->
        # 3 rappels : 48h, 24h, 2h avant
        schedule_reminder(appointment, hours_before: 48, channel: [:email, :sms, :push])
        schedule_reminder(appointment, hours_before: 24, channel: [:sms, :push, :call])
        schedule_reminder(appointment, hours_before: 2, channel: [:push, :call])
        
      {:medium_risk, _} ->
        # 2 rappels standards
        schedule_reminder(appointment, hours_before: 24, channel: [:email, :push])
        schedule_reminder(appointment, hours_before: 2, channel: [:push])
        
      {:low_risk, _} ->
        # 1 rappel simple
        schedule_reminder(appointment, hours_before: 24, channel: [:email])
    end
  end
end
```

##### B. Détection Anomalies (Zero Trust)
```elixir
defmodule Telemed.Security.AnomalyDetection do
  @moduledoc """
  Détection comportements anormaux via ML
  Exemples: accès inhabituel (heure, lieu), volume requêtes, tentatives accès non autorisé
  """
  
  def analyze_session(conn) do
    user = conn.assigns.current_user
    
    features = [
      hour_of_day: DateTime.utc_now().hour,
      day_of_week: Date.day_of_week(DateTime.utc_now()),
      ip_country: geolocate_ip(conn.remote_ip),
      request_count_last_hour: count_recent_requests(user),
      failed_auth_attempts: count_failed_auth(user)
    ]
    
    risk_score = calculate_risk_score(features, user.id)
    
    cond do
      risk_score > 0.8 ->
        # Bloquer + alerter
        require_2fa(conn)
        notify_security_team(user, risk_score)
        
      risk_score > 0.5 ->
        # Challenge supplémentaire
        require_2fa(conn)
        
      true ->
        # Normal
        conn
    end
  end
end
```

---

#### 2.2 Télésurveillance Avancée (2 mois)

##### Dashboard Patient en Temps Réel
```elixir
# LiveView pour monitoring
defmodule TelemedWeb.MonitoringLive do
  use TelemedWeb, :live_view
  
  @impl true
  def mount(%{"patient_id" => patient_id}, _session, socket) do
    if connected?(socket) do
      # Subscribe à PubSub pour updates temps réel
      Phoenix.PubSub.subscribe(Telemed.PubSub, "monitoring:#{patient_id}")
    end
    
    {:ok, 
     socket
     |> assign(:patient, load_patient(patient_id))
     |> assign(:latest_measurements, load_measurements(patient_id))
     |> assign(:alerts, [])
    }
  end
  
  @impl true
  def handle_info({:new_measurement, measurement}, socket) do
    # Nouvelle mesure reçue (glucomètre, tensiomètre, etc.)
    alerts = check_thresholds(measurement, socket.assigns.patient)
    
    {:noreply, 
     socket
     |> update(:latest_measurements, &[measurement | &1])
     |> assign(:alerts, alerts)
     |> push_event("new-measurement", %{data: measurement})
    }
  end
  
  defp check_thresholds(measurement, patient) do
    # Vérifier seuils personnalisés patient
    case measurement.type do
      "blood_pressure" ->
        if measurement.systolic > 140 or measurement.diastolic > 90 do
          [create_alert(:high_blood_pressure, measurement, patient)]
        else
          []
        end
        
      "blood_glucose" ->
        if measurement.value < 70 or measurement.value > 180 do
          [create_alert(:abnormal_glucose, measurement, patient)]
        else
          []
        end
        
      _ -> []
    end
  end
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="monitoring-dashboard">
      <h1>Télésurveillance - <%= @patient.nom %></h1>
      
      <!-- Alertes actives -->
      <div :if={length(@alerts) > 0} class="alerts bg-red-100 p-4 rounded">
        <h2>⚠️ Alertes Actives</h2>
        <div :for={alert <- @alerts} class="alert">
          <%= alert.message %>
        </div>
      </div>
      
      <!-- Graphiques temps réel (Chart.js via hooks) -->
      <div id="real-time-chart" phx-hook="RealtimeChart" data-measurements={Jason.encode!(@latest_measurements)}>
      </div>
      
      <!-- Dernières mesures -->
      <div class="measurements-table">
        <table>
          <thead>
            <tr>
              <th>Type</th>
              <th>Valeur</th>
              <th>Unité</th>
              <th>Date</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={m <- Enum.take(@latest_measurements, 20)}>
              <td><%= m.type %></td>
              <td class={value_class(m)}><%= m.value %></td>
              <td><%= m.unit %></td>
              <td><%= format_datetime(m.timestamp) %></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
```

---

#### 2.3 UX Exceptionnelle (1 mois)

##### A. Accessibilité WCAG 2.2 AAA
```elixir
# Composants accessibles (lib/telemed_web/components/accessible_components.ex)
defmodule TelemedWeb.AccessibleComponents do
  use Phoenix.Component
  
  attr :label, :string, required: true
  attr :id, :string, required: true
  attr :error, :string, default: nil
  attr :required, :boolean, default: false
  attr :rest, :global
  
  def accessible_input(assigns) do
    ~H"""
    <div class="form-group">
      <label for={@id} class="form-label">
        <%= @label %>
        <span :if={@required} aria-label="requis" class="text-red-600">*</span>
      </label>
      <input
        id={@id}
        name={@id}
        aria-required={@required}
        aria-invalid={!!@error}
        aria-describedby={if @error, do: "#{@id}-error"}
        class="form-input"
        {@rest}
      />
      <div :if={@error} id={"#{@id}-error"} role="alert" class="text-red-600 text-sm mt-1">
        <%= @error %>
      </div>
    </div>
    """
  end
  
  @doc "Mode vocal pour seniors (intégration Web Speech API)"
  attr :on_command, :any, required: true
  
  def voice_assistant(assigns) do
    ~H"""
    <div id="voice-assistant" phx-hook="VoiceAssistant" data-on-command={@on_command}>
      <button 
        type="button"
        aria-label="Activer l'assistant vocal"
        class="voice-button"
        phx-click="toggle_voice">
        🎤 Assistant Vocal
      </button>
    </div>
    """
  end
end

# Hook JavaScript (assets/js/voice_assistant.js)
"""
export const VoiceAssistant = {
  mounted() {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    this.recognition = new SpeechRecognition();
    this.recognition.lang = 'fr-FR';
    this.recognition.continuous = true;
    
    this.recognition.onresult = (event) => {
      const transcript = event.results[event.results.length - 1][0].transcript;
      this.pushEvent("voice_command", { transcript });
    };
    
    this.handleEvent("toggle_voice", () => {
      this.recognition.start();
    });
  }
}
"""
```

##### B. Mode Hors-ligne (PWA)
```javascript
// assets/js/service-worker.js
const CACHE_NAME = 'telemed-v1';
const OFFLINE_URL = '/offline';

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll([
        '/',
        '/css/app.css',
        '/js/app.js',
        '/offline',
        '/images/logo.svg'
      ]);
    })
  );
});

self.addEventListener('fetch', (event) => {
  if (event.request.mode === 'navigate') {
    event.respondWith(
      fetch(event.request).catch(() => {
        return caches.match(OFFLINE_URL);
      })
    );
  }
});
```

---

### **PHASE 3: SCALABILITÉ & ÉCOSYSTÈME** (Budget: 80-100k€ | Durée: 3-4 mois)

**Objectif**: Export international (EHDS), marketplace, monitoring avancé

#### 3.1 Export Europe (EHDS) (2 mois)

##### Compatibilité FHIR EU
```elixir
# Module export EHDS
defmodule Telemed.EHDS.Exporter do
  @moduledoc """
  Export données santé vers European Health Data Space
  Conformité: GDPR, FHIR R4, eIDAS
  """
  
  def export_patient_summary(patient_id, destination_country) do
    with {:ok, patient} <- load_patient(patient_id),
         {:ok, consent} <- verify_cross_border_consent(patient),
         {:ok, bundle} <- build_patient_summary_bundle(patient),
         {:ok, signed_bundle} <- sign_with_eidas(bundle),
         {:ok, _} <- send_to_ehds_node(destination_country, signed_bundle) do
      {:ok, "Export réussi vers #{destination_country}"}
    end
  end
  
  defp build_patient_summary_bundle(patient) do
    # International Patient Summary (IPS) - Profil FHIR
    %{
      "resourceType" => "Bundle",
      "type" => "document",
      "entry" => [
        build_patient_resource(patient),
        build_medication_summary(patient),
        build_allergy_intolerances(patient),
        build_problems_list(patient)
      ]
    }
  end
end
```

---

#### 3.2 Marketplace Apps (2 mois)

##### API Publique pour Tiers
```elixir
# Nouvelle app API
defmodule TelemedAPI do
  use Phoenix.Endpoint, otp_app: :telemed_api
  
  # Routes API v1
  scope "/api/v1", TelemedAPI do
    pipe_through :api_auth  # JWT Guardian
    
    resources "/patients", PatientController, only: [:index, :show]
    resources "/appointments", AppointmentController
    post "/observations", ObservationController, :create  # Pour objets connectés
  end
end

# OAuth2 pour apps tierces
defmodule Telemed.OAuth do
  @moduledoc """
  OAuth2 Server pour autoriser apps tierces
  Ex: App mobile de suivi diabète veut lire glycémies
  """
  
  # TODO: Implémenter avec ex_oauth2_provider ou boruta
end
```

---

## 📊 ESTIMATION BUDGET GLOBAL

| Phase | Durée | Dev | Infra HDS | Certif | Total |
|-------|-------|-----|-----------|--------|-------|
| **P0 Audit** | 1 mois | 15k€ | - | 5k€ | **20k€** |
| **P1 MVP Conforme** | 6 mois | 80k€ | 25k€/an | 15k€ | **120k€** |
| **P2 Innovations** | 6 mois | 100k€ | - | - | **100k€** |
| **P3 Scalabilité** | 4 mois | 70k€ | - | 10k€ | **80k€** |
| **TOTAL** | **17 mois** | **265k€** | **25k€** | **30k€** | **320k€** |

*Note: Hors coûts équipe permanente (2-3 devs + 1 PO + 1 DevSecOps)*

---

## 🎯 QUICK WINS (3 mois pour impact immédiat)

### Actions Prioritaires Sans Budget Lourd

1. **Chiffrement Cloak** (1 semaine) - Ajouter `cloak_ecto` pour champs sensibles
2. **Logs Audit Immuables** (2 semaines) - Implémenter `AuditLog` avec hash chain
3. **Consentements RGPD** (1 semaine) - Table `consents` + UI
4. **2FA TOTP** (1 semaine) - Ajouter `nimble_totp` pour admin/doctors
5. **Export FHIR Basique** (2 semaines) - Converter SOAP → FHIR JSON
6. **Prédiction No-Shows** (3 semaines) - ML avec `scholar`
7. **Dashboard Monitoring** (2 semaines) - LiveView pour télésurveillance

**Total**: ~10 semaines dev | Budget: ~25k€ (0.5 ETP)

---

## 🚨 RISQUES & MITIGATION

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Refus certification HDS | Moyenne | Bloquant | Audit préalable + accompagnement ANS |
| Coûts infra HDS explosifs | Élevée | Financier | Négocier tarifs, envisager multi-tenant |
| Délais intégration INS/PSC | Élevée | Planning | Commencer tests en sandbox ANS dès P0 |
| Turnover équipe | Moyenne | Qualité | Documentation intensive, tests auto |
| Changements réglementaires | Élevée | Conformité | Veille ANS/HAS continue, architecture modulaire |
| Adoption faible (résistance médecins) | Moyenne | Business | UX irréprochable, formation, support |

---

## 📚 RESSOURCES TECHNIQUES

### Documentation Officielle
- [Référentiel ANS v1.5.1](https://esante.gouv.fr/produits-services/referentiel-didentification-electronique)
- [HL7 FHIR R4](https://www.hl7.org/fhir/)
- [Guide RGPD Santé - CNIL](https://www.cnil.fr/fr/la-sante)
- [Certification HDS](https://esante.gouv.fr/produits-services/hds)

### Librairies Elixir Recommandées
```elixir
# Security
{:cloak_ecto, "~> 1.3"}          # Chiffrement DB
{:guardian, "~> 2.3"}             # JWT
{:nimble_totp, "~> 1.0"}          # 2FA
{:sobelow, "~> 0.13", only: :dev} # Audit sécurité

# FHIR / Interop
{:fhir_client, "~> 0.5"}          # Client FHIR
{:soap, "~> 1.0"}                 # Client SOAP (INSi)
{:xml_builder, "~> 2.2"}          # Construction XML

# ML / Analytics
{:scholar, "~> 0.3"}              # ML
{:nx, "~> 0.7"}                   # Tenseurs
{:explorer, "~> 0.8"}             # Dataframes

# Monitoring
{:telemetry_metrics_prometheus, "~> 1.1"}  # Prometheus exporter
{:sentry, "~> 10.0"}              # Error tracking
{:appsignal, "~> 2.8"}            # APM (alternative)

# Storage
{:ex_aws, "~> 2.5"}               # S3-compatible (MinIO)
{:ex_aws_s3, "~> 2.5"}
```

---

## ✅ CHECKLIST DE CONFORMITÉ 2025

### Référentiel ANS (Jalon 1-3)
- [ ] Identification utilisateurs (INS pour patients, RPPS pour pros)
- [ ] Authentification forte (Pro Santé Connect pour pros)
- [ ] Traçabilité des accès (logs immuables 3 ans)
- [ ] Chiffrement transport (TLS 1.3) + stockage (AES-256)
- [ ] Gestion consentements (RGPD Art. 6, 7, 9)
- [ ] Interopérabilité (FHIR R4, CDA R2)

### RGPD (CNIL Santé)
- [ ] Registre des traitements
- [ ] DPO désigné
- [ ] AIPD (Analyse Impact Vie Privée) réalisée
- [ ] Procédures droit d'accès/rectification/oubli
- [ ] Consentements explicites et révocables
- [ ] Limitation durées conservation (10 ans DME, 6 mois sessions)

### HDS (Hébergement Données de Santé)
- [ ] Prestataire certifié (OVH Healthcare, Scaleway Health, etc.)
- [ ] Audit annuel de conformité
- [ ] PRA/PCA testés (RPO <1h, RTO <4h)
- [ ] Sauvegarde chiffrée géo-redondante
- [ ] Procédures gestion incidents

### Télémédecine (Décret 2022-1101)
- [ ] Consentement libre et éclairé patient
- [ ] Identification formelle patient/médecin
- [ ] Compte-rendu systématique
- [ ] Conservation 10 ans (+ enregistrements si consentis)
- [ ] Facturation CCAM (TCY)

---

## 🎉 PROCHAINES ACTIONS IMMÉDIATES

### Semaine 1-2: Audit & Planning
```bash
# 1. Audit sécurité automatisé
mix deps.audit
mix sobelow --config

# 2. Analyse dette technique
mix credo --strict

# 3. Tests de charge
mix run priv/repo/seeds.exs # Générer 10k fake users
mix loadtest --target http://localhost:4000 --duration 60s

# 4. Documentation architecture
# → Créer diagrammes C4 (Context, Container, Component, Code)

# 5. Choix prestataire HDS
# → Demander devis OVH Healthcare vs Scaleway Health
```

### Semaine 3-4: Quick Wins Sécurité
```bash
# 1. Ajouter cloak_ecto
mix deps.get
# Modifier medical_record.ex pour champs chiffrés

# 2. Implémenter AuditLog
mix ecto.gen.migration create_audit_logs
# Coder module Telemed.AuditLog

# 3. Ajouter consentements
mix ecto.gen.migration create_consents
# UI formulaire consentements inscription

# 4. 2FA pour admins
mix deps.add nimble_totp
# Ajouter champ otp_secret dans users

# 5. Tests sécurité
mix test --only security
```

### Mois 2: POC Intégrations
```bash
# 1. Sandbox INS (téléservice de test)
# Tester appels SOAP vers https://ins-ref.oup.esante-si.infra-terr-2.asipsante.fr/

# 2. POC FHIR Converter
# Créer module Telemed.FHIR.Converter + tests

# 3. POC ML No-Shows
# Entraîner modèle sur données historiques

# 4. Setup monitoring Prometheus
# Ajouter telemetry_metrics_prometheus + dashboard Grafana
```

---

## 📞 CONTACTS & SUPPORT

### Organismes Officiels
- **ANS** (Agence du Numérique en Santé): https://esante.gouv.fr | support-ans@esante.gouv.fr
- **HAS** (Haute Autorité de Santé): https://www.has-sante.fr
- **CNIL**: https://www.cnil.fr | Tel: 01 53 73 22 22
- **CERT Santé**: cert@esante.gouv.fr

### Communautés
- **Interop'Santé**: https://www.interopsante.org/ (standards FHIR France)
- **Forum ANS**: https://industriels.esante.gouv.fr/forums
- **Elixir Forum**: https://elixirforum.com (section Healthcare)

---

## 🏁 CONCLUSION

Votre plateforme dispose **déjà de fondations solides** (authentification, DME SOAP, WebRTC). Pour atteindre la conformité 2025 et vous différencier :

### Priorités Absolues (6 mois)
1. **HDS** : Migrer vers hébergeur certifié
2. **INS** : Intégrer identité nationale santé
3. **Chiffrement E2E** : Protéger données au repos
4. **FHIR** : Préparer interopérabilité Mon espace santé

### Différenciateurs (12 mois)
5. **IA** : Prédiction no-shows, détection anomalies
6. **Télésurveillance** : Intégrer objets connectés
7. **UX** : Accessibilité WCAG 2.2, mode vocal

Avec cette roadmap, vous aurez une plateforme **certifiable, innovante et scalable** d'ici fin 2026. N'hésitez pas à prioriser les Quick Wins (§9) pour des résultats rapides !

**Besoin d'aide pour démarrer une phase spécifique ?** Je peux :
- Générer les migrations Elixir complètes
- Coder les modules critiques (AuditLog, FHIR Converter, etc.)
- Créer les tests automatisés
- Rédiger la documentation technique

**Quelle phase souhaitez-vous approfondir en premier ?** 🚀


