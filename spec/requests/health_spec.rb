# frozen_string_literal: true

RSpec.describe 'Kubernetes probes', type: :request do
  def stub_ready_requires(flags)
    allow(YetiConfig).to receive(:probes).and_return(OpenStruct.new(ready_requires: flags))
  end

  def stub_down(pool)
    allow(pool).to receive(:with_connection).and_raise(PG::ConnectionBad, 'could not connect to server')
  end

  describe 'GET /live' do
    it 'answers without touching the databases' do
      expect(ApplicationRecord.connection_pool).not_to receive(:with_connection)
      expect(Cdr::Base.connection_pool).not_to receive(:with_connection)

      get '/live'

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq('status' => 'ok')
    end
  end

  describe 'GET /ready' do
    it 'answers ok when the databases respond' do
      get '/ready'

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq('status' => 'ok', 'databases' => { 'primary' => 'ok', 'cdr' => 'ok' })
    end

    context 'when the CDR database is down' do
      before { stub_down(Cdr::Base.connection_pool) }

      it 'answers 503 naming the database, without the error text' do
        get '/ready'

        expect(response).to have_http_status(:service_unavailable)
        expect(response.parsed_body).to eq('status' => 'error', 'databases' => { 'primary' => 'ok', 'cdr' => 'error' })
        expect(response.body).not_to include('could not connect')
      end

      context 'when the CDR database is not required' do
        before { stub_ready_requires(cdr: false) }

        it 'answers ok and still reports the CDR database' do
          get '/ready'

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to eq('status' => 'ok', 'databases' => { 'primary' => 'ok', 'cdr' => 'error' })
        end
      end
    end

    context 'when the primary database is down' do
      before { stub_down(ApplicationRecord.connection_pool) }

      it 'answers 503' do
        get '/ready'

        expect(response).to have_http_status(:service_unavailable)
        expect(response.parsed_body['databases']).to eq('primary' => 'error', 'cdr' => 'ok')
      end

      context 'when the primary database is not required' do
        before { stub_ready_requires(primary: false) }

        it 'answers ok' do
          get '/ready'

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['databases']).to eq('primary' => 'error', 'cdr' => 'ok')
        end
      end
    end

    context 'with a CDR replica configured' do
      let(:replica_pool) { instance_double(ActiveRecord::ConnectionAdapters::ConnectionPool) }

      before { allow(Cdr::Base).to receive(:replica_connection_pool).and_return(replica_pool) }

      context 'when it responds' do
        before { allow(replica_pool).to receive(:with_connection).and_yield(double(select_value: 1)) }

        it 'reports it' do
          get '/ready'

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['databases']).to eq('primary' => 'ok', 'cdr' => 'ok', 'cdr_replica' => 'ok')
        end
      end

      context 'when it is down' do
        before do
          allow(replica_pool).to receive(:db_config).and_return(double(name: 'cdr_replica'))
          stub_down(replica_pool)
        end

        it 'answers ok by default: reads fall back to the CDR database' do
          get '/ready'

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['databases']).to eq('primary' => 'ok', 'cdr' => 'ok', 'cdr_replica' => 'error')
        end

        it 'answers 503 when the replica is required' do
          stub_ready_requires(cdr_replica: true)

          get '/ready'

          expect(response).to have_http_status(:service_unavailable)
          expect(response.parsed_body['status']).to eq('error')
        end
      end
    end

    it 'ignores a required database that is not configured' do
      stub_ready_requires(cdr_replica: true)

      get '/ready'

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['databases'].keys).to eq(%w[primary cdr])
    end
  end

  it 'silences the probes in the request log' do
    silencer = Rails.application.middleware.find { |middleware| middleware.klass == Rails::Rack::SilenceRequest }
    path = silencer.args.first[:path]

    expect(path).to match('/live').and match('/ready')
    expect(path).not_to match('/liveness')
  end
end
