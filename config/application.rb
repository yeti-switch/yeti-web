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
if ENV['SKIP_RAILS_SEMANTIC_LOGGER'] != 'true'
  require 'rails_semantic_logger'
  # require_relative and not require: lib is not on the $LOAD_PATH yet. Inside the guard,
  # because it requires the semantic_logger gem, that is `require: false` in the Gemfile.
  require_relative '../lib/yeti_log_setup'
end
require 'config'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Yeti
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

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
                    customer_v1_jwt_secret = ENV['CUSTOMER_V1_JWT_SECRET']
                    secret_key_base ||= SecureRandom.hex(64) if Rails.env.local?
                    customer_v1_jwt_secret ||= SecureRandom.hex(64) if Rails.env.local?
                    { secret_key_base:, customer_v1_jwt_secret: }
                  end
    config.secrets = ActiveSupport::OrderedOptions.new
    config.secrets.merge!(secrets_cfg)
    delegate :secrets, to: :config # define Rails.application.secrets
    config.secret_key_base = config.secrets.secret_key_base
    raise ArgumentError, "`secret_key_base` for #{Rails.env} environment must be a type of String`" if config.secret_key_base.blank?
    raise ArgumentError, "Missing `secret_key_base` for '#{Rails.env}' environment" if config.secret_key_base.blank?

    if ENV['SKIP_RAILS_SEMANTIC_LOGGER'] != 'true'
      $stdout.sync = true
      config.rails_semantic_logger.semantic = true
      # Static tags (YetiConfig.logging.elasticsearch.tags) are not added here on purpose: log_tags
      # are applied by the rack middleware only, so they would be missing in the
      # logs of delayed_job/scheduler. YetiLogFormatter adds them to every record of
      # the elasticsearch appender instead. The stdout appender logs no static tags at
      # all - the process is identified there by the systemd unit (SyslogIdentifier).
      config.log_tags = {
        request_id: :request_id,
        remote_ip: :remote_ip
      }

      # Every environment logs the same way - to stdout, plus elasticsearch when it is
      # configured, see config/initializers/semantic_logger.rb. Only the test environment
      # keeps the log/test.log file appender instead, to leave the rspec output readable:
      # declaring no appender at all is what leaves rails_semantic_logger building its own.
      #
      # Declared here and not added from an initializer: the gem creates the declared
      # appenders in its :initialize_logger initializer, that runs before
      # config/initializers/*, so that the boot itself is logged as well.
      unless Rails.env.test?
        config.rails_semantic_logger.appenders do |appenders|
          # The level is applied here and not left to the .apply_levels! of
          # config/initializers/semantic_logger.rb: that one runs after the initializers
          # that log the boot, so a `logging.stdout.level` applied only there would let
          # everything they write through first.
          appenders.add(
            **YetiLogSetup.stdout_appender_options(
              formatter: :default,
              level: YetiLogSetup.preloaded_stdout_level
            )
          )
        end
      end
    end
  end
end
