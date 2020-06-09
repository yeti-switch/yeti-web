# frozen_string_literal: true

RSpec.describe BatchUpdateForm::AreaPrefix, :js do
  include_context :login_as_admin
  let!(:area) { create :area }
  let!(:_area_prefix) { create_list :area_prefix, 3 }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  before do
    visit routing_area_prefixes_path
    click_button 'Update batch'
  end

  subject { click_button :OK }

  context 'check validations fo field "area_id":' do
    let(:changes) { { area_id: area.id.to_s } }
    it 'must be changed and pass validation' do
      check :Area_id
      select area.name, from: :area_id
      expect do
        subject
        expect(page).to have_selector '.flash', text: success_message
      end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::AreaPrefix', be_present, changes, be_present
    end
  end
end
