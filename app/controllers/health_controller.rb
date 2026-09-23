# frozen_string_literal: true

# Kubernetes probes. Unauthenticated, drawn before the 404 catch-all, silenced in
# the request log (see config/application.rb).
#
#   GET /live  - the process serves requests. Checks no dependency, so a database
#                outage does not get the pods restarted in a loop.
#   GET /ready - the databases answer, so the pod may receive traffic. Every
#                database is checked and reported; probes.ready_requires in
#                config/yeti_web.yml says which of them answer 503 when down.
class HealthController < ActionController::API
  READY_REQUIRES = { primary: true, cdr: true, cdr_replica: false }.freeze

  def live
    render json: { status: 'ok' }
  end

  def ready
    databases = connection_pools.transform_values { |pool| database_status(pool) }
    ok = required_databases.all? { |name| databases.fetch(name, 'ok') == 'ok' }
    render json: { status: ok ? 'ok' : 'error', databases: databases }, status: ok ? :ok : :service_unavailable
  end

  private

  def connection_pools
    pools = { primary: ApplicationRecord.connection_pool, cdr: Cdr::Base.connection_pool }
    replica_pool = Cdr::Base.replica_connection_pool
    pools[:cdr_replica] = replica_pool if replica_pool
    pools
  end

  def required_databases
    configured = YetiConfig.probes&.ready_requires&.to_h&.transform_keys(&:to_sym) || {}
    READY_REQUIRES.merge(configured).select { |_, required| required }.keys
  end

  # The reason is logged, not returned: the endpoint is public and a connection
  # error names the database host.
  def database_status(pool)
    pool.with_connection { |connection| connection.select_value('SELECT 1') }
    'ok'
  rescue StandardError => e
    Rails.logger.error { "readiness: #{pool.db_config.name} database check failed: #{e.class}: #{e.message}" }
    'error'
  end
end
