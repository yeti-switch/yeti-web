# frozen_string_literal: true

require 'yeti_victorialogs_appender'

RSpec.describe YetiVictoriaLogsAppender do
  subject { described_class.new(url: url, formatter: formatter) }

  let(:url) { 'http://127.0.0.1:19999/insert/jsonline?_msg_field=message' }
  let(:formatter) { YetiLogFormatter.new(time_format: :iso_8601, time_key: :timestamp) }

  let(:log) do
    SemanticLogger::Log.new('SomeClass', :info).tap { |log| log.message = 'some message' }
  end

  describe '#initialize' do
    before do
      # WebMock defers the connection of Net::HTTP#start, so the failure of an
      # unreachable VictoriaLogs has to be raised explicitly here.
      allow_any_instance_of(Net::HTTP).to receive(:start).and_raise(Errno::ECONNREFUSED)
    end

    it 'does not raise when VictoriaLogs is unavailable' do
      expect { subject }.not_to raise_error
    end
  end

  context 'when VictoriaLogs is unavailable' do
    before do
      stub_request(:post, url).to_raise(Errno::ECONNREFUSED)
      allow(subject.logger).to receive(:error)
    end

    describe '#batch' do
      it 'discards the records instead of raising' do
        expect { subject.batch([log, log]) }.not_to raise_error
        expect(subject.logger).to have_received(:error)
          .with('VictoriaLogs: 2 log record(s) discarded', kind_of(StandardError))
      end
    end

    describe '#log' do
      it 'discards the record instead of raising' do
        expect { subject.log(log) }.not_to raise_error
        expect(subject.logger).to have_received(:error)
          .with('VictoriaLogs: 1 log record(s) discarded', kind_of(StandardError))
      end
    end
  end

  context 'when the connection was closed while the request was in flight' do
    # Net::HTTP reconnects a connection it knows to be closed, but the peer can close it
    # while the request is written, and it does not retry a POST of its own.
    before do
      stub_request(:post, url).to_raise(EOFError).then.to_return(status: 204)
      allow(subject.logger).to receive(:error)
    end

    it 'retries the batch once on a new connection' do
      expect(subject.batch([log])).to be true
      expect(subject.logger).not_to have_received(:error)
      expect(WebMock).to have_requested(:post, url).twice
    end
  end

  context 'when every attempt hits a closed connection' do
    before do
      stub_request(:post, url).to_raise(EOFError)
      allow(subject.logger).to receive(:error)
    end

    it 'gives up after one retry and discards the records' do
      expect { subject.batch([log]) }.not_to raise_error
      expect(WebMock).to have_requested(:post, url).twice
      expect(subject.logger).to have_received(:error)
        .with('VictoriaLogs: 1 log record(s) discarded', kind_of(StandardError))
    end
  end

  context 'when VictoriaLogs is available' do
    before { stub_request(:post, url).to_return(status: 204) }

    it 'posts newline delimited JSON, keeping the query string of the url' do
      expect(subject.batch([log, log])).to be true

      expect(WebMock).to have_requested(:post, url).with { |request|
        lines = request.body.lines
        lines.size == 2 &&
          lines.all? { |line| line.end_with?("\n") } &&
          JSON.parse(lines.first).values_at('message', 'level') == ['some message', 'info']
      }
    end
  end
end
