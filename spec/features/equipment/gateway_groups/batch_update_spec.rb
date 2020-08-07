# frozen_string_literal: true

RSpec.describe BatchUpdateForm::GatewayGroup, :js do
  include_context :login_as_admin
  let!(:_gateway_groups) { FactoryBot.create_list :gateway_group, 3 }
  let!(:vendor) { FactoryBot.create :vendor }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  let(:assign_params) { { vendor_id: vendor.id.to_s } }

  before do
    visit gateway_groups_path
    click_button 'Update batch'
    expect(page).to have_selector('.ui-dialog')
  end

  let(:fill_batch_form) do
    if assign_params.key? :vendor_id
      check :Vendor_id
      select_by_value assign_params[:vendor_id], from: :vendor_id
    end
  end

  subject do
    fill_batch_form
    click_button 'OK'
  end

  context 'when all field filled with valid values' do
    it 'should pass validation' do
      expect do
        subject
        expect(page).to have_selector '.flash', text: success_message
      end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'GatewayGroup', be_present, assign_params, be_present
    end
  end
end
