# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Contact, :js do
  include_context :login_as_admin
  let!(:_contacts) { create_list :contact, 3 }
  let!(:contractor) { create :contractor, vendor: true }
  let!(:admin_user) { create :admin_user }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  before do
    visit billing_contacts_path
    click_button 'Update batch'
  end

  subject { click_button :OK }

  context 'should check validates for the field:' do
    context '"contractor_id"' do
      let(:changes) { { contractor_id: contractor.id.to_s } }
      it 'should change value and pass validates' do
        check :Contractor_id
        select contractor.name, from: :contractor_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Billing::Contact', be_present, changes, be_present
      end
    end

    context '"admin_user_id"' do
      it 'should change value and pass validates' do
        check :Admin_user_id
        select admin_user.username, from: :admin_user_id
        click_button :OK
        expect(page).to have_selector '.flash', text: success_message
      end
    end

    context '"email"' do
      before { check :Email }
      context 'should have error:' do
        it "can't be blank" do
          fill_in :email, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'must be matched to the following format' do
          fill_in :email, with: 'example.com'
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be matched to the following format john@deer.ua'
        end
      end

      context 'should have success' do
        let(:changes) { { email: 'yeti@gmail.com' } }
        it 'change value lonely' do
          check :Email
          fill_in :email, with: 'yeti@gmail.com'
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Billing::Contact', be_present, changes, be_present
        end
      end
    end

    context '"notes"' do
      let(:changes) { { notes: 'some note' } }
      it 'should change value lonely' do
        check :Notes
        fill_in :notes, with: 'some note'
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Billing::Contact', be_present, changes, be_present
      end
    end

    let(:changes) {
      {
        contractor_id: contractor.id.to_s,
        admin_user_id: admin_user.id.to_s,
        email: 'example@gmail.com',
        notes: 'notes'
      }
    }
    it 'all fields should pass validates' do
      check :Contractor_id
      select contractor.name, from: :contractor_id

      check :Admin_user_id
      select admin_user.username, from: :admin_user_id

      check :Email
      fill_in :email, with: 'example@gmail.com'

      check :Notes
      fill_in :notes, with: 'notes'

      expect do
        subject
        expect(page).to have_selector '.flash', text: success_message
      end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Billing::Contact', be_present, changes, be_present
    end
  end
end
