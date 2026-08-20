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
    subject { described_class.add_elasticsearch_appender(tags: { processor: 'cdr_billing' }) }

    it 'adds the appender with the transport options of the config' do
      expect(SemanticLogger).to receive(:add_appender).with(
        hash_including(
          appender: :elasticsearch,
          url: 'http://localhost:9428/insert/elasticsearch',
          transport_options: { params: { _msg_field: 'message' } }
        )
      )
      subject
    end

    it 'adds static tags of the config and the given ones to every record' do
      expect(SemanticLogger).to receive(:add_appender) do |options|
        expect(options[:formatter].static_tags).to eq(env: 'production', system: 'yeti', processor: 'cdr_billing')
      end
      subject
    end

    context 'when elasticsearch is not configured' do
      let(:elasticsearch_config) { nil }

      it 'adds no appender' do
        expect(SemanticLogger).not_to receive(:add_appender)
        expect(subject).to be_nil
      end
    end
  end

  describe '.call' do
    subject { described_class.call(component: 'cdr_processor', level: 'DEBUG') }

    let(:default_level) { SemanticLogger.default_level }

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
      expect(YetiLogComponent.name).to eq('cdr_processor')
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
