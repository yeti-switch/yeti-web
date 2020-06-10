# frozen_string_literal: true

RSpec.describe 'Index Log Audit log items', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    audit_log_items = create_list(:audit_log_item, 2)
    visit audit_log_items_path
    audit_log_items.each do |audit_log_item|
      expect(page).to have_css('.resource_id_link', text: audit_log_item.id)
    end
  end
end
