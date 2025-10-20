defmodule TelemedWeb.VideoController do
  use TelemedWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def consultation(conn, _params) do
    render(conn, :consultation)
  end

  def mobile_help(conn, _params) do
    render(conn, :mobile_help)
  end
end
