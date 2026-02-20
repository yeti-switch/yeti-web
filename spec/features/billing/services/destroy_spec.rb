# frozen_string_literal: true

RSpec.describe 'Billing Services Destroy' do
  include_context :login_as_admin

  let!(:account) { create(:account) }
  let(:service_type_attrs) { {} }
  let!(:service_type) { create(:service_type, service_type_attrs) }
  let!(:record) { create(:service, :renew_daily, record_attrs) }
  let(:record_attrs) { { name: 'test', account:, type: service_type } }

  describe 'from show page', :js do
    subject { accept_confirm { click_action_item 'Delete Service' } }

    before { visit service_path(record) }

    it 'should be destroyed' do
      subject

      expect(page).to have_flash_message 'Service was successfully destroyed.', exact: true
    end
  end
end
