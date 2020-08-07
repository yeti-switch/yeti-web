# frozen_string_literal: true

RSpec.describe BatchUpdateForm::RoutingPlanLnpRule do
  let!(:database) { FactoryBot.create :lnp_database, :thinq }
  let!(:routing_plan) { FactoryBot.create :routing_plan }
  let!(:assign_params) do
    {
      routing_plan_id: routing_plan.id.to_s,
      req_dst_rewrite_rule: 'string 123',
      req_dst_rewrite_result: 'string 123',
      database_id: database.id.to_s,
      lrn_rewrite_rule: 'string 123',
      lrn_rewrite_result: 'string 123'
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
    it { is_expected.to allow_value('', ' ').for :req_dst_rewrite_rule }
    it { is_expected.to allow_value('', ' ').for :req_dst_rewrite_result }
    it { is_expected.to allow_value('', ' ').for :lrn_rewrite_rule }
    it { is_expected.to allow_value('', ' ').for :lrn_rewrite_result }
  end
end
