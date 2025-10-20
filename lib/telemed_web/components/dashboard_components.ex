defmodule TelemedWeb.DashboardComponents do
  @moduledoc """
  Composants pour le dashboard - Élimine la duplication de code.
  """
  use Phoenix.Component

  @doc """
  Grille de statistiques avec cartes colorées.

  ## Exemples

      <.stat_grid>
        <.stat_card
          title="Total RDV"
          value={@stats.total_appointments}
          icon="calendar"
          color="blue" />

        <.stat_card
          title="Patients"
          value={@stats.total_patients}
          icon="users"
          color="green" />
      </.stat_grid>
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def stat_grid(assigns) do
    ~H"""
    <div class={["grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Carte de statistique avec icône et couleur.
  """
  attr :title, :string, required: true
  attr :value, :any, required: true
  attr :icon, :string, required: true
  attr :color, :string, default: "blue"
  attr :subtitle, :string, default: nil
  attr :class, :string, default: ""

  def stat_card(assigns) do
    ~H"""
    <div class={[
      "bg-white rounded-lg shadow-card hover:shadow-card-hover transition-shadow duration-200 p-6",
      @class
    ]} role="region" aria-label={"Statistique: #{@title}"}>
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-gray-600"><%= @title %></p>
          <p class="text-3xl font-bold text-gray-900 mt-2" aria-live="polite">
            <%= @value %>
          </p>
          <p :if={@subtitle} class="text-xs text-gray-500 mt-1"><%= @subtitle %></p>
        </div>

        <div class={[
          "p-3 rounded-full",
          icon_bg_color(@color)
        ]}>
          <.stat_icon name={@icon} color={@color} />
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Carte de section avec liste d'éléments.
  """
  attr :title, :string, required: true
  attr :empty_message, :string, default: "Aucun élément"
  attr :items, :list, required: true
  attr :view_all_link, :string, default: nil
  attr :class, :string, default: ""
  slot :item, required: true

  def section_card(assigns) do
    ~H"""
    <div class={["bg-white rounded-lg shadow-card p-6", @class]}>
      <h2 class="text-xl font-semibold text-gray-900 mb-4"><%= @title %></h2>

      <%= if Enum.empty?(@items) do %>
        <p class="text-gray-500 text-center py-4"><%= @empty_message %></p>
      <% else %>
        <div class="space-y-3">
          <%= for item <- @items do %>
            <%= render_slot(@item, item) %>
          <% end %>
        </div>
      <% end %>

      <%= if @view_all_link do %>
        <div class="mt-4 pt-4 border-t border-gray-200">
          <a
            href={@view_all_link}
            class="text-primary-600 hover:text-primary-800 text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500 focus-visible:ring-offset-2 rounded">
            Voir tout →
          </a>
        </div>
      <% end %>
    </div>
    """
  end

  @doc """
  Badge de statut pour les rendez-vous.
  """
  attr :status, :string, required: true
  attr :class, :string, default: ""

  def status_badge(assigns) do
    ~H"""
    <span class={[
      "px-2 py-1 text-xs rounded-full font-medium inline-flex items-center",
      status_classes(@status),
      @class
    ]} role="status" aria-label={"Statut: #{status_label(@status)}"}>
      <span class={["w-1.5 h-1.5 rounded-full mr-1.5", dot_color(@status)]} aria-hidden="true"></span>
      <%= status_label(@status) %>
    </span>
    """
  end

  # === ICÔNES ===

  defp stat_icon(assigns) do
    ~H"""
    <%= case @name do %>
      <% "calendar" -> %>
        <svg class={["w-8 h-8", icon_color(@color)]} fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>

      <% "users" -> %>
        <svg class={["w-8 h-8", icon_color(@color)]} fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
        </svg>

      <% "clock" -> %>
        <svg class={["w-8 h-8", icon_color(@color)]} fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>

      <% "arrow-right" -> %>
        <svg class={["w-8 h-8", icon_color(@color)]} fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
        </svg>

      <% "bell" -> %>
        <svg class={["w-8 h-8", icon_color(@color)]} fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
        </svg>

      <% "document" -> %>
        <svg class={["w-8 h-8", icon_color(@color)]} fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>

      <% _ -> %>
        <svg class="w-8 h-8 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
    <% end %>
    """
  end

  # === HELPER FUNCTIONS ===

  defp icon_bg_color("blue"), do: "bg-blue-100"
  defp icon_bg_color("green"), do: "bg-green-100"
  defp icon_bg_color("yellow"), do: "bg-yellow-100"
  defp icon_bg_color("purple"), do: "bg-purple-100"
  defp icon_bg_color("red"), do: "bg-red-100"
  defp icon_bg_color(_), do: "bg-gray-100"

  defp icon_color("blue"), do: "text-blue-600"
  defp icon_color("green"), do: "text-green-600"
  defp icon_color("yellow"), do: "text-yellow-600"
  defp icon_color("purple"), do: "text-purple-600"
  defp icon_color("red"), do: "text-red-600"
  defp icon_color(_), do: "text-gray-600"

  defp status_classes("confirmed"), do: "bg-success-100 text-success-800"
  defp status_classes("pending"), do: "bg-warning-100 text-warning-800"
  defp status_classes("rejected"), do: "bg-danger-100 text-danger-800"
  defp status_classes("cancelled"), do: "bg-danger-100 text-danger-800"
  defp status_classes("completed"), do: "bg-primary-100 text-primary-800"
  defp status_classes(_), do: "bg-gray-100 text-gray-800"

  defp dot_color("confirmed"), do: "bg-success-500"
  defp dot_color("pending"), do: "bg-warning-500"
  defp dot_color("rejected"), do: "bg-danger-500"
  defp dot_color("cancelled"), do: "bg-danger-500"
  defp dot_color("completed"), do: "bg-primary-500"
  defp dot_color(_), do: "bg-gray-500"

  defp status_label("confirmed"), do: "Confirmé"
  defp status_label("pending"), do: "En attente"
  defp status_label("rejected"), do: "Refusé"
  defp status_label("cancelled"), do: "Annulé"
  defp status_label("completed"), do: "Terminé"
  defp status_label(status), do: status
end
