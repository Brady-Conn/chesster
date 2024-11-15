import Config

# Configure your database
config :chesster, Chesster.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "chesster_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10


# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
