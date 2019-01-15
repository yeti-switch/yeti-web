# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_job/railtie'
# require 'action_cable/engine' # rails 5.0
# require 'active_storage/engine' # rails 5.2
# require 'rails/test_unit/railtie' # rails 4.2
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Yeti
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W[#{config.root}/lib]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]t

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

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
    p "Timezone #{config.time_zone}"

    config.active_record.default_timezone = :local
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

    # SecondBase aims to work seamlessly within your Rails application.
    # When it makes sense, we run a mirrored db:second_base task
    # for matching ActiveRecord base database task.
    # These can all be deactivated by set to "false"
    config.second_base.run_with_db_tasks = false

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
    end
  end
end
