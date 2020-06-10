# frozen_string_literal: true

RSpec.describe 'Index System Lnp Resolvers', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    system_lnp_resolvers = create_list(:lnp_resolver, 2)
    visit system_lnp_resolvers_path
    system_lnp_resolvers.each do |system_lnp_resolver|
      expect(page).to have_css('.resource_id_link', text: system_lnp_resolver.id)
    end
  end
end
