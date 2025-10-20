defmodule TelemedWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use TelemedWeb, :controller
      use TelemedWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: TelemedWeb.Layouts]

      use Gettext, backend: TelemedWeb.Gettext

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {TelemedWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # Translation
      use Gettext, backend: TelemedWeb.Gettext

      # HTML escaping functionality
      import Phoenix.HTML

      # Import fonctions de base de Phoenix.Component (link, form, etc.)
      import Phoenix.Component

      # Simple UI components (épurés - pas de styles imposés)
      import TelemedWeb.SimpleComponents

      # Medical UI components (composants médicaux personnalisés)
      import TelemedWeb.MedicalComponents

      # Navigation components (avec accessibilité WCAG 2.1)
      import TelemedWeb.NavComponents

      # Dashboard components (stat cards, grilles)
      import TelemedWeb.DashboardComponents

      # DME components (Dossier Médical Électronique v2 - Timeline SOAP)
      import TelemedWeb.DmeComponents

      # Video consultation components (interface moderne Discord/Zoom)
      import TelemedWeb.VideoComponents

      # Core components Phoenix (désactivé - perturbe la typographie)
      # import TelemedWeb.CoreComponents

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: TelemedWeb.Endpoint,
        router: TelemedWeb.Router,
        statics: TelemedWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
