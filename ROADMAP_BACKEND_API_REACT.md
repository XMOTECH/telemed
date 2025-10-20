# 🚀 Roadmap Backend-First + React Frontend

**Date** : 18 octobre 2025  
**Architecture** : Phoenix API (Backend) + React TypeScript (Frontend)  
**Objectif** : Plateforme SaaS télémédecine découplée, scalable, mobile-ready

---

## 🎯 POURQUOI CETTE ARCHITECTURE ?

### Avantages Architecture Découplée

✅ **Mobile Apps** : React Native (iOS/Android) avec 70% code partagé  
✅ **Scalabilité** : Frontend/Backend indépendants  
✅ **Équipes** : Dev backend (Elixir) ≠ Dev frontend (React)  
✅ **Écosystème** : Accès meilleur de React (WebRTC, charts, FHIR)  
✅ **Performance** : CDN pour frontend statique  
✅ **Flexibilité** : Changer frontend sans toucher backend

### Stack Technique Finale

```
┌─────────────────────────────────────────────────┐
│           CLIENTS (Multi-plateforme)            │
├─────────────────────────────────────────────────┤
│  React Web (SPA)  │  React Native  │  API Tiers │
│  TypeScript       │  iOS + Android │  (Objets   │
│  Vite + TailwindCSS│                │  connectés)│
└──────────┬──────────────────┬───────────────────┘
           │                  │
           ▼                  ▼
┌─────────────────────────────────────────────────┐
│              API GATEWAY (NGINX)                │
│         - Load Balancing                        │
│         - Rate Limiting                         │
│         - SSL Termination                       │
└──────────┬──────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────┐
│         BACKEND : Phoenix API (Elixir)          │
├─────────────────────────────────────────────────┤
│  REST API          │  GraphQL      │  WebSockets│
│  /api/v1/*         │  /graphql     │  /socket   │
│                    │               │            │
│  Guardian JWT      │  Absinthe     │  Channels  │
│  (Auth)            │               │  (Real-time)│
├─────────────────────────────────────────────────┤
│              Business Logic (Contexts)          │
│  Accounts │ MedicalRecords │ Appointments │ etc.│
├─────────────────────────────────────────────────┤
│             PostgreSQL (HDS certifié)           │
│  - Multi-tenant (schemas)                       │
│  - Chiffrement Cloak                            │
│  - Audit logs immuables                         │
└─────────────────────────────────────────────────┘
```

---

## 📅 PLAN DE DÉVELOPPEMENT (12 Semaines)

### **PHASE 1 : Backend API (Semaines 1-6)**

#### **Semaine 1-2 : Setup API Phoenix + Authentification JWT**

##### 1.1 Transformer Phoenix en API Mode

```elixir
# mix.exs - Supprimer dépendances UI
defp deps do
  [
    {:phoenix, "~> 1.7.21"},
    {:phoenix_ecto, "~> 4.5"},
    {:ecto_sql, "~> 3.10"},
    {:postgrex, ">= 0.0.0"},
    {:jason, "~> 1.2"},
    {:bandit, "~> 1.5"},
    
    # API & Auth
    {:guardian, "~> 2.3"},         # JWT
    {:cors_plug, "~> 3.0"},        # CORS
    {:absinthe, "~> 1.7"},         # GraphQL (optionnel)
    {:absinthe_plug, "~> 1.5"},
    
    # Existing
    {:pbkdf2_elixir, "~> 2.0"},
    {:cloak_ecto, "~> 1.3"},
    {:swoosh, "~> 1.5"},
    {:finch, "~> 0.13"}
  ]
end
```

##### 1.2 Configuration Guardian JWT

```elixir
# config/config.exs
config :telemed, Telemed.Guardian,
  issuer: "telemed",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY") || "dev_secret_must_be_at_least_32_characters",
  ttl: {30, :days},  # Token valide 30 jours
  token_ttl: %{
    "access" => {1, :hour},
    "refresh" => {30, :days}
  }
```

```elixir
# lib/telemed/guardian.ex (NOUVEAU FICHIER)
defmodule Telemed.Guardian do
  use Guardian, otp_app: :telemed

  alias Telemed.Accounts

  @doc "Encode user dans JWT"
  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  @doc "Decode user depuis JWT"
  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user(id) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end
end
```

##### 1.3 API Routes

```elixir
# lib/telemed_web/router.ex
defmodule TelemedWeb.Router do
  use TelemedWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug, origin: ["http://localhost:3000", "https://app.telemed.fr"]
  end

  pipeline :api_auth do
    plug :accepts, ["json"]
    plug Telemed.Guardian.AuthPipeline
  end

  # Routes publiques
  scope "/api/v1", TelemedWeb.API.V1 do
    pipe_through :api

    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login
    post "/auth/refresh", AuthController, :refresh_token
    post "/auth/forgot_password", AuthController, :forgot_password
  end

  # Routes authentifiées
  scope "/api/v1", TelemedWeb.API.V1 do
    pipe_through :api_auth

    # Users
    get "/me", UserController, :show_current
    put "/me", UserController, :update_current
    delete "/me", UserController, :delete_current

    # Medical Records
    resources "/medical_records", MedicalRecordController, except: [:new, :edit]
    get "/patients/:patient_id/medical_records", MedicalRecordController, :list_by_patient

    # Appointments
    resources "/appointments", AppointmentController, except: [:new, :edit]
    post "/appointments/:id/confirm", AppointmentController, :confirm
    post "/appointments/:id/cancel", AppointmentController, :cancel
    post "/appointments/:id/complete", AppointmentController, :complete

    # Notifications
    resources "/notifications", NotificationController, only: [:index, :show]
    put "/notifications/:id/read", NotificationController, :mark_as_read
    put "/notifications/read_all", NotificationController, :mark_all_as_read

    # Consents (RGPD)
    get "/consents", ConsentController, :index
    post "/consents/:type", ConsentController, :grant
    delete "/consents/:type", ConsentController, :revoke

    # FHIR Export
    get "/fhir/patient", FHIRController, :patient_summary
    post "/fhir/export_mes", FHIRController, :export_to_mes
  end

  # GraphQL (optionnel)
  scope "/api" do
    pipe_through :api_auth

    forward "/graphql", Absinthe.Plug, schema: TelemedWeb.Schema
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: TelemedWeb.Schema
  end

  # WebSocket pour WebRTC signaling
  scope "/", TelemedWeb do
    get "/health", HealthController, :check
  end
end
```

##### 1.4 Auth Pipeline Guardian

```elixir
# lib/telemed/guardian/auth_pipeline.ex (NOUVEAU)
defmodule Telemed.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :telemed,
    module: Telemed.Guardian,
    error_handler: Telemed.Guardian.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
  plug :assign_current_user

  defp assign_current_user(conn, _opts) do
    current_user = Guardian.Plug.current_resource(conn)
    Plug.Conn.assign(conn, :current_user, current_user)
  end
end
```

```elixir
# lib/telemed/guardian/auth_error_handler.ex (NOUVEAU)
defmodule Telemed.Guardian.AuthErrorHandler do
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    body = Jason.encode!(%{error: to_string(type)})
    
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
  end
end
```

##### 1.5 Auth Controller

```elixir
# lib/telemed_web/controllers/api/v1/auth_controller.ex (NOUVEAU)
defmodule TelemedWeb.API.V1.AuthController do
  use TelemedWeb, :controller
  
  alias Telemed.{Accounts, Guardian}
  alias Telemed.Accounts.User

  action_fallback TelemedWeb.FallbackController

  @doc "Inscription utilisateur"
  def register(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.register_user(user_params),
         {:ok, access_token, _claims} <- Guardian.encode_and_sign(user, %{}, token_type: "access"),
         {:ok, refresh_token, _claims} <- Guardian.encode_and_sign(user, %{}, token_type: "refresh") do
      
      # Enregistrer consentements obligatoires
      Accounts.grant_consent(user, "data_processing")
      Accounts.grant_consent(user, "telemedicine_usage")
      
      conn
      |> put_status(:created)
      |> render(:auth, %{
        user: user,
        access_token: access_token,
        refresh_token: refresh_token
      })
    end
  end

  @doc "Connexion"
  def login(conn, %{"email" => email, "password" => password}) do
    with {:ok, user} <- Accounts.authenticate_user(email, password),
         {:ok, access_token, _claims} <- Guardian.encode_and_sign(user, %{}, token_type: "access"),
         {:ok, refresh_token, _claims} <- Guardian.encode_and_sign(user, %{}, token_type: "refresh") do
      
      # Log audit
      Telemed.AuditLog.log("login", user, user, %{
        ip: get_ip(conn),
        user_agent: get_req_header(conn, "user-agent") |> List.first()
      })
      
      render(conn, :auth, %{
        user: user,
        access_token: access_token,
        refresh_token: refresh_token
      })
    else
      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> render(:error, %{error: "Email ou mot de passe invalide"})
    end
  end

  @doc "Refresh token"
  def refresh_token(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, _old, {new_access, _claims}} <- Guardian.exchange(refresh_token, "refresh", "access"),
         {:ok, user} <- Guardian.resource_from_token(new_access) do
      
      render(conn, :token, %{access_token: new_access, user: user})
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> render(:error, %{error: "Refresh token invalide"})
    end
  end

  @doc "Reset password"
  def forgot_password(conn, %{"email" => email}) do
    case Accounts.get_user_by_email(email) do
      nil ->
        # Ne pas révéler si email existe (sécurité)
        conn
        |> put_status(:ok)
        |> render(:message, %{message: "Si cet email existe, un lien a été envoyé"})
        
      user ->
        {:ok, token} = Accounts.generate_reset_password_token(user)
        # TODO: Envoyer email avec token
        
        conn
        |> put_status(:ok)
        |> render(:message, %{message: "Email envoyé"})
    end
  end

  defp get_ip(conn) do
    conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
  end
end
```

##### 1.6 JSON Views

```elixir
# lib/telemed_web/controllers/api/v1/auth_json.ex (NOUVEAU)
defmodule TelemedWeb.API.V1.AuthJSON do
  alias Telemed.Accounts.User

  def auth(%{user: user, access_token: access_token, refresh_token: refresh_token}) do
    %{
      data: %{
        user: user_data(user),
        tokens: %{
          access_token: access_token,
          refresh_token: refresh_token,
          token_type: "Bearer",
          expires_in: 3600  # 1 heure
        }
      }
    }
  end

  def token(%{access_token: access_token, user: user}) do
    %{
      data: %{
        access_token: access_token,
        user: user_data(user)
      }
    }
  end

  def error(%{error: message}) do
    %{error: %{message: message}}
  end

  def message(%{message: message}) do
    %{data: %{message: message}}
  end

  defp user_data(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      role: user.role,
      confirmed_at: user.confirmed_at,
      inserted_at: user.inserted_at
    }
  end
end
```

---

#### **Semaine 3-4 : API REST Complète (CRUD)**

##### Medical Records Controller

```elixir
# lib/telemed_web/controllers/api/v1/medical_record_controller.ex
defmodule TelemedWeb.API.V1.MedicalRecordController do
  use TelemedWeb, :controller
  
  alias Telemed.MedicalRecords
  alias Telemed.MedicalRecords.MedicalRecord

  action_fallback TelemedWeb.FallbackController

  @doc "Liste DME selon rôle"
  def index(conn, params) do
    user = conn.assigns.current_user
    
    records = case user.role do
      :patient -> MedicalRecords.list_patient_records(user.id)
      :doctor -> MedicalRecords.list_doctor_records(user.id, params)
      :admin -> MedicalRecords.list_all_records(params)
    end
    
    # Log accès
    Telemed.AuditLog.log("access", "medical_records_list", user, %{
      count: length(records)
    })
    
    render(conn, :index, records: records)
  end

  @doc "Créer DME"
  def create(conn, %{"medical_record" => record_params}) do
    user = conn.assigns.current_user
    
    # Vérifier autorisation (seulement médecin)
    if user.role != :doctor do
      conn
      |> put_status(:forbidden)
      |> render(:error, %{error: "Seuls les médecins peuvent créer des DME"})
    else
      record_params = Map.put(record_params, "doctor_id", user.id)
      
      with {:ok, %MedicalRecord{} = record} <- MedicalRecords.create_record(record_params) do
        Telemed.AuditLog.log("create", record, user)
        
        conn
        |> put_status(:created)
        |> render(:show, record: record)
      end
    end
  end

  @doc "Afficher DME"
  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    
    with {:ok, record} <- MedicalRecords.get_record(id, user) do
      Telemed.AuditLog.log("access", record, user)
      render(conn, :show, record: record)
    end
  end

  @doc "Modifier DME"
  def update(conn, %{"id" => id, "medical_record" => record_params}) do
    user = conn.assigns.current_user
    
    with {:ok, record} <- MedicalRecords.get_record(id, user),
         {:ok, %MedicalRecord{} = updated_record} <- MedicalRecords.update_record(record, record_params, user) do
      
      Telemed.AuditLog.log("update", updated_record, user)
      render(conn, :show, record: updated_record)
    end
  end

  @doc "Supprimer DME (soft delete)"
  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    
    with {:ok, record} <- MedicalRecords.get_record(id, user),
         {:ok, %MedicalRecord{}} <- MedicalRecords.delete_record(record, user) do
      
      Telemed.AuditLog.log("delete", record, user)
      send_resp(conn, :no_content, "")
    end
  end

  @doc "Liste DME d'un patient (pour médecin)"
  def list_by_patient(conn, %{"patient_id" => patient_id}) do
    user = conn.assigns.current_user
    
    # Vérifier autorisation
    if user.role not in [:doctor, :admin] do
      conn
      |> put_status(:forbidden)
      |> render(:error, %{error: "Accès interdit"})
    else
      records = MedicalRecords.list_patient_records(patient_id)
      
      Telemed.AuditLog.log("access", "patient_records", user, %{
        patient_id: patient_id,
        count: length(records)
      })
      
      render(conn, :index, records: records)
    end
  end
end
```

##### JSON Views

```elixir
# lib/telemed_web/controllers/api/v1/medical_record_json.ex
defmodule TelemedWeb.API.V1.MedicalRecordJSON do
  alias Telemed.MedicalRecords.MedicalRecord

  def index(%{records: records}) do
    %{data: Enum.map(records, &record_data/1)}
  end

  def show(%{record: record}) do
    %{data: record_data(record)}
  end

  def error(%{error: message}) do
    %{error: %{message: message}}
  end

  defp record_data(%MedicalRecord{} = record) do
    %{
      id: record.id,
      nom: record.nom,
      age: record.age,
      category: record.category,
      priority: record.priority,
      status: record.status,
      
      # SOAP Structure
      soap: %{
        subjective: record.soap_subjective,
        objective: record.soap_objective,
        assessment: record.soap_assessment,
        plan: record.soap_plan
      },
      
      # Metadata
      consultation_date: record.consultation_date,
      follow_up_date: record.follow_up_date,
      tags: record.tags,
      attachments: record.attachments,
      
      # Relations
      patient_id: record.user_id,
      doctor_id: record.doctor_id,
      
      # Timestamps
      inserted_at: record.inserted_at,
      updated_at: record.updated_at
    }
  end
end
```

---

#### **Semaine 5-6 : WebSocket + WebRTC Signaling**

##### Phoenix Channel pour Consultations

```elixir
# lib/telemed_web/channels/consultation_channel.ex
defmodule TelemedWeb.ConsultationChannel do
  use TelemedWeb, :channel
  
  alias Telemed.Appointments

  @doc "Join consultation room"
  def join("consultation:" <> appointment_id, _payload, socket) do
    user = socket.assigns.current_user
    
    # Vérifier que user a accès à cette consultation
    case Appointments.can_access?(appointment_id, user) do
      true ->
        send(self(), :after_join)
        {:ok, assign(socket, :appointment_id, appointment_id)}
        
      false ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", %{})
    
    # Notifier autres participants
    broadcast!(socket, "user_joined", %{
      user_id: socket.assigns.current_user.id,
      role: socket.assigns.current_user.role
    })
    
    {:noreply, socket}
  end

  @doc "WebRTC Signaling"
  def handle_in("webrtc_offer", %{"offer" => offer, "to" => target_user_id}, socket) do
    broadcast_from!(socket, "webrtc_offer", %{
      from: socket.assigns.current_user.id,
      offer: offer
    })
    
    {:noreply, socket}
  end

  def handle_in("webrtc_answer", %{"answer" => answer, "to" => target_user_id}, socket) do
    broadcast_from!(socket, "webrtc_answer", %{
      from: socket.assigns.current_user.id,
      answer: answer
    })
    
    {:noreply, socket}
  end

  def handle_in("webrtc_ice_candidate", %{"candidate" => candidate}, socket) do
    broadcast_from!(socket, "webrtc_ice_candidate", %{
      from: socket.assigns.current_user.id,
      candidate: candidate
    })
    
    {:noreply, socket}
  end

  @doc "Chat messages"
  def handle_in("chat_message", %{"message" => message}, socket) do
    broadcast!(socket, "chat_message", %{
      from: socket.assigns.current_user.id,
      message: message,
      timestamp: DateTime.utc_now()
    })
    
    {:noreply, socket}
  end

  @doc "Toggle audio/video"
  def handle_in("media_toggle", %{"audio" => audio, "video" => video}, socket) do
    broadcast_from!(socket, "media_state", %{
      user_id: socket.assigns.current_user.id,
      audio: audio,
      video: video
    })
    
    {:noreply, socket}
  end
end
```

##### User Socket avec Auth JWT

```elixir
# lib/telemed_web/channels/user_socket.ex
defmodule TelemedWeb.UserSocket do
  use Phoenix.Socket
  
  alias Telemed.Guardian

  ## Channels
  channel "consultation:*", TelemedWeb.ConsultationChannel
  channel "notifications:*", TelemedWeb.NotificationChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        case Guardian.resource_from_claims(claims) do
          {:ok, user} ->
            {:ok, assign(socket, :current_user, user)}
          {:error, _} ->
            :error
        end
      {:error, _} ->
        :error
    end
  end

  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.current_user.id}"
end
```

---

### **PHASE 2 : Frontend React (Semaines 7-10)**

#### **Semaine 7 : Setup React + Architecture**

##### 2.1 Créer Projet React

```bash
# Créer app React avec Vite (ultra rapide)
npm create vite@latest telemed-frontend -- --template react-ts

cd telemed-frontend

# Installer dépendances
npm install

# UI Components
npm install @headlessui/react @heroicons/react
npm install tailwindcss postcss autoprefixer
npx tailwindcss init -p

# Routing
npm install react-router-dom

# State Management
npm install zustand  # Plus simple que Redux

# API Client
npm install axios
npm install @tanstack/react-query  # Cache + optimistic updates

# Forms
npm install react-hook-form zod @hookform/resolvers

# WebRTC
npm install simple-peer
npm install socket.io-client  # Pour channels Phoenix

# Date/Time
npm install date-fns

# Charts (pour dashboards)
npm install recharts

# Dev tools
npm install -D @types/node
```

##### 2.2 Structure Projet

```
telemed-frontend/
├── public/
├── src/
│   ├── api/              # Clients API
│   │   ├── axios.ts
│   │   ├── auth.ts
│   │   ├── medicalRecords.ts
│   │   └── appointments.ts
│   ├── components/       # Composants réutilisables
│   │   ├── ui/          # Buttons, Inputs, etc.
│   │   ├── layout/      # Header, Sidebar, etc.
│   │   └── medical/     # DME, Consultation, etc.
│   ├── features/        # Features par module
│   │   ├── auth/
│   │   │   ├── Login.tsx
│   │   │   ├── Register.tsx
│   │   │   └── useAuth.ts
│   │   ├── medical-records/
│   │   │   ├── MedicalRecordList.tsx
│   │   │   ├── MedicalRecordForm.tsx
│   │   │   └── useMedicalRecords.ts
│   │   ├── consultation/
│   │   │   ├── VideoRoom.tsx
│   │   │   ├── useWebRTC.ts
│   │   │   └── Chat.tsx
│   │   └── dashboard/
│   ├── hooks/           # Custom hooks
│   ├── store/           # Zustand stores
│   ├── types/           # TypeScript types
│   ├── utils/           # Helpers
│   ├── App.tsx
│   └── main.tsx
├── package.json
└── tsconfig.json
```

##### 2.3 API Client (Axios + React Query)

```typescript
// src/api/axios.ts
import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:4000/api/v1';

const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Intercepteur pour ajouter JWT automatiquement
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('access_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Intercepteur pour refresh token si expired
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      
      try {
        const refreshToken = localStorage.getItem('refresh_token');
        const { data } = await axios.post(`${API_URL}/auth/refresh`, {
          refresh_token: refreshToken,
        });
        
        localStorage.setItem('access_token', data.data.access_token);
        return apiClient(originalRequest);
      } catch (refreshError) {
        // Redirect to login
        localStorage.clear();
        window.location.href = '/login';
        return Promise.reject(refreshError);
      }
    }
    
    return Promise.reject(error);
  }
);

export default apiClient;
```

```typescript
// src/api/auth.ts
import apiClient from './axios';

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterData {
  email: string;
  password: string;
  role: 'patient' | 'doctor';
}

export interface AuthResponse {
  data: {
    user: User;
    tokens: {
      access_token: string;
      refresh_token: string;
      token_type: string;
      expires_in: number;
    };
  };
}

export const authAPI = {
  login: (credentials: LoginCredentials) =>
    apiClient.post<AuthResponse>('/auth/login', credentials),
  
  register: (data: RegisterData) =>
    apiClient.post<AuthResponse>('/auth/register', { user: data }),
  
  logout: () => {
    localStorage.clear();
    return Promise.resolve();
  },
  
  getCurrentUser: () =>
    apiClient.get<{ data: User }>('/me'),
};
```

##### 2.4 Store Auth (Zustand)

```typescript
// src/store/authStore.ts
import { create } from 'zustand';
import { authAPI } from '../api/auth';

interface User {
  id: number;
  email: string;
  role: 'patient' | 'doctor' | 'admin';
}

interface AuthStore {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  
  login: (email: string, password: string) => Promise<void>;
  register: (data: RegisterData) => Promise<void>;
  logout: () => void;
  checkAuth: () => Promise<void>;
}

export const useAuthStore = create<AuthStore>((set) => ({
  user: null,
  isAuthenticated: false,
  isLoading: true,
  
  login: async (email, password) => {
    const { data } = await authAPI.login({ email, password });
    
    localStorage.setItem('access_token', data.data.tokens.access_token);
    localStorage.setItem('refresh_token', data.data.tokens.refresh_token);
    
    set({ user: data.data.user, isAuthenticated: true });
  },
  
  register: async (registerData) => {
    const { data } = await authAPI.register(registerData);
    
    localStorage.setItem('access_token', data.data.tokens.access_token);
    localStorage.setItem('refresh_token', data.data.tokens.refresh_token);
    
    set({ user: data.data.user, isAuthenticated: true });
  },
  
  logout: () => {
    authAPI.logout();
    set({ user: null, isAuthenticated: false });
  },
  
  checkAuth: async () => {
    const token = localStorage.getItem('access_token');
    
    if (!token) {
      set({ isLoading: false });
      return;
    }
    
    try {
      const { data } = await authAPI.getCurrentUser();
      set({ user: data.data, isAuthenticated: true, isLoading: false });
    } catch (error) {
      localStorage.clear();
      set({ user: null, isAuthenticated: false, isLoading: false });
    }
  },
}));
```

---

#### **Semaine 8 : Pages Core (Auth, DME, Appointments)**

##### Login Component

```typescript
// src/features/auth/Login.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useAuthStore } from '../../store/authStore';
import { useNavigate } from 'react-router-dom';

const loginSchema = z.object({
  email: z.string().email('Email invalide'),
  password: z.string().min(12, 'Minimum 12 caractères'),
});

type LoginForm = z.infer<typeof loginSchema>;

export default function Login() {
  const { login } = useAuthStore();
  const navigate = useNavigate();
  
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginForm>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginForm) => {
    try {
      await login(data.email, data.password);
      navigate('/dashboard');
    } catch (error) {
      alert('Email ou mot de passe invalide');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="max-w-md w-full space-y-8 p-8 bg-white rounded-lg shadow">
        <div>
          <h2 className="text-3xl font-bold text-center">Connexion</h2>
          <p className="mt-2 text-center text-gray-600">
            Télémédecine sécurisée
          </p>
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-gray-700">
              Email
            </label>
            <input
              type="email"
              {...register('email')}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            />
            {errors.email && (
              <p className="mt-1 text-sm text-red-600">{errors.email.message}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">
              Mot de passe
            </label>
            <input
              type="password"
              {...register('password')}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            />
            {errors.password && (
              <p className="mt-1 text-sm text-red-600">{errors.password.message}</p>
            )}
          </div>

          <button
            type="submit"
            disabled={isSubmitting}
            className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
          >
            {isSubmitting ? 'Connexion...' : 'Se connecter'}
          </button>
        </form>
      </div>
    </div>
  );
}
```

##### Medical Records List

```typescript
// src/features/medical-records/MedicalRecordList.tsx
import { useQuery } from '@tanstack/react-query';
import { medicalRecordsAPI } from '../../api/medicalRecords';
import { Link } from 'react-router-dom';

export default function MedicalRecordList() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['medical-records'],
    queryFn: medicalRecordsAPI.getAll,
  });

  if (isLoading) return <div>Chargement...</div>;
  if (error) return <div>Erreur de chargement</div>;

  const records = data?.data.data || [];

  return (
    <div className="px-4 sm:px-6 lg:px-8">
      <div className="sm:flex sm:items-center">
        <div className="sm:flex-auto">
          <h1 className="text-2xl font-semibold text-gray-900">
            Dossiers Médicaux
          </h1>
        </div>
        <div className="mt-4 sm:mt-0 sm:ml-16 sm:flex-none">
          <Link
            to="/medical-records/new"
            className="inline-flex items-center justify-center rounded-md border border-transparent bg-blue-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-blue-700"
          >
            Nouveau DME
          </Link>
        </div>
      </div>

      <div className="mt-8 flex flex-col">
        <div className="-my-2 -mx-4 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div className="inline-block min-w-full py-2 align-middle md:px-6 lg:px-8">
            <div className="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
              <table className="min-w-full divide-y divide-gray-300">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                      Patient
                    </th>
                    <th className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                      Catégorie
                    </th>
                    <th className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                      Priorité
                    </th>
                    <th className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                      Date
                    </th>
                    <th className="relative py-3.5 pl-3 pr-4 sm:pr-6">
                      <span className="sr-only">Actions</span>
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200 bg-white">
                  {records.map((record) => (
                    <tr key={record.id}>
                      <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-900">
                        {record.nom}
                      </td>
                      <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                        {record.category}
                      </td>
                      <td className="whitespace-nowrap px-3 py-4 text-sm">
                        <span className={`inline-flex rounded-full px-2 text-xs font-semibold leading-5 ${getPriorityColor(record.priority)}`}>
                          {record.priority}
                        </span>
                      </td>
                      <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                        {new Date(record.consultation_date).toLocaleDateString('fr-FR')}
                      </td>
                      <td className="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-6">
                        <Link
                          to={`/medical-records/${record.id}`}
                          className="text-blue-600 hover:text-blue-900"
                        >
                          Voir
                        </Link>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function getPriorityColor(priority: string) {
  switch (priority) {
    case 'urgent':
      return 'bg-red-100 text-red-800';
    case 'high':
      return 'bg-orange-100 text-orange-800';
    case 'normal':
      return 'bg-green-100 text-green-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
}
```

---

#### **Semaine 9-10 : WebRTC Video + Chat**

##### Video Room avec WebRTC

```typescript
// src/features/consultation/VideoRoom.tsx
import { useEffect, useRef, useState } from 'react';
import { useParams } from 'react-router-dom';
import SimplePeer from 'simple-peer';
import { io, Socket } from 'socket.io-client';
import { useAuthStore } from '../../store/authStore';

export default function VideoRoom() {
  const { appointmentId } = useParams();
  const { user } = useAuthStore();
  
  const [localStream, setLocalStream] = useState<MediaStream | null>(null);
  const [remoteStream, setRemoteStream] = useState<MediaStream | null>(null);
  const [peer, setPeer] = useState<SimplePeer.Instance | null>(null);
  const [socket, setSocket] = useState<Socket | null>(null);
  const [isAudioEnabled, setIsAudioEnabled] = useState(true);
  const [isVideoEnabled, setIsVideoEnabled] = useState(true);
  
  const localVideoRef = useRef<HTMLVideoElement>(null);
  const remoteVideoRef = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    initializeMedia();
    connectToSocket();
    
    return () => {
      cleanup();
    };
  }, []);

  const initializeMedia = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: {
          width: { ideal: 1280 },
          height: { ideal: 720 },
        },
        audio: {
          echoCancellation: true,
          noiseSuppression: true,
        },
      });
      
      setLocalStream(stream);
      
      if (localVideoRef.current) {
        localVideoRef.current.srcObject = stream;
      }
    } catch (error) {
      console.error('Erreur accès média:', error);
      alert('Impossible d\'accéder à la caméra/microphone');
    }
  };

  const connectToSocket = () => {
    const token = localStorage.getItem('access_token');
    const socketUrl = import.meta.env.VITE_SOCKET_URL || 'ws://localhost:4000/socket';
    
    const newSocket = io(socketUrl, {
      query: { token },
    });
    
    newSocket.on('connect', () => {
      console.log('Connected to socket');
      newSocket.emit('phx_join', {
        topic: `consultation:${appointmentId}`,
        payload: {},
      });
    });
    
    // WebRTC Signaling
    newSocket.on('webrtc_offer', handleReceiveOffer);
    newSocket.on('webrtc_answer', handleReceiveAnswer);
    newSocket.on('webrtc_ice_candidate', handleReceiveIceCandidate);
    newSocket.on('user_joined', handleUserJoined);
    
    setSocket(newSocket);
  };

  const handleUserJoined = (data: { user_id: number; role: string }) => {
    console.log('User joined:', data);
    
    // Si on est le médecin, on initie la connexion
    if (user?.role === 'doctor' && localStream) {
      createPeerConnection(true);
    }
  };

  const createPeerConnection = (initiator: boolean) => {
    const newPeer = new SimplePeer({
      initiator,
      trickle: true,
      stream: localStream!,
    });
    
    newPeer.on('signal', (data) => {
      if (data.type === 'offer') {
        socket?.emit('webrtc_offer', { offer: data });
      } else if (data.type === 'answer') {
        socket?.emit('webrtc_answer', { answer: data });
      }
    });
    
    newPeer.on('stream', (stream) => {
      setRemoteStream(stream);
      if (remoteVideoRef.current) {
        remoteVideoRef.current.srcObject = stream;
      }
    });
    
    newPeer.on('error', (err) => {
      console.error('Peer error:', err);
    });
    
    setPeer(newPeer);
  };

  const handleReceiveOffer = (data: { from: number; offer: any }) => {
    if (!peer && localStream) {
      const newPeer = createPeerConnection(false);
      newPeer.signal(data.offer);
    }
  };

  const handleReceiveAnswer = (data: { from: number; answer: any }) => {
    peer?.signal(data.answer);
  };

  const handleReceiveIceCandidate = (data: { from: number; candidate: any }) => {
    peer?.signal(data.candidate);
  };

  const toggleAudio = () => {
    if (localStream) {
      const audioTrack = localStream.getAudioTracks()[0];
      audioTrack.enabled = !audioTrack.enabled;
      setIsAudioEnabled(audioTrack.enabled);
      
      socket?.emit('media_toggle', {
        audio: audioTrack.enabled,
        video: isVideoEnabled,
      });
    }
  };

  const toggleVideo = () => {
    if (localStream) {
      const videoTrack = localStream.getVideoTracks()[0];
      videoTrack.enabled = !videoTrack.enabled;
      setIsVideoEnabled(videoTrack.enabled);
      
      socket?.emit('media_toggle', {
        audio: isAudioEnabled,
        video: videoTrack.enabled,
      });
    }
  };

  const endCall = () => {
    cleanup();
    window.location.href = '/dashboard';
  };

  const cleanup = () => {
    localStream?.getTracks().forEach((track) => track.stop());
    peer?.destroy();
    socket?.disconnect();
  };

  return (
    <div className="h-screen bg-gray-900 flex flex-col">
      {/* Videos */}
      <div className="flex-1 relative">
        {/* Remote Video (main) */}
        <video
          ref={remoteVideoRef}
          autoPlay
          playsInline
          className="w-full h-full object-cover"
        />
        
        {/* Local Video (pip) */}
        <div className="absolute bottom-4 right-4 w-64 h-48 bg-black rounded-lg overflow-hidden shadow-lg">
          <video
            ref={localVideoRef}
            autoPlay
            playsInline
            muted
            className="w-full h-full object-cover"
          />
        </div>
      </div>

      {/* Controls */}
      <div className="bg-gray-800 p-4 flex justify-center gap-4">
        <button
          onClick={toggleAudio}
          className={`p-4 rounded-full ${isAudioEnabled ? 'bg-gray-700' : 'bg-red-600'}`}
        >
          {isAudioEnabled ? '🎤' : '🔇'}
        </button>
        
        <button
          onClick={toggleVideo}
          className={`p-4 rounded-full ${isVideoEnabled ? 'bg-gray-700' : 'bg-red-600'}`}
        >
          {isVideoEnabled ? '📹' : '📴'}
        </button>
        
        <button
          onClick={endCall}
          className="p-4 rounded-full bg-red-600 hover:bg-red-700"
        >
          📞 Raccrocher
        </button>
      </div>
    </div>
  );
}
```

---

### **PHASE 3 : Mobile Apps (Semaines 11-12)**

#### React Native Setup

```bash
# Créer app React Native
npx react-native init TelemedMobile --template react-native-template-typescript

cd TelemedMobile

# Installer dépendances (mêmes que web !)
npm install @react-navigation/native
npm install react-native-webrtc
npm install socket.io-client
npm install zustand

# Réutiliser 70% du code web !
# Partager: stores, API clients, types, utils
```

---

## 💰 BUDGET DÉTAILLÉ

| Phase | Durée | Dev | Infra | Total |
|-------|-------|-----|-------|-------|
| **Backend API** | 6 sem | 30k€ | 2k€ | **32k€** |
| **Frontend React** | 4 sem | 20k€ | 1k€ | **21k€** |
| **Mobile React Native** | 2 sem | 10k€ | - | **10k€** |
| **Tests & Deploy** | 2 sem | 10k€ | 3k€ | **13k€** |
| **TOTAL** | **14 sem** | **70k€** | **6k€** | **76k€** |

---

## ✅ AVANTAGES ARCHITECTURE DÉCOUPLÉE

### Pour le Développement
- ✅ **Équipes parallèles** (backend/frontend simultanés)
- ✅ **Tests indépendants**
- ✅ **Déploiements découplés**
- ✅ **Réutilisation code** (mobile partage 70% avec web)

### Pour les Utilisateurs
- ✅ **Mobile apps natives** (React Native)
- ✅ **Progressive Web App** (PWA offline)
- ✅ **Performance** (CDN pour frontend)

### Pour la Conformité
- ✅ **Backend Elixir** garde avantages (sécurité, concurrence)
- ✅ **Audit facilité** (backend seul pour certification HDS)
- ✅ **Logs centralisés** (backend contrôle tout)

---

## 🚀 PROCHAINE ACTION

**Je peux générer MAINTENANT** :

1. **Tous les contrôleurs API REST** (Auth, MedicalRecords, Appointments, etc.)
2. **Projet React complet** (structure + composants de base)
3. **WebSocket channels** pour WebRTC
4. **Tests automatisés** (backend + frontend)

**Dites-moi par où commencer** :

> "Génère-moi [BACKEND_API / FRONTEND_REACT / LES_DEUX] en commençant par [MODULE]"

**Ou je fais tout d'un coup ?** 💪

**Qu'en pensez-vous de cette approche Backend API + React ?** 🤔


