# frozen_string_literal: true

# The batch-update / schedule-rate-changes UI was built on
# active_admin_scoped_collection_actions, which was removed for the ActiveAdmin 4
# upgrade (the gem has no AA4 support). These specs are the acceptance criteria
# for the reimplementation on AA4 batch actions, so they are kept rather than
# deleted. See doc/activeadmin4_upstream_gaps.md, entry YW-02.
RSpec.describe BatchUpdateForm::Contact, :js, skip: 'awaiting batch-action reimplementation on ActiveAdmin 4 (YW-02)' do
  include_context :login_as_admin
  let!(:_contacts) { FactoryBot.create_list :contact, 3 }
  let!(:contractor) { FactoryBot.create :contractor, vendor: true }
  let!(:admin_user) { FactoryBot.create :admin_user }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }

  before do
    visit billing_contacts_path
    click_button 'Update batch'
    expect(page).to have_selector('.ui-dialog')
  end

  let(:assign_params) do
    {
      contractor_id: contractor.id.to_s,
      admin_user_id: admin_user.id.to_s,
      email: 'example@gmail.com',
      notes: 'notes'
    }
  end

  let(:fill_batch_form) do
    if assign_params.key? :contractor_id
      check :Contractor_id
      select_by_value assign_params[:contractor_id], from: :contractor_id
    end

    if assign_params.key? :admin_user_id
      check :Admin_user_id
      select_by_value assign_params[:admin_user_id], from: :admin_user_id
    end

    if assign_params.key? :email
      check :Email
      fill_in :email, with: assign_params[:email]
    end

    if assign_params.key? :notes
      check :Notes
      fill_in :notes, with: assign_params[:notes]
    end
  end

  subject do
    fill_batch_form
    click_button 'OK'
    confirm_batch_update
  end

  context 'should check validates' do
    context 'when :email field with wrong format' do
      let(:assign_params) { { email: 'text@text' } }

      it 'should have error: must be matched to the following format' do
        subject
        expect(page).to have_selector '.flash', text: I18n.t('activerecord.errors.models.billing\contact.attributes.email')
      end
    end

    context 'when all fields is filled with valid values' do
      it 'should have success message' do
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Billing::Contact', be_present, assign_params, be_present
      end
    end
  end
end
