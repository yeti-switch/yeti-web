# frozen_string_literal: true

require 'yeti_log_setup'

RSpec.describe YetiLogSetup do
  let(:elasticsearch_config) do
    OpenStruct.new(
      url: 'http://localhost:9428/insert/elasticsearch',
      index: nil,
      transport_options: { params: { _msg_field: 'message' } }
    )
  end
  let(:logs_config) { OpenStruct.new(tags: { env: 'production', system: 'yeti' }) }

  before do
    stub_const('YetiConfig', OpenStruct.new(elasticsearch: elasticsearch_config, logs: logs_config))
  end

  describe '.add_elasticsearch_appender' do
    subject { described_class.add_elasticsearch_appender(tags: { processor: 'cdr_billing' })&.appender }

    # SemanticLogger.add_appender returns the SemanticLogger::Appender::AsyncBatch wrapper.
    # Stubbed, so that the specs never register a real appender in the global SemanticLogger.
    before do
      allow(SemanticLogger).to receive(:add_appender) do |appender:, **|
        instance_double(SemanticLogger::Appender::AsyncBatch, appender:)
      end
    end

    it 'adds an appender that never raises, so that a broken elasticsearch cannot hang the process' do
      expect(subject).to be_a(YetiElasticsearchAppender)
    end

    it 'batches the records' do
      subject
      expect(SemanticLogger).to have_received(:add_appender).with(hash_including(batch_size: 10))
    end

    it 'uses the url and the transport options of the config' do
      expect(subject.url).to eq('http://localhost:9428/insert/elasticsearch')
      expect(subject.elasticsearch_args[:transport_options]).to include(params: { _msg_field: 'message' })
    end

    it 'adds static tags of the config and the given ones to every record' do
      expect(subject.formatter.static_tags).to eq(env: 'production', system: 'yeti', processor: 'cdr_billing')
    end

    context 'when elasticsearch is not configured' do
      let(:elasticsearch_config) { nil }

      it 'adds no appender' do
        expect(subject).to be_nil
        expect(SemanticLogger).not_to have_received(:add_appender)
      end
    end

    context 'when the elasticsearch url is empty' do
      let(:elasticsearch_config) { OpenStruct.new(url: '', index: nil, transport_options: nil) }

      it 'adds no appender' do
        expect(subject).to be_nil
        expect(SemanticLogger).not_to have_received(:add_appender)
      end
    end
  end

  describe '.call' do
    subject { described_class.call(component: 'cdr_processor', level: 'DEBUG') }

    # let! and not let: the subject changes the level, so a lazy let would first be
    # evaluated by the after hook and restore the changed level to the whole suite.
    let!(:default_level) { SemanticLogger.default_level }

    before do
      allow(SemanticLogger).to receive(:add_appender)
      allow(YetiConfigLoader).to receive(:call)
      YetiLogComponent.reset!
    end

    after do
      SemanticLogger.default_level = default_level
      YetiLogComponent.reset!
    end

    it 'sets the component of the process' do
      subject
      expect(YetiLogComponent.current).to eq('cdr_processor')
    end

    it 'returns the logger of the component' do
      expect(subject.name).to eq('cdr_processor')
    end

    it 'applies the log level of the config' do
      subject
      expect(SemanticLogger.default_level).to eq(:debug)
    end

    context 'when config/yeti_web.yml is missing or invalid' do
      before do
        allow(YetiConfigLoader).to receive(:call).and_raise(YetiConfigLoader::Error, 'config file not found')
      end

      it 'keeps logging to stdout and warns' do
        expect(subject).to be_a(SemanticLogger::Logger)
        expect(SemanticLogger).to have_received(:add_appender).with(hash_including(io: $stdout))
      end
    end

    it 'logs to stdout in the plain format' do
      expect(SemanticLogger).to receive(:add_appender) do |options|
        next unless options.key?(:io)

        expect(options[:io]).to be($stdout)
        expect(options[:formatter]).to be_a(YetiPlainLogFormatter)
      end.twice
      subject
    end
  end
end
