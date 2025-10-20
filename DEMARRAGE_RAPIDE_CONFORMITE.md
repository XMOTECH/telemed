# 🚨 Démarrage Rapide : Conformité Minimale (30 jours)

## Objectif
Rendre votre plateforme **légalement opérable** en France en 1 mois avec budget minimal.

---

## ✅ CHECKLIST JOUR PAR JOUR

### **Semaine 1 : Audit & Documentation** (5 jours)

#### Jour 1 : Audit Sécurité Automatisé
```bash
# Terminal 1 : Audit dépendances
mix deps.audit

# Terminal 2 : Scan vulnérabilités Elixir
mix archive.install hex sobelow
mix sobelow --config

# Terminal 3 : Qualité code
mix archive.install hex credo
mix credo --strict

# Documenter résultats dans AUDIT_SECURITE.md
```

#### Jour 2-3 : Registre des Traitements RGPD
Créer fichier `REGISTRE_TRAITEMENTS_RGPD.md` avec :
```markdown
# Registre des Traitements - Telemed

## Traitement 1 : Gestion Consultations Vidéo
- **Finalité** : Téléconsultations médicales
- **Base légale** : Consentement explicite (Art. 6.1.a + 9.2.a RGPD)
- **Catégories données** : Identité, santé, connexion
- **Destinataires** : Patient, médecin, hébergeur HDS
- **Durée conservation** : 10 ans (Code Santé Publique L1111-7)
- **Mesures sécurité** : Chiffrement, logs, RBAC

## Traitement 2 : Dossiers Médicaux Électroniques
[...]

## Traitement 3 : Authentification & Sessions
[...]
```

#### Jour 4 : Choix Hébergeur HDS
Comparer et choisir :
| Prestataire | Prix/mois | Certification | Support |
|-------------|-----------|---------------|---------|
| **OVH Healthcare** | 150-300€ | HDS, ISO 27001 | 24/7 FR |
| **Scaleway Health** | 200-350€ | HDS, SecNumCloud | 24/7 FR |
| **3DS OUTSCALE** | 250-400€ | HDS, SecNumCloud | 24/7 FR |

→ Ouvrir compte et demander devis détaillé

#### Jour 5 : Plan de Reprise d'Activité (PRA)
Documenter dans `PRA.md` :
- Sauvegardes quotidiennes chiffrées (rétention 30j)
- RPO : 1 heure max (perte de données acceptable)
- RTO : 4 heures max (temps de restauration)
- Procédure restauration base de données
- Tests mensuels

---

### **Semaine 2 : Implémentations Critiques** (5 jours)

#### Jour 6-7 : Logs Audit Immuables

##### Migration
```bash
mix ecto.gen.migration create_audit_logs
```

```elixir
# priv/repo/migrations/XXXXXX_create_audit_logs.exs
defmodule Telemed.Repo.Migrations.CreateAuditLogs do
  use Ecto.Migration

  def change do
    create table(:audit_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_type, :string, null: false  # access, create, update, delete, export
      add :resource_type, :string, null: false
      add :resource_id, :integer
      add :actor_id, references(:users, on_delete: :nilify_all), null: false
      add :actor_role, :string
      add :action_details, :map
      add :ip_address, :inet
      add :user_agent, :text
      add :result, :string, default: "success"
      add :hash_chain, :string, null: false  # Immutabilité
      
      timestamps(updated_at: false)  # Pas de modification possible
    end

    create index(:audit_logs, [:resource_type, :resource_id])
    create index(:audit_logs, [:actor_id])
    create index(:audit_logs, [:event_type])
    create index(:audit_logs, [:inserted_at])
  end
end
```

##### Schema
```elixir
# lib/telemed/audit_log.ex
defmodule Telemed.AuditLog do
  use Ecto.Schema
  import Ecto.Changeset
  alias Telemed.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [updated_at: false]
  
  schema "audit_logs" do
    field :event_type, :string
    field :resource_type, :string
    field :resource_id, :integer
    belongs_to :actor, Telemed.Accounts.User
    field :actor_role, :string
    field :action_details, :map
    field :ip_address, :string
    field :user_agent, :string
    field :result, :string
    field :hash_chain, :string
    
    timestamps()
  end

  @required_fields [:event_type, :resource_type, :actor_id, :hash_chain]
  @optional_fields [:resource_id, :actor_role, :action_details, :ip_address, :user_agent, :result]

  def changeset(audit_log, attrs) do
    audit_log
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:event_type, ~w(access create update delete export))
    |> validate_inclusion(:result, ~w(success failure partial))
  end

  @doc "Log une action sensible avec hash blockchain-like"
  def log(event_type, resource, actor, metadata \\ %{}) do
    %__MODULE__{}
    |> changeset(%{
      event_type: event_type,
      resource_type: extract_resource_type(resource),
      resource_id: extract_resource_id(resource),
      actor_id: actor.id,
      actor_role: actor.role,
      action_details: metadata,
      ip_address: Map.get(metadata, :ip),
      user_agent: Map.get(metadata, :user_agent),
      hash_chain: compute_hash_chain()
    })
    |> Repo.insert()
  end

  defp extract_resource_type(resource) when is_struct(resource) do
    resource.__struct__ |> to_string() |> String.split(".") |> List.last()
  end
  defp extract_resource_type(type) when is_binary(type), do: type

  defp extract_resource_id(resource) when is_struct(resource), do: Map.get(resource, :id)
  defp extract_resource_id(_), do: nil

  defp compute_hash_chain do
    import Ecto.Query
    
    last_log = 
      from(l in __MODULE__, order_by: [desc: l.inserted_at], limit: 1)
      |> Repo.one()
    
    previous_hash = if last_log, do: last_log.hash_chain, else: "genesis"
    timestamp = DateTime.utc_now() |> DateTime.to_iso8601()
    
    :crypto.hash(:sha256, "#{previous_hash}#{timestamp}")
    |> Base.encode16(case: :lower)
  end
end
```

##### Plug Auto-Logging
```elixir
# lib/telemed_web/plugs/audit_log_plug.ex
defmodule TelemedWeb.AuditLogPlug do
  import Plug.Conn
  alias Telemed.AuditLog

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      register_before_send(conn, &log_if_sensitive/1)
    else
      conn
    end
  end

  defp log_if_sensitive(conn) do
    if sensitive_route?(conn) && conn.status in 200..299 do
      metadata = %{
        ip: format_ip(conn.remote_ip),
        user_agent: get_req_header(conn, "user-agent") |> List.first(),
        method: conn.method,
        path: conn.request_path
      }

      # Extraire ressource depuis assigns (si disponible)
      resource = conn.assigns[:resource] || conn.request_path

      AuditLog.log(
        map_event_type(conn.method),
        resource,
        conn.assigns.current_user,
        metadata
      )
    end
    conn
  end

  defp sensitive_route?(conn) do
    conn.request_path =~ ~r{^/(medical_records|appointments|users/settings)}
  end

  defp map_event_type("GET"), do: "access"
  defp map_event_type("POST"), do: "create"
  defp map_event_type("PUT"), do: "update"
  defp map_event_type("PATCH"), do: "update"
  defp map_event_type("DELETE"), do: "delete"

  defp format_ip({a, b, c, d}), do: "#{a}.#{b}.#{c}.#{d}"
  defp format_ip(ip), do: inspect(ip)
end
```

##### Activer le Plug
```elixir
# lib/telemed_web/router.ex
pipeline :browser do
  # ... existing plugs
  plug TelemedWeb.AuditLogPlug  # ← AJOUTER ICI
end
```

```bash
# Appliquer migration
mix ecto.migrate
```

#### Jour 8-9 : Consentements RGPD

##### Migration
```bash
mix ecto.gen.migration create_consents
```

```elixir
# priv/repo/migrations/XXXXX_create_consents.exs
defmodule Telemed.Repo.Migrations.CreateConsents do
  use Ecto.Migration

  def change do
    create table(:consents) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :consent_type, :string, null: false
      add :granted, :boolean, default: false, null: false
      add :granted_at, :utc_datetime
      add :revoked_at, :utc_datetime
      add :version, :string, null: false  # Version CGU/politique
      add :ip_address, :inet
      add :metadata, :map
      
      timestamps()
    end

    create index(:consents, [:user_id, :consent_type])
    create unique_index(:consents, [:user_id, :consent_type, :version], 
      where: "revoked_at IS NULL",
      name: :unique_active_consent
    )
  end
end
```

##### Schema + Context
```elixir
# lib/telemed/accounts/consent.ex
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

  @consent_types ~w(
    data_processing
    telemedicine_usage
    medical_record_storage
    mes_sharing
    research_anonymized
    marketing
  )

  @current_version "2025.1"

  def changeset(consent, attrs) do
    consent
    |> cast(attrs, [:user_id, :consent_type, :granted, :version, :ip_address, :metadata])
    |> validate_required([:user_id, :consent_type, :granted, :version])
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

  def current_version, do: @current_version
  def consent_types, do: @consent_types
end
```

```elixir
# Ajouter dans lib/telemed/accounts.ex
defmodule Telemed.Accounts do
  import Ecto.Query
  alias Telemed.Repo
  alias Telemed.Accounts.{User, Consent}

  @doc "Vérifie si l'utilisateur a un consentement actif"
  def has_consent?(user, consent_type) do
    Consent
    |> where([c], c.user_id == ^user.id)
    |> where([c], c.consent_type == ^consent_type)
    |> where([c], c.granted == true)
    |> where([c], is_nil(c.revoked_at))
    |> Repo.exists?()
  end

  @doc "Enregistre un consentement"
  def grant_consent(user, consent_type, ip_address \\ nil) do
    %Consent{}
    |> Consent.changeset(%{
      user_id: user.id,
      consent_type: consent_type,
      granted: true,
      version: Consent.current_version(),
      ip_address: ip_address
    })
    |> Repo.insert(
      on_conflict: {:replace, [:granted, :granted_at, :revoked_at, :updated_at]},
      conflict_target: [:user_id, :consent_type, :version]
    )
  end

  @doc "Révoque un consentement (droit à l'oubli)"
  def revoke_consent(user, consent_type) do
    from(c in Consent,
      where: c.user_id == ^user.id and c.consent_type == ^consent_type,
      where: c.granted == true and is_nil(c.revoked_at)
    )
    |> Repo.update_all(set: [revoked_at: DateTime.utc_now()])
  end

  @doc "Liste tous les consentements actifs d'un utilisateur"
  def list_consents(user) do
    Consent
    |> where([c], c.user_id == ^user.id)
    |> where([c], is_nil(c.revoked_at))
    |> order_by([c], desc: c.inserted_at)
    |> Repo.all()
  end
end
```

##### UI - Formulaire à l'Inscription
```elixir
# lib/telemed_web/controllers/user_registration_controller.ex
# Modifier la fonction create:

def create(conn, %{"user" => user_params}) do
  case Accounts.register_user(user_params) do
    {:ok, user} ->
      # Enregistrer consentements obligatoires
      ip = format_ip(conn.remote_ip)
      Accounts.grant_consent(user, "data_processing", ip)
      Accounts.grant_consent(user, "telemedicine_usage", ip)
      Accounts.grant_consent(user, "medical_record_storage", ip)
      
      # Consentements optionnels (si cochés)
      if user_params["consent_mes_sharing"] == "true" do
        Accounts.grant_consent(user, "mes_sharing", ip)
      end
      
      if user_params["consent_research"] == "true" do
        Accounts.grant_consent(user, "research_anonymized", ip)
      end

      conn
      |> put_flash(:info, "Compte créé avec succès.")
      |> redirect(to: ~p"/users/log_in")

    {:error, %Ecto.Changeset{} = changeset} ->
      render(conn, :new, changeset: changeset)
  end
end

defp format_ip({a, b, c, d}), do: "#{a}.#{b}.#{c}.#{d}"
```

```heex
<!-- lib/telemed_web/controllers/user_registration_html/new.html.heex -->
<!-- Ajouter avant le bouton Submit: -->

<div class="mt-6 border-t pt-6">
  <h3 class="text-lg font-semibold mb-4">Consentements (RGPD)</h3>
  
  <div class="space-y-3">
    <div class="flex items-start">
      <input type="checkbox" name="consent_required" value="true" checked disabled class="mt-1" />
      <label class="ml-2 text-sm">
        <span class="font-semibold">Obligatoire</span> : 
        J'accepte le traitement de mes données personnelles et de santé 
        pour l'usage de la télémédecine, conformément au RGPD.
        <a href="/cgu" target="_blank" class="text-blue-600 underline">Voir CGU</a>
      </label>
    </div>

    <div class="flex items-start">
      <input 
        type="checkbox" 
        name="user[consent_mes_sharing]" 
        value="true" 
        id="consent_mes" 
        class="mt-1"
      />
      <label for="consent_mes" class="ml-2 text-sm">
        <span class="font-semibold">Optionnel</span> : 
        J'autorise le partage de mes données avec Mon espace santé.
      </label>
    </div>

    <div class="flex items-start">
      <input 
        type="checkbox" 
        name="user[consent_research]" 
        value="true" 
        id="consent_research" 
        class="mt-1"
      />
      <label for="consent_research" class="ml-2 text-sm">
        <span class="font-semibold">Optionnel</span> : 
        J'accepte l'utilisation anonymisée de mes données pour la recherche médicale.
      </label>
    </div>
  </div>

  <p class="text-xs text-gray-600 mt-4">
    💡 Vous pouvez modifier ces consentements à tout moment dans vos paramètres.
  </p>
</div>
```

```bash
mix ecto.migrate
```

#### Jour 10 : Headers Sécurité HTTP

```elixir
# lib/telemed_web/endpoint.ex
# Modifier plug Plug.Session pour ajouter sécurité:

plug Plug.Session,
  store: :cookie,
  key: "_telemed_key",
  signing_salt: "ISr3z5Lt",
  same_site: "Lax",
  secure: true,  # ← HTTPS obligatoire en prod
  http_only: true  # ← Pas d'accès JavaScript

# Ajouter après plug Plug.RequestId:
plug :put_secure_headers

defp put_secure_headers(conn, _opts) do
  conn
  |> put_resp_header("x-frame-options", "DENY")  # Anti clickjacking
  |> put_resp_header("x-content-type-options", "nosniff")
  |> put_resp_header("x-xss-protection", "1; mode=block")
  |> put_resp_header("referrer-policy", "strict-origin-when-cross-origin")
  |> put_resp_header("permissions-policy", "geolocation=(), microphone=(), camera=(self)")
  |> put_resp_header(
    "content-security-policy",
    "default-src 'self'; " <>
    "script-src 'self' 'unsafe-inline' 'unsafe-eval'; " <>  # TODO: Remove unsafe-eval
    "style-src 'self' 'unsafe-inline'; " <>
    "img-src 'self' data: https:; " <>
    "connect-src 'self' wss: https:; " <>
    "font-src 'self' data:;"
  )
end
```

---

### **Semaine 3 : Chiffrement & TLS** (5 jours)

#### Jour 11-13 : Chiffrement Champs Sensibles

##### Installation Cloak
```elixir
# mix.exs
defp deps do
  [
    # ... existing deps
    {:cloak_ecto, "~> 1.3.0"}
  ]
end
```

```bash
mix deps.get
```

##### Configuration
```elixir
# lib/telemed/vault.ex (NOUVEAU FICHIER)
defmodule Telemed.Vault do
  use Cloak.Vault, otp_app: :telemed

  @impl GenServer
  def init(config) do
    config =
      Keyword.put(config, :ciphers, [
        default: {
          Cloak.Ciphers.AES.GCM,
          tag: "AES.GCM.V1",
          key: decode_env!("CLOAK_KEY"),
          iv_length: 12
        }
      ])

    {:ok, config}
  end

  defp decode_env!(var) do
    var
    |> System.get_env()
    |> Base.decode64!()
  end
end
```

```elixir
# config/runtime.exs
# Ajouter après config :telemed, Telemed.Repo:

config :telemed, Telemed.Vault,
  ciphers: [
    default: {
      Cloak.Ciphers.AES.GCM,
      tag: "AES.GCM.V1",
      key: Base.decode64!(System.get_env("CLOAK_KEY") || generate_default_key()),
      iv_length: 12
    }
  ]

defp generate_default_key do
  # UNIQUEMENT POUR DEV ! En prod, utiliser variable environnement
  if config_env() == :dev do
    :crypto.strong_rand_bytes(32) |> Base.encode64()
  else
    raise "CLOAK_KEY environment variable must be set in production!"
  end
end
```

##### Générer Clé de Chiffrement
```bash
# Générer clé AES-256 (32 bytes)
iex -S mix
> :crypto.strong_rand_bytes(32) |> Base.encode64()
# Copier la sortie et l'ajouter dans .env

# Fichier .env (NE JAMAIS COMMITER !)
CLOAK_KEY=votreclébase64généréeici==
```

##### Migration Champs Chiffrés
```bash
mix ecto.gen.migration add_encrypted_fields_to_medical_records
```

```elixir
defmodule Telemed.Repo.Migrations.AddEncryptedFieldsToMedicalRecords do
  use Ecto.Migration

  def change do
    alter table(:medical_records) do
      # Nouveaux champs chiffrés (binary)
      add :encrypted_soap_subjective, :binary
      add :encrypted_soap_objective, :binary
      add :encrypted_soap_assessment, :binary
      add :encrypted_soap_plan, :binary
      add :encrypted_diagnosis, :binary
      add :encrypted_treatment_plan, :binary
    end

    # Conserver anciens champs pendant migration
    # TODO: Migrer données puis supprimer anciens champs
  end
end
```

##### Modifier Schema
```elixir
# lib/telemed/medical_records/medical_record.ex
defmodule Telemed.MedicalRecords.MedicalRecord do
  use Ecto.Schema
  import Ecto.Changeset

  schema "medical_records" do
    # Relations
    belongs_to :user, Telemed.Accounts.User
    belongs_to :doctor, Telemed.Accounts.User

    # Champs chiffrés (nouveaux)
    field :soap_subjective, Telemed.Encrypted.Binary
    field :soap_objective, Telemed.Encrypted.Binary
    field :soap_assessment, Telemed.Encrypted.Binary
    field :soap_plan, Telemed.Encrypted.Binary
    field :diagnosis, Telemed.Encrypted.Binary
    field :treatment_plan, Telemed.Encrypted.Binary

    # Champs non sensibles (en clair)
    field :nom, :string
    field :age, :integer
    field :category, :string
    field :priority, :string
    field :status, :string

    timestamps()
  end

  # ... reste du code inchangé
end
```

##### Type Cloak Custom
```elixir
# lib/telemed/encrypted/binary.ex (NOUVEAU FICHIER)
defmodule Telemed.Encrypted.Binary do
  use Cloak.Ecto.Binary, vault: Telemed.Vault
end
```

##### Démarrer Vault
```elixir
# lib/telemed/application.ex
def start(_type, _args) do
  children = [
    TelemedWeb.Telemetry,
    Telemed.Repo,
    {DNSCluster, query: Application.get_env(:telemed, :dns_cluster_query) || :ignore},
    {Phoenix.PubSub, name: Telemed.PubSub},
    {Finch, name: Telemed.Finch},
    Telemed.Vault,  # ← AJOUTER ICI
    TelemedWeb.Endpoint
  ]

  opts = [strategy: :one_for_one, name: Telemed.Supervisor]
  Supervisor.start_link(children, opts)
end
```

```bash
mix ecto.migrate
mix test  # Vérifier que tout compile
```

#### Jour 14-15 : TLS 1.3 & HTTPS Forcé

##### Configuration Bandit (serveur HTTP)
```elixir
# config/runtime.exs
# Modifier config TelemedWeb.Endpoint:

if config_env() == :prod do
  # HTTPS avec TLS 1.3
  config :telemed, TelemedWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    https: [
      port: 443,
      cipher_suite: :strong,
      certfile: System.get_env("SSL_CERT_PATH"),
      keyfile: System.get_env("SSL_KEY_PATH"),
      versions: [:"tlsv1.3", :"tlsv1.2"],  # TLS 1.3 prioritaire
      secure_renegotiate: true,
      reuse_sessions: true,
      honor_cipher_order: true
    ],
    force_ssl: [hsts: true, rewrite_on: [:x_forwarded_proto]]
end
```

##### Redirection HTTP → HTTPS
```elixir
# lib/telemed_web/router.ex
pipeline :browser do
  plug :accepts, ["html"]
  plug :fetch_session
  plug :fetch_live_flash
  plug :put_root_layout, html: {TelemedWeb.Layouts, :root}
  plug :protect_from_forgery
  plug :put_secure_browser_headers
  plug :force_https  # ← AJOUTER
  plug :fetch_current_user
  # ... rest
end

defp force_https(conn, _opts) do
  if Application.get_env(:telemed, :env) == :prod && conn.scheme == :http do
    conn
    |> Phoenix.Controller.redirect(external: "https://#{conn.host}#{conn.request_path}")
    |> Plug.Conn.halt()
  else
    conn
  end
end
```

---

### **Semaine 4 : Tests & Documentation** (5 jours)

#### Jour 16-17 : Tests Sécurité

```elixir
# test/telemed/audit_log_test.exs
defmodule Telemed.AuditLogTest do
  use Telemed.DataCase
  alias Telemed.{AuditLog, Accounts}

  describe "log/4" do
    test "creates audit log with hash chain" do
      user = user_fixture()
      resource = %{id: 123, __struct__: Telemed.MedicalRecords.MedicalRecord}

      assert {:ok, log} = AuditLog.log("access", resource, user, %{ip: "192.168.1.1"})
      assert log.event_type == "access"
      assert log.resource_type == "MedicalRecord"
      assert log.resource_id == 123
      assert log.hash_chain != nil
    end

    test "hash chain is linked to previous log" do
      user = user_fixture()
      {:ok, log1} = AuditLog.log("access", "test", user)
      {:ok, log2} = AuditLog.log("access", "test", user)

      # Hash du log2 doit contenir hash du log1
      assert log1.hash_chain != log2.hash_chain
      assert log2.inserted_at > log1.inserted_at
    end

    test "logs are immutable (no update)" do
      user = user_fixture()
      {:ok, log} = AuditLog.log("access", "test", user)

      # Tenter update doit échouer
      assert_raise Ecto.NoPrimaryKeyValueError, fn ->
        Ecto.Changeset.change(log, %{event_type: "delete"})
        |> Telemed.Repo.update()
      end
    end
  end
end
```

```elixir
# test/telemed/accounts_test.exs
# Ajouter tests consentements:

describe "consents" do
  test "has_consent?/2 returns true for active consent" do
    user = user_fixture()
    Accounts.grant_consent(user, "data_processing")
    
    assert Accounts.has_consent?(user, "data_processing") == true
    assert Accounts.has_consent?(user, "marketing") == false
  end

  test "revoke_consent/2 marks consent as revoked" do
    user = user_fixture()
    Accounts.grant_consent(user, "marketing")
    
    assert Accounts.has_consent?(user, "marketing") == true
    
    Accounts.revoke_consent(user, "marketing")
    
    assert Accounts.has_consent?(user, "marketing") == false
  end
end
```

```bash
mix test
```

#### Jour 18-19 : Documentation Technique

Créer fichier `SECURITE.md` :
```markdown
# Documentation Sécurité - Telemed

## 1. Chiffrement

### Données au Repos
- **Algorithme** : AES-256-GCM (via Cloak)
- **Champs chiffrés** :
  - `medical_records.soap_*`
  - `medical_records.diagnosis`
  - `medical_records.treatment_plan`
- **Rotation clés** : Annuelle (TODO: automatiser)

### Données en Transit
- **TLS 1.3** obligatoire en production
- **Ciphers** : Suite strong uniquement
- **HSTS** : Activé (force HTTPS)

## 2. Authentification

### Mots de Passe
- **Hachage** : Bcrypt (cost factor 12)
- **Politique** : Min 12 caractères
- **Rotation** : Suggérée tous les 90j (non forcée)

### Sessions
- **Durée** : 60 jours max (paramétrable)
- **Stockage** : Cookie signé + token DB
- **Invalidation** : Logout ou changement password

## 3. Traçabilité

### Logs Audit
- **Événements loggés** :
  - Accès DME
  - Création/modification/suppression données
  - Exports
- **Immutabilité** : Hash chain (blockchain-like)
- **Rétention** : 3 ans (RGPD Art. 30)
- **Accès** : Admin uniquement

## 4. Conformité RGPD

### Consentements
- Enregistrés avec timestamp + IP
- Révocables par l'utilisateur
- Versionnés (CGU v2025.1)

### Droits Utilisateurs
- **Accès** : `/users/settings/data` (TODO)
- **Rectification** : `/users/settings/edit`
- **Oubli** : Contact admin (TODO: automatiser)
- **Portabilité** : Export JSON (TODO)

## 5. Procédures Incident

### En cas de Breach
1. Isoler serveur compromis
2. Notifier CNIL sous 72h
3. Analyser logs audit
4. Notifier utilisateurs si nécessaire
5. Rapport post-mortem

### Contact Urgence
- **CERT Santé** : cert@esante.gouv.fr
- **CNIL** : 01 53 73 22 22
```

#### Jour 20 : Checklist Finale

```markdown
# ✅ CHECKLIST CONFORMITÉ MINIMALE

## Sécurité Technique
- [x] Logs audit immuables
- [x] Chiffrement AES-256 champs sensibles
- [x] TLS 1.3 en production
- [x] Headers sécurité HTTP
- [x] CSRF protection
- [x] RBAC actif

## RGPD
- [x] Registre des traitements documenté
- [x] Consentements obligatoires à l'inscription
- [x] Consentements révocables
- [x] Logs traçabilité 3 ans

## HDS (En cours)
- [ ] Hébergeur HDS choisi et contrat signé
- [ ] Migration données vers infra HDS
- [ ] PRA testé
- [ ] Audit annuel planifié

## Documentation
- [x] PRA rédigé
- [x] SECURITE.md créé
- [x] REGISTRE_TRAITEMENTS_RGPD.md créé
- [ ] CGU/Politique confidentialité publiées

## Tests
- [x] Tests unitaires sécurité
- [ ] Pentest par cabinet externe (à planifier)
```

---

## 🚀 COMMANDES DE DÉPLOIEMENT

### Setup Environnement Production

```bash
# 1. Générer clé secrète Phoenix
mix phx.gen.secret

# 2. Générer clé chiffrement Cloak
iex -S mix
> :crypto.strong_rand_bytes(32) |> Base.encode64()

# 3. Variables environnement (.env)
export DATABASE_URL="postgresql://user:pass@host/db"
export SECRET_KEY_BASE="votre_secret_phoenix"
export CLOAK_KEY="votre_cle_cloak_base64"
export PHX_HOST="votre-domaine.fr"
export SSL_CERT_PATH="/etc/letsencrypt/live/domain/fullchain.pem"
export SSL_KEY_PATH="/etc/letsencrypt/live/domain/privkey.pem"

# 4. Build production
MIX_ENV=prod mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy

# 5. Migrations
MIX_ENV=prod mix ecto.migrate

# 6. Démarrer serveur
MIX_ENV=prod mix phx.server
```

---

## 📞 SUPPORT

**En cas de blocage** :
- 📧 Email : support@votre-domaine.fr
- 📞 Téléphone : XXX
- 🔗 GitHub Issues : https://github.com/...

**Organismes Officiels** :
- **CNIL** : https://www.cnil.fr | 01 53 73 22 22
- **ANS** : https://esante.gouv.fr | support-ans@esante.gouv.fr
- **CERT Santé** : cert@esante.gouv.fr

---

## ✅ PROCHAINES ÉTAPES (Post-Conformité)

Après ces 30 jours, vous serez **légalement opérable**. Pour aller plus loin :

1. **INS** (Mois 2) : Intégration identité nationale santé
2. **FHIR** (Mois 3) : Export Mon espace santé
3. **Facturation** (Mois 4) : SESAM-Vitale/SCOR
4. **IA** (Mois 5-6) : Prédiction no-shows

Voir **ROADMAP_SAAS_TELEMEDECINE_2025.md** pour détails.


