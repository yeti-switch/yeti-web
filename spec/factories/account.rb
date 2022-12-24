# frozen_string_literal: true

FactoryBot.define do
  factory :account, class: Account do
    sequence(:name) { |n| "account#{n}" }
    association :contractor, vendor: true
    balance { 0 }
    vat { 23.1 }
    destination_rate_limit { 0.3444 }
    max_call_duration { 36_000 }
    min_balance { 0 }
    max_balance { 0 }
    origination_capacity { 1 }
    termination_capacity { 2 }
    total_capacity { 5 }
    timezone_id { 1 }

    transient do
      balance_low_threshold { nil }
      balance_high_threshold { nil }
      send_balance_notifications_to { nil }
      threshold_state_id { AccountBalanceNotificationSetting::CONST::STATE_ID_NONE }
    end

    trait :with_customer do
      association :contractor, vendor: false, customer: true
    end

    trait :with_max_balance do
      max_balance { 1_000 }
    end

    trait :with_uuid do
      uuid { SecureRandom.uuid }
    end

    trait :filled do
      association :vendor_invoice_template, factory: :invoice_template
      association :customer_invoice_template, factory: :invoice_template
      customer_invoice_period { Billing::InvoicePeriod.find(Billing::InvoicePeriod::DAILY_ID) }
      contractor { build(:contractor, vendor: true) }
      timezone { System::Timezone.take || build(:timezone) }
      payments { build_list(:payment, 2) }
      # invoices { build_list(:invoice, 2, :manual, :pending) }
      api_access { build_list(:api_access, 2) }
      customers_auths { build_list(:customers_auth, 2) }
      dialpeers { build_list(:dialpeer, 2) }
    end

    trait :vendor_weekly do
      vendor_invoice_period_id { Billing::InvoicePeriod::WEEKLY_ID }
    end

    trait :customer_weekly do
      customer_invoice_period_id { Billing::InvoicePeriod::WEEKLY_ID }
    end

    after(:create) do |record, ev|
      record.build_balance_notification_setting if record.balance_notification_setting.nil?
      record.balance_notification_setting.update!(
        state_id: ev.threshold_state_id,
        low_threshold: ev.balance_low_threshold,
        high_threshold: ev.balance_high_threshold,
        send_to: ev.send_balance_notifications_to
      )
    end
  end
end
