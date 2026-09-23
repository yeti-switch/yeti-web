# frozen_string_literal: true

# Kubernetes probes: GET /live and GET /ready. Unauthenticated, not logged.
class HealthController < ActionController::API
  READY_REQUIRES = { 'primary' => true, 'cdr' => true }.freeze
  CHECK_TIMEOUT = 2

  def live
    render json: { status: 'ok' }
  end

  def ready
    databases = database_configs.to_h { |config| [config.name, database_status(config)] }
    required_databases.each { |name| databases[name] ||= 'missing' }
    ok = required_databases.all? { |name| databases[name] == 'ok' }
    render json: { status: ok ? 'ok' : 'error', databases: databases }, status: ok ? :ok : :service_unavailable
  end

  private

  def database_configs
    ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, include_hidden: true)
  end

  def required_databases
    configured = (YetiConfig.probes&.ready_requires&.to_h || {}).transform_keys(&:to_s)
    READY_REQUIRES.merge(configured).select { |_, required| required }.keys
  end

  # A connection of its own, bounded by CHECK_TIMEOUT: the application pools may be busy
  # or hang on an unreachable host for minutes. The reason is logged, not returned - the
  # endpoint is public and a connection error names the host.
  def database_status(config)
    adapter = ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.new(
      config.configuration_hash.merge(connect_timeout: CHECK_TIMEOUT)
    )
    Timeout.timeout(CHECK_TIMEOUT) { adapter.select_value('SELECT 1') }
    'ok'
  rescue StandardError => e
    Rails.logger.error { "readiness: #{config.name} database check failed: #{e.class}: #{e.message}" }
    'error'
  ensure
    adapter&.disconnect!
  end
end
