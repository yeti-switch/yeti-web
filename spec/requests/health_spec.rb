# frozen_string_literal: true

RSpec.describe 'Kubernetes probes', type: :request do
  let(:configurations) { ActiveRecord::Base.configurations }
  let(:primary_config) { configurations.configs_for(env_name: 'test', name: 'primary') }
  let(:cdr_config) { configurations.configs_for(env_name: 'test', name: 'cdr') }
  # The databases /ready sees are stubbed: the local database.yml may or may not have a replica.
  let(:database_configs) { [primary_config, cdr_config] }

  before do
    allow(configurations).to receive(:configs_for).and_call_original
    allow(configurations).to receive(:configs_for).with(env_name: 'test', include_hidden: true).and_return(database_configs)
  end

  def unreachable(config, name: config.name, host: nil, port: 1)
    hash = config.configuration_hash.merge(port: port)
    hash = hash.merge(host: host) if host
    ActiveRecord::DatabaseConfigurations::HashConfig.new('test', name, hash)
  end

  def stub_required(*names)
    allow(YetiConfig).to receive(:probes).and_return(OpenStruct.new(ready_require_databases: names))
  end

  describe 'GET /live' do
    it 'answers without touching the databases' do
      expect(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter).not_to receive(:new)

      get '/live'

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq('status' => 'ok')
    end
  end

  describe 'GET /ready' do
    it 'answers ok when the databases respond, without touching the application pools' do
      expect(ApplicationRecord.connection_pool).not_to receive(:with_connection)
      expect(Cdr::Base.connection_pool).not_to receive(:with_connection)

      get '/ready'

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq('status' => 'ok', 'databases' => { 'primary' => 'ok', 'cdr' => 'ok' })
    end

    context 'when the CDR database is down' do
      let(:database_configs) { [primary_config, unreachable(cdr_config)] }

      it 'answers 503 naming the database, without the error text' do
        get '/ready'

        expect(response).to have_http_status(:service_unavailable)
        expect(response.parsed_body).to eq('status' => 'error', 'databases' => { 'primary' => 'ok', 'cdr' => 'error' })
        expect(response.body).not_to include('connect')
      end

      it 'answers ok when the CDR database is not required, still reporting it' do
        stub_required('primary')

        get '/ready'

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq('status' => 'ok', 'databases' => { 'primary' => 'ok', 'cdr' => 'error' })
      end

      it 'answers ok when no database is required' do
        stub_required

        get '/ready'

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq('status' => 'ok', 'databases' => { 'primary' => 'ok', 'cdr' => 'error' })
      end
    end

    context 'when the primary database is down' do
      let(:database_configs) { [unreachable(primary_config), cdr_config] }

      it 'answers 503' do
        get '/ready'

        expect(response).to have_http_status(:service_unavailable)
        expect(response.parsed_body['databases']).to eq('primary' => 'error', 'cdr' => 'ok')
      end

      it 'answers ok when the primary database is not required' do
        stub_required('cdr')

        get '/ready'

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['databases']).to eq('primary' => 'error', 'cdr' => 'ok')
      end
    end

    context 'with a CDR replica configured' do
      let(:replica_config) { ActiveRecord::DatabaseConfigurations::HashConfig.new('test', 'cdr_replica', cdr_config.configuration_hash) }
      let(:database_configs) { [primary_config, cdr_config, replica_config] }

      it 'reports it' do
        get '/ready'

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['databases']).to eq('primary' => 'ok', 'cdr' => 'ok', 'cdr_replica' => 'ok')
      end

      context 'when it is down' do
        let(:replica_config) { unreachable(cdr_config, name: 'cdr_replica') }

        it 'answers ok by default' do
          get '/ready'

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['databases']).to eq('primary' => 'ok', 'cdr' => 'ok', 'cdr_replica' => 'error')
        end

        it 'answers 503 when the replica is required' do
          stub_required('primary', 'cdr', 'cdr_replica')

          get '/ready'

          expect(response).to have_http_status(:service_unavailable)
          expect(response.parsed_body['status']).to eq('error')
        end
      end
    end

    context 'when a database host does not answer at all' do
      let(:database_configs) { [primary_config, unreachable(cdr_config, host: '10.255.255.1', port: 5432)] }

      it 'gives up within the check timeout' do
        started = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        get '/ready'

        expect(Process.clock_gettime(Process::CLOCK_MONOTONIC) - started).to be < HealthController::CHECK_TIMEOUT + 1
        expect(response).to have_http_status(:service_unavailable)
        expect(response.parsed_body['databases']['cdr']).to eq('error')
      end
    end
  end

  describe 'request log' do
    let(:appender) { SemanticLogger::Test::CaptureLogEvents.new(level: :info) }

    before { SemanticLogger.add_appender(appender: appender) }

    after { SemanticLogger.remove_appender(appender) }

    def logged_messages
      SemanticLogger.flush
      appender.events.map(&:message)
    end

    it 'does not log the probes' do
      get '/live'
      get '/ready'

      expect(logged_messages).to be_empty
    end

    it 'logs the other requests' do
      get '/liveness'

      expect(logged_messages).to include(a_string_matching(/\A(Started|Completed)/))
    end
  end
end
