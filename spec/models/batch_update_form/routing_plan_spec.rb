# frozen_string_literal: true

RSpec.describe BatchUpdateForm::RoutingPlan do
  let!(:sorting) { Sorting.take || FactoryBot.create(:sorting) }
  let!(:assign_params) do
    {
      sorting_id: sorting.id.to_s,
      use_lnp: 'true',
      rate_delta_max: '2.5'
    }
  end

  subject do
    form = described_class.new(assign_params)
    form.valid?
    form
  end

  describe 'validation' do
    it 'should be valid' do expect(subject).to be_valid end

    # presence
    it { is_expected.to_not allow_value('', ' ').for :rate_delta_max }

    # numericality
    it { is_expected.to validate_numericality_of(:rate_delta_max).is_greater_than_or_equal_to 0 }
    it { is_expected.to allow_value('0.1', '100', '10.5').for :rate_delta_max }
  end
end
