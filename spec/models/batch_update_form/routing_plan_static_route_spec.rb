# frozen_string_literal: true

RSpec.describe BatchUpdateForm::RoutingPlanStaticRoute do
  let(:pg_max_smallint) { ApplicationRecord::PG_MAX_SMALLINT }
  let(:prefix_err_message) { I18n.t 'activerecord.errors.models.routing\plan_static_route.attributes.prefix.with_spaces' }
  let!(:vendor) { FactoryBot.create :vendor }
  let!(:routing_plan) { FactoryBot.create :routing_plan, :with_static_routes }
  let!(:assign_params) do
    {
      routing_plan_id: routing_plan.id.to_s,
      prefix: '_test',
      priority: '12',
      weight: '123',
      vendor_id: vendor.id.to_s
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
    it { is_expected.to_not allow_value('', ' ').for :priority }
    it { is_expected.to_not allow_value('', ' ').for :weight }

    # numericality
    it { is_expected.to validate_numericality_of(:priority).is_greater_than 0 }
    it { is_expected.to validate_numericality_of(:priority).is_less_than_or_equal_to pg_max_smallint }
    it { is_expected.to validate_numericality_of(:priority).only_integer }
    it { is_expected.to validate_numericality_of(:weight).is_greater_than 0 }
    it { is_expected.to validate_numericality_of(:weight).is_less_than_or_equal_to pg_max_smallint }
    it { is_expected.to validate_numericality_of(:weight).only_integer }

    it { is_expected.to_not allow_value('string test').for(:prefix).with_message(prefix_err_message) }
  end
end
