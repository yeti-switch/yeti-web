# frozen_string_literal: true

RSpec.shared_context :save_api_logs do
  let(:message) { nil }
  let(:controller) { nil }
  let(:action) { nil }
  let(:path) { nil }
  let(:method) { nil }
  let(:status) { nil }
  let(:tags) { YetiConfig.api_logs.tags || [] }

  before do
    allow(ApiLogger).to receive(:adapter).and_return(api_log_adapter)
  end

  let(:api_log_adapter) { ApiLogger::CONST::DB_ADAPTER }

  it 'should save api_log to db' do
    expect { subject }.to change { Log::ApiLog.count }.by(1)

    api_log = Log::ApiLog.last!
    expect(api_log).to have_attributes(
                         path:,
                         controller:,
                         action:,
                         method:,
                         request_body: nil,
                         request_headers: nil,
                         response_body: nil,
                         response_headers: nil,
                         status:,
                         remote_ip: '0.0.0.0'
                       )
  end

  context 'when api_log adapter is elasticsearch' do
    let(:api_log_adapter) { ApiLogger::CONST::ELASTICSEARCH_ADAPTER }
    let(:capture_logger) { SemanticLogger::Test::CaptureLogEvents.new }

    before do
      allow_any_instance_of(ApiLogger).to receive(:logger).and_return(capture_logger)
    end

    it 'should save api_log to elasticsearch' do
      subject

      expect(capture_logger.events.last).to have_attributes(
                                              level: :info,
                                              message:,
                                              payload: {
                                                meta: nil,
                                                method:,
                                                remote_ip: '0.0.0.0',
                                                status:,
                                                path:,
                                                page_duration: be_present,
                                                db_duration: be_present,
                                                tags:,
                                                controller:,
                                                action:,
                                                params: be_present
                                              }
                                            )
    end
  end

  context 'when api_log adapter is victoralogs' do
    let(:api_log_adapter) { ApiLogger::CONST::VICTORIALOGS_ADAPTER }
    let(:capture_logger) { SemanticLogger::Test::CaptureLogEvents.new }

    before do
      allow_any_instance_of(ApiLogger).to receive(:logger).and_return(capture_logger)
    end

    it 'should save api_log to victoralogs' do
      subject

      expect(capture_logger.events.last).to have_attributes(
                                              level: :info,
                                              message:,
                                              payload: {
                                                meta: nil,
                                                method:,
                                                remote_ip: '0.0.0.0',
                                                status:,
                                                path:,
                                                page_duration: be_present,
                                                db_duration: be_present,
                                                tags:,
                                                controller:,
                                                action:,
                                                params: be_present
                                              }
                                            )
    end
  end
end
