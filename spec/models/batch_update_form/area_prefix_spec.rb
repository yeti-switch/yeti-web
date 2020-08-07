# frozen_string_literal: true

RSpec.describe BatchUpdateForm::AreaPrefix do
  let!(:area) { FactoryBot.create :area }
  let!(:assign_params) { { area_id: area.id.to_s } }

  subject do
    form = described_class.new(assign_params)
    form.valid?
    form
  end

  describe 'validation' do
    it 'should be valid' do expect(subject).to be_valid end
  end
end
