require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups)
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Yeti
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

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
        file = File.open("/etc/timezone", "r")
        data=file.read
        file.close
        config.time_zone=data.delete!("\n")
      rescue
        config.time_zone='UTC'
      end
    end
    p "Timezone #{config.time_zone}"


    config.active_record.default_timezone = :local
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    config.assets.precompile += ['yeti/*']

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

  end
end
