defmodule TelemedWeb.SettingsHTML do
  use TelemedWeb, :html

  embed_templates "settings_html/*"

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
