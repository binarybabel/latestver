require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Latestver
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Include libs from data directory.
    config.enable_dependency_loading = true
    config.autoload_paths << Rails.root.join('data', 'lib')
    config.eager_load_paths << Rails.root.join('data', 'lib')
  end
end
