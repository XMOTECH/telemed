defmodule TelemedWeb.DmeComponents do
  @moduledoc """
  Composants pour le Dossier Médical Électronique (DME) v2
  Interface moderne style Discord/Notion
  """
  use Phoenix.Component
  use Gettext, backend: TelemedWeb.Gettext
  alias Telemed.MedicalRecords.MedicalRecord

  @doc """
  Header DME avec avatar patient et quick actions
  """
  attr :patient, :map, required: true
  attr :class, :string, default: ""
  slot :actions

  def dme_header(assigns) do
    ~H"""
    <div class={["bg-white border-b sticky top-0 z-10", @class]}>
      <div class="max-w-7xl mx-auto px-4 py-4">
        <div class="flex items-center justify-between">
          <!-- Patient Info -->
          <div class="flex items-center space-x-4">
            <.patient_avatar patient={@patient} size="lg" />
            <div>
              <h1 class="text-2xl font-bold text-gray-900">
                <%= @patient.first_name %> <%= @patient.last_name %>
              </h1>
              <p class="text-gray-600">
                <%= if @patient.age do %><%= @patient.age %> ans • <% end %>
                <%= if @patient.email do %><%= @patient.email %><% end %>
              </p>
            </div>
          </div>

          <!-- Quick Actions -->
          <div class="flex items-center space-x-3">
            <%= render_slot(@actions) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Avatar patient avec initiales
  """
  attr :patient, :map, required: true
  attr :size, :string, default: "md"  # sm, md, lg

  def patient_avatar(assigns) do
    size_classes = case assigns.size do
      "sm" -> "w-10 h-10 text-sm"
      "md" -> "w-12 h-12 text-base"
      "lg" -> "w-16 h-16 text-2xl"
      _ -> "w-12 h-12 text-base"
    end

    initials = get_initials(assigns.patient)
    assigns = assign(assigns, :size_classes, size_classes)
    assigns = assign(assigns, :initials, initials)

    ~H"""
    <div class={[
      "rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-white font-bold",
      @size_classes
    ]}>
      <%= @initials %>
    </div>
    """
  end

  @doc """
  Barre de recherche avec filtres
  """
  attr :class, :string, default: ""

  def dme_search_bar(assigns) do
    ~H"""
    <div class={["mt-4 flex items-center space-x-3", @class]}>
      <div class="flex-1">
        <div class="relative">
          <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </div>
          <input
            type="search"
            placeholder="🔍 Rechercher dans le dossier... (Ctrl+K)"
            class="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
      </div>

      <div class="flex items-center space-x-2">
        <button class="px-3 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition-colors">
          📅 Tout
        </button>
        <button class="px-3 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
          🩺 Consultations
        </button>
        <button class="px-3 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
          💉 Examens
        </button>
        <button class="px-3 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
          💊 Traitements
        </button>
        <button class="px-3 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
          📋 Rapports
        </button>
      </div>
    </div>
    """
  end

  @doc """
  Item de timeline - Style Discord Message
  """
  attr :record, :map, required: true
  attr :class, :string, default: ""

  def timeline_item(assigns) do
    type_info = MedicalRecord.type_display(assigns.record.consultation_type || "consultation")
    priority_info = MedicalRecord.priority_display(assigns.record.priority || "normal")

    assigns = assign(assigns, :type_info, type_info)
    assigns = assign(assigns, :priority_info, priority_info)

    ~H"""
    <div class={[
      "bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow",
      @class
    ]}>
      <!-- Header -->
      <div class="flex items-start justify-between mb-4">
        <div class="flex items-center space-x-3">
          <div class={"w-10 h-10 rounded-full flex items-center justify-center text-2xl bg-#{@type_info.color}-100"}>
            <%= @type_info.emoji %>
          </div>
          <div>
            <div class="flex items-center space-x-2">
              <h3 class="font-semibold text-gray-900">
                <%= @type_info.label %>
                <%= if @record.specialty do %>
                  • <%= @record.specialty %>
                <% end %>
              </h3>
              <%= if @record.priority && @record.priority != "normal" do %>
                <span class={["px-2 py-1 text-xs rounded-full", @priority_info.badge]}>
                  <%= @priority_info.label %>
                </span>
              <% end %>
            </div>
            <p class="text-sm text-gray-500">
              <%= if @record.created_by_name do %>
                <%= @record.created_by_name %> •
              <% end %>
              <%= format_date(@record.consultation_date || @record.inserted_at) %>
              <%= if @record.duration_minutes do %>
                • <%= @record.duration_minutes %> min
              <% end %>
            </p>
          </div>
        </div>
        <div class="flex items-center space-x-2">
          <button class="p-2 hover:bg-gray-100 rounded transition-colors" title="Copier">
            📋
          </button>
          <button class="p-2 hover:bg-gray-100 rounded transition-colors" title="Partager">
            🔗
          </button>
          <button class="p-2 hover:bg-gray-100 rounded transition-colors" title="Plus">
            ⋯
          </button>
        </div>
      </div>

      <!-- SOAP Tabs -->
      <%= if has_soap_data?(@record) do %>
        <div class="border-t pt-4">
          <.soap_tabs record={@record} />
        </div>
      <% else %>
        <!-- Description classique -->
        <div class="border-t pt-4">
          <p class="text-gray-700"><%= @record.description %></p>
        </div>
      <% end %>

      <!-- Tags -->
      <%= if @record.tags && length(@record.tags) > 0 do %>
        <div class="mt-4 flex flex-wrap gap-2">
          <%= for tag <- @record.tags do %>
            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
              🏷️ <%= tag %>
            </span>
          <% end %>
        </div>
      <% end %>

      <!-- Attachments -->
      <%= if @record.attachments && map_size(@record.attachments) > 0 do %>
        <div class="mt-4 flex items-center space-x-2">
          <div class="px-3 py-2 bg-blue-50 rounded-lg flex items-center space-x-2 text-sm">
            <span class="text-blue-600">📄</span>
            <span class="text-blue-900">Documents joints</span>
            <span class="text-gray-500"><%= map_size(@record.attachments) %></span>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @doc """
  Onglets SOAP interactifs
  """
  attr :record, :map, required: true

  def soap_tabs(assigns) do
    ~H"""
    <div x-data="{ activeTab: 'subjective' }">
      <!-- Tabs Headers -->
      <div class="flex space-x-1 mb-4 border-b">
        <button
          x-on:click="activeTab = 'subjective'"
          x-bind:class="activeTab === 'subjective' ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="px-4 py-2 font-medium text-sm border-b-2 transition-colors"
        >
          S - Symptômes
        </button>
        <button
          x-on:click="activeTab = 'objective'"
          x-bind:class="activeTab === 'objective' ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="px-4 py-2 font-medium text-sm border-b-2 transition-colors"
        >
          O - Examens
        </button>
        <button
          x-on:click="activeTab = 'assessment'"
          x-bind:class="activeTab === 'assessment' ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="px-4 py-2 font-medium text-sm border-b-2 transition-colors"
        >
          A - Diagnostic
        </button>
        <button
          x-on:click="activeTab = 'plan'"
          x-bind:class="activeTab === 'plan' ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="px-4 py-2 font-medium text-sm border-b-2 transition-colors"
        >
          P - Traitement
        </button>
      </div>

      <!-- Tabs Content -->
      <div class="prose max-w-none">
        <div x-show="activeTab === 'subjective'" class="text-gray-700">
          <h4 class="text-sm font-semibold text-gray-900 mb-2">Symptômes rapportés</h4>
          <p><%= @record.soap_subjective || "Non renseigné" %></p>
        </div>

        <div x-show="activeTab === 'objective'" x-cloak class="text-gray-700">
          <h4 class="text-sm font-semibold text-gray-900 mb-2">Examens et observations</h4>
          <p><%= @record.soap_objective || "Non renseigné" %></p>
        </div>

        <div x-show="activeTab === 'assessment'" x-cloak class="text-gray-700">
          <h4 class="text-sm font-semibold text-gray-900 mb-2">Diagnostic et évaluation</h4>
          <p><%= @record.soap_assessment || "Non renseigné" %></p>
        </div>

        <div x-show="activeTab === 'plan'" x-cloak class="text-gray-700">
          <h4 class="text-sm font-semibold text-gray-900 mb-2">Plan de traitement</h4>
          <p><%= @record.soap_plan || "Non renseigné" %></p>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Sidebar avec infos rapides
  """
  attr :patient, :map, required: true
  attr :stats, :map, default: %{}

  def dme_sidebar(assigns) do
    ~H"""
    <div class="space-y-4">
      <!-- Infos rapides -->
      <div class="bg-white rounded-lg shadow-sm border p-4">
        <h3 class="font-semibold text-gray-900 mb-3">📊 Infos rapides</h3>
        <div class="space-y-2 text-sm">
          <div class="flex justify-between">
            <span class="text-gray-600">Allergies</span>
            <span class="font-semibold text-red-600">Aucune connue</span>
          </div>
          <div class="flex justify-between">
            <span class="text-gray-600">Groupe sanguin</span>
            <span class="font-semibold">Non renseigné</span>
          </div>
          <div class="flex justify-between">
            <span class="text-gray-600">Dernière visite</span>
            <span class="font-semibold"><%= format_date(@stats[:last_visit]) %></span>
          </div>
        </div>
      </div>

      <!-- Alertes -->
      <div class="bg-red-50 border border-red-200 rounded-lg p-4">
        <h3 class="font-semibold text-red-900 mb-2">⚠️ Alertes</h3>
        <ul class="text-sm text-red-700 space-y-1">
          <li>• Aucune alerte active</li>
        </ul>
      </div>
    </div>
    """
  end

  # === Helper Functions ===

  defp get_initials(%{first_name: first, last_name: last}) when is_binary(first) and is_binary(last) do
    String.upcase("#{String.first(first)}#{String.first(last)}")
  end
  defp get_initials(%{email: email}) when is_binary(email) do
    email |> String.split("@") |> List.first() |> String.slice(0..1) |> String.upcase()
  end
  defp get_initials(_), do: "?"

  defp format_date(nil), do: "Non renseigné"
  defp format_date(date) when is_struct(date, DateTime) do
    Calendar.strftime(date, "%d/%m/%Y à %H:%M")
  end
  defp format_date(date) when is_struct(date, NaiveDateTime) do
    Calendar.strftime(date, "%d/%m/%Y à %H:%M")
  end
  defp format_date(date) when is_struct(date, Date) do
    Calendar.strftime(date, "%d/%m/%Y")
  end
  defp format_date(_), do: "Date invalide"

  defp has_soap_data?(record) do
    record.soap_subjective || record.soap_objective ||
    record.soap_assessment || record.soap_plan
  end

  @doc """
  Modal générique avec Alpine.js pour DME
  """
  attr :id, :string, required: true
  attr :title, :string, required: true
  attr :class, :string, default: ""
  slot :inner_block, required: true
  slot :actions

  def dme_modal(assigns) do
    ~H"""
    <div
      x-data={"{ open: false, modalId: '#{@id}' }"}
      x-on:open-modal.window="if ($event.detail.id === modalId) open = true"
      x-on:close-modal.window="if ($event.detail.id === modalId) open = false"
      x-show="open"
      x-cloak
      class="fixed inset-0 z-50 overflow-y-auto"
      style="display: none;"
    >
      <!-- Backdrop -->
      <div
        x-show="open"
        x-transition:enter="ease-out duration-300"
        x-transition:enter-start="opacity-0"
        x-transition:enter-end="opacity-100"
        x-transition:leave="ease-in duration-200"
        x-transition:leave-start="opacity-100"
        x-transition:leave-end="opacity-0"
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
        @click="open = false"
      ></div>

      <!-- Modal Content -->
      <div class="flex min-h-full items-center justify-center p-4">
        <div
          x-show="open"
          x-transition:enter="ease-out duration-300"
          x-transition:enter-start="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
          x-transition:enter-end="opacity-100 translate-y-0 sm:scale-100"
          x-transition:leave="ease-in duration-200"
          x-transition:leave-start="opacity-100 translate-y-0 sm:scale-100"
          x-transition:leave-end="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
          class={["relative bg-white rounded-lg shadow-xl max-w-2xl w-full", @class]}
          @click.away="open = false"
        >
          <!-- Header -->
          <div class="px-6 py-4 border-b flex items-center justify-between">
            <h3 class="text-xl font-semibold text-gray-900"><%= @title %></h3>
            <button @click="open = false" class="text-gray-400 hover:text-gray-600">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          <!-- Body -->
          <div class="px-6 py-4">
            <%= render_slot(@inner_block) %>
          </div>

          <!-- Footer -->
          <%= if @actions != [] do %>
            <div class="px-6 py-4 border-t bg-gray-50 flex justify-end space-x-3">
              <%= render_slot(@actions) %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Gestionnaire de tags interactif
  """
  attr :tags, :list, default: []
  attr :record_id, :integer, required: true

  def tag_manager(assigns) do
    tags_json = Jason.encode!(assigns.tags)
    assigns = Map.put(assigns, :tags_json, tags_json)

    ~H"""
    <div x-data={"{
      tags: #{@tags_json},
      newTag: '',
      addTag() {
        if (this.newTag.trim()) {
          this.tags.push(this.newTag.trim());
          this.newTag = '';
        }
      },
      removeTag(index) {
        this.tags.splice(index, 1);
      }
    }"} class="space-y-3">
      <!-- Tags existants -->
      <div class="flex flex-wrap gap-2">
        <template x-for="(tag, index) in tags">
          <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800">
            <span x-text="tag"></span>
            <button @click="removeTag(index)" class="ml-2 hover:text-blue-600">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </span>
        </template>

        <!-- Placeholder si vide -->
        <span x-show="tags.length === 0" class="text-gray-400 text-sm italic">
          Aucun tag. Ajoutez-en un ci-dessous.
        </span>
      </div>

      <!-- Input pour nouveau tag -->
      <div class="flex space-x-2">
        <input
          x-model="newTag"
          @keydown.enter.prevent="addTag()"
          type="text"
          placeholder="🏷️ Ajouter un tag (Entrée pour valider)"
          class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        />
        <button
          @click="addTag()"
          type="button"
          class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
        >
          ➕ Ajouter
        </button>
      </div>

      <p class="text-xs text-gray-500 mt-2">
        💡 Note : Cette interface permet de visualiser et gérer les tags. La sauvegarde se fait via le formulaire d'édition du dossier.
      </p>
    </div>
    """
  end

  @doc """
  Gestionnaire d'attachments avec upload
  """
  attr :attachments, :map, default: %{}
  attr :record_id, :integer, required: true

  def attachment_manager(assigns) do
    ~H"""
    <div x-data="{
      uploading: false,
      files: [],
      handleFiles(event) {
        const fileList = Array.from(event.target.files || event.dataTransfer.files);
        fileList.forEach(file => {
          this.files.push({
            name: file.name,
            size: (file.size / 1024).toFixed(2) + ' KB',
            type: file.type.includes('image') ? 'image' : 'document'
          });
        });
      }
    }" class="space-y-4">
      <!-- Zone de drop -->
      <div
        @dragover.prevent
        @drop.prevent="handleFiles($event)"
        class="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center hover:border-blue-400 transition-colors cursor-pointer"
      >
        <input
          type="file"
          multiple
          @change="handleFiles($event)"
          class="hidden"
          id={"file-upload-#{@record_id}"}
        />
        <label for={"file-upload-#{@record_id}"} class="cursor-pointer">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
          </svg>
          <p class="mt-2 text-sm text-gray-600">
            <span class="font-semibold text-blue-600 hover:text-blue-500">Cliquez pour uploader</span> ou glissez-déposez
          </p>
          <p class="text-xs text-gray-500 mt-1">PNG, JPG, PDF jusqu'à 10MB</p>
        </label>
      </div>

      <!-- Liste des fichiers -->
      <div x-show="files.length > 0" class="space-y-2">
        <h4 class="font-semibold text-gray-900">Fichiers ajoutés :</h4>
        <template x-for="(file, index) in files">
          <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
            <div class="flex items-center space-x-3">
              <!-- Icon based on type -->
              <div x-show="file.type === 'image'" class="flex-shrink-0">
                <svg class="w-8 h-8 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              </div>
              <div x-show="file.type === 'document'" class="flex-shrink-0">
                <svg class="w-8 h-8 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
                </svg>
              </div>
              <div>
                <p class="text-sm font-medium text-gray-900" x-text="file.name"></p>
                <p class="text-xs text-gray-500" x-text="file.size"></p>
              </div>
            </div>
            <button @click="files.splice(index, 1)" class="text-red-500 hover:text-red-700">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
            </button>
          </div>
        </template>
      </div>
    </div>
    """
  end

  @doc """
  Quick Action Button
  """
  attr :action, :string, required: true  # "consult", "prescription", "share", "tags", "attachments"
  attr :record_id, :integer, required: true
  attr :class, :string, default: ""

  def quick_action_button(assigns) do
    config = case assigns.action do
      "consult" -> %{icon: "🩺", label: "Consultation", classes: "bg-blue-100 text-blue-700 hover:bg-blue-200", modal: "modal-quick-consult"}
      "prescription" -> %{icon: "💊", label: "Prescription", classes: "bg-green-100 text-green-700 hover:bg-green-200", modal: "modal-prescription"}
      "share" -> %{icon: "📤", label: "Partager", classes: "bg-purple-100 text-purple-700 hover:bg-purple-200", modal: "modal-share"}
      "tags" -> %{icon: "🏷️", label: "Tags", classes: "bg-yellow-100 text-yellow-700 hover:bg-yellow-200", modal: "modal-tags"}
      "attachments" -> %{icon: "📎", label: "Fichiers", classes: "bg-gray-100 text-gray-700 hover:bg-gray-200", modal: "modal-attachments"}
      _ -> %{icon: "⚡", label: "Action", classes: "bg-blue-100 text-blue-700 hover:bg-blue-200", modal: "modal-default"}
    end

    modal_id = "#{config.modal}-#{assigns.record_id}"
    assigns = Map.merge(assigns, %{config: config, modal_id: modal_id})

    ~H"""
    <button
      type="button"
      x-data
      @click={"window.dispatchEvent(new CustomEvent('open-modal', { detail: { id: '#{@modal_id}' } }))"}
      class={[
        "inline-flex items-center px-4 py-2 rounded-lg font-medium transition-all shadow-sm hover:shadow-md",
        @config.classes,
        @class
      ]}
    >
      <span class="text-lg mr-2"><%= @config.icon %></span>
      <%= @config.label %>
    </button>
    """
  end
end
