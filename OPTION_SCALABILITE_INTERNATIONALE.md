# 🌍 Option C : Scalabilité Internationale (Vision Globale)

## Profil
✅ **Pour vous si** :
- Ambition expansion internationale (UE, Afrique, Canada)
- Budget conséquent (>200k€)
- Équipe tech expérimentée
- Horizon 12-18 mois

❌ **Pas pour vous si** :
- Budget limité (<50k€)
- Focus uniquement marché français

---

## 🎯 OBJECTIF : Plateforme Multi-Pays en 12 Mois

### Livrables Finaux
1. **Multi-tenancy** (1 instance → 1000 cliniques)
2. **Multi-langue** (FR, EN, ES, AR)
3. **Multi-réglementaire** (GDPR, HIPAA, POPIA)
4. **Multi-monnaie** (EUR, USD, XOF)
5. **CDN global** (<100ms partout)
6. **99.99% uptime** (HA multi-région)

---

## 📅 ROADMAP 12 MOIS

### **Phase 1 : Architecture Scalable (Mois 1-3)**

#### Mois 1 : Multi-Tenancy

##### Stratégie Choisie : Schema-Based (PostgreSQL)

```elixir
# Migration
defmodule Telemed.Repo.Migrations.CreateTenants do
  use Ecto.Migration

  def change do
    create table(:tenants) do
      add :slug, :string, null: false  # ex: "hopital-paris"
      add :name, :string, null: false
      add :country, :string, null: false
      add :subscription_plan, :string, default: "free"
      add :subscription_status, :string, default: "active"
      add :settings, :map, default: %{}
      add :db_schema, :string, null: false  # ex: "tenant_hopital_paris"
      
      timestamps()
    end

    create unique_index(:tenants, [:slug])
    create unique_index(:tenants, [:db_schema])
  end
end
```

```elixir
# lib/telemed/tenants/tenant.ex
defmodule Telemed.Tenants.Tenant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tenants" do
    field :slug, :string
    field :name, :string
    field :country, :string
    field :subscription_plan, :string
    field :subscription_status, :string
    field :settings, :map
    field :db_schema, :string

    timestamps()
  end

  @doc "Crée un nouveau tenant avec son schema PostgreSQL"
  def create_tenant(attrs) do
    changeset = 
      %__MODULE__{}
      |> cast(attrs, [:slug, :name, :country, :subscription_plan])
      |> validate_required([:slug, :name, :country])
      |> validate_format(:slug, ~r/^[a-z0-9\-]+$/)
      |> put_db_schema()
      |> unique_constraint(:slug)

    with {:ok, tenant} <- Telemed.Repo.insert(changeset),
         :ok <- create_postgres_schema(tenant.db_schema),
         :ok <- run_migrations_for_tenant(tenant.db_schema) do
      {:ok, tenant}
    end
  end

  defp put_db_schema(changeset) do
    if slug = get_change(changeset, :slug) do
      put_change(changeset, :db_schema, "tenant_#{slug}")
    else
      changeset
    end
  end

  defp create_postgres_schema(schema_name) do
    Telemed.Repo.query("CREATE SCHEMA IF NOT EXISTS #{schema_name}")
    |> case do
      {:ok, _} -> :ok
      error -> error
    end
  end

  defp run_migrations_for_tenant(schema_name) do
    # Exécuter migrations dans le schema du tenant
    path = Application.app_dir(:telemed, "priv/repo/tenant_migrations")
    
    Ecto.Migrator.run(
      Telemed.Repo,
      path,
      :up,
      all: true,
      prefix: schema_name
    )
    
    :ok
  end
end
```

##### Plug Tenant Resolution

```elixir
# lib/telemed_web/plugs/tenant_plug.ex
defmodule TelemedWeb.TenantPlug do
  import Plug.Conn
  alias Telemed.Tenants

  def init(opts), do: opts

  def call(conn, _opts) do
    tenant = resolve_tenant(conn)
    
    conn
    |> assign(:tenant, tenant)
    |> put_session(:tenant_id, tenant && tenant.id)
    |> Telemed.Repo.put_dynamic_repo_prefix(tenant && tenant.db_schema)
  end

  defp resolve_tenant(conn) do
    # Option 1: Sous-domaine (ex: hopital-paris.telemed.fr)
    host = conn.host
    
    if subdomain = extract_subdomain(host) do
      Tenants.get_by_slug(subdomain)
    else
      # Option 2: Header custom (mobile app)
      case get_req_header(conn, "x-tenant-slug") do
        [slug | _] -> Tenants.get_by_slug(slug)
        _ -> nil
      end
    end
  end

  defp extract_subdomain(host) do
    case String.split(host, ".") do
      [subdomain, "telemed", _tld] when subdomain != "www" -> subdomain
      _ -> nil
    end
  end
end
```

##### Router avec Tenant

```elixir
# lib/telemed_web/router.ex
pipeline :browser do
  # ... existing plugs
  plug TelemedWeb.TenantPlug  # ← AVANT fetch_current_user
  plug :fetch_current_user
end

# Routes admin pour gestion tenants
scope "/admin/tenants", TelemedWeb.Admin do
  pipe_through [:browser, :require_super_admin]
  
  resources "/", TenantController
end
```

---

#### Mois 2 : Internationalisation (i18n)

##### Configuration Gettext

```elixir
# config/config.exs
config :telemed, TelemedWeb.Gettext,
  default_locale: "fr",
  locales: ~w(fr en es ar)  # Français, Anglais, Espagnol, Arabe
```

##### Traductions

```po
# priv/gettext/fr/LC_MESSAGES/default.po
msgid "welcome"
msgstr "Bienvenue"

msgid "book_appointment"
msgstr "Prendre rendez-vous"

msgid "medical_record"
msgstr "Dossier médical"
```

```po
# priv/gettext/en/LC_MESSAGES/default.po
msgid "welcome"
msgstr "Welcome"

msgid "book_appointment"
msgstr "Book Appointment"

msgid "medical_record"
msgstr "Medical Record"
```

```po
# priv/gettext/ar/LC_MESSAGES/default.po (RTL)
msgid "welcome"
msgstr "مرحبا"

msgid "book_appointment"
msgstr "حجز موعد"

msgid "medical_record"
msgstr "السجل الطبي"
```

##### Plug Locale

```elixir
# lib/telemed_web/plugs/locale_plug.ex
defmodule TelemedWeb.LocalePlug do
  import Plug.Conn

  @supported_locales ["fr", "en", "es", "ar"]

  def init(opts), do: opts

  def call(conn, _opts) do
    locale = determine_locale(conn)
    Gettext.put_locale(TelemedWeb.Gettext, locale)
    
    conn
    |> assign(:locale, locale)
    |> assign(:text_direction, if(locale == "ar", do: "rtl", else: "ltr"))
  end

  defp determine_locale(conn) do
    # Priorité:
    # 1. Paramètre URL (?locale=en)
    # 2. Session utilisateur
    # 3. Header Accept-Language
    # 4. Tenant country
    # 5. Défaut (fr)
    
    conn.params["locale"] ||
      get_session(conn, :locale) ||
      extract_from_accept_language(conn) ||
      tenant_default_locale(conn.assigns[:tenant]) ||
      "fr"
  end

  defp extract_from_accept_language(conn) do
    case get_req_header(conn, "accept-language") do
      [value | _] ->
        value
        |> String.split(",")
        |> List.first()
        |> String.split("-")
        |> List.first()
        |> String.downcase()
        |> then(&if &1 in @supported_locales, do: &1)
      _ -> nil
    end
  end

  defp tenant_default_locale(%{country: "FR"}), do: "fr"
  defp tenant_default_locale(%{country: "US"}), do: "en"
  defp tenant_default_locale(%{country: "MA"}), do: "ar"
  defp tenant_default_locale(_), do: nil
end
```

##### Composants i18n

```elixir
# lib/telemed_web/components/i18n_components.ex
defmodule TelemedWeb.I18nComponents do
  use Phoenix.Component
  import TelemedWeb.Gettext

  def language_switcher(assigns) do
    ~H"""
    <div class="language-switcher">
      <button 
        :for={locale <- ~w(fr en es ar)}
        phx-click="switch_locale"
        phx-value-locale={locale}
        class={"px-2 py-1 #{if @locale == locale, do: "font-bold"}"}>
        <%= locale_flag(locale) %> <%= locale_name(locale) %>
      </button>
    </div>
    """
  end

  defp locale_flag("fr"), do: "🇫🇷"
  defp locale_flag("en"), do: "🇬🇧"
  defp locale_flag("es"), do: "🇪🇸"
  defp locale_flag("ar"), do: "🇸🇦"

  defp locale_name("fr"), do: "Français"
  defp locale_name("en"), do: "English"
  defp locale_name("es"), do: "Español"
  defp locale_name("ar"), do: "العربية"
end
```

##### CSS RTL (pour Arabe)

```css
/* assets/css/rtl.css */
[dir="rtl"] {
  direction: rtl;
  text-align: right;
}

[dir="rtl"] .ml-4 {
  margin-left: 0;
  margin-right: 1rem;
}

[dir="rtl"] .text-left {
  text-align: right;
}
```

---

#### Mois 3 : Multi-Réglementaire

##### Adapter Modules par Pays

```elixir
# lib/telemed/compliance/adapter.ex
defmodule Telemed.Compliance.Adapter do
  @moduledoc """
  Adapte règles de conformité selon pays du tenant
  """

  def required_fields_for_patient(tenant) do
    case tenant.country do
      "FR" ->
        [:nom, :prenom, :date_naissance, :nir, :ins]  # France: INS obligatoire
        
      "US" ->
        [:first_name, :last_name, :date_of_birth, :ssn, :insurance_provider]  # USA: Assurance
        
      "ZA" ->  # Afrique du Sud
        [:name, :surname, :id_number, :medical_aid]
        
      _ ->
        [:nom, :date_naissance]  # Minimum
    end
  end

  def consent_types(tenant) do
    base = ["data_processing", "telemedicine_usage"]
    
    case tenant.country do
      "FR" -> base ++ ["mes_sharing"]  # Mon espace santé
      "US" -> base ++ ["hipaa_authorization"]
      _ -> base
    end
  end

  def data_retention_period(tenant) do
    case tenant.country do
      "FR" -> {10, :years}  # Code Santé Publique L1111-7
      "US" -> {6, :years}  # HIPAA
      "ZA" -> {6, :years}  # POPIA
      _ -> {5, :years}
    end
  end

  def requires_encryption_at_rest?(tenant) do
    tenant.country in ["FR", "US", "DE", "ZA"]  # Tous pays sensibles
  end
end
```

##### Facturation Multi-Monnaie

```elixir
# lib/telemed/billing/currency.ex
defmodule Telemed.Billing.Currency do
  @exchange_rates %{
    "EUR" => 1.0,
    "USD" => 1.08,
    "GBP" => 0.87,
    "XOF" => 655.96  # Franc CFA
  }

  def convert(amount, from_currency, to_currency) do
    # TODO: Intégrer API taux de change en temps réel (ex: exchangerate-api.com)
    rate_from = Map.get(@exchange_rates, from_currency, 1.0)
    rate_to = Map.get(@exchange_rates, to_currency, 1.0)
    
    Decimal.mult(amount, Decimal.div(rate_to, rate_from))
  end

  def tenant_currency(tenant) do
    case tenant.country do
      "FR" -> "EUR"
      "US" -> "USD"
      "GB" -> "GBP"
      country when country in ~w(SN CI BJ) -> "XOF"  # Zone CFA
      _ -> "EUR"
    end
  end

  def format_price(amount, currency) do
    case currency do
      "EUR" -> "#{amount} €"
      "USD" -> "$#{amount}"
      "GBP" -> "£#{amount}"
      "XOF" -> "#{amount} FCFA"
      _ -> "#{amount} #{currency}"
    end
  end
end
```

---

### **Phase 2 : Infrastructure Globale (Mois 4-6)**

#### Mois 4 : CDN & Edge Computing

##### Déploiement Multi-Région (Fly.io)

```toml
# fly.toml
app = "telemed"
primary_region = "cdg"  # Paris

[build]
  [build.args]
    MIX_ENV = "prod"

[[services]]
  http_checks = []
  internal_port = 8080
  processes = ["app"]
  protocol = "tcp"
  
  [[services.ports]]
    force_https = true
    handlers = ["http"]
    port = 80

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443

# Régions multiples
[regions]
  cdg = true   # Europe (Paris)
  iad = true   # US East (Virginia)
  syd = true   # Australie (Sydney)
  jnb = true   # Afrique du Sud (Johannesburg)
```

```bash
# Déployer sur toutes les régions
fly scale count 2 --region cdg
fly scale count 2 --region iad
fly scale count 1 --region syd
fly scale count 1 --region jnb
```

##### CDN CloudFlare

```elixir
# config/prod.exs
config :telemed, TelemedWeb.Endpoint,
  url: [host: "telemed.fr", port: 443, scheme: "https"],
  cache_static_manifest: "priv/static/cache_manifest.json",
  http: [
    ip: {0, 0, 0, 0, 0, 0, 0, 0},
    port: String.to_integer(System.get_env("PORT") || "8080")
  ],
  static_url: [
    scheme: "https",
    host: "cdn.telemed.fr",  # ← CloudFlare CDN
    port: 443
  ]
```

##### Cache Edge (LiveView + ETag)

```elixir
# lib/telemed_web/controllers/page_controller.ex
defmodule TelemedWeb.PageController do
  use TelemedWeb, :controller
  
  plug :set_cache_headers when action in [:terms, :privacy]

  defp set_cache_headers(conn, _opts) do
    conn
    |> put_resp_header("cache-control", "public, max-age=86400")  # 24h
    |> put_resp_header("vary", "Accept-Language")
  end
end
```

---

#### Mois 5 : Base de Données Distribuée

##### Read Replicas PostgreSQL

```elixir
# config/prod.exs
config :telemed, Telemed.Repo,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  queue_target: 5000,
  queue_interval: 1000

# Replica lecture (ex: AWS RDS Read Replica)
config :telemed, Telemed.Repo.Replica,
  url: System.get_env("REPLICA_DATABASE_URL"),
  pool_size: 20,
  queue_target: 5000
```

```elixir
# lib/telemed/repo.ex
defmodule Telemed.Repo do
  use Ecto.Repo,
    otp_app: :telemed,
    adapter: Ecto.Adapters.Postgres
  
  @doc "Utilise replica pour lectures"
  def replica, do: Telemed.Repo.Replica
end

# Usage
Telemed.Appointments
|> Telemed.Repo.replica().all()  # ← Lecture depuis replica
```

##### Sharding Géographique (Optionnel)

```elixir
# lib/telemed/repo_router.ex
defmodule Telemed.RepoRouter do
  @moduledoc """
  Route requêtes vers DB régionale selon tenant
  """

  def repo_for_tenant(%{country: country}) do
    case country do
      c when c in ~w(FR DE ES IT) -> Telemed.Repo.EU
      c when c in ~w(US CA) -> Telemed.Repo.US
      c when c in ~w(ZA) -> Telemed.Repo.Africa
      _ -> Telemed.Repo
    end
  end
end
```

---

#### Mois 6 : Monitoring Global

##### Prometheus Multi-Région

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  external_labels:
    monitor: 'telemed-global'

scrape_configs:
  - job_name: 'telemed-eu'
    static_configs:
      - targets: ['telemed-cdg.fly.dev:9090']
        labels:
          region: 'europe'
  
  - job_name: 'telemed-us'
    static_configs:
      - targets: ['telemed-iad.fly.dev:9090']
        labels:
          region: 'us'
```

##### Grafana Dashboard

```json
{
  "dashboard": {
    "title": "Telemed - Global Performance",
    "panels": [
      {
        "title": "Latency by Region",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_milliseconds_bucket[5m])) by (region)"
          }
        ]
      },
      {
        "title": "Active Tenants by Country",
        "targets": [
          {
            "expr": "count(tenant_active_sessions) by (country)"
          }
        ]
      }
    ]
  }
}
```

---

### **Phase 3 : Marketplace & Écosystème (Mois 7-9)**

#### API REST Publique v1

```elixir
# lib/telemed_api/router.ex
defmodule TelemedAPI.Router do
  use Plug.Router
  
  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  plug TelemedAPI.AuthPlug  # OAuth2
  plug :dispatch

  # Patients
  get "/v1/patients" do
    # Liste patients du tenant
    conn
    |> json_response(200, %{data: []})
  end

  post "/v1/patients" do
    # Créer patient
    conn
    |> json_response(201, %{data: %{}})
  end

  # Appointments
  get "/v1/appointments" do
    conn
    |> json_response(200, %{data: []})
  end

  post "/v1/appointments" do
    conn
    |> json_response(201, %{data: %{}})
  end

  # Observations (pour objets connectés)
  post "/v1/observations" do
    # Recevoir données IoT (glucomètre, tensiomètre)
    conn
    |> json_response(201, %{data: %{}})
  end

  match _ do
    conn
    |> json_response(404, %{error: "Not Found"})
  end

  defp json_response(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end
end
```

#### OAuth2 Provider (Boruta)

```elixir
# mix.exs
{:boruta, "~> 2.3"}
```

```elixir
# Configuration OAuth2
# lib/telemed/oauth.ex
defmodule Telemed.OAuth do
  use Boruta.Oauth.Application

  def resource_owner(%{username: username, password: password}) do
    # Authentifier app tierce
    with {:ok, user} <- Telemed.Accounts.authenticate_api(username, password) do
      {:ok, %{sub: user.id, scope: user.api_scopes}}
    end
  end
end
```

---

#### Marketplace Apps

```elixir
# Migration
defmodule Telemed.Repo.Migrations.CreateApps do
  use Ecto.Migration

  def change do
    create table(:marketplace_apps) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text
      add :developer, :string
      add :icon_url, :string
      add :category, :string  # iot, analytics, communication
      add :pricing, :string   # free, freemium, paid
      add :oauth_client_id, :string
      add :oauth_client_secret, :string
      add :webhook_url, :string
      add :approved, :boolean, default: false
      
      timestamps()
    end

    create unique_index(:marketplace_apps, [:slug])

    # Relations tenant <-> apps
    create table(:tenant_apps) do
      add :tenant_id, references(:tenants, on_delete: :delete_all)
      add :app_id, references(:marketplace_apps, on_delete: :delete_all)
      add :enabled, :boolean, default: true
      add :settings, :map
      
      timestamps()
    end

    create unique_index(:tenant_apps, [:tenant_id, :app_id])
  end
end
```

---

### **Phase 4 : AI & Advanced Features (Mois 10-12)**

#### Diagnostic Assistance (GPT-4 Medical)

```elixir
# lib/telemed/ai/diagnostic_assistant.ex
defmodule Telemed.AI.DiagnosticAssistant do
  @moduledoc """
  Assistance diagnostique via LLM médical
  (ATTENTION: Ne remplace PAS le médecin, seulement aide)
  """

  @api_key System.get_env("OPENAI_API_KEY")

  def suggest_differential_diagnosis(symptoms, patient_history) do
    prompt = """
    Patient présente:
    - Symptômes: #{symptoms}
    - Antécédents: #{patient_history}
    
    En tant qu'assistant médical, suggère 3-5 diagnostics différentiels possibles,
    classés par probabilité. Pour chaque diagnostic, indique examens complémentaires pertinents.
    
    Format JSON:
    {
      "diagnoses": [
        {"name": "...", "probability": 0.7, "exams": ["..."]}
      ]
    }
    """
    
    case call_openai(prompt) do
      {:ok, response} -> Jason.decode(response)
      error -> error
    end
  end

  defp call_openai(prompt) do
    # TODO: Implémenter client OpenAI
    {:error, :not_implemented}
  end
end
```

---

## 💰 BUDGET TOTAL (12 MOIS)

| Poste | Coût Mensuel | Total 12 mois |
|-------|--------------|---------------|
| **Dev Team** (3 devs + 1 PO) | 35k€ | 420k€ |
| **Infra Cloud** (multi-région) | 2-5k€ | 36k€ |
| **CDN CloudFlare** (Business) | 200€ | 2.4k€ |
| **Monitoring** (Datadog/New Relic) | 300€ | 3.6k€ |
| **APIs Externes** (OpenAI, météo, etc.) | 500€ | 6k€ |
| **Certifications** (ISO 27001, HDS) | - | 50k€ |
| **Marketing** (multilingue) | 2k€ | 24k€ |
| **TOTAL** | **40k€** | **542k€** |

---

## 🎯 RÉSULTAT (Mois 12)

### Métriques Cibles
- **Tenants actifs** : 100+ (cliniques, hôpitaux)
- **Utilisateurs** : 50k+ (patients + médecins)
- **Pays couverts** : 10+
- **Uptime** : 99.95%
- **Latence p95** : <200ms globalement

### Positionnement Marché
- "Seule plateforme télémédecine **globale** et **multi-réglementaire**"
- Levée de fonds facilitée (Series A)
- Partenariats ONG (Médecins Sans Frontières, Croix-Rouge)

---

## 🚀 NEXT STEPS

1. **Semaine 1** : Valider architecture multi-tenancy (POC)
2. **Semaine 2** : Setup CI/CD multi-région
3. **Semaine 3** : Premières traductions (FR/EN)
4. **Semaine 4** : Tests de charge (10k users simultanés)

**Prêt pour la conquête mondiale ?** 🌍🚀


