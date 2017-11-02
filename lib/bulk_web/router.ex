defmodule BulkWeb.Router do
  use BulkWeb, :router
  alias Plug.Conn

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :remove_iframe_header
  end

  defp remove_iframe_header(conn, _params) do
    Conn.delete_resp_header(conn, "x-frame-options")
  end

  scope "/", BulkWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/install", PageController, :install
    get "/auth", PageController, :auth
    get "/info", PageController, :info
    get "/*path", PageController, :index
  end
end
