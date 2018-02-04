use Mix.Config

config :bulk, token_secret: "123", api_client_id: "456", api_client_secret: "789"
config :bulk, skip_auth: true

config :bulk, BulkWeb.Endpoint,
  http: [port: 4001],
  url: [scheme: "https", host: "testhost", port: 443],
  server: false

config :logger, level: :warn

config :bulk, Bulk.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "bulk_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
