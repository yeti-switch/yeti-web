# frozen_string_literal: true

RSpec.describe BatchUpdateForm::GatewayGroup do
  let!(:vendor) { FactoryBot.create :vendor }
  let(:assign_params) { { vendor_id: vendor.id.to_s } }

  subject do
    form = described_class.new(assign_params)
    form.valid?
    form
  end

  describe 'validation' do
    it 'should be valid' do expect(subject).to be_valid end
  end
end
