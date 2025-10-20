defmodule TelemedWeb.NavComponents do
  @moduledoc """
  Composants de navigation réutilisables pour éliminer la duplication de code.
  Conforme aux standards d'accessibilité WCAG 2.1 AA.
  """
  use Phoenix.Component

  @doc """
  Lien de navigation avec icône et support d'accessibilité.

  ## Attributs
  - `href` - URL de destination (required)
  - `icon` - Nom de l'icône SVG (required)
  - `active` - Si le lien est actif (default: false)
  - `color` - Couleur du thème: "blue", "green", "purple" (default: "blue")
  - `badge` - Texte du badge (optionnel)

  ## Exemples

      <.nav_link href="/dashboard" icon="home" active={@current_path == "/dashboard"}>
        Dashboard
      </.nav_link>

      <.nav_link href="/notifications" icon="bell" badge="3">
        Notifications
      </.nav_link>
  """
  attr :href, :string, required: true
  attr :icon, :string, required: true
  attr :active, :boolean, default: false
  attr :color, :string, default: "blue"
  attr :badge, :string, default: nil
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def nav_link(assigns) do
    ~H"""
    <a
      href={@href}
      class={[
        "group flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-all duration-200",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2",
        active_classes(@active, @color),
        @class
      ]}
      aria-current={if @active, do: "page", else: nil}>

      <.nav_icon name={@icon} active={@active} color={@color} />

      <span class="flex-1">
        <%= render_slot(@inner_block) %>
      </span>

      <%= if @badge do %>
        <span class={[
          "ml-auto inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none rounded-full",
          badge_classes(@color)
        ]} aria-label={"#{@badge} notifications non lues"}>
          <%= @badge %>
        </span>
      <% end %>

      <%= if @active do %>
        <span class={[
          "ml-2 w-1.5 h-1.5 rounded-full",
          active_dot_color(@color)
        ]} aria-hidden="true"></span>
      <% end %>
    </a>
    """
  end

  @doc """
  Icône de navigation avec animations.
  """
  attr :name, :string, required: true
  attr :active, :boolean, default: false
  attr :color, :string, default: "blue"
  attr :class, :string, default: ""

  def nav_icon(assigns) do
    ~H"""
    <svg
      class={[
        "w-5 h-5 mr-3 transition-colors duration-200",
        icon_color(@active, @color),
        @class
      ]}
      fill="none"
      stroke="currentColor"
      viewBox="0 0 24 24"
      aria-hidden="true">
      <%= case @name do %>
        <% "home" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />

        <% "calendar" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />

        <% "document" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />

        <% "video" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />

        <% "users" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />

        <% "bell" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />

        <% "settings" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />

        <% "logout" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />

        <% _ -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      <% end %>
    </svg>
    """
  end

  # === HELPER FUNCTIONS ===

  defp active_classes(true, "blue"), do: "bg-blue-50 text-blue-700 focus-visible:ring-blue-500"
  defp active_classes(true, "green"), do: "bg-green-50 text-green-700 focus-visible:ring-green-500"
  defp active_classes(true, "purple"), do: "bg-purple-50 text-purple-700 focus-visible:ring-purple-500"
  defp active_classes(false, "blue"), do: "text-gray-700 hover:bg-blue-50 hover:text-blue-700 focus-visible:ring-blue-500"
  defp active_classes(false, "green"), do: "text-gray-700 hover:bg-green-50 hover:text-green-700 focus-visible:ring-green-500"
  defp active_classes(false, "purple"), do: "text-gray-700 hover:bg-purple-50 hover:text-purple-700 focus-visible:ring-purple-500"

  defp icon_color(true, "blue"), do: "text-blue-600"
  defp icon_color(true, "green"), do: "text-green-600"
  defp icon_color(true, "purple"), do: "text-purple-600"
  defp icon_color(false, _), do: "text-gray-400 group-hover:text-current"

  defp active_dot_color("blue"), do: "bg-blue-600"
  defp active_dot_color("green"), do: "bg-green-600"
  defp active_dot_color("purple"), do: "bg-purple-600"

  defp badge_classes("blue"), do: "bg-red-600 text-white"
  defp badge_classes("green"), do: "bg-red-600 text-white"
  defp badge_classes("purple"), do: "bg-red-600 text-white"
end


