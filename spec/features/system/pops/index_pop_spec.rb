# frozen_string_literal: true

RSpec.describe 'Index Pops', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    pops = create_list(:pop, 2, :filled)
    visit pops_path
    pops.each do |pop|
      expect(page).to have_css('.resource_id_link', text: pop.id)
    end
  end
end
