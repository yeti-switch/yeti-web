# frozen_string_literal: true

RSpec.describe BatchUpdateForm::AreaPrefix, :js do
  include_context :login_as_admin
  let!(:area) { FactoryBot.create :area }
  let!(:_area_prefix) { FactoryBot.create_list :area_prefix, 3 }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  let(:assign_params) { { area_id: area.id.to_s } }

  before do
    visit routing_area_prefixes_path
    click_button 'Update batch'
    expect(page).to have_selector('.ui-dialog')
  end

  subject do
    fill_batch_form
    click_button 'OK'
  end

  let(:fill_batch_form) do
    if assign_params.key? :area_id
      check :Area_id
      select_by_value assign_params[:area_id], from: :area_id
    end
  end

  context 'check validations' do
    context 'when all fields filed with valid values' do
      it 'should pass validations' do
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::AreaPrefix', be_present, assign_params, be_present
      end
    end
  end
end
