defmodule TelemedWeb.Router do
  use TelemedWeb, :router

  import TelemedWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TelemedWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug TelemedWeb.AssignCurrentUserPlug  # Ajoute le compteur de notifications
    plug TelemedWeb.RBACPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug, origin: ["http://localhost:3000", "http://localhost:5173", "https://app.telemed.fr"]
    plug OpenApiSpex.Plug.PutApiSpec, module: TelemedWeb.ApiSpec
  end

  pipeline :api_auth do
    plug :accepts, ["json"]
    plug CORSPlug, origin: ["http://localhost:3000", "http://localhost:5173", "https://app.telemed.fr"]
    plug Telemed.Guardian.AuthPipeline
  end

  # Pipeline public sans authentification
  pipeline :public do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TelemedWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  # Routes API publiques
  scope "/api/v1", TelemedWeb.API.V1 do
    pipe_through :api

    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login
    post "/auth/refresh", AuthController, :refresh_token
    post "/auth/forgot_password", AuthController, :forgot_password
  end

  # Routes API authentifiées
  scope "/api/v1", TelemedWeb.API.V1 do
    pipe_through :api_auth

    # Users
    get "/me", UserController, :show_current
    put "/me", UserController, :update_current

    # Medical Records
    resources "/medical_records", MedicalRecordController, except: [:new, :edit]
    get "/patients/:patient_id/medical_records", MedicalRecordController, :list_by_patient

    # Appointments
    resources "/appointments", AppointmentController, except: [:new, :edit]
    post "/appointments/:id/confirm", AppointmentController, :confirm
    post "/appointments/:id/cancel", AppointmentController, :cancel

    # Notifications
    resources "/notifications", NotificationController, only: [:index]
    put "/notifications/:id/read", NotificationController, :mark_as_read
  end

  # Health check
  scope "/api" do
    pipe_through :api
    get "/health", TelemedWeb.HealthController, :check
    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end

  # Swagger UI
  scope "/swaggerui" do
    pipe_through :browser
    get "/", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
  end

  # Routes publiques (consultation vidéo accessible sans connexion)
  scope "/", TelemedWeb do
    pipe_through :public

    get "/video", VideoController, :index
    get "/video/consultation", VideoController, :consultation
    get "/video/mobile-help", VideoController, :mobile_help
    get "/test-camera", PageController, :test_camera
  end

  scope "/", TelemedWeb do
    pipe_through :browser

    get "/", PageController, :home
    resources "/medical_records", MedicalRecordController
    resources "/appointments", AppointmentController do
      patch "/confirm", AppointmentController, :confirm
      patch "/reject", AppointmentController, :reject
    end
    post "/notifications/mark-all-read", NotificationController, :mark_all_as_read
    resources "/notifications", NotificationController do
      patch "/mark-read", NotificationController, :mark_as_read
    end
    get "/dashboard", DashboardController, :index

    # Settings routes
    get "/settings/profile", SettingsController, :profile
    post "/settings/profile", SettingsController, :update_profile

    # ========== INSTANT CONSULTATION (WhatsApp-Style) ==========
    get "/instant/:token", InstantController, :join
    get "/instant/room/:room_id", InstantController, :room
    post "/instant/start/:appointment_id/:patient_id", InstantController, :start_instant

    # ========== DOCUMENTS MÉDICAUX ==========
    get "/medical_records/:medical_record_id/documents", DocumentController, :index
    get "/medical_records/:medical_record_id/documents/new", DocumentController, :new
    post "/medical_records/:medical_record_id/documents", DocumentController, :create
    get "/documents/:id", DocumentController, :show
    get "/documents/:id/download", DocumentController, :download
    delete "/documents/:id", DocumentController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", TelemedWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:telemed, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TelemedWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", TelemedWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{TelemedWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
    post "/users/register", UserRegistrationController, :create
  end

  scope "/", TelemedWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{TelemedWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", TelemedWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    post "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{TelemedWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
