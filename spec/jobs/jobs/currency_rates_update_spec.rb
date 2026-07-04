# frozen_string_literal: true

RSpec.describe Jobs::CurrencyRatesUpdate, '#call' do
  subject do
    job.call
  end

  let(:job) { described_class.new(double) }

  it 'calls CurrencyRates::Update' do
    expect(CurrencyRates::Update).to receive(:call).once
    subject
  end
end
