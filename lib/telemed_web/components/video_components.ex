defmodule TelemedWeb.VideoComponents do
  @moduledoc """
  Composants pour la Consultation Vidéo v2
  Interface moderne style Discord/Zoom
  """
  use Phoenix.Component
  use Gettext, backend: TelemedWeb.Gettext

  @doc """
  Card participant avec avatar et statut en temps réel
  """
  attr :participant, :map, required: true
  attr :is_self, :boolean, default: false
  attr :is_speaking, :boolean, default: false

  def participant_card(assigns) do
    ~H"""
    <div class={[
      "flex items-center p-3 rounded-lg transition-all cursor-pointer",
      @is_self && "bg-blue-50 border-2 border-blue-500",
      !@is_self && "hover:bg-gray-100",
      @is_speaking && "ring-2 ring-green-500 shadow-lg"
    ]}>
      <!-- Avatar avec indicateur -->
      <div class="relative flex-shrink-0">
        <div class={[
          "w-10 h-10 rounded-full flex items-center justify-center text-white font-bold",
          @is_self && "bg-blue-600",
          !@is_self && "bg-gray-600"
        ]}>
          <%= String.first(@participant[:name] || "?") |> String.upcase() %>
        </div>

        <!-- Indicateur de statut -->
        <div class={[
          "absolute bottom-0 right-0 w-3 h-3 rounded-full border-2 border-white",
          @participant[:audio_enabled] && "bg-green-500",
          !@participant[:audio_enabled] && "bg-red-500"
        ]}></div>
      </div>

      <!-- Info participant -->
      <div class="ml-3 flex-1 min-w-0">
        <div class="flex items-center space-x-2">
          <p class="text-sm font-semibold text-gray-900 truncate">
            <%= @participant[:name] %>
            <%= if @is_self do %>
              <span class="text-xs text-blue-600">(Vous)</span>
            <% end %>
          </p>
        </div>

        <div class="flex items-center space-x-2 mt-1">
          <!-- Micro -->
          <%= if @participant[:audio_enabled] do %>
            <svg class="w-3 h-3 text-green-600" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M7 4a3 3 0 016 0v4a3 3 0 11-6 0V4zm4 10.93A7.001 7.001 0 0017 8a1 1 0 10-2 0A5 5 0 015 8a1 1 0 00-2 0 7.001 7.001 0 006 6.93V17H6a1 1 0 100 2h8a1 1 0 100-2h-3v-2.07z" clip-rule="evenodd" />
            </svg>
          <% else %>
            <svg class="w-3 h-3 text-red-600" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M13.477 14.89A6 6 0 015.11 6.524l8.367 8.368zm1.414-1.414L6.524 5.11a6 6 0 018.367 8.367zM18 10a8 8 0 11-16 0 8 8 0 0116 0z" clip-rule="evenodd" />
            </svg>
          <% end %>

          <!-- Caméra -->
          <%= if @participant[:video_enabled] do %>
            <svg class="w-3 h-3 text-green-600" fill="currentColor" viewBox="0 0 20 20">
              <path d="M2 6a2 2 0 012-2h6a2 2 0 012 2v8a2 2 0 01-2 2H4a2 2 0 01-2-2V6zM14.553 7.106A1 1 0 0014 8v4a1 1 0 00.553.894l2 1A1 1 0 0018 13V7a1 1 0 00-1.447-.894l-2 1z" />
            </svg>
          <% else %>
            <svg class="w-3 h-3 text-red-600" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M3.707 2.293a1 1 0 00-1.414 1.414l14 14a1 1 0 001.414-1.414l-1.473-1.473A2 2 0 0018 13V7a1 1 0 00-1.447-.894l-2 1A1 1 0 0014 8v.586l-4-4V4a2 2 0 00-2-2H6.414l-2.707-2.707z" clip-rule="evenodd" />
            </svg>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Fenêtre vidéo pour un participant
  """
  attr :participant, :map, required: true
  attr :video_id, :string, required: true
  attr :mode, :string, default: "normal"  # normal, spotlight, thumbnail
  attr :class, :string, default: ""

  def video_window(assigns) do
    ~H"""
    <div class={[
      "relative bg-gray-900 rounded-lg overflow-hidden shadow-2xl",
      @mode == "spotlight" && "aspect-video",
      @mode == "thumbnail" && "w-40 h-30",
      @mode == "normal" && "aspect-video",
      @class
    ]}>
      <!-- Video element -->
      <video
        id={@video_id}
        autoplay
        playsinline
        muted={@participant[:is_self]}
        class="w-full h-full object-cover absolute inset-0 z-10"
      ></video>

      <!-- Placeholder si pas de vidéo -->
      <div id={"#{@video_id}-placeholder"} class="absolute inset-0 flex items-center justify-center bg-gradient-to-br from-gray-800 to-gray-900 z-0">
        <div class="text-center">
          <!-- Avatar grand -->
          <div class="w-24 h-24 mx-auto rounded-full bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center text-white text-4xl font-bold mb-3">
            <%= String.first(@participant[:name] || "?") |> String.upcase() %>
          </div>
          <p class="text-white font-semibold text-lg"><%= @participant[:name] %></p>
          <%= if !@participant[:video_enabled] do %>
            <p class="text-gray-400 text-sm mt-1">Caméra désactivée</p>
          <% end %>
        </div>
      </div>

      <!-- Overlay avec infos -->
      <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent p-3 z-20">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-2">
            <p class="text-white font-semibold text-sm"><%= @participant[:name] %></p>

            <!-- Badges statut -->
            <%= if !@participant[:audio_enabled] do %>
              <div class="p-1 bg-red-500 rounded-full">
                <svg class="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M13.477 14.89A6 6 0 015.11 6.524l8.367 8.368zm1.414-1.414L6.524 5.11a6 6 0 018.367 8.367zM18 10a8 8 0 11-16 0 8 8 0 0116 0z" clip-rule="evenodd" />
                </svg>
              </div>
            <% end %>
          </div>

          <!-- Actions rapides (au survol) -->
          <div class="opacity-0 hover:opacity-100 transition-opacity flex space-x-1">
            <button class="p-1 bg-white/20 hover:bg-white/30 rounded transition-colors">
              <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v3m0 0v3m0-3h3m-3 0H7" />
              </svg>
            </button>
          </div>
        </div>
      </div>

      <!-- Indicateur de parole -->
      <%= if @participant[:is_speaking] do %>
        <div class="absolute inset-0 ring-4 ring-green-500 ring-inset pointer-events-none z-30"></div>
      <% end %>
    </div>
    """
  end

  @doc """
  Sélecteur de mode d'affichage vidéo
  """
  attr :current_mode, :string, default: "gallery"

  def view_mode_selector(assigns) do
    ~H"""
    <div class="flex items-center space-x-2 bg-gray-800/90 backdrop-blur-sm px-4 py-2 rounded-lg">
      <span class="text-white text-sm font-medium mr-2">Vue :</span>

      <button
        data-mode="gallery"
        class={[
          "px-3 py-1.5 rounded-md text-sm font-medium transition-all",
          @current_mode == "gallery" && "bg-blue-600 text-white",
          @current_mode != "gallery" && "text-gray-300 hover:bg-gray-700"
        ]}
      >
        <svg class="w-4 h-4 inline mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 5a1 1 0 011-1h4a1 1 0 011 1v7a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM14 5a1 1 0 011-1h4a1 1 0 011 1v7a1 1 0 01-1 1h-4a1 1 0 01-1-1V5zM4 16a1 1 0 011-1h4a1 1 0 011 1v3a1 1 0 01-1 1H5a1 1 0 01-1-1v-3zM14 16a1 1 0 011-1h4a1 1 0 011 1v3a1 1 0 01-1 1h-4a1 1 0 01-1-1v-3z" />
        </svg>
        Galerie
      </button>

      <button
        data-mode="speaker"
        class={[
          "px-3 py-1.5 rounded-md text-sm font-medium transition-all",
          @current_mode == "speaker" && "bg-blue-600 text-white",
          @current_mode != "speaker" && "text-gray-300 hover:bg-gray-700"
        ]}
      >
        <svg class="w-4 h-4 inline mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
        </svg>
        Intervenant
      </button>

      <button
        data-mode="pip"
        class={[
          "px-3 py-1.5 rounded-md text-sm font-medium transition-all",
          @current_mode == "pip" && "bg-blue-600 text-white",
          @current_mode != "pip" && "text-gray-300 hover:bg-gray-700"
        ]}
      >
        <svg class="w-4 h-4 inline mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17V7m0 10a2 2 0 01-2 2H5a2 2 0 01-2-2V7a2 2 0 012-2h2a2 2 0 012 2m0 10a2 2 0 002 2h2a2 2 0 002-2M9 7a2 2 0 012-2h2a2 2 0 012 2m0 10V7m0 10a2 2 0 002 2h2a2 2 0 002-2V7a2 2 0 00-2-2h-2a2 2 0 00-2 2" />
        </svg>
        PiP
      </button>
    </div>
    """
  end

  @doc """
  Barre de contrôles vidéo flottante
  """
  attr :audio_enabled, :boolean, default: true
  attr :video_enabled, :boolean, default: true
  attr :screen_sharing, :boolean, default: false

  def video_controls(assigns) do
    ~H"""
    <div class="flex items-center justify-center space-x-3 bg-gray-900/95 backdrop-blur-sm px-6 py-4 rounded-full shadow-2xl">
      <!-- Toggle Audio -->
      <button
        id="toggleAudioBtn"
        class={[
          "p-4 rounded-full transition-all shadow-lg hover:scale-110",
          @audio_enabled && "bg-gray-700 hover:bg-gray-600 text-white",
          !@audio_enabled && "bg-red-600 hover:bg-red-500 text-white"
        ]}
        title={@audio_enabled && "Couper le micro" || "Activer le micro"}
      >
        <%= if @audio_enabled do %>
          <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M7 4a3 3 0 016 0v4a3 3 0 11-6 0V4zm4 10.93A7.001 7.001 0 0017 8a1 1 0 10-2 0A5 5 0 015 8a1 1 0 00-2 0 7.001 7.001 0 006 6.93V17H6a1 1 0 100 2h8a1 1 0 100 2h-3v-2.07z" clip-rule="evenodd" />
          </svg>
        <% else %>
          <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M13.477 14.89A6 6 0 015.11 6.524l8.367 8.368zm1.414-1.414L6.524 5.11a6 6 0 018.367 8.367zM18 10a8 8 0 11-16 0 8 8 0 0116 0z" clip-rule="evenodd" />
          </svg>
        <% end %>
      </button>

      <!-- Toggle Video -->
      <button
        id="toggleVideoBtn"
        class={[
          "p-4 rounded-full transition-all shadow-lg hover:scale-110",
          @video_enabled && "bg-gray-700 hover:bg-gray-600 text-white",
          !@video_enabled && "bg-red-600 hover:bg-red-500 text-white"
        ]}
        title={@video_enabled && "Couper la caméra" || "Activer la caméra"}
      >
        <%= if @video_enabled do %>
          <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
            <path d="M2 6a2 2 0 012-2h6a2 2 0 012 2v8a2 2 0 01-2 2H4a2 2 0 01-2-2V6zM14.553 7.106A1 1 0 0014 8v4a1 1 0 00.553.894l2 1A1 1 0 0018 13V7a1 1 0 00-1.447-.894l-2 1z" />
          </svg>
        <% else %>
          <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M3.707 2.293a1 1 0 00-1.414 1.414l14 14a1 1 0 001.414-1.414l-1.473-1.473A2 2 0 0018 13V7a1 1 0 00-1.447-.894l-2 1A1 1 0 0014 8v.586l-4-4V4a2 2 0 00-2-2H6.414l-2.707-2.707z" clip-rule="evenodd" />
          </svg>
        <% end %>
      </button>

      <!-- Screen Share -->
      <button
        id="screenShareBtn"
        class={[
          "p-4 rounded-full transition-all shadow-lg hover:scale-110",
          @screen_sharing && "bg-yellow-600 hover:bg-yellow-500 text-white",
          !@screen_sharing && "bg-gray-700 hover:bg-gray-600 text-white"
        ]}
        title={@screen_sharing && "Arrêter le partage" || "Partager l'écran"}
      >
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
        </svg>
      </button>

      <!-- Paramètres -->
      <button
        class="p-4 bg-gray-700 hover:bg-gray-600 text-white rounded-full transition-all shadow-lg hover:scale-110"
        title="Paramètres"
      >
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
      </button>

      <!-- Raccrocher -->
      <button
        id="endCallBtn"
        class="p-4 bg-red-600 hover:bg-red-500 text-white rounded-full transition-all shadow-lg hover:scale-110"
        title="Terminer l'appel"
      >
        <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
          <path d="M2 3a1 1 0 011-1h2.153a1 1 0 01.986.836l.74 4.435a1 1 0 01-.54 1.06l-1.548.773a11.037 11.037 0 006.105 6.105l.774-1.548a1 1 0 011.059-.54l4.435.74a1 1 0 01.836.986V17a1 1 0 01-1 1h-2C7.82 18 2 12.18 2 5V3z" />
        </svg>
      </button>
    </div>
    """
  end
end
