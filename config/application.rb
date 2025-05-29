# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
# require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require 'action_mailbox/engine'
# require 'action_text/engine'
require 'action_view/railtie'
# require 'action_cable/engine'
# require 'rails/test_unit/railtie'

# custom
require_relative '../lib/capture_error'
require 'rails_semantic_logger'
require 'config'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Yeti
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # changing defaults
    config.action_view.default_enforce_utf8 = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    #    config.time_zone = ENV['YETI_TZ'] || 'UTC'
    if !ENV['YETI_TZ'].nil?
      config.time_zone = ENV['YETI_TZ']
    else
      begin
        file = File.open('/etc/timezone', 'r')
        data = file.read
        file.close
        config.time_zone = data.delete!("\n")
      rescue StandardError
        config.time_zone = 'UTC'
      end
    end

    active_record_tz = ENV.fetch('YETI_PG_TZ', :utc).to_sym
    config.active_record.default_timezone = active_record_tz

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    config.active_record.schema_format = :sql

    config.active_record.schema_migrations_table_name = 'public.schema_migrations'

    # Controls which database schemas will be dumped when calling db:structure:dump.
    config.active_record.dump_schemas = :all

    config.action_mailer.delivery_method = :smtp

    config.action_mailer.smtp_settings = {
      address: 'smtp.yeti-switch.org',
      port: 25,
      enable_starttls_auto: true,
      openssl_verify_mode: 'none'
    }
    config.action_mailer.default_options = {
      from: 'instance@yeti-switch.org',
      to: 'backtrace@yeti-switch.org'
    }

    config.active_job.queue_adapter = :delayed_job
    config.active_job.enqueue_after_transaction_commit = :never

    # Use RSpec for testing
    config.generators do |g|
      g.test_framework :rspec
      g.integration_tool :rspec
      g.system_tests nil
    end

    # reimplementing minimal Rails.application.secrets, that was removed in Rails 7.2
    # https://github.com/rails/rails/pull/47801
    secrets_yml_path = Rails.root.join('config/secrets.yml')
    secrets_cfg = if secrets_yml_path.exist?
                    config_for(secrets_yml_path)
                  else
                    secret_key_base = ENV['SECRET_KEY_BASE']
                    secret_key_base ||= SecureRandom.hex(64) if Rails.env.local?
                    { secret_key_base: }
                  end
    config.secrets = ActiveSupport::OrderedOptions.new
    config.secrets.merge!(secrets_cfg)
    delegate :secrets, to: :config # define Rails.application.secrets
    config.secret_key_base = config.secrets.secret_key_base
    raise ArgumentError, "`secret_key_base` for #{Rails.env} environment must be a type of String`" if config.secret_key_base.blank?
    raise ArgumentError, "Missing `secret_key_base` for '#{Rails.env}' environment" if config.secret_key_base.blank?

    config.rails_semantic_logger.semantic = false
    config.rails_semantic_logger.format = :default
    config.log_tags = { request_id: :request_id }
  end
end
