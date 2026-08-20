# frozen_string_literal: true

require 'yeti_plain_log_formatter'

RSpec.describe YetiPlainLogFormatter do
  subject { described_class.new.call(log, nil) }

  let(:log) do
    SemanticLogger::Log.new('cdr_processor:cdr_billing', level).tap do |log|
      log.message = 'some message'
      log.time = Time.utc(2026, 8, 20, 15, 55, 34, 103_215.5)
    end
  end
  let(:level) { :info }

  it 'keeps the format of the plain Logger that bin/cdr_processor used' do
    expect(subject).to eq('2026-08-20T15:55:34.103215 INFO some message')
  end

  context 'with error level' do
    let(:level) { :error }

    it { is_expected.to eq('2026-08-20T15:55:34.103215 ERROR some message') }
  end

  context 'with payload' do
    before { log.payload = { job: 'SomeJob' } }

    it { is_expected.to eq('2026-08-20T15:55:34.103215 INFO some message {job: "SomeJob"}') }
  end

  context 'with exception' do
    before do
      exception = StandardError.new('some error')
      exception.set_backtrace(['some_file.rb:1'])
      log.exception = exception
    end

    it 'appends the exception and its backtrace' do
      expect(subject).to eq(
        "2026-08-20T15:55:34.103215 INFO some message\nStandardError: some error\nsome_file.rb:1"
      )
    end
  end

  it 'returns a mutable string, SemanticLogger::Appender::IO appends a newline to it' do
    expect(subject).not_to be_frozen
  end
end
