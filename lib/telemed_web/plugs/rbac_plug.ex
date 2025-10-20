defmodule TelemedWeb.RBACPlug do
  import Plug.Conn
  import Phoenix.Controller

  @roles_by_path %{
    "/dashboard" => ["patient", "doctor", "admin"],
    "/medical_records" => ["doctor", "admin"],
    "/appointments" => ["patient", "doctor", "admin"],
    "/notifications" => ["patient", "doctor", "admin"],
    "/video" => ["patient", "doctor"],
    "/test-camera" => ["patient", "doctor", "admin"]
  }

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_user]
    path = conn.request_path

    # Trouver le(s) rôle(s) autorisé(s) pour ce chemin
    allowed_roles = Enum.find_value(@roles_by_path, fn {prefix, roles} ->
      if String.starts_with?(path, prefix), do: roles, else: nil
    end)

    cond do
      is_nil(user) and allowed_roles ->
        conn
        |> put_flash(:error, "Vous devez être connecté pour accéder à cette page.")
        |> redirect(to: "/")
        |> halt()
      allowed_roles && user.role not in allowed_roles ->
        conn
        |> put_flash(:error, "Accès refusé : rôle insuffisant.")
        |> redirect(to: "/")
        |> halt()
      true ->
        conn
    end
  end
end
