require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Olubalance
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Enforce javascript engine (not coffeescript)
    config.generators.javascript_engine = :js

    # Fonts path
    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    # Force schema format to SQL since schema.db doesn't include
    # Postgres views
    config.active_record.schema_format = :sql
  end
end
