# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Account, :js do
  include_context :login_as_admin
  let!(:_accounts) { create_list :account, 3 }
  let!(:contractor) { create :contractor, vendor: true }
  let!(:invoice_template) { create :invoice_template }
  let(:pg_max_smallint) { Yeti::ActiveRecord::PG_MAX_SMALLINT }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  before do
    visit accounts_path
    click_button 'Update batch'
  end

  subject { click_button :OK }

  context 'should check validates for the field:' do
    context '"contractor_id"' do
      let(:changes) { { contractor_id: contractor.id.to_s } }
      it 'should changed and have success message' do
        check :Contractor_id
        select contractor.name, from: :contractor_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
      end
    end

    context '"min_balance"' do
      before { check :Min_balance }
      context 'should have error:' do
        it "can't be blank and not a number" do
          fill_in :min_balance, with: nil
          subject
          expect(page).to have_selector '.flash', text: "can't be blank"
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be changed together' do
          fill_in :min_balance, with: 10
          subject
          expect(page).to have_selector '.flash', text: 'must be changed together'
        end
      end

      context 'should have success' do
        let(:changes) { { min_balance: '5', max_balance: '10' } }
        it 'change values lonely' do
          check :Max_balance
          fill_in :min_balance, with: 5
          fill_in :max_balance, with: 10
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
        end
      end
    end

    context '"max_balance"' do
      before { check :Max_balance }
      context 'should have error:' do
        it "can't be blank and not a number and together with 'min_balance'" do
          fill_in :max_balance, with: nil
          subject
          expect(page).to have_selector '.flash', text: "can't be blank"
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be changed together' do
          fill_in :max_balance, with: 10
          subject
          expect(page).to have_selector '.flash', text: 'must be changed together'
        end

        it 'must be greater than or equal to #account.min_balance' do
          check :Min_balance
          fill_in :max_balance, with: 49
          fill_in :min_balance, with: 50
          subject
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to'
        end
      end

      context 'should have success' do
        let(:changes) { { min_balance: '10', max_balance: '10' } }
        it 'change "max_balance" and "min_balance" together with equal value' do
          check :Max_balance
          check :Min_balance
          fill_in :max_balance, with: 10
          fill_in :min_balance, with: 10
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
        end
      end
    end

    context '"vat"' do
      before { check :Vat }
      context 'should have error:' do
        it "can't be blank and is not a number" do
          fill_in :vat, with: nil
          subject
          expect(page).to have_selector '.flash', text: "can't be blank"
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be greater than or equal to zero' do
          fill_in :vat, with: -1
          subject
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to 0'
        end

        it 'less than or equal to 100' do
          fill_in :vat, with: 101
          subject
          expect(page).to have_selector '.flash', text: 'must be less than or equal to 100'
        end
      end

      context 'should have success' do
        let(:changes) { { vat: '50' } }
        it 'change value lonely' do
          fill_in :vat, with: 50
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
        end
      end
    end

    context '"balance_high_threshold"' do
      context 'should have error:' do
        it 'is not a number' do
          check :Balance_high_threshold
          fill_in :balance_high_threshold, with: 'string'
          subject
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be changed together' do
          check :Balance_high_threshold
          fill_in :balance_high_threshold, with: 12
          subject
          expect(page).to have_selector '.flash', text: 'must be changed together'
        end

        it 'must be greater than or equal to' do
          check :Balance_low_threshold
          check :Balance_high_threshold
          fill_in :balance_low_threshold, with: 100
          fill_in :balance_high_threshold, with: 5
          subject
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to'
        end
      end

      it 'should have success with equal value' do
        changes = { balance_low_threshold: '50', balance_high_threshold: '50' }
        check :Balance_low_threshold
        check :Balance_high_threshold
        fill_in :balance_low_threshold, with: 50
        fill_in :balance_high_threshold, with: 50
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
      end
    end

    context '"balance_low_threshold"' do
      context 'should have error:' do
        it 'is not a number' do
          check :Balance_low_threshold
          fill_in :balance_low_threshold, with: 'string'
          subject
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be changed together' do
          check :Balance_low_threshold
          fill_in :balance_low_threshold, with: 12
          subject
          expect(page).to have_selector '.flash', text: 'must be changed together'
        end
      end

      it 'should have success' do
        changes = { balance_low_threshold: '10', balance_high_threshold: '50' }
        check :Balance_low_threshold
        check :Balance_high_threshold
        fill_in :balance_low_threshold, with: 10
        fill_in :balance_high_threshold, with: 50
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
      end
    end

    context '"destination_rate_limit"' do
      before { check :Destination_rate_limit }
      context 'should have error:' do
        it 'is not a number' do
          fill_in :destination_rate_limit, with: 'string'
          subject
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be greater than or equal to zero' do
          fill_in :destination_rate_limit, with: -1
          subject
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to 0'
        end
      end

      context 'should have success' do
        it 'with blank value' do
          changes = { destination_rate_limit: '' }
          fill_in :destination_rate_limit, with: nil
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
        end

        it 'change value lonely' do
          changes = { destination_rate_limit: '5' }
          fill_in :destination_rate_limit, with: 5
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
        end
      end
    end

    context '"origination_capacity"' do
      before { check :Origination_capacity }
      context 'should have error:' do
        it 'is not a number' do
          fill_in :origination_capacity, with: 'string'
          subject
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be greater than zero' do
          fill_in :origination_capacity, with: 0
          subject
          expect(page).to have_selector '.flash', text: 'must be greater than 0'
        end

        it 'must be less than or equal to' do
          fill_in :origination_capacity, with: pg_max_smallint + 1
          subject
          expect(page).to have_selector '.flash', text: "must be less than or equal to #{pg_max_smallint}"
        end

        it 'must be an integer' do
          fill_in :origination_capacity, with: 1.5
          subject
          expect(page).to have_selector '.flash', text: 'must be an integer'
        end
      end

      context 'should have success' do
        it 'with blank value' do
          changes = { origination_capacity: '' }
          fill_in :origination_capacity, with: nil
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
        end

        it 'change value lonely' do
          changes = { origination_capacity: '5' }
          fill_in :origination_capacity, with: 5
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
        end
      end
    end

    context '"termination_capacity"' do
      before { check :Termination_capacity }
      context 'should have error:' do
        it 'must be greater than zero' do
          fill_in :termination_capacity, with: 0
          subject
          expect(page).to have_selector '.flash', text: 'must be greater than 0'
        end

        it 'must be less than or equal' do
          fill_in :termination_capacity, with: pg_max_smallint + 1
          subject
          expect(page).to have_selector '.flash', text: "must be less than or equal to #{pg_max_smallint}"
        end

        it 'is not a number' do
          fill_in :termination_capacity, with: 'string'
          subject
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be an integer' do
          fill_in :termination_capacity, with: 1.5
          subject
          expect(page).to have_selector '.flash', text: 'must be an integer'
        end
      end

      context 'should have success' do
        it 'with blank value' do
          changes = { termination_capacity: '' }
          fill_in :termination_capacity, with: nil
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
        end

        it 'change value lonely' do
          changes = { termination_capacity: '5' }
          fill_in :termination_capacity, with: 5
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
        end
      end
    end

    context '"total_capacity"' do
      before { check :Total_capacity }
      context 'should have error:' do
        it 'is not a number' do
          fill_in :total_capacity, with: 'string'
          subject
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be greater than zero"' do
          fill_in :total_capacity, with: 0
          subject
          expect(page).to have_selector '.flash', text: 'must be greater than 0'
        end

        it 'must be less than or equal to' do
          fill_in :total_capacity, with: pg_max_smallint + 1
          subject
          expect(page).to have_selector '.flash', text: "must be less than or equal to #{pg_max_smallint}"
        end

        it 'must be an integer' do
          fill_in :total_capacity, with: 1.5
          subject
          expect(page).to have_selector '.flash', text: 'must be an integer'
        end
      end

      context 'should have success' do
        it 'with blank value' do
          changes = { total_capacity: '' }
          fill_in :total_capacity, with: nil
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
        end

        it 'change value lonely' do
          changes = { total_capacity: '5' }
          fill_in :total_capacity, with: 5
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
        end
      end
    end

    context '"max_call_duration" should' do
      before { check :Max_call_duration }
      context 'should have error:' do
        it 'is not a number' do
          fill_in :max_call_duration, with: 'string'
          subject
          expect(page).to have_selector '.flash', text: 'is not a number'
        end

        it 'must be greater than zero' do
          fill_in :max_call_duration, with: 0
          subject
          expect(page).to have_selector '.flash', text: 'must be greater than 0'
        end
      end

      let(:changes) { { max_call_duration: '' } }
      it 'should have success with blank value' do
        fill_in :max_call_duration, with: nil
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
      end
    end

    context '"vendor_invoice_period_id"' do
      let(:changes) { { vendor_invoice_period_id: Billing::InvoicePeriod.first!.id.to_s } }
      it 'should change value lonely' do
        check :Vendor_invoice_period_id
        select Billing::InvoicePeriod.first!.name, from: :vendor_invoice_period_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
      end
    end

    context '"customer_invoice_period_id"' do
      let(:changes) { { customer_invoice_period_id: Billing::InvoicePeriod.last!.id.to_s } }
      it 'should change value lonely' do
        check :Customer_invoice_period_id
        select Billing::InvoicePeriod.last!.name, from: :customer_invoice_period_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
      end
    end

    context '"vendor_invoice_template_id"' do
      let(:changes) { { vendor_invoice_template_id: invoice_template.id.to_s } }
      it 'should change value lonely' do
        check :Vendor_invoice_template_id
        select invoice_template.name, from: :vendor_invoice_template_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
      end
    end

    context '"customer_invoice_template_id"' do
      let(:changes) { { customer_invoice_template_id: invoice_template.id.to_s } }
      it 'should change value lonely' do
        check :Customer_invoice_template_id
        select invoice_template.name, from: :customer_invoice_template_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
      end
    end

    context '"timezone_id"' do
      let(:changes) { { timezone_id: System::Timezone.last!.id.to_s } }
      it 'should change value lonely' do
        check :Timezone_id
        select System::Timezone.last!.name, from: :timezone_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
      end
    end

    context 'fill all field' do
      let(:changes) {
        {
          contractor_id: contractor.id.to_s,
          min_balance: '1',
          max_balance: '5',
          vat: '100',
          balance_low_threshold: '2',
          balance_high_threshold: '3',
          destination_rate_limit: '0',
          origination_capacity: pg_max_smallint.to_s,
          termination_capacity: pg_max_smallint.to_s,
          total_capacity: pg_max_smallint.to_s,
          max_call_duration: '1',
          vendor_invoice_period_id: Billing::InvoicePeriod.first!.id.to_s,
          customer_invoice_period_id: Billing::InvoicePeriod.last!.id.to_s,
          vendor_invoice_template_id: invoice_template.id.to_s,
          customer_invoice_template_id: invoice_template.id.to_s,
          timezone_id: System::Timezone.last!.id.to_s
        }
      }

      it 'should have success' do
        check :Contractor_id
        select contractor.name, from: :contractor_id

        check :Min_balance
        fill_in :min_balance, with: 1

        check :Max_balance
        fill_in :max_balance, with: 5

        check :Vat
        fill_in :vat, with: 100

        check :Balance_low_threshold
        fill_in :balance_low_threshold, with: 2

        check :Balance_high_threshold
        fill_in :balance_high_threshold, with: 3

        check :Destination_rate_limit
        fill_in :destination_rate_limit, with: 0

        check :Origination_capacity
        fill_in :origination_capacity, with: pg_max_smallint

        check :Termination_capacity
        fill_in :termination_capacity, with: pg_max_smallint

        check :Total_capacity
        fill_in :total_capacity, with: pg_max_smallint

        check :Max_call_duration
        fill_in :max_call_duration, with: 1

        check :Vendor_invoice_period_id
        select Billing::InvoicePeriod.first!.name, from: :vendor_invoice_period_id

        check :Customer_invoice_period_id
        select Billing::InvoicePeriod.last!.name, from: :customer_invoice_period_id

        check :Vendor_invoice_template_id
        select invoice_template.name, from: :vendor_invoice_template_id

        check :Customer_invoice_template_id
        select invoice_template.name, from: :customer_invoice_template_id

        check :Timezone_id
        select System::Timezone.last!.name, from: :timezone_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, changes, be_present
      end
    end
  end
end
