use Mix.Config

config :bulk,
  ecto_repos: [Bulk.Repo],
  api_client_id: System.get_env("API_CLIENT_ID"),
  api_client_secret: System.get_env("API_CLIENT_SECRET"),
  token_secret: System.get_env("TOKEN_SECRET")

config :bulk, BulkWeb.Endpoint,
  secret_key_base: System.get_env("APP_SECRET"),
  render_errors: [view: BulkWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Bulk.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :bulk, Bulk.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("DATABASE_URL"),
  pool_size: 10

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env}.exs"
