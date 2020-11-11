# frozen_string_literal: true

RSpec.describe 'Create new Routing Plan', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_routing_routing_plan_path
  end

  # TODO: add array of routing groups
  include_context :fill_form, 'new_routing_routing_plan' do
    let(:attributes) do
      {
        name: 'test routing plan',
        use_lnp: true,
        rate_delta_max: 0.11,
        max_rerouting_attempts: 8,
        validate_dst_number_format: true,
        validate_dst_number_network: true
      }
    end

    it 'creates new routing group succesfully' do
      click_on_submit

      expect(page).to have_css('.flash_notice', text: 'Routing plan was successfully created.')

      expect(Routing::RoutingPlan.last).to have_attributes(
        name: attributes[:name]
      )
    end
  end
end
