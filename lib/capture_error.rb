# frozen_string_literal: true

require_relative 'capture_error/base_methods'
require_relative 'capture_error/controller_methods'
require_relative 'capture_error/job_methods'

module CaptureError
  EXCEPTION_CTX_VAR_NAME = :@__capture_error_context

  class << self
    # Checks whether capture error enabled or not
    # @return [TrueClass,FalseClass]
    def enabled?
      Rails.configuration.yeti_web.dig('sentry', 'enabled')
    end

    # Configures Sentry gem.
    # Use only once in initializer.
    def configure!
      require 'sentry-ruby'
      require 'sentry-rails'

      if defined?(Delayed::Job)
        require 'sentry-delayed_job'
      end

      Sentry.init do |sentry_config|
        sentry_config.dsn = Rails.configuration.yeti_web.dig('sentry', 'dsn')
        sentry_config.release = Rails.configuration.app_build_info.fetch('version', 'unknown')
        sentry_config.environment = Rails.configuration.yeti_web.dig('sentry', 'environment')
        sentry_config.logger = Rails.logger
        sentry_config.inspect_exception_causes_for_exclusion = false

        # use Rails' parameter filter to sanitize the event
        filters = [
          ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters),
          ActiveSupport::ParameterFilter.new(['Authorization'])
        ]
        sentry_config.before_send = lambda { |event, _hint = nil|
          filters.each { |filter| event = filter.filter(event) }
          event
        }

        sentry_config.async = ->(event, hint = nil) { Worker::CaptureErrorJob.perform_later(event, hint) }
        sentry_config.send_default_pii = true
        sentry_config.breadcrumbs_logger = %i[sentry_logger active_support_logger]
        sentry_config.project_root = Rails.root.to_s
        sentry_config.trusted_proxies += Array(Rails.application.config.action_dispatch.trusted_proxies)
      end

      Sentry.set_tags(
        rails_env: Rails.env.to_s,
        node_name: Rails.configuration.yeti_web.dig('sentry', 'node_name')
      )

      # Override method added by Sentry::Rails::ActiveJobExtensions,
      # because we ErrorNotification adds it's own active job extension.
      ActiveSupport.on_load(:active_job) do
        mod = Module.new do
          def already_supported_by_specific_integration?(_)
            true
          end
        end
        ActiveJob::Base.prepend(mod)
      end

      ActiveSupport.on_load :action_controller do
        require 'sentry/rails/controller_transaction'
        include Sentry::Rails::ControllerTransaction
      end

      require 'sentry/rails/background_worker'

      # By default sentry thinks that any private IP address is a trusted proxy,
      # so it can't be real request ip_address.
      # But our admin UI accessible only in private subnet, and only localhost can be a proxy.
      # P.S. it's a proper way to redefine a constant without warning
      Sentry::Utils::RealIp.send(:remove_const, 'LOCAL_ADDRESSES')
      Sentry::Utils::RealIp.const_set 'LOCAL_ADDRESSES', ['127.0.0.1', '::1']
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

      with_capture_context(context, exception: exception) do
        Sentry.capture_exception(exception)
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

      with_capture_context(context) do
        Sentry.capture_message(message)
      end
    end

    # Adds extra data for sentry if code raises within block.
    # @param context [Hash] additional context data for sentry
    def with_exception_context(context)
      yield
    rescue StandardError => e
      store_exception_context(e, context)
      raise e
    end

    # Retrieves extra data from exception.
    # Needed to extract stored extra exception context for sentry.
    # @param exception [Exception]
    # @return [Hash] extra data from exception (empty Hash if it's missing)
    def retrieve_exception_context(exception)
      if exception.instance_variable_defined?(EXCEPTION_CTX_VAR_NAME)
        exception.instance_variable_get(EXCEPTION_CTX_VAR_NAME)
      else
        {}
      end
    end

    # Adds extra data to exception.
    # Will be saved in extra exception context for sentry.
    # @param exception [Exception]
    # @param context [Hash] additional context data for sentry
    def store_exception_context(exception, context)
      old_context = retrieve_exception_context(exception)
      context = old_context.deep_merge(context) if old_context.present?
      exception.instance_variable_set(EXCEPTION_CTX_VAR_NAME, context)
    end

    private

    def with_capture_context(context, exception: nil)
      Sentry.with_scope do |scope|
        apply_exception_context(scope, exception) if exception
        apply_merged_context(scope, context)
        apply_replace_context(scope, context)
        yield
      end
    end

    # Here we add only keys that are replace current values.
    def apply_replace_context(scope, context)
      scope.set_user context[:user] if context[:user]
      scope.set_rack_env context[:rack_env] if context[:rack_env]
      scope.set_span context[:span] if context[:span]
      scope.set_level context[:level] if context[:level]
      scope.set_fingerprint context[:fingerprint] if context[:fingerprint]
    end

    # Here we add only keys that are merges with current values.
    def apply_merged_context(scope, context)
      scope.set_tags context[:tags] if context[:tags]
      scope.set_extras context[:extra] if context[:extra]
      scope.add_breadcrumb context[:breadcrumb] if context[:breadcrumb]
      scope.set_contexts context[:context] if context[:context]
      scope.set_transaction_name context[:transaction] if context[:transaction]
      scope.add_event_processor context[:event_processor] if context[:event_processor]
    end

    def apply_exception_context(scope, exception)
      context = retrieve_exception_context(exception)
      apply_merged_context(scope, context) if context.present?
    end
  end
end
