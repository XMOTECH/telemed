defmodule TelemedWeb.VideoController do
  use TelemedWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
