# frozen_string_literal: true

RSpec.describe CdrProcessor::Processors::CdrStat do
  subject do
    consumer.perform_batch
  end

  let(:logger) { Logger.new(IO::NULL) }
  let(:config) do
    { 'stored_procedure' => 'switch.async_cdr_statistics' }
  end
  let(:consumer) do
    described_class.new(logger, nil, nil, config)
  end
  let(:expected_sql) do
    "SELECT processed_records FROM #{config['stored_procedure']}()"
  end

  before do
    allow(CdrProcessor::CdrDb.connection).to receive(:select_value).once.with(expected_sql).and_return(return_value)
  end

  context 'when stored_procedure returns 3' do
    let(:return_value) { '3' }

    it 'returns 3' do
      expect(subject).to eq 3
    end
  end

  context 'when stored_procedure returns 0' do
    let(:return_value) { '0' }

    it 'returns -1' do
      expect(subject).to eq(-1)
    end
  end

  context 'when stored_procedure returns null' do
    let(:return_value) { nil }

    it 'returns 0' do
      expect(subject).to eq 0
    end
  end
end
