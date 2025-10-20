defmodule TelemedWeb.InstantHTML do
  @moduledoc """
  Rendu des templates pour consultations instantanées.
  """
  use TelemedWeb, :html

  embed_templates "instant_html/*"
end
