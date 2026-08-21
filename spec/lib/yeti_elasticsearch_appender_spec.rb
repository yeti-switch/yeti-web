# frozen_string_literal: true

require 'yeti_elasticsearch_appender'

RSpec.describe YetiElasticsearchAppender do
  subject { described_class.new(url: 'http://127.0.0.1:19999', index: nil, type: nil) }

  let(:log) do
    SemanticLogger::Log.new('SomeClass', :info).tap { |log| log.message = 'some message' }
  end

  before { allow(subject.logger).to receive(:error) }

  describe '#batch' do
    it 'does not raise when elasticsearch is unavailable' do
      expect { subject.batch([log]) }.not_to raise_error
      expect(subject.logger).to have_received(:error).with('Elasticsearch: 1 log record(s) discarded', kind_of(StandardError))
    end
  end

  describe '#log' do
    it 'does not raise when elasticsearch is unavailable' do
      expect { subject.log(log) }.not_to raise_error
      expect(subject.logger).to have_received(:error).with('Elasticsearch: 1 log record(s) discarded', kind_of(StandardError))
    end
  end
end
