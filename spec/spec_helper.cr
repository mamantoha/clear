require "spec"

require "../src/clear"

class ::Crypto::Bcrypt::Password
  # Redefine the default cost to 4 (the minimum allowed) to accelerate greatly the tests.
  DEFAULT_COST = 4
end

def initdb
  pg.exec("DROP DATABASE IF EXISTS clear_spec;")
  pg.exec("CREATE DATABASE clear_spec;")

  pg.exec("DROP DATABASE IF EXISTS clear_secondary_spec;")
  pg.exec("CREATE DATABASE clear_secondary_spec;")
  pg.exec("CREATE TABLE models_post_stats (id serial PRIMARY KEY, post_id INTEGER);")

  Clear::SQL.init("postgres://#{postgres_user}:#{postgres_password}@#{postgres_host}/clear_spec", connection_pool_size: 5)
  Clear::SQL.init("secondary", "postgres://#{postgres_user}:#{postgres_password}@#{postgres_host}/clear_secondary_spec", connection_pool_size: 5)

  {% if flag?(:quiet) %} Log.setup(:error) {% else %} Log.setup(:debug) {% end %}
end

def reinit_migration_manager
  Clear::Migration::Manager.instance.reinit!
end

def temporary(&block)
  Clear::SQL.with_savepoint do
    yield
    Clear::SQL.rollback
  end
end

def postgres_user
  ENV["POSTGRES_USER"]? || "postgres"
end

def postgres_password
  ENV["POSTGRES_PASSWORD"]? || ""
end

def postgres_host
  ENV["POSTGRES_HOST"]? || "localhost"
end

def postgres_db
  ENV["POSTGRES_DB"]? || "postgres"
end

def pg
  DB.open("postgres://#{postgres_user}:#{postgres_password}@#{postgres_host}/#{postgres_db}")
end

initdb
