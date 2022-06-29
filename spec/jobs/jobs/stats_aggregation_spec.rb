# frozen_string_literal: true

RSpec.describe Jobs::StatsAggregation, '#call' do
  subject do
    job.call
  end

  let(:job) do
    described_class.new(double)
  end

  it 'calls StatsAggregation services' do
    expect(StatsAggregation::ActiveCall).to receive(:call).once.and_call_original
    expect(StatsAggregation::ActiveCallAccount).to receive(:call).once.and_call_original
    expect(StatsAggregation::ActiveCallOrigGateway).to receive(:call).once.and_call_original
    expect(StatsAggregation::ActiveCallTermGateway).to receive(:call).once.and_call_original
    subject
  end
end
