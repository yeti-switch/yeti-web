# frozen_string_literal: true

RSpec.describe 'Create new Routing Group', type: :feature do
  include_context :login_as_admin

  before do
    visit new_routing_group_path
  end

  include_context :fill_form, 'new_routing_group' do
    let(:attributes) do
      {
        name: 'test routing group'
      }
    end

    it 'creates new routing group succesfully' do
      click_on_submit
      expect(page).to have_css('.flash_notice', text: 'Routing group was successfully created.')

      expect(RoutingGroup.last).to have_attributes(
        name: attributes[:name]
      )
    end
  end
end
