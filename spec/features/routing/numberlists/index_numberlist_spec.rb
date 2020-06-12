# frozen_string_literal: true

RSpec.describe 'Index Numberlists', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    numberlists = create_list(:numberlist, 2, :filled)
    visit numberlists_path
    numberlists.each do |numberlist|
      expect(page).to have_css('.resource_id_link', text: numberlist.id)
    end
  end
end
