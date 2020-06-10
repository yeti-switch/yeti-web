# frozen_string_literal: true

RSpec.describe 'Index Routeset Discriminators', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    routeset_discriminators = create_list(:routeset_discriminator, 2)
    visit routing_routeset_discriminators_path
    routeset_discriminators.each do |routeset_discriminator|
      expect(page).to have_css('.resource_id_link', text: routeset_discriminator.id)
    end
  end
end
