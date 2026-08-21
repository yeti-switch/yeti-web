# frozen_string_literal: true

require 'yeti_log_formatter'

RSpec.describe YetiLogFormatter do
  subject { formatter.call(log, logger) }

  let(:formatter) { described_class.new(time_format: :iso_8601, time_key: :timestamp, static_tags:) }
  let(:static_tags) { { env: 'production', system: 'yeti' } }
  # the formatter is called by an appender, that provides host/application/environment
  let(:logger) { SemanticLogger::Appender::IO.new(StringIO.new) }
  let(:named_tags) { { request_id: 'req-1', remote_ip: '127.0.0.1' } }
  let(:log) do
    SemanticLogger::Log.new('SomeClass', :info).tap do |log|
      log.message = 'some message'
      log.named_tags = named_tags
    end
  end

  before { allow(YetiLogComponent).to receive(:current).and_return('puma') }

  it 'puts named tags on the top level' do
    expect(subject).to include(request_id: 'req-1', remote_ip: '127.0.0.1')
    expect(subject).not_to have_key(:named_tags)
  end

  it 'puts static tags on the top level' do
    expect(subject).to include(env: 'production', system: 'yeti')
  end

  it 'adds component of the process' do
    expect(subject).to include(component: 'puma')
  end

  it 'keeps the fields of the record itself' do
    expect(subject).to include(message: 'some message', level: :info)
  end

  it 'does not emit the logger name' do
    expect(subject).not_to have_key(:name)
  end

  it 'does not emit level_index, it duplicates level' do
    expect(subject).to include(level: :info)
    expect(subject).not_to have_key(:level_index)
  end

  it 'does not emit application and environment, they are configured as static tags' do
    expect(subject).not_to have_key(:application)
    expect(subject).not_to have_key(:environment)
  end

  context 'without named tags' do
    let(:named_tags) { nil }

    it 'still adds static tags and component' do
      expect(subject).to include(env: 'production', system: 'yeti', component: 'puma')
    end
  end

  context 'when a named tag has the same name as a static one' do
    let(:named_tags) { { env: 'staging' } }

    it 'named tag wins' do
      expect(subject).to include(env: 'staging')
    end
  end

  context 'when a tag has the same name as a record field' do
    let(:named_tags) { { message: 'hacked', component: 'hacked', level: 'hacked' } }

    it 'does not overwrite the record field' do
      expect(subject).to include(message: 'some message', component: 'puma', level: :info)
    end
  end
end
