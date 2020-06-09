# frozen_string_literal: true

RSpec.describe BatchUpdateForm::GatewayGroup, :js do
  include_context :login_as_admin
  let!(:_gateway_groups) { create_list :gateway_group, 3 }
  let!(:vendor) { create :vendor }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  before do
    visit gateway_groups_path
    click_button 'Update batch'
  end

  subject { click_button :OK }

  context 'validation check for field:' do
    context 'vendor:' do
      before { check :Vendor_id }
      let(:changes) { { vendor_id: vendor.id.to_s } }
      it 'should pass validation' do
        select vendor.name, from: :vendor_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'GatewayGroup', be_present, changes, be_present
      end
    end
  end
end
