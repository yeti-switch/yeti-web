# frozen_string_literal: true

RSpec.describe 'Index DNS Records', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    l = create_list(:dns_record, 2)
    visit equipment_dns_records_path
    l.each do |d|
      expect(page).to have_css('.resource_id_link', text: d.id)
    end
  end
end
