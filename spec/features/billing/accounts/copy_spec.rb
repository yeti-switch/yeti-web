# frozen_string_literal: true

RSpec.describe 'Copy Account', type: :feature, js: true do
  subject do
    visit account_path(old_account)
    click_action_item('Copy')
    change_form!
    click_submit('Create Account')
  end

  include_context :login_as_admin
  include_context :timezone_helpers
  let!(:customer) { create(:customer) }
  let!(:old_account) { create(:account, :filled, contractor: customer, external_id: '123456') }
  let(:change_form!) do
    fill_in 'Name', with: 'new name'
  end

  it 'creates account copy successfully' do
    expect do
      subject
      expect(page).to have_flash_message('Account was successfully created.', type: :notice)
    end.to change { Account.count }.by(1)
    account = Account.last!
    expect(page).to have_current_path account_path(account.id)

    expect(account).to have_attributes(
      id: not_eq(old_account.id),
      uuid: not_eq(old_account.uuid),
      external_id: nil,
      name: 'new name',
      contractor: old_account.contractor,
      balance: 0,
      max_balance: old_account.max_balance,
      min_balance: old_account.min_balance,
      destination_rate_limit: old_account.destination_rate_limit,
      max_call_duration: old_account.max_call_duration,
      origination_capacity: old_account.origination_capacity,
      termination_capacity: old_account.termination_capacity,
      total_capacity: old_account.total_capacity,
      timezone: old_account.timezone,
      vendor_invoice_period_id: old_account.vendor_invoice_period_id,
      next_vendor_invoice_at: old_account.next_vendor_invoice_at,
      next_vendor_invoice_type_id: old_account.next_vendor_invoice_type_id,
      customer_invoice_period_id: old_account.customer_invoice_period_id,
      next_customer_invoice_at: old_account.next_customer_invoice_at,
      next_customer_invoice_type_id: old_account.next_customer_invoice_type_id,
      customer_invoice_ref_template: old_account.customer_invoice_ref_template,
      vendor_invoice_ref_template: old_account.vendor_invoice_ref_template,
      send_invoices_to: old_account.send_invoices_to,
      vat: old_account.vat,
      customer_invoice_template_id: old_account.customer_invoice_template_id,
      vendor_invoice_template_id: old_account.vendor_invoice_template_id
    )
    expect(account.balance_notification_setting).to have_attributes(
      state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE,
      low_threshold: nil,
      high_threshold: nil,
      send_to: nil
    )
  end
end
