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
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TelemedWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/video", VideoController, :index
    get "/test-camera", PageController, :test_camera
  end

  scope "/", TelemedWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live "/users/register", UserRegistrationLive, :new
    live "/users/log_in", UserLoginLive, :new
    live "/users/reset_password", UserForgotPasswordLive, :new
    live "/users/confirm", UserConfirmationInstructionsLive, :new
  end

  scope "/", TelemedWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/users/settings", UserSettingsLive, :edit
    live "/users/confirm/:token", UserConfirmationLive, :edit
    live "/users/reset_password/:token", UserResetPasswordLive, :edit
    resources "/medical_records", MedicalRecordController
  end

  scope "/", TelemedWeb do
    pipe_through :browser

    delete "/users/log_out", UserSessionController, :delete
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
end
