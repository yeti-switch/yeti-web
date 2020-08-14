# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Account, :js do
  include_context :login_as_admin
  let!(:_accounts) { FactoryBot.create_list :account, 3 }
  let!(:contractor) { FactoryBot.create :contractor, vendor: true }
  let!(:invoice_template) { FactoryBot.create :invoice_template }
  let(:pg_max_smallint) { Yeti::ActiveRecord::PG_MAX_SMALLINT }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }

  before do
    visit accounts_path
    click_button 'Update batch'
    expect(page).to have_selector('.ui-dialog')
  end

  let(:assign_params) do
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
  end

  let(:fill_batch_form) do
    if assign_params.key? :contractor_id
      check :Contractor_id
      select_by_value assign_params[:contractor_id], from: :contractor_id
    end

    if assign_params.key? :min_balance
      check :Min_balance
      fill_in :min_balance, with: assign_params[:min_balance]
    end

    if assign_params.key? :max_balance
      check :Max_balance
      fill_in :max_balance, with: assign_params[:max_balance]
    end

    if assign_params.key? :vat
      check :Vat
      fill_in :vat, with: assign_params[:vat]
    end

    if assign_params.key? :balance_low_threshold
      check :Balance_low_threshold
      fill_in :balance_low_threshold, with: assign_params[:balance_low_threshold]
    end

    if assign_params.key? :balance_high_threshold
      check :Balance_high_threshold
      fill_in :balance_high_threshold, with: assign_params[:balance_high_threshold]
    end

    if assign_params.key? :destination_rate_limit
      check :Destination_rate_limit
      fill_in :destination_rate_limit, with: assign_params[:destination_rate_limit]
    end

    if assign_params.key? :origination_capacity
      check :Origination_capacity
      fill_in :origination_capacity, with: assign_params[:origination_capacity]
    end

    if assign_params.key? :termination_capacity
      check :Termination_capacity
      fill_in :termination_capacity, with: assign_params[:termination_capacity]
    end

    if assign_params.key? :total_capacity
      check :Total_capacity
      fill_in :total_capacity, with: assign_params[:total_capacity]
    end

    if assign_params.key? :max_call_duration
      check :Max_call_duration
      fill_in :max_call_duration, with: assign_params[:max_call_duration]
    end

    if assign_params.key? :vendor_invoice_period_id
      check :Vendor_invoice_period_id
      select_by_value assign_params[:vendor_invoice_period_id], from: :vendor_invoice_period_id
    end

    if assign_params.key? :customer_invoice_period_id
      check :Customer_invoice_period_id
      select_by_value assign_params[:customer_invoice_period_id], from: :customer_invoice_period_id
    end

    if assign_params.key? :vendor_invoice_template_id
      check :Vendor_invoice_template_id
      select_by_value assign_params[:vendor_invoice_template_id], from: :vendor_invoice_template_id
    end

    if assign_params.key? :customer_invoice_template_id
      check :Customer_invoice_template_id
      select_by_value assign_params[:customer_invoice_template_id], from: :customer_invoice_template_id
    end

    if assign_params.key? :timezone_id
      check :Timezone_id
      select_by_value assign_params[:timezone_id], from: :timezone_id
    end
  end

  subject do
    fill_batch_form
    click_button 'OK'
  end

  context 'should check validates' do
    context 'when "total_capacity" field have wrong float value' do
      let(:assign_params) { { total_capacity: '1.5' } }

      it 'should have error: must be an integer' do
        subject
        expect(page).to have_selector '.flash', text: 'must be an integer'
      end
    end

    context 'when all fields is filled with valid values' do
      it 'should have success message' do
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Account', be_present, assign_params, be_present
      end
    end
  end
end
