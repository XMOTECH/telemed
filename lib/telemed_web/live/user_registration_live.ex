defmodule TelemedWeb.UserRegistrationLive do
  use TelemedWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Créer un compte
        <:subtitle>
          Déjà inscrit ?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            Connectez-vous
          </.link>
          à votre compte.
        </:subtitle>
      </.header>

      <form method="post" action="/users/register" class="space-y-4">
        <input type="hidden" name="_csrf_token" value={Plug.CSRFProtection.get_csrf_token()} />

        <div>
          <label for="user_email" class="block text-sm font-semibold leading-6 text-zinc-800">
            Email
          </label>
          <input
            type="email"
            name="user[email]"
            id="user_email"
            required
            class="mt-2 block w-full rounded-lg border-zinc-300 py-[7px] px-[11px] text-zinc-900 focus:border-zinc-400 focus:outline-none focus:ring-4 focus:ring-zinc-800/5 sm:text-sm sm:leading-6"
          />
        </div>

        <div>
          <label for="user_password" class="block text-sm font-semibold leading-6 text-zinc-800">
            Mot de passe <span class="text-xs text-zinc-500">(minimum 12 caractères)</span>
          </label>
          <input
            type="password"
            name="user[password]"
            id="user_password"
            required
            minlength="12"
            class="mt-2 block w-full rounded-lg border-zinc-300 py-[7px] px-[11px] text-zinc-900 focus:border-zinc-400 focus:outline-none focus:ring-4 focus:ring-zinc-800/5 sm:text-sm sm:leading-6"
          />
        </div>

        <div>
          <label for="user_role" class="block text-sm font-semibold leading-6 text-zinc-800">
            Rôle
          </label>
          <select
            name="user[role]"
            id="user_role"
            required
            class="mt-2 block w-full rounded-lg border-zinc-300 py-[7px] px-[11px] text-zinc-900 focus:border-zinc-400 focus:outline-none focus:ring-4 focus:ring-zinc-800/5 sm:text-sm sm:leading-6"
          >
            <option value="">Sélectionnez un rôle</option>
            <option value="patient">Patient</option>
            <option value="doctor">Médecin</option>
            <option value="admin">Administrateur</option>
          </select>
        </div>

        <div class="mt-6">
          <button type="submit" class="w-full rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3 text-sm font-semibold leading-6 text-white active:text-white/80">
            Créer un compte
          </button>
        </div>
      </form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
