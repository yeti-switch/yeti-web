# frozen_string_literal: true

require 'yeti_log_tags'

RSpec.describe YetiLogTags do
  describe '.tagged' do
    subject { described_class.tagged(logger, tags) { SemanticLogger.named_tags } }

    let(:logger) { SemanticLogger['SomeClass'] }
    let(:tags) { { job: 'Jobs::CallsMonitoring', run_id: 'run-1' } }

    it 'tags the records of the block by name' do
      expect(subject).to eq(job: 'Jobs::CallsMonitoring', run_id: 'run-1')
    end

    it 'adds no tag outside of the block' do
      subject
      expect(SemanticLogger.named_tags).to be_blank
    end

    context 'when there is nothing to tag' do
      let(:tags) { {} }

      it { is_expected.to be_blank }
    end

    context 'when there is no logger' do
      let(:logger) { nil }

      it 'yields anyway' do
        expect(described_class.tagged(nil, tags) { :result }).to eq(:result)
      end
    end

    # SKIP_RAILS_SEMANTIC_LOGGER=true, when Rails.logger has no named tags and would
    # inspect the Hash into the line instead.
    context 'when the logger is not a SemanticLogger' do
      subject { described_class.tagged(logger, tags) { logger.formatter.current_tags.dup } }

      let(:logger) { ActiveSupport::TaggedLogging.new(Logger.new(StringIO.new)) }

      it 'tags the values one by one' do
        expect(subject).to eq(['Jobs::CallsMonitoring', 'run-1'])
      end
    end
  end
end
