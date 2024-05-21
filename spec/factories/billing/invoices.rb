# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoices
#
#  id                                :integer(4)       not null, primary key
#  amount_earned                     :decimal(, )      default(0.0), not null
#  amount_spent                      :decimal(, )      default(0.0), not null
#  amount_total                      :decimal(, )      default(0.0), not null
#  end_date                          :timestamptz      not null
#  first_originated_call_at          :timestamptz
#  first_terminated_call_at          :timestamptz
#  last_originated_call_at           :timestamptz
#  last_terminated_call_at           :timestamptz
#  originated_amount_earned          :decimal(, )      default(0.0), not null
#  originated_amount_spent           :decimal(, )      default(0.0), not null
#  originated_billing_duration       :bigint(8)        default(0), not null
#  originated_calls_count            :bigint(8)        default(0), not null
#  originated_calls_duration         :bigint(8)        default(0), not null
#  originated_successful_calls_count :bigint(8)        default(0), not null
#  reference                         :string
#  service_transactions_count        :integer(4)       default(0), not null
#  services_amount_earned            :decimal(, )      default(0.0), not null
#  services_amount_spent             :decimal(, )      default(0.0), not null
#  start_date                        :timestamptz      not null
#  terminated_amount_earned          :decimal(, )      default(0.0), not null
#  terminated_amount_spent           :decimal(, )      default(0.0), not null
#  terminated_billing_duration       :integer(4)       default(0), not null
#  terminated_calls_count            :integer(4)       default(0), not null
#  terminated_calls_duration         :integer(4)       default(0), not null
#  terminated_successful_calls_count :integer(4)       default(0), not null
#  uuid                              :uuid             not null
#  created_at                        :timestamptz      not null
#  account_id                        :integer(4)       not null
#  contractor_id                     :integer(4)
#  state_id                          :integer(2)       default(3), not null
#  type_id                           :integer(2)       not null
#
# Indexes
#
#  index_billing.invoices_on_reference  (reference)
#
FactoryBot.define do
  factory :invoice, class: Billing::Invoice do
    start_date { 7.days.ago.utc }
    end_date { 1.day.ago.utc }
    state_id { Billing::InvoiceState::NEW }
    type_id { Billing::InvoiceType::MANUAL }

    after(:build) do |record, _ev|
      record.contractor_id ||= record.account&.contractor_id
    end

    trait :manual do
      type_id { Billing::InvoiceType::MANUAL }
    end

    trait :auto_full do
      type_id { Billing::InvoiceType::AUTO_FULL }
    end

    trait :auto_partial do
      type_id { Billing::InvoiceType::AUTO_PARTIAL }
    end

    trait :new do
      state_id { Billing::InvoiceState::NEW }
    end

    trait :pending do
      state_id { Billing::InvoiceState::PENDING }
    end

    trait :approved do
      state_id { Billing::InvoiceState::APPROVED }
    end

    trait :with_vendor_account do
      account { FactoryBot.create(:account, contractor: FactoryBot.create(:vendor)) }
    end

    after(:create) do |record|
      record.update!(reference: record.id.to_s) if record.reference.blank?
      record.reload # to populate uuid
    end
  end
end
