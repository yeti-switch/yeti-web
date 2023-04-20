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
      vendor_invoice_period { Billing::InvoicePeriod.find(Billing::InvoicePeriod::WEEKLY_ID) }
      contractor { create(:contractor, vendor: true) }
      timezone { System::Timezone.take || create(:timezone) }
      balance { 100 }
      max_balance { 1_000 }
      min_balance { 0 }
      destination_rate_limit { 123 }
      max_call_duration { 124 }
      origination_capacity { 125 }
      termination_capacity { 126 }
      total_capacity { 127 }
      next_vendor_invoice_at { (timezone.time_zone.now + 7.days).beginning_of_week }
      next_vendor_invoice_type_id { Billing::InvoiceType::AUTO_FULL }
      next_customer_invoice_at { (timezone.time_zone.now + 1.day).beginning_of_day }
      next_customer_invoice_type_id { Billing::InvoiceType::AUTO_FULL }
      customer_invoice_ref_template { 'cus_$id' }
      vendor_invoice_ref_template { 'ven_$id' }
      send_invoices_to { [FactoryBot.create(:contact, contractor: contractor).id] }
      vat { 1.23 }

      after(:create) do |record|
        # create_list(:invoice, 2, :manual, :pending, account: record)
        create_list(:payment, 2, account: record)
        create_list(:api_access, 2, customer: record.contractor, account_ids: [record.id])
        create_list(:customers_auth, 2, account: record)
        create_list(:dialpeer, 2, vendor: record.contractor, account: record) if record.contractor.vendor
      end
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
