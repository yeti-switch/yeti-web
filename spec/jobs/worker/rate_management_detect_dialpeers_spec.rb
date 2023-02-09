# frozen_string_literal: true

RSpec.describe Worker::RateManagementDetectDialpeers, type: :job do
  subject do
    described_class.perform_now(pricelist_id)
  end

  let(:pricelist_id) { pricelist.id }
  let!(:pricelist) { FactoryBot.create(:rate_management_pricelist, :with_project) }

  it 'should be perform done' do
    expect(RateManagement::DetectDialpeers).to receive(:call).with(pricelist: pricelist).once
    subject
  end

  context 'when failure' do
    let(:error) { RateManagement::DetectDialpeers::Error.new('some error') }

    before do
      allow(RateManagement::DetectDialpeers).to receive(:call).with(pricelist: pricelist).and_raise(error)
    end

    it 'raises error' do
      expect { subject }.to raise_error(error)
    end
  end

  context 'when pricelist does not exist' do
    let(:pricelist_id) { 999_999_999 }

    it 'does not do anything' do
      expect(RateManagement::DetectDialpeers).not_to receive(:call)
      subject
    end
  end
end
