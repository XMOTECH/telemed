defmodule TelemedWeb.MedicalComponents do
  @moduledoc """
  Composants UI personnalisés pour la plateforme de télémédecine.

  Ces composants fournissent des éléments réutilisables spécifiques
  au domaine médical : cartes de patients, badges de statut,
  cartes de rendez-vous, etc.
  """
  use Phoenix.Component
  use Gettext, backend: TelemedWeb.Gettext

  @doc """
  Carte d'information patient.

  ## Exemples

      <.patient_card
        name="Marie Dupont"
        age={35}
        email="marie@example.com"
        last_visit={~D[2025-01-15]}
      />
  """
  attr :name, :string, required: true
  attr :age, :integer, default: nil
  attr :email, :string, default: nil
  attr :phone, :string, default: nil
  attr :last_visit, :any, default: nil
  attr :class, :string, default: ""

  def patient_card(assigns) do
    ~H"""
    <div class={"bg-white rounded-xl shadow-lg p-6 hover:shadow-xl transition-shadow #{@class}"}>
      <div class="flex items-start justify-between">
        <div class="flex items-center space-x-4">
          <div class="bg-blue-100 rounded-full p-3">
            <svg class="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
            </svg>
          </div>
          <div>
            <h3 class="text-lg font-bold text-gray-800"><%= @name %></h3>
            <p :if={@age} class="text-sm text-gray-500"><%= @age %> ans</p>
          </div>
        </div>
        <.status_badge status="actif" />
      </div>

      <div class="mt-4 space-y-2">
        <div :if={@email} class="flex items-center text-sm text-gray-600">
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
          </svg>
          <%= @email %>
        </div>

        <div :if={@phone} class="flex items-center text-sm text-gray-600">
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
          </svg>
          <%= @phone %>
        </div>

        <div :if={@last_visit} class="flex items-center text-sm text-gray-500 mt-3 pt-3 border-t">
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
          Dernière visite: <%= @last_visit %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Carte de rendez-vous.

  ## Exemples

      <.appointment_card
        patient_name="Marie Dupont"
        doctor_name="Dr. Martin"
        date={~N[2025-01-20 10:00:00]}
        status="confirmed"
        type="consultation"
      />
  """
  attr :patient_name, :string, required: true
  attr :doctor_name, :string, required: true
  attr :date, :any, required: true
  attr :status, :string, default: "pending"
  attr :type, :string, default: "consultation"
  attr :notes, :string, default: nil
  attr :class, :string, default: ""
  slot :actions

  def appointment_card(assigns) do
    ~H"""
    <div class={"bg-white rounded-lg shadow-md p-6 border-l-4 #{border_color(@status)} #{@class}"}>
      <div class="flex justify-between items-start">
        <div class="flex-1">
          <div class="flex items-center space-x-2 mb-2">
            <.appointment_icon type={@type} />
            <h3 class="text-lg font-semibold text-gray-800"><%= @patient_name %></h3>
          </div>

          <div class="space-y-1 text-sm text-gray-600">
            <div class="flex items-center">
              <svg class="w-4 h-4 mr-2 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
              </svg>
              Avec: <%= @doctor_name %>
            </div>

            <div class="flex items-center">
              <svg class="w-4 h-4 mr-2 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <%= format_datetime(@date) %>
            </div>

            <p :if={@notes} class="mt-2 text-gray-500 italic"><%= @notes %></p>
          </div>
        </div>

        <div class="flex flex-col items-end space-y-2">
          <.status_badge status={@status} />
          <%= render_slot(@actions) %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Badge de statut coloré.

  ## Exemples

      <.status_badge status="confirmed" />
      <.status_badge status="pending" />
      <.status_badge status="cancelled" />
  """
  attr :status, :string, required: true
  attr :class, :string, default: ""

  def status_badge(assigns) do
    ~H"""
    <span class={"inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold #{badge_color(@status)} #{@class}"}>
      <span class={"w-2 h-2 rounded-full mr-2 #{dot_color(@status)}"}></span>
      <%= status_text(@status) %>
    </span>
    """
  end

  @doc """
  Carte de dossier médical.

  ## Exemples

      <.medical_record_card
        title="Consultation de routine"
        date={~D[2025-01-15]}
        doctor="Dr. Martin"
        type="consultation"
        confidentiality="standard"
      />
  """
  attr :title, :string, required: true
  attr :date, :any, required: true
  attr :doctor, :string, required: true
  attr :type, :string, default: "consultation"
  attr :confidentiality, :string, default: "standard"
  attr :diagnosis, :string, default: nil
  attr :class, :string, default: ""
  slot :actions

  def medical_record_card(assigns) do
    ~H"""
    <div class={"bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow #{@class}"}>
      <div class="flex justify-between items-start mb-4">
        <div class="flex items-center space-x-3">
          <div class={"p-2 rounded-lg #{record_type_color(@type)}"}>
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
          </div>
          <div>
            <h3 class="text-lg font-bold text-gray-800"><%= @title %></h3>
            <p class="text-sm text-gray-500"><%= @type %></p>
          </div>
        </div>

        <.confidentiality_badge level={@confidentiality} />
      </div>

      <div class="space-y-2 text-sm">
        <div class="flex items-center text-gray-600">
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
          </svg>
          Dr. <%= @doctor %>
        </div>

        <div class="flex items-center text-gray-600">
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
          <%= @date %>
        </div>

        <p :if={@diagnosis} class="mt-3 p-3 bg-blue-50 rounded-lg text-gray-700">
          <span class="font-semibold">Diagnostic:</span> <%= @diagnosis %>
        </p>
      </div>

      <div :if={@actions != []} class="mt-4 pt-4 border-t flex space-x-2">
        <%= render_slot(@actions) %>
      </div>
    </div>
    """
  end

  @doc """
  Badge de confidentialité.
  """
  attr :level, :string, required: true

  def confidentiality_badge(assigns) do
    ~H"""
    <span class={"px-2 py-1 rounded text-xs font-semibold #{confidentiality_color(@level)}"}>
      <%= confidentiality_text(@level) %>
    </span>
    """
  end

  @doc """
  Carte de notification.

  ## Exemples

      <.notification_card
        title="Nouveau rendez-vous"
        message="Rendez-vous demandé par Marie Dupont"
        type="appointment"
        read={false}
        timestamp={~U[2025-01-15 10:00:00Z]}
      />
  """
  attr :title, :string, required: true
  attr :message, :string, required: true
  attr :type, :string, default: "info"
  attr :read, :boolean, default: false
  attr :timestamp, :any, required: true
  attr :class, :string, default: ""
  slot :actions

  def notification_card(assigns) do
    ~H"""
    <div class={"rounded-lg p-4 border-l-4 #{if @read, do: "bg-gray-50", else: "bg-white shadow-md"} #{notification_border(@type)} #{@class}"}>
      <div class="flex items-start justify-between">
        <div class="flex items-start space-x-3 flex-1">
          <div class={"p-2 rounded-lg #{notification_icon_bg(@type)}"}>
            <.medical_notification_icon type={@type} />
          </div>

          <div class="flex-1">
            <div class="flex items-center space-x-2">
              <h4 class={"font-semibold #{if @read, do: "text-gray-600", else: "text-gray-800"}"}><%= @title %></h4>
              <span :if={!@read} class="w-2 h-2 bg-blue-500 rounded-full"></span>
            </div>
            <p class={"text-sm mt-1 #{if @read, do: "text-gray-500", else: "text-gray-700"}"}><%= @message %></p>
            <p class="text-xs text-gray-400 mt-2"><%= format_timestamp(@timestamp) %></p>
          </div>
        </div>

        <div :if={@actions != []} class="ml-4">
          <%= render_slot(@actions) %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Icône de notification selon le type.
  """
  attr :type, :string, required: true

  def medical_notification_icon(assigns) do
    ~H"""
    <%= case @type do %>
      <% "appointment" -> %>
        <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
      <% "medical_record" -> %>
        <svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
      <% "message" -> %>
        <svg class="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
        </svg>
      <% "alert" -> %>
        <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
        </svg>
      <% _ -> %>
        <svg class="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
    <% end %>
    """
  end

  @doc """
  Icône de type de rendez-vous.
  """
  attr :type, :string, required: true

  def appointment_icon(assigns) do
    ~H"""
    <%= case @type do %>
      <% "consultation" -> %>
        <svg class="w-5 h-5 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
      <% "urgence" -> %>
        <svg class="w-5 h-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
        </svg>
      <% "suivi" -> %>
        <svg class="w-5 h-5 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      <% _ -> %>
        <svg class="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
    <% end %>
    """
  end

  @doc """
  Carte statistique pour le dashboard.

  ## Exemples

      <.stat_card
        title="Consultations du jour"
        value={5}
        icon="calendar"
        color="blue"
        trend={+12}
      />
  """
  attr :title, :string, required: true
  attr :value, :any, required: true
  attr :subtitle, :string, default: nil
  attr :icon, :string, default: "chart"
  attr :color, :string, default: "blue"
  attr :trend, :integer, default: nil
  attr :class, :string, default: ""

  def stat_card(assigns) do
    ~H"""
    <div class={"bg-white rounded-xl shadow-lg p-6 #{@class}"}>
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-gray-600"><%= @title %></p>
          <p class="text-3xl font-bold text-gray-900 mt-2"><%= @value %></p>
          <p :if={@subtitle} class="text-xs text-gray-500 mt-1"><%= @subtitle %></p>
        </div>

        <div class={"p-4 rounded-full #{stat_icon_bg(@color)}"}>
          <.stat_icon icon={@icon} color={@color} />
        </div>
      </div>

      <div :if={@trend} class="mt-4 flex items-center">
        <%= if @trend > 0 do %>
          <svg class="w-4 h-4 text-green-500 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 10l7-7m0 0l7 7m-7-7v18" />
          </svg>
          <span class="text-sm font-medium text-green-600">+<%= @trend %>%</span>
        <% else %>
          <svg class="w-4 h-4 text-red-500 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3" />
          </svg>
          <span class="text-sm font-medium text-red-600"><%= @trend %>%</span>
        <% end %>
        <span class="text-xs text-gray-500 ml-2">vs. mois dernier</span>
      </div>
    </div>
    """
  end

  @doc """
  Icône pour stat_card.
  """
  attr :icon, :string, required: true
  attr :color, :string, default: "blue"

  def stat_icon(assigns) do
    ~H"""
    <%= case @icon do %>
      <% "calendar" -> %>
        <svg class={"w-8 h-8 #{stat_icon_color(@color)}"} fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
      <% "users" -> %>
        <svg class={"w-8 h-8 #{stat_icon_color(@color)}"} fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
        </svg>
      <% "chart" -> %>
        <svg class={"w-8 h-8 #{stat_icon_color(@color)}"} fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
        </svg>
      <% "heart" -> %>
        <svg class={"w-8 h-8 #{stat_icon_color(@color)}"} fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
        </svg>
      <% _ -> %>
        <svg class={"w-8 h-8 #{stat_icon_color(@color)}"} fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
    <% end %>
    """
  end

  @doc """
  Bouton d'action rapide avec icône.

  ## Exemples

      <.action_button type="confirm" navigate={~p"/appointments/\#{@id}/confirm"}>
        Confirmer
      </.action_button>
  """
  attr :type, :string, default: "primary"
  attr :size, :string, default: "md"
  attr :navigate, :string, default: nil
  attr :href, :string, default: nil
  attr :patch, :string, default: nil
  attr :class, :string, default: ""
  attr :rest, :global, include: ~w(disabled form name value)
  slot :inner_block, required: true

  def action_button(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      href={@href}
      patch={@patch}
      class={"inline-flex items-center px-4 py-2 rounded-lg font-semibold transition-colors #{button_style(@type)} #{button_size(@size)} #{@class}"}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  @doc """
  Widget de caméra pour affichage vidéo.

  ## Exemples

      <.video_widget
        id="local-video"
        label="Vous"
        size="small"
      />
  """
  attr :id, :string, required: true
  attr :label, :string, default: "Vidéo"
  attr :size, :string, default: "large"
  attr :muted, :boolean, default: false
  attr :class, :string, default: ""

  def video_widget(assigns) do
    ~H"""
    <div class={"relative rounded-xl overflow-hidden shadow-2xl #{video_size(@size)} #{@class}"}>
      <video
        id={@id}
        autoplay
        playsinline
        muted={@muted}
        class="w-full h-full object-cover bg-gray-900"
      >
      </video>

      <div class="absolute bottom-3 left-3 bg-black bg-opacity-60 px-3 py-1 rounded-lg">
        <p class="text-white text-sm font-semibold"><%= @label %></p>
      </div>

      <div id={"#{@id}-placeholder"} class="absolute inset-0 bg-gray-900 flex items-center justify-center">
        <div class="text-center">
          <svg class="w-16 h-16 mx-auto text-gray-600 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
          </svg>
          <p class="text-gray-400 text-sm"><%= @label %></p>
        </div>
      </div>
    </div>
    """
  end

  # === FONCTIONS HELPER ===

  defp border_color("confirmed"), do: "border-green-500"
  defp border_color("pending"), do: "border-yellow-500"
  defp border_color("cancelled"), do: "border-red-500"
  defp border_color("completed"), do: "border-blue-500"
  defp border_color(_), do: "border-gray-300"

  defp badge_color("confirmed"), do: "bg-green-100 text-green-800"
  defp badge_color("pending"), do: "bg-yellow-100 text-yellow-800"
  defp badge_color("cancelled"), do: "bg-red-100 text-red-800"
  defp badge_color("completed"), do: "bg-blue-100 text-blue-800"
  defp badge_color("actif"), do: "bg-green-100 text-green-800"
  defp badge_color(_), do: "bg-gray-100 text-gray-800"

  defp dot_color("confirmed"), do: "bg-green-500"
  defp dot_color("pending"), do: "bg-yellow-500"
  defp dot_color("cancelled"), do: "bg-red-500"
  defp dot_color("actif"), do: "bg-green-500"
  defp dot_color(_), do: "bg-gray-500"

  defp status_text("confirmed"), do: "Confirmé"
  defp status_text("pending"), do: "En attente"
  defp status_text("cancelled"), do: "Annulé"
  defp status_text("completed"), do: "Terminé"
  defp status_text("actif"), do: "Actif"
  defp status_text(status), do: status

  defp record_type_color("consultation"), do: "bg-blue-100 text-blue-600"
  defp record_type_color("urgence"), do: "bg-red-100 text-red-600"
  defp record_type_color("suivi"), do: "bg-green-100 text-green-600"
  defp record_type_color(_), do: "bg-gray-100 text-gray-600"

  defp confidentiality_color("public"), do: "bg-green-100 text-green-700"
  defp confidentiality_color("standard"), do: "bg-blue-100 text-blue-700"
  defp confidentiality_color("private"), do: "bg-yellow-100 text-yellow-700"
  defp confidentiality_color("confidentiel"), do: "bg-red-100 text-red-700"
  defp confidentiality_color(_), do: "bg-gray-100 text-gray-700"

  defp confidentiality_text("public"), do: "Public"
  defp confidentiality_text("standard"), do: "Standard"
  defp confidentiality_text("private"), do: "Privé"
  defp confidentiality_text("confidentiel"), do: "Confidentiel"
  defp confidentiality_text(level), do: level

  defp notification_border("appointment"), do: "border-blue-500"
  defp notification_border("medical_record"), do: "border-green-500"
  defp notification_border("message"), do: "border-purple-500"
  defp notification_border("alert"), do: "border-red-500"
  defp notification_border(_), do: "border-gray-300"

  defp notification_icon_bg("appointment"), do: "bg-blue-100"
  defp notification_icon_bg("medical_record"), do: "bg-green-100"
  defp notification_icon_bg("message"), do: "bg-purple-100"
  defp notification_icon_bg("alert"), do: "bg-red-100"
  defp notification_icon_bg(_), do: "bg-gray-100"

  defp button_style("primary"), do: "bg-blue-600 text-white hover:bg-blue-700"
  defp button_style("secondary"), do: "bg-gray-200 text-gray-800 hover:bg-gray-300"
  defp button_style("success"), do: "bg-green-600 text-white hover:bg-green-700"
  defp button_style("danger"), do: "bg-red-600 text-white hover:bg-red-700"
  defp button_style("confirm"), do: "bg-green-500 text-white hover:bg-green-600"
  defp button_style("reject"), do: "bg-red-500 text-white hover:bg-red-600"
  defp button_style(_), do: "bg-gray-600 text-white hover:bg-gray-700"

  defp button_size("sm"), do: "text-xs px-3 py-1"
  defp button_size("md"), do: "text-sm px-4 py-2"
  defp button_size("lg"), do: "text-base px-6 py-3"
  defp button_size(_), do: "text-sm px-4 py-2"

  defp stat_icon_bg("blue"), do: "bg-blue-100"
  defp stat_icon_bg("green"), do: "bg-green-100"
  defp stat_icon_bg("red"), do: "bg-red-100"
  defp stat_icon_bg("yellow"), do: "bg-yellow-100"
  defp stat_icon_bg("purple"), do: "bg-purple-100"
  defp stat_icon_bg(_), do: "bg-gray-100"

  defp stat_icon_color("blue"), do: "text-blue-600"
  defp stat_icon_color("green"), do: "text-green-600"
  defp stat_icon_color("red"), do: "text-red-600"
  defp stat_icon_color("yellow"), do: "text-yellow-600"
  defp stat_icon_color("purple"), do: "text-purple-600"
  defp stat_icon_color(_), do: "text-gray-600"

  defp video_size("small"), do: "max-w-xs"
  defp video_size("medium"), do: "max-w-md"
  defp video_size("large"), do: "max-w-4xl"
  defp video_size(_), do: "max-w-2xl"

  defp format_datetime(datetime) when is_binary(datetime), do: datetime
  defp format_datetime(%NaiveDateTime{} = datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y à %H:%M")
  end
  defp format_datetime(%DateTime{} = datetime) do
    datetime
    |> DateTime.shift_zone!("Europe/Paris")
    |> Calendar.strftime("%d/%m/%Y à %H:%M")
  end
  defp format_datetime(_), do: "Date inconnue"

  defp format_timestamp(timestamp) when is_binary(timestamp) do
    case DateTime.from_iso8601(timestamp) do
      {:ok, dt, _} -> format_relative_time(dt)
      _ -> timestamp
    end
  end
  defp format_timestamp(%DateTime{} = timestamp), do: format_relative_time(timestamp)
  defp format_timestamp(_), do: "Date inconnue"

  defp format_relative_time(datetime) do
    now = DateTime.utc_now()
    diff = DateTime.diff(now, datetime, :second)

    cond do
      diff < 60 -> "Il y a quelques secondes"
      diff < 3600 -> "Il y a #{div(diff, 60)} minutes"
      diff < 86400 -> "Il y a #{div(diff, 3600)} heures"
      diff < 604800 -> "Il y a #{div(diff, 86400)} jours"
      true -> Calendar.strftime(datetime, "%d/%m/%Y")
    end
  end
end
