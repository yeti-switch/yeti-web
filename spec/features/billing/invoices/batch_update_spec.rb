# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Invoice, :js do
  include_context :login_as_admin
  let!(:account) { create :account }
  let!(:contractor) { create :vendor }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  let!(:type) { Billing::InvoiceType.take || create(:invoice_type, :manual) }
  let!(:state) { Billing::InvoiceState.take || create(:invoice_state) }
  let!(:contractor_vendor) { create :vendor }
  let!(:account_vendor) { create :account, contractor: contractor_vendor }
  let!(:contractor_customer) { create :customer }
  let!(:account_customer) { create :account, contractor: contractor_customer }

  before do
    visit invoices_path
    click_button 'Update batch'
  end

  subject { click_button :OK }

  context 'should check validates for the field:' do
    context '"contractor_id"' do
      context 'should have error:' do
        it 'must be changed together' do
          check :Contractor_id
          select contractor_vendor.name, from: :contractor_id
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be changed together'
        end
      end
    end

    context '"account_id"' do
      context 'should have error:' do
        it 'must be changed together' do
          check :Account_id
          select account_vendor.name, from: :account_id
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be changed together'
        end

        it 'must be owners by selected' do
          check :Contractor
          check :Account_id
          select contractor.name, from: :contractor_id
          select account_vendor.name, from: :account_id
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be owners by selected'
        end
      end

      context 'should have success' do
        let(:changes) { { account_id: account_vendor.id.to_s, contractor_id: contractor_vendor.id.to_s } }
        it 'change value lonely' do
          # preparing
          check :Contractor_id
          select contractor_vendor.name, from: :contractor_id

          check :Account_id
          select account_vendor.name, from: :account_id
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Billing::Invoice', be_present, changes, be_present
        end
      end
    end

    context '"state_id"' do
      let(:changes) { { state_id: state.id.to_s } }
      it 'should change value lonely' do
        check :State_id
        select state.name, from: :state_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Billing::Invoice', be_present, changes, be_present
      end
    end

    context '"start_date" should have error:' do
      before { check :Start_date }
      it "can't be blank" do
        fill_in :start_date, with: nil
        click_button :OK
        expect(page).to have_selector '.flash', text: "can't be blank"
      end

      it 'must be changed together' do
        fill_in :start_date, with: '1993-05-05'
        click_button :OK
        expect(page).to have_selector '.flash', text: 'must be changed together'
      end

      it 'must be before or equal to' do
        date_start = Time.now.utc
        end_date = date_start - 2.days
        check :End_date
        fill_in :start_date, with: date_start.strftime('%Y-%m-%d')
        fill_in :end_date, with: end_date.strftime('%Y-%m-%d')
        click_button :OK
        expect(page).to have_selector '.flash', text: 'must be before or equal to'
      end
    end

    context '"end_date"' do
      before { check :End_date }
      context 'should have error:' do
        it "can't be blank" do
          fill_in :end_date, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
        end

        it 'must be changed together' do
          fill_in :end_date, with: '1993-05-05'
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be changed together'
        end
      end

      context 'should have success' do
        let(:changes) { { start_date: '2020-05-05', end_date: '2020-05-20' } }
        it 'change value end_date and start_date lonely' do
          check :Start_date
          check :End_date
          fill_in :start_date, with: changes[:start_date]
          fill_in :end_date, with: changes[:end_date]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Billing::Invoice', be_present, changes, be_present
        end
      end
    end

    context '"amount"' do
      before { check :Amount }
      context 'should have error:' do
        it "can't be blank" do
          fill_in :amount, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
          expect(page).to have_selector '.flash', text: 'not a number'
        end
      end

      context 'should have success' do
        let(:changes) { { amount: '2' } }
        it 'change value lonely' do
          fill_in :amount, with: 2
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Billing::Invoice', be_present, changes, be_present
        end
      end
    end

    context '"type_id"' do
      let(:changes) { { type_id: type.id.to_s } }
      it 'should change value lonely' do
        check :Type_id
        select type.name, from: :type_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Billing::Invoice', be_present, changes, be_present
      end
    end

    context '"vendor_invoice"' do
      context 'should have error:' do
        it 'must changed together' do
          check :Vendor_invoice
          select :Yes, from: :vendor_invoice
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be changed together with'
        end

        it 'selected Contractor is not a vendor' do
          check :Contractor_id
          check :Account_id
          check :Vendor_invoice
          select contractor_customer.name, from: :contractor_id
          select account_customer.name, from: :account_id
          select :Yes, from: :vendor_invoice
          click_button :OK
          expect(page).to have_selector '.flash', text: 'selected Contractor is not a vendor or choose vendor_invoice in No'
        end
      end

      context 'should have success' do
        it 'should change value lonely' do
          changes = { contractor_id: contractor_vendor.id.to_s, account_id: account_vendor.id.to_s, vendor_invoice: true }
          # preparing
          check :Contractor_id
          check :Account_id
          select contractor_vendor.name, from: :contractor_id
          select account_vendor.name, from: :account_id

          check :Vendor_invoice
          select :Yes, from: :vendor_invoice
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Billing::Invoice', be_present, changes, be_present
        end

        it 'pass because selected "vendor_invoice" into No' do
          changes = { contractor_id: contractor_customer.id.to_s, account_id: account_customer.id.to_s, vendor_invoice: false }
          # preparing
          check :Contractor_id
          check :Account_id
          select contractor_customer.name, from: :contractor_id
          select account_customer.name, from: :account_id

          check :Vendor_invoice
          select :No, from: :vendor_invoice
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Billing::Invoice', be_present, changes, be_present
        end
      end
    end

    it 'all fields should have success' do
      changes = {
        contractor_id: contractor_vendor.id.to_s,
        account_id: account_vendor.id.to_s,
        state_id: state.id.to_s,
        start_date: '2020-01-10',
        end_date: '2020-01-20',
        amount: '20.4',
        type_id: type.id.to_s,
        vendor_invoice: true
      }
      check :Contractor_id
      select contractor_vendor.name, from: :contractor_id

      check :Account_id
      select account_vendor.name, from: :account_id

      check :State_id
      select state.name, from: :state_id

      check :Start_date
      fill_in :start_date, with: changes[:start_date]

      check :End_date
      fill_in :end_date, with: changes[:end_date]

      check :Amount
      fill_in :amount, with: changes[:amount]

      check :Type_id
      select type.name, from: :type_id

      check :Vendor_invoice
      select :Yes, from: :vendor_invoice

      expect do
        subject
        expect(page).to have_selector '.flash', text: success_message
      end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Billing::Invoice', be_present, changes, be_present
    end
  end
end
