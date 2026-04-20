# frozen_string_literal: true

RSpec.describe 'Billing Services Terminate', :js do
  include_context :login_as_admin

  let!(:account) { create(:account) }
  let!(:service_type) { create(:service_type) }
  let!(:record) { create(:service, :renew_daily, account:, type: service_type) }

  before do
    visit service_path(record.id)
  end

  it 'terminates service from show page' do
    accept_confirm { click_action_item 'Terminate' }

    expect(page).to have_flash_message('Service has been terminated.', type: :notice, exact: true)
    expect(record.reload.state_id).to eq(Billing::Service::STATE_ID_TERMINATED)
    expect(page).not_to have_action_item('Edit Services')
  end
end
