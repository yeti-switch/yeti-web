# frozen_string_literal: true

require 'spec_helper'

describe 'Index Routing Plan Lnp Rules', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    lnp_routing_plan_lnp_rules = create_list(:lnp_routing_plan_lnp_rule, 2)
    visit lnp_routing_plan_lnp_rules_path
    lnp_routing_plan_lnp_rules.each do |lnp_routing_plan_lnp_rule|
      expect(page).to have_css('.resource_id_link', text: lnp_routing_plan_lnp_rule.id)
    end
  end
end
