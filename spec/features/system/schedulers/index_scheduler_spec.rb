# frozen_string_literal: true

RSpec.describe 'Index Schedulers', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    ss = create_list(:scheduler, 4)
    visit system_schedulers_path
    ss.each do |s|
      expect(page).to have_css('.resource_id_link', text: s.id)
    end
  end
end
