defmodule TelemedWeb.UserLoginLive do
  use TelemedWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-blue-200">
      <div class="bg-white shadow-lg rounded-lg p-8 w-full max-w-md">
        <h2 class="text-2xl font-bold mb-6 text-center text-blue-700">Connexion</h2>
        <.form for={@form} phx-submit="save" class="space-y-4">
          <.input field={@form[:email]} type="email" label="Email" class="w-full" />
          <.input field={@form[:password]} type="password" label="Mot de passe" class="w-full" />
          <div class="flex items-center justify-between">
            <label class="flex items-center">
              <input type="checkbox" name="user[remember_me]" class="mr-2" />
              <span class="text-sm">Se souvenir de moi</span>
            </label>
            <.link patch={~p"/users/reset_password"} class="text-sm text-blue-600 hover:underline">Mot de passe oublié ?</.link>
          </div>
          <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 rounded transition">Se connecter</button>
        </.form>
        <p class="mt-6 text-center text-sm">
          Pas encore de compte ?
          <.link patch={~p"/users/register"} class="text-blue-600 hover:underline">Créer un compte</.link>
        </p>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
