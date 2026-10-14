# frozen_string_literal: true

# Kubernetes probes: GET /live and GET /ready. Unauthenticated, not logged.
class HealthController < ActionController::API
  READY_REQUIRE_DATABASES = %w[primary cdr].freeze
  CONNECT_TIMEOUT = 2
  CHECK_TIMEOUT = 3
  CONNECTION_PARAM_KEYS = (PG::Connection.conndefaults_hash.keys + [:requiressl]).freeze

  def live
    render json: { status: 'ok' }
  end

  def ready
    checks = database_configs.map { |config| [config.name, Thread.new { database_status(config) }] }
    databases = checks.to_h { |name, thread| [name, thread.value] }
    ok = required_databases.all? { |name| databases[name] == 'ok' }
    render json: { status: ok ? 'ok' : 'error', databases: databases }, status: ok ? :ok : :service_unavailable
  end

  private

  def database_configs
    ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, include_hidden: true)
  end

  def required_databases
    (YetiConfig.probes&.ready_require_databases || READY_REQUIRE_DATABASES).map(&:to_s)
  end

  # A bare PG connection of its own, bounded by CHECK_TIMEOUT: the application pools may be
  # busy or hang on an unreachable host for minutes, and an AR adapter would spend ~10 round
  # trips (SETs, type map) before the probe query. CONNECT_TIMEOUT is below CHECK_TIMEOUT so
  # libpq gives up first and closes its own socket. The reason is logged, not returned - the
  # endpoint is public and a connection error names the host.
  def database_status(config)
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    stage = 'connect'
    connection = nil
    Timeout.timeout(CHECK_TIMEOUT) do
      connection = PG.connect(**connection_params(config))
      stage = 'query'
      connection.exec('SELECT 1')
    end
    'ok'
  rescue StandardError => e
    elapsed = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started).round(3)
    Rails.logger.error do
      "readiness: #{config.name} database check failed at #{stage} after #{elapsed}s: #{e.class}: #{e.message}"
    end
    'error'
  ensure
    connection&.close
  end

  def connection_params(config)
    params = config.configuration_hash.compact
    params[:user] = params.delete(:username) if params.key?(:username)
    params[:dbname] = params.delete(:database) if params.key?(:database)
    params.slice(*CONNECTION_PARAM_KEYS).merge(connect_timeout: CONNECT_TIMEOUT)
  end
end
