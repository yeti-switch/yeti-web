# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Payment, :js do
  include_context :login_as_admin
  let!(:_payments) { create_list :payment, 3 }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  let!(:account) { create :account }
  before do
    visit payments_path
    click_button 'Update batch'
  end

  subject { click_button :OK }

  context 'should check validates for the field:' do
    context 'account_id' do
      let(:changes) { { account_id: account.id.to_s } }
      it 'should change value lonely' do
        check :Account_id
        select account.name, from: :account_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Payment', be_present, changes, be_present
      end
    end

    context '"amount"' do
      context 'should have error:' do
        it "can't be blank and not a number" do
          check :Amount
          fill_in :amount, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
          expect(page).to have_selector '.flash', text: 'not a number'
        end
      end

      context 'should have success' do
        let(:changes) { { amount: '12' } }
        it 'change value lonely' do
          check :Amount
          fill_in :amount, with: changes[:amount]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Payment', be_present, changes, be_present
        end
      end
    end

    context '"notes"' do
      let(:changes) { { notes: 'string' } }
      it 'should change value lonely' do
        check :Notes
        fill_in :notes, with: changes[:notes]
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Payment', be_present, changes, be_present
      end
    end

    it 'should all fields have success message' do
      changes = {
        account_id: account.id.to_s,
        amount: '2.5',
        notes: 'string'
      }
      check :Account_id
      select account.name, from: :account_id

      check :Amount
      fill_in :amount, with: changes[:amount]

      check :Notes
      fill_in :notes, with: changes[:notes]

      expect do
        subject
        expect(page).to have_selector '.flash', text: success_message
      end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Payment', be_present, changes, be_present
    end
  end
end
