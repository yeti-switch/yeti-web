# frozen_string_literal: true

FactoryBot.define do
  factory :accounting_profile, class: Equipment::Radius::AccountingProfile do
    sequence(:name) { |n| "profile#{n}" }
    server { 'server' }
    port { '1' }
    secret { 'secret' }
    timeout { 100 }
    attempts { 2 }

    trait :filled do
      gateways { build_list :gateway, 2 }
      stop_avps { build_list :accounting_profile_stop_attribute, 2 }
      start_avps { build_list :accounting_profile_start_attribute, 2 }
      customers_auths { build_list :customers_auth, 2 }
    end
  end
end
