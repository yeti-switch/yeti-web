# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.services
#
#  id              :bigint(8)        not null, primary key
#  initial_price   :decimal(, )      not null
#  name            :string
#  renew_at        :timestamptz
#  renew_price     :decimal(, )      not null
#  uuid            :uuid             not null
#  variables       :jsonb
#  created_at      :timestamptz      not null
#  account_id      :integer(4)       not null
#  renew_period_id :integer(2)
#  state_id        :integer(2)       default(10), not null
#  type_id         :integer(2)       not null
#
# Indexes
#
#  services_account_id_idx  (account_id)
#  services_renew_at_idx    (renew_at)
#  services_type_id_idx     (type_id)
#  services_uuid_idx        (uuid)
#
# Foreign Keys
#
#  services_account_id_fkey  (account_id => accounts.id)
#  services_type_id_fkey     (type_id => service_types.id)
#
FactoryBot.define do
  factory :service, class: 'Billing::Service' do
    sequence(:name) { |n| "Service_#{n}" }
    account { FactoryBot.create(:account) }
    type { FactoryBot.create(:service_type) }
    initial_price { rand(100) + rand.round(2) }
    renew_price { rand(100) + rand.round(2) }
    created_at { Time.current - rand(600).minutes }
    variables { { 'baz' => 123 } }

    trait :renew_daily do
      renew_at { 1.day.from_now.beginning_of_day }
      renew_period_id { Billing::Service::RENEW_PERIOD_ID_DAY }
    end

    trait :renew_monthly do
      renew_at { 1.month.from_now.beginning_of_month }
      renew_period_id { Billing::Service::RENEW_PERIOD_ID_MONTH }
    end

    trait :terminated do
      state_id { Billing::Service::STATE_ID_TERMINATED }
    end
  end
end
