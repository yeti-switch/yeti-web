# frozen_string_literal: true

RSpec.describe Worker::RateManagementRedetectDialpeers, type: :job do
  subject do
    described_class.perform_now(pricelist_id)
  end

  let(:pricelist_id) { pricelist.id }
  let!(:pricelist) { FactoryBot.create(:rate_management_pricelist, :dialpeers_detected, :with_project) }

  it 'should be perform done' do
    expect(RateManagement::RedetectDialpeers).to receive(:call).with(pricelist: pricelist).once
    subject
  end

  context 'when failure' do
    let(:error) { RateManagement::RedetectDialpeers::Error.new('some error') }

    before do
      allow(RateManagement::RedetectDialpeers).to receive(:call).with(pricelist: pricelist).and_raise(error)
    end

    it 'raises error' do
      expect { subject }.to raise_error(error)
    end
  end

  context 'when pricelist does not exist' do
    let(:pricelist_id) { 999_999_999 }

    it 'does not do anything' do
      expect(RateManagement::RedetectDialpeers).not_to receive(:call)
      subject
    end
  end
end
