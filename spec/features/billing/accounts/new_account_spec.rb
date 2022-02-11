# frozen_string_literal: true

RSpec.describe 'Create new Account', type: :feature, js: true do
  subject do
    click_submit('Create Account')
  end

  include_context :login_as_admin
  include_context :timezone_helpers
  let!(:customer) { create(:customer) }
  let!(:vendor) { create(:vendor) }
  let!(:account_time_zone) { ActiveSupport::TimeZone.new(form_params[:timezone].name) }
  let(:before_visit!) {}
  before do
    before_visit!
    visit new_account_path

    fill_in 'Name', with: form_params[:name]
    fill_in_chosen 'Contractor', with: form_params[:contractor].display_name, ajax: true
    fill_in 'Min balance', with: form_params[:min_balance]
    fill_in 'Max balance', with: form_params[:max_balance]
    fill_in 'Vat', with: form_params[:vat]
    fill_in 'Destination rate limit', with: form_params[:destination_rate_limit]
    fill_in 'Max call duration', with: form_params[:max_call_duration]
    fill_in 'Balance low threshold', with: form_params[:balance_low_threshold]
    fill_in 'Balance high threshold', with: form_params[:balance_high_threshold]
    fill_in 'Origination capacity', with: form_params[:origination_capacity]
    fill_in 'Termination capacity', with: form_params[:termination_capacity]
    fill_in 'Total capacity', with: form_params[:total_capacity]
    fill_in_chosen 'Timezone', with: form_params[:timezone].name
  end

  let(:form_params) do
    {
      name: 'Account',
      contractor: customer,
      min_balance: -100,
      max_balance: 100,
      vat: 44.1,
      destination_rate_limit: 0.11,
      max_call_duration: 100_500,
      balance_low_threshold: -90,
      balance_high_threshold: 90,
      origination_capacity: 100,
      termination_capacity: 50,
      total_capacity: 101,
      timezone: la_timezone
    }
  end

  context 'with only required fields' do
    it 'creates new account successfully' do
      subject

      expect(page).to have_flash_message('Account was successfully created.', type: :notice)
      account = Account.last!
      expect(page).to have_current_path account_path(account.id)

      expect(account).to have_attributes(
                           name: form_params[:name],
                           contractor: form_params[:contractor],
                           max_balance: form_params[:max_balance],
                           min_balance: form_params[:min_balance],
                           balance_low_threshold: form_params[:balance_low_threshold],
                           balance_high_threshold: form_params[:balance_high_threshold],
                           destination_rate_limit: form_params[:destination_rate_limit],
                           max_call_duration: form_params[:max_call_duration],
                           origination_capacity: form_params[:origination_capacity],
                           termination_capacity: form_params[:termination_capacity],
                           total_capacity: form_params[:total_capacity],
                           timezone: form_params[:timezone],
                           vendor_invoice_period_id: nil,
                           next_vendor_invoice_at: nil,
                           next_vendor_invoice_type_id: nil,
                           customer_invoice_period_id: nil,
                           next_customer_invoice_at: nil,
                           next_customer_invoice_type_id: nil,
                           customer_invoice_ref_template: '$id',
                           vendor_invoice_ref_template: '$id'
                         )
    end
  end

  context 'with invoice ref templates' do
    let(:form_params) do
      super().merge customer_invoice_ref_template: 'cust-$id',
                    vendor_invoice_ref_template: 'vend-$id'
    end
    before do
      fill_in 'Customer invoice ref template', with: form_params[:customer_invoice_ref_template]
      fill_in 'Vendor invoice ref template', with: form_params[:vendor_invoice_ref_template]
    end

    it 'creates new account successfully' do
      subject

      expect(page).to have_flash_message('Account was successfully created.', type: :notice)
      account = Account.last!
      expect(page).to have_current_path account_path(account.id)

      expect(account).to have_attributes(
                           name: form_params[:name],
                           contractor: form_params[:contractor],
                           max_balance: form_params[:max_balance],
                           min_balance: form_params[:min_balance],
                           balance_low_threshold: form_params[:balance_low_threshold],
                           balance_high_threshold: form_params[:balance_high_threshold],
                           destination_rate_limit: form_params[:destination_rate_limit],
                           max_call_duration: form_params[:max_call_duration],
                           origination_capacity: form_params[:origination_capacity],
                           termination_capacity: form_params[:termination_capacity],
                           total_capacity: form_params[:total_capacity],
                           timezone: form_params[:timezone],
                           vendor_invoice_period_id: nil,
                           next_vendor_invoice_at: nil,
                           next_vendor_invoice_type_id: nil,
                           customer_invoice_period_id: nil,
                           next_customer_invoice_at: nil,
                           next_customer_invoice_type_id: nil,
                           customer_invoice_ref_template: form_params[:customer_invoice_ref_template],
                           vendor_invoice_ref_template: form_params[:vendor_invoice_ref_template]
                         )
    end
  end

  context 'with customer invoice period' do
    let(:invoice_period) { Billing::InvoicePeriod.find Billing::InvoicePeriod::WEEKLY_ID }

    before do
      expect(BillingInvoice::CalculatePeriod::Current).to receive(:call)
        .with(account: a_kind_of(Account), is_vendor: false)
        .and_return(
          end_time: account_time_zone.parse('2020-01-06 00:00:00'),
          type_id: Billing::InvoiceType::AUTO_FULL
        )

      fill_in_chosen 'Customer invoice period', with: invoice_period.name, exact: true
    end

    it 'creates new account successfully' do
      subject

      expect(page).to have_flash_message('Account was successfully created.', type: :notice)
      account = Account.last!
      expect(page).to have_current_path account_path(account.id)

      expect(account).to have_attributes(
                           name: form_params[:name],
                           contractor: form_params[:contractor],
                           max_balance: form_params[:max_balance],
                           min_balance: form_params[:min_balance],
                           balance_low_threshold: form_params[:balance_low_threshold],
                           balance_high_threshold: form_params[:balance_high_threshold],
                           destination_rate_limit: form_params[:destination_rate_limit],
                           max_call_duration: form_params[:max_call_duration],
                           origination_capacity: form_params[:origination_capacity],
                           termination_capacity: form_params[:termination_capacity],
                           total_capacity: form_params[:total_capacity],
                           timezone: form_params[:timezone],
                           vendor_invoice_period_id: nil,
                           next_vendor_invoice_at: nil,
                           next_vendor_invoice_type_id: nil,
                           customer_invoice_period_id: Billing::InvoicePeriod::WEEKLY_ID,
                           next_customer_invoice_at: account_time_zone.parse('2020-01-06 00:00:00'),
                           next_customer_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                           customer_invoice_ref_template: '$id',
                           vendor_invoice_ref_template: '$id'
                         )
    end
  end

  context 'with vendor invoice period' do
    let(:form_params) { super().merge contractor: vendor }
    let(:invoice_period) { Billing::InvoicePeriod.find Billing::InvoicePeriod::WEEKLY_SPLIT_ID }

    before do
      expect(BillingInvoice::CalculatePeriod::Current).to receive(:call)
        .with(account: a_kind_of(Account), is_vendor: true)
        .and_return(
          end_time: account_time_zone.parse('2020-01-02 00:00:00'),
          type_id: Billing::InvoiceType::AUTO_PARTIAL
        )

      fill_in_chosen 'Vendor invoice period', with: invoice_period.name, exact: true
    end

    it 'creates new account successfully' do
      subject

      expect(page).to have_flash_message('Account was successfully created.', type: :notice)
      account = Account.last!
      expect(page).to have_current_path account_path(account.id)

      expect(account).to have_attributes(
                           name: form_params[:name],
                           contractor: form_params[:contractor],
                           max_balance: form_params[:max_balance],
                           min_balance: form_params[:min_balance],
                           balance_low_threshold: form_params[:balance_low_threshold],
                           balance_high_threshold: form_params[:balance_high_threshold],
                           destination_rate_limit: form_params[:destination_rate_limit],
                           max_call_duration: form_params[:max_call_duration],
                           origination_capacity: form_params[:origination_capacity],
                           termination_capacity: form_params[:termination_capacity],
                           total_capacity: form_params[:total_capacity],
                           timezone: form_params[:timezone],
                           vendor_invoice_period_id: Billing::InvoicePeriod::WEEKLY_SPLIT_ID,
                           next_vendor_invoice_at: account_time_zone.parse('2020-01-02 00:00:00'),
                           next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_PARTIAL,
                           customer_invoice_period_id: nil,
                           next_customer_invoice_at: nil,
                           next_customer_invoice_type_id: nil,
                           customer_invoice_ref_template: '$id',
                           vendor_invoice_ref_template: '$id'
                         )
    end
  end
end
