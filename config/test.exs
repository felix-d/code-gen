use Mix.Config

config :bulk, skip_auth: true
# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bulk, BulkWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :bulk, Bulk.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "bulk_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
