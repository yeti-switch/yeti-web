# frozen_string_literal: true

require 'capture_error/base_methods'
require 'capture_error/controller_methods'
require 'capture_error/job_methods'

module CaptureError
  EXTRA_VAR_NAME = :@__capture_error_extra

  class << self
    # Checks whether capture error enabled or not
    # @return [TrueClass,FalseClass]
    def enabled?
      Rails.configuration.yeti_web.dig('sentry', 'enabled')
    end

    # Configures Raven gem.
    # Use only once in initializer.
    def configure!
      # require 'raven/base'
      # require 'raven/integrations/rails'
      # require 'raven/integrations/delayed_job'
      require 'sentry-raven-without-integrations'
      require 'raven/integrations/rack'

      Raven.configure do |config|
        config.dsn = Rails.configuration.yeti_web.dig('sentry', 'dsn')
        config.release = Rails.configuration.app_build_info.fetch('version', 'unknown')
        config.current_environment = Rails.configuration.yeti_web.dig('sentry', 'environment')
        config.logger = Rails.logger
        config.sanitize_http_headers = ['Authorization']
        config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
        config.async = ->(event) { Worker::CaptureErrorJob.perform_later(event) }
        config.transport_failure_callback = ->(_event) { raise CaptureError::Errors::SentFailed }
        config.tags = {
          rails_env: Rails.env.to_s,
          node_name: Rails.configuration.yeti_web.dig('sentry', 'node_name')
        }
      end
    end

    # Captures exception if sentry is enabled
    # @param exception [Exception]
    # @param context [Hash] exception context
    def capture(exception, context = {})
      unless enabled?
        Rails.logger.error { 'CaptureError.capture is disabled. Skipping exception.' }
        Rails.logger.error { "<#{exception.class}>: #{exception.message}" }
        return
      end

      extra = retrieve_extra(exception)
      context.deep_merge(extra: extra) if extra.present?
      request_env = context.delete(:request_env)
      if request_env
        Raven::Rack.capture_exception(exception, request_env, context)
      else
        Raven.capture_exception(exception, context)
      end
    end

    # Captures message if sentry is enabled
    # @param message [String]
    # @param context [Hash] message context
    def capture_message(message, context)
      unless enabled?
        Rails.logger.error { "CaptureError.capture_message is disabled. Skipping message #{message.inspect}." }
        return
      end

      request_env = context.delete(:request_env)
      if request_env
        Raven::Rack.capture_message(message, request_env, context)
      else
        Raven.capture_message(message, context)
      end
    end

    # Adds extra data to exception.
    # Will be saved in extra exception context for sentry.
    # @param exception [Exception]
    # @param extra [Hash] extra data for sentry
    def store_extra(exception, extra)
      old_extra = retrieve_extra(exception)
      extra = old_extra.merge(extra) if old_extra.present?
      exception.instance_variable_set(EXTRA_VAR_NAME, extra)
    end

    # Retrieves extra data from exception.
    # Needed to extract stored extra exception context for sentry.
    # @param exception [Exception]
    # @return [Hash] extra data from exception (empty Hash if it's missing)
    def retrieve_extra(exception)
      if exception.instance_variable_defined?(EXTRA_VAR_NAME)
        exception.instance_variable_get(EXTRA_VAR_NAME)
      else
        {}
      end
    end

    # Adds extra data for sentry if code raises within block.
    # @param extra [Hash] extra data for sentry
    def with_extra(extra)
      yield
    rescue StandardError => e
      store_extra(e, extra)
      raise e
    end
  end
end
