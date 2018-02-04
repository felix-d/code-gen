use Mix.Config

config :bulk, BulkWeb.Endpoint,
  load_from_system_env: true,
  url: [scheme: "https", host: System.get_env("HOST"), port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :bulk, skip_auth: false
config :logger, level: :debug
