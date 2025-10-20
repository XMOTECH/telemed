defmodule TelemedWeb.SimpleComponents do
  @moduledoc """
  Composants UI simplifiés sans styles imposés.
  Remplace les CoreComponents par des versions épurées.
  """
  use Phoenix.Component
  use Gettext, backend: TelemedWeb.Gettext

  alias Phoenix.LiveView.JS

  @doc """
  Flash messages simplifiés.
  """
  attr :flash, :map, required: true
  attr :id, :string, default: "flash-group"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} class="fixed top-4 right-4 z-50 space-y-2">
      <.simple_flash kind={:info} flash={@flash} />
      <.simple_flash kind={:error} flash={@flash} />
    </div>
    """
  end

  attr :kind, :atom
  attr :flash, :map

  def simple_flash(assigns) do
    ~H"""
    <div
      :if={msg = Phoenix.Flash.get(@flash, @kind)}
      class={[
        "px-4 py-3 rounded-lg shadow-lg max-w-md",
        @kind == :info && "bg-green-100 text-green-800 border border-green-300",
        @kind == :error && "bg-red-100 text-red-800 border border-red-300"
      ]}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind})}
    >
      <p class="text-sm font-medium">{msg}</p>
    </div>
    """
  end

  @doc """
  Bouton simple.
  """
  attr :type, :string, default: "button"
  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button type={@type} class={@class} {@rest}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Input simple sans styles imposés.
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any, default: nil
  attr :type, :string, default: "text"
  attr :class, :string, default: ""
  attr :field, Phoenix.HTML.FormField, doc: "a form field struct"
  attr :required, :boolean, default: false
  attr :placeholder, :string, default: nil
  attr :errors, :list, default: []
  attr :rest, :global

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(assigns) do
    ~H"""
    <div>
      <label :if={@label} for={@id} class="block mb-1">
        <%= @label %>
      </label>

      <input
        type={@type}
        name={@name}
        id={@id}
        value={@value}
        class={@class}
        {@rest}
      />

      <p :for={error <- @errors || []} class="text-red-600 text-sm mt-1">
        <%= error %>
      </p>
    </div>
    """
  end

  @doc """
  Header simple.
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <div class={@class}>
      <h1><%= render_slot(@inner_block) %></h1>
      <p :if={@subtitle != []}><%= render_slot(@subtitle) %></p>
      <div :if={@actions != []}><%= render_slot(@actions) %></div>
    </div>
    """
  end


  @doc """
  Error simple.
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <div class={@class}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Bouton retour simple.
  """
  attr :navigate, :any, required: true
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <Phoenix.Component.link navigate={@navigate} class={@class}>
      ← <%= render_slot(@inner_block) %>
    </Phoenix.Component.link>
    """
  end

  @doc """
  Simple form wrapper.
  """
  attr :for, :any, required: true
  attr :as, :any, default: nil
  attr :action, :string, default: nil
  attr :method, :string, default: "post"
  attr :rest, :global
  slot :inner_block, required: true
  slot :actions

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <%= render_slot(@inner_block, f) %>
      <div :if={@actions != []} class="mt-4">
        <%= render_slot(@actions, f) %>
      </div>
    </.form>
    """
  end

  @doc """
  Icon héroicon simple.
  """
  attr :name, :string, required: true
  attr :class, :string, default: ""

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  @doc """
  Table simple.
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil
  attr :row_click, :any, default: nil
  slot :col, required: true do
    attr :label, :string
  end
  slot :action

  def table(assigns) do
    ~H"""
    <table class="w-full">
      <thead>
        <tr>
          <th :for={col <- @col} class="text-left p-2">
            <%= col[:label] %>
          </th>
          <th :if={@action != []} class="text-left p-2">Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr :for={row <- @rows} class="border-t">
          <td :for={col <- @col} class="p-2">
            <%= render_slot(col, row) %>
          </td>
          <td :if={@action != []} class="p-2">
            <%= render_slot(@action, row) %>
          </td>
        </tr>
      </tbody>
    </table>
    """
  end

  @doc """
  Modal simple.
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "fixed inset-0 z-50 flex items-center justify-center p-4",
        @show && "block" || "hidden"
      ]}
    >
      <div class="fixed inset-0 bg-black opacity-50" phx-click={@on_cancel}></div>
      <div class="relative bg-white rounded-lg shadow-xl max-w-2xl w-full p-6 z-10">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  @doc """
  Liste simple.
  """
  attr :class, :string, default: ""
  slot :inner_block, required: false
  slot :item do
    attr :title, :string
  end

  def list(assigns) do
    ~H"""
    <ul class={@class}>
      <%= if @inner_block != [], do: render_slot(@inner_block) %>
      <li :for={item <- @item}>
        <strong><%= item.title %>:</strong> <%= render_slot(item) %>
      </li>
    </ul>
    """
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
