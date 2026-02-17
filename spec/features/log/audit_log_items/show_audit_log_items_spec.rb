# frozen_string_literal: true

RSpec.describe 'Show Log Audit log items' do
  include_context :login_as_admin

  let!(:service) { create(:service, name: 'service-before-update') }
  let!(:audit_log_item) do
    service.update!(name: 'service-after-update')
    service.versions.last
  end

  it 'renders update entry for models with readonly attributes' do
    visit audit_log_item_path(audit_log_item)

    expect(page).to have_page_title(audit_log_item.id)
    within_panel('Values before event') do
      expect(page).to have_text('service-before-update')
    end
    expect(page).to have_text('service-after-update')
  end
end
