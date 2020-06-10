# frozen_string_literal: true

RSpec.describe 'Create new Routeset discriminators', type: :feature do
  include_context :login_as_admin

  before do
    visit new_routing_routeset_discriminator_path
  end

  include_context :fill_form, 'new_routing_routeset_discriminator' do
    let(:attributes) do
      {
        name: 'test discriminator'
      }
    end

    it 'creates new discriminator succesfully' do
      click_on_submit
      expect(page).to have_css('.flash_notice', text: 'Routeset discriminator was successfully created.')

      expect(Routing::RoutesetDiscriminator.last).to have_attributes(
        name: attributes[:name]
      )
    end
  end
end
