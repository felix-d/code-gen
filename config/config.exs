# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :bulk,
  ecto_repos: [Bulk.Repo],
  api_client_id: System.get_env("API_CLIENT_ID"),
  api_client_secret: System.get_env("API_CLIENT_SECRET"),
  token_secret: System.get_env("TOKEN_SECRET")

# Configures the endpoint
config :bulk, BulkWeb.Endpoint,
  secret_key_base: System.get_env("APP_SECRET"),
  render_errors: [view: BulkWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Bulk.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :bulk, Bulk.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("DATABASE_URL"),
  pool_size: 10

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
