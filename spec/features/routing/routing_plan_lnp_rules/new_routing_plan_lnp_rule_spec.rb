# frozen_string_literal: true

RSpec.describe 'Create new Routing Plan Lnp Rule', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Lnp::RoutingPlanLnpRule, 'new'
  include_context :login_as_admin

  let!(:routing_plan) { FactoryBot.create(:routing_plan) }
  let!(:lnp_database) { FactoryBot.create(:lnp_database, :thinq) }
  before do
    FactoryBot.create(:routing_plan)
    FactoryBot.create(:lnp_database, :thinq)
    visit new_lnp_routing_plan_lnp_rule_path

    aa_form.fill_in_tom_select 'Routing plan', with: routing_plan.name
    aa_form.fill_in_tom_select 'Database', with: lnp_database.name
  end

  it 'creates record' do
    subject
    record = Lnp::RoutingPlanLnpRule.last
    expect(record).to be_present
    expect(record).to have_attributes(
      routing_plan_id: routing_plan.id,
      database_id: lnp_database.id,
      dst_prefix: '',
      req_dst_rewrite_rule: '',
      req_dst_rewrite_result: '',
      lrn_rewrite_rule: '',
      lrn_rewrite_result: '',
      drop_call_on_error: false,
      rewrite_call_destination: false
    )
  end

  include_examples :changes_records_qty_of, Lnp::RoutingPlanLnpRule, by: 1
  include_examples :shows_flash_message, :notice, 'Routing plan lnp rule was successfully created.'
end
