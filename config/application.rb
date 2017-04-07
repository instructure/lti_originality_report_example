# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SimilarityDetectionReferenceTool
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths << Rails.root.join('lib')

    # Set up logging to be the same in all environments but control the level
    # through an environment variable.
    config.log_level = ENV['LOG_LEVEL'] || :debug

    # Don't care if the mailer can't send.
    config.action_mailer.raise_delivery_errors = false
    config.action_mailer.perform_caching = false

    if ENV['RAILS_LOG_TO_STDOUT'].present?
      logger = ActiveSupport::Logger.new(STDOUT)
      logger.formatter = config.log_formatter
      config.logger = ActiveSupport::TaggedLogging.new(logger)
    end

    config.cache_store = :memory_store
    config.cache_store = :redis_store, ENV['REDIS_CACHE_URL'] if ENV['REDIS_CACHE'].present?

    config_path = File.join(Rails.root, 'config', 'canvas_creds.yml')
    if File.exist?(config_path)
      config.canvas_creds = config_for :canvas_creds
    else
      config.canvas_creds = {
        'developer_key' => ENV['CANVAS_DEV_KEY'],
        'developer_secret' => ENV['CANVAS_DEV_SECRET']
      }
    end
  end
end
