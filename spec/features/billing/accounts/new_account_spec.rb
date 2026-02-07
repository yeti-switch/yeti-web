# frozen_string_literal: true

RSpec.describe 'Create new Account', type: :feature, js: true do
  subject do
    visit new_account_path
    fill_form!
    click_submit('Create Account')
  end

  include_context :login_as_admin
  include_context :timezone_helpers
  let!(:customer) { create(:customer) }
  let!(:contact) { create(:contact, contractor: customer) }
  let!(:vendor) { create(:vendor) }
  let(:fill_form!) do
    fill_in 'Name', with: form_params[:name]
    fill_in_tom_select 'Contractor', with: form_params[:contractor].display_name, ajax: true
    fill_in 'Min balance', with: form_params[:min_balance]
    fill_in 'Max balance', with: form_params[:max_balance]
    fill_in 'Vat', with: form_params[:vat]
    fill_in 'Destination rate limit', with: form_params[:destination_rate_limit]
    fill_in 'Max call duration', with: form_params[:max_call_duration]
    fill_in 'Balance low threshold', with: form_params[:balance_low_threshold]
    fill_in 'Balance high threshold', with: form_params[:balance_high_threshold]
    fill_in_tom_select 'Send balance notifications to', with: form_params[:send_balance_notifications_to].email, multiple: true
    fill_in 'Origination capacity', with: form_params[:origination_capacity]
    fill_in 'Termination capacity', with: form_params[:termination_capacity]
    fill_in 'Total capacity', with: form_params[:total_capacity]
    fill_in_tom_select 'Timezone', with: form_params[:timezone]
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
      send_balance_notifications_to: contact,
      origination_capacity: 100,
      termination_capacity: 50,
      total_capacity: 101,
      timezone: la_timezone
    }
  end

  context 'with all fields filled' do
    it 'creates new account successfully' do
      expect do
        subject
        expect(page).to have_flash_message('Account was successfully created.', type: :notice)
      end.to change { Account.count }.by(1)
      account = Account.last!
      expect(page).to have_current_path account_path(account.id)

      expect(account).to have_attributes(
                           name: form_params[:name],
                           contractor: form_params[:contractor],
                           max_balance: form_params[:max_balance],
                           min_balance: form_params[:min_balance],
                           destination_rate_limit: form_params[:destination_rate_limit],
                           max_call_duration: form_params[:max_call_duration],
                           origination_capacity: form_params[:origination_capacity],
                           termination_capacity: form_params[:termination_capacity],
                           total_capacity: form_params[:total_capacity],
                           timezone: form_params[:timezone],
                           invoice_period_id: nil,
                           next_invoice_at: nil,
                           next_invoice_type_id: nil,
                           invoice_ref_template: '$id'
                         )
      expect(account.balance_notification_setting).to have_attributes(
                                                        state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE,
                                                        low_threshold: form_params[:balance_low_threshold],
                                                        high_threshold: form_params[:balance_high_threshold],
                                                        send_to: [form_params[:send_balance_notifications_to].id]
                                                      )
    end
  end

  context 'with only required fields filled' do
    let(:fill_form!) do
      fill_in 'Name', with: form_params[:name]
      fill_in_tom_select 'Contractor', with: form_params[:contractor].display_name, ajax: true
    end
    let(:form_params) do
      super().slice(:name, :contractor)
    end

    it 'creates new account successfully' do
      expect do
        subject
        expect(page).to have_flash_message('Account was successfully created.', type: :notice)
      end.to change { Account.count }.by(1)
      account = Account.last!
      expect(page).to have_current_path account_path(account.id)

      expect(account).to have_attributes(
                           name: form_params[:name],
                           contractor: form_params[:contractor],
                           max_balance: 0.0,
                           min_balance: 0.0,
                           destination_rate_limit: nil,
                           max_call_duration: nil,
                           origination_capacity: nil,
                           termination_capacity: nil,
                           total_capacity: nil,
                           timezone: utc_timezone,
                           invoice_period_id: nil,
                           next_invoice_at: nil,
                           next_invoice_type_id: nil,
                           invoice_ref_template: '$id'
                         )
      expect(account.balance_notification_setting).to have_attributes(
                                                        state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE,
                                                        low_threshold: nil,
                                                        high_threshold: nil,
                                                        send_to: nil
                                                      )
    end
  end

  context 'with invoice ref templates' do
    let(:form_params) do
      super().merge invoice_ref_template: 'new-$id'
    end
    let(:fill_form!) do
      super()
      fill_in 'Invoice ref template', with: form_params[:invoice_ref_template]
    end

    it 'creates new account successfully' do
      expect do
        subject
        expect(page).to have_flash_message('Account was successfully created.', type: :notice)
      end.to change { Account.count }.by(1)
      account = Account.last!
      expect(page).to have_current_path account_path(account.id)

      expect(account).to have_attributes(
                           name: form_params[:name],
                           contractor: form_params[:contractor],
                           max_balance: form_params[:max_balance],
                           min_balance: form_params[:min_balance],
                           destination_rate_limit: form_params[:destination_rate_limit],
                           max_call_duration: form_params[:max_call_duration],
                           origination_capacity: form_params[:origination_capacity],
                           termination_capacity: form_params[:termination_capacity],
                           total_capacity: form_params[:total_capacity],
                           timezone: form_params[:timezone],
                           invoice_period_id: nil,
                           next_invoice_at: nil,
                           next_invoice_type_id: nil,
                           invoice_ref_template: form_params[:invoice_ref_template]
                         )
      expect(account.balance_notification_setting).to have_attributes(
                                                        state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE,
                                                        low_threshold: form_params[:balance_low_threshold],
                                                        high_threshold: form_params[:balance_high_threshold],
                                                        send_to: [form_params[:send_balance_notifications_to].id]
                                                      )
    end
  end

  context 'with invoice period' do
    let(:invoice_period) { Billing::InvoicePeriod.find Billing::InvoicePeriod::WEEKLY }
    let(:account_time_zone) { ActiveSupport::TimeZone.new(form_params[:timezone]) }
    let(:fill_form!) do
      super()
      fill_in_tom_select 'Invoice period', with: invoice_period.name, exact: true
    end

    before do
      expect(BillingInvoice::CalculatePeriod::Current).to receive(:call)
        .with(account: a_kind_of(Account))
        .and_return(
          end_time: account_time_zone.parse('2020-01-06 00:00:00'),
          type_id: Billing::InvoiceType::AUTO_FULL
        )
    end

    it 'creates new account successfully' do
      expect do
        subject
        expect(page).to have_flash_message('Account was successfully created.', type: :notice)
      end.to change { Account.count }.by(1)
      account = Account.last!
      expect(page).to have_current_path account_path(account.id)

      expect(account).to have_attributes(
                           name: form_params[:name],
                           contractor: form_params[:contractor],
                           max_balance: form_params[:max_balance],
                           min_balance: form_params[:min_balance],
                           destination_rate_limit: form_params[:destination_rate_limit],
                           max_call_duration: form_params[:max_call_duration],
                           origination_capacity: form_params[:origination_capacity],
                           termination_capacity: form_params[:termination_capacity],
                           total_capacity: form_params[:total_capacity],
                           timezone: form_params[:timezone],
                           invoice_period_id: Billing::InvoicePeriod::WEEKLY,
                           next_invoice_at: account_time_zone.parse('2020-01-06 00:00:00'),
                           next_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                           invoice_ref_template: '$id'
                         )
      expect(account.balance_notification_setting).to have_attributes(
                                                        state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE,
                                                        low_threshold: form_params[:balance_low_threshold],
                                                        high_threshold: form_params[:balance_high_threshold],
                                                        send_to: [form_params[:send_balance_notifications_to].id]
                                                      )
    end
  end

  context 'with empty form' do
    let(:fill_form!) { nil }
    let(:form_params) { nil }

    it 'shows validation errors' do
      expect do
        subject
        expect(page).to have_semantic_error_texts(
                          "Name can't be blank",
                          'Contractor must exist'
                        )
      end.not_to change { Account.count }
    end
  end

  context 'with balance_low_threshold = balance_high_threshold' do
    let(:form_params) do
      super().merge balance_low_threshold: '90.01',
                    balance_high_threshold: '90.01'
    end

    it 'shows validation errors' do
      expect do
        subject
        expect(page).to have_semantic_error_texts(
                          'Balance low threshold must be less than Balance high threshold'
                        )
      end.not_to change { Account.count }
    end
  end

  context 'with balance_low_threshold > balance_high_threshold' do
    let(:form_params) do
      super().merge balance_low_threshold: '91',
                    balance_high_threshold: '90'
    end

    it 'shows validation errors' do
      expect do
        subject
        expect(page).to have_semantic_error_texts(
                          'Balance low threshold must be less than Balance high threshold'
                        )
      end.not_to change { Account.count }
    end
  end
end
