# frozen_string_literal: true

require 'yeti_log_setup'

RSpec.describe YetiLogSetup do
  let(:elasticsearch_config) do
    OpenStruct.new(
      level: elasticsearch_level,
      url: 'http://localhost:9428/insert/elasticsearch',
      index: nil,
      tags: { env: 'production', system: 'yeti' },
      transport_options: { params: { _msg_field: 'message' } }
    )
  end
  let(:elasticsearch_level) { nil }
  let(:stdout_level) { nil }
  let(:logging_config) do
    OpenStruct.new(
      stdout: OpenStruct.new(level: stdout_level),
      elasticsearch: elasticsearch_config
    )
  end

  before do
    stub_const('YetiConfig', OpenStruct.new(logging: logging_config))
  end

  describe '.add_stdout_appender' do
    before { allow(SemanticLogger).to receive(:add_appender) }

    it 'logs to stdout with the given formatter, following the global level' do
      formatter = YetiPlainLogFormatter.new
      described_class.add_stdout_appender(formatter:)
      expect(SemanticLogger).to have_received(:add_appender).with(io: $stdout, formatter:, level: nil)
    end

    it 'accepts a formatter name, as the Rails processes pass' do
      described_class.add_stdout_appender(formatter: :default)
      expect(SemanticLogger).to have_received(:add_appender).with(hash_including(formatter: :default))
    end

    it 'accepts a level of its own' do
      described_class.add_stdout_appender(formatter: :default, level: :error)
      expect(SemanticLogger).to have_received(:add_appender).with(hash_including(level: :error))
    end
  end

  describe '.most_verbose' do
    it 'returns the least severe level, that SemanticLogger indexes lowest' do
      expect(described_class.most_verbose(:error, :info)).to eq(:info)
      expect(described_class.most_verbose('WARN', :fatal)).to eq(:warn)
    end

    it 'ignores the levels that are not configured' do
      expect(described_class.most_verbose(nil, 'error')).to eq(:error)
      expect(described_class.most_verbose(nil, nil)).to be_nil
    end
  end

  describe '.apply_levels!' do
    subject { described_class.apply_levels!(default_level: 'info') }

    let(:stdout_level) { 'error' }
    let(:elasticsearch_level) { 'debug' }
    let(:stdout_appender) { SemanticLogger::Appender::IO.new($stdout) }

    # let! and not let: the subject changes the level, so a lazy let would first be
    # evaluated by the after hook and restore the changed level to the whole suite.
    let!(:default_level) { SemanticLogger.default_level }

    before do
      allow(SemanticLogger).to receive(:appenders).and_return([stdout_appender])
      allow(described_class).to receive(:add_elasticsearch_appender)
    end

    after { SemanticLogger.default_level = default_level }

    it 'sets the global level to the most verbose of the two, so that neither is starved' do
      subject
      expect(SemanticLogger.default_level).to eq(:debug)
    end

    it 'applies the configured level to the stdout appender' do
      subject
      expect(stdout_appender.level).to eq(:error)
    end

    it 'passes the configured level to the elasticsearch appender' do
      subject
      expect(described_class).to have_received(:add_elasticsearch_appender).with(tags: {}, level: :debug)
    end

    context 'when no appender is given a level of its own' do
      let(:stdout_level) { nil }
      let(:elasticsearch_level) { nil }

      it 'falls back to the given default level' do
        subject
        expect(SemanticLogger.default_level).to eq(:info)
      end

      it 'leaves the stdout appender following the global level' do
        subject
        expect(stdout_appender.level).to eq(:trace)
      end
    end

    context 'when the logging block is missing' do
      let(:logging_config) { nil }

      it 'falls back to the given default level' do
        subject
        expect(SemanticLogger.default_level).to eq(:info)
      end
    end
  end

  describe '.add_elasticsearch_appender' do
    subject { described_class.add_elasticsearch_appender(tags: { processor: 'cdr_billing' }, **level)&.appender }

    let(:level) { {} }

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

    it 'follows the global level when it is given none' do
      expect(subject.level).to eq(:trace)
    end

    context 'with a level of its own' do
      let(:level) { { level: :warn } }

      # SemanticLogger::Appender.factory returns an already built Subscriber as it is, so
      # the level has to reach the constructor, not SemanticLogger.add_appender.
      it 'applies it to the appender itself' do
        expect(subject.level).to eq(:warn)
      end
    end

    context 'when elasticsearch is not configured' do
      let(:elasticsearch_config) { nil }

      it 'adds no appender' do
        expect(subject).to be_nil
        expect(SemanticLogger).not_to have_received(:add_appender)
      end
    end

    context 'when the elasticsearch url is empty' do
      let(:elasticsearch_config) { OpenStruct.new(url: '', index: nil, tags: nil, transport_options: nil) }

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

    context 'when config/yeti_web.yml gives the appenders levels of their own' do
      let(:stdout_level) { 'error' }
      let(:elasticsearch_level) { 'info' }

      before { allow(described_class).to receive(:add_elasticsearch_appender) }

      it 'prefers them over the given level' do
        subject
        expect(SemanticLogger.default_level).to eq(:info)
        expect(described_class).to have_received(:add_elasticsearch_appender)
          .with(hash_including(level: :info))
      end
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
