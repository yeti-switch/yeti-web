# frozen_string_literal: true

RSpec.describe 'Index Routing Plans', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    routing_plans = create_list(:routing_plan, 2, :filled)
    visit routing_routing_plans_path
    routing_plans.each do |routing_plan|
      expect(page).to have_css('.resource_id_link', text: routing_plan.id)
    end
  end
end
