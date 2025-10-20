defmodule TelemedWeb.UserLoginLive do
  use TelemedWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Connexion à votre compte
        <:subtitle>
          Pas encore de compte ?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Inscrivez-vous
          </.link>
          dès maintenant.
        </:subtitle>
      </.header>

      <form method="post" action="/users/log_in" class="space-y-4">
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
            Mot de passe
          </label>
          <input
            type="password"
            name="user[password]"
            id="user_password"
            required
            class="mt-2 block w-full rounded-lg border-zinc-300 py-[7px] px-[11px] text-zinc-900 focus:border-zinc-400 focus:outline-none focus:ring-4 focus:ring-zinc-800/5 sm:text-sm sm:leading-6"
          />
        </div>

        <div class="mt-4">
          <label class="flex items-center gap-2 text-sm leading-6 text-zinc-600">
            <input type="checkbox" name="user[remember_me]" value="true" class="rounded border-zinc-300 text-zinc-900 focus:ring-0" />
            <span>Rester connecté</span>
          </label>
        </div>

        <div class="mt-4 flex items-center justify-between gap-6">
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold text-brand hover:underline">
            Mot de passe oublié ?
          </.link>
          <.link navigate={~p"/users/register"} class="text-sm font-semibold text-brand hover:underline">
            Créer un compte
          </.link>
        </div>

        <div class="mt-6">
          <button type="submit" class="w-full rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3 text-sm font-semibold leading-6 text-white active:text-white/80">
            Se connecter <span aria-hidden="true">→</span>
          </button>
        </div>
      </form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [form: nil]}
  end
end
