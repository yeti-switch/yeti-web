# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = false

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV['CI'].present?

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.headers = { 'Cache-Control' => "public, max-age=#{1.hour.to_i}" }

  # Show full error reports and disable caching.
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Render exception templates for rescuable exceptions and raise for other exceptions.
  # config.action_dispatch.show_exceptions = :rescuable
  config.action_dispatch.show_exceptions = :none

  # Disable request forgery protection in test environment.
  # config.action_controller.allow_forgery_protection = false
  config.action_controller.allow_forgery_protection = true

  # Disable caching for Action Mailer templates even if Action Controller
  # caching is enabled.
  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Unlike controllers, the mailer instance doesn't have any context about the
  # incoming request so you'll need to provide the :host parameter yourself.
  config.action_mailer.default_url_options = { host: 'www.example.com' }

  # Print deprecation notices to the stderr.
  # config.active_support.deprecation = :stderr
  config.active_support.deprecation = :raise

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  config.active_job.queue_adapter = :test

  config.after_initialize do
    Bullet.enable = true
    # Detect unnecessary COUNT queries which could be avoided
    # with a counter_cache
    Bullet.counter_cache_enable = false
    # Detect eager-loaded associations which are not used
    Bullet.unused_eager_loading_enable = false
    Bullet.n_plus_one_query_enable = true
    Bullet.bullet_logger = true
    Bullet.raise = true
  end

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    STDOUT.sync = true
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end
end
