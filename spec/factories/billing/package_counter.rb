# frozen_string_literal: true

FactoryBot.define do
  factory :billing_package_counter, class: Billing::PackageCounter do
    account { FactoryBot.create(:account) }
    service { FactoryBot.create(:service) }
    prefix { '' }
    duration { 120 }
    exclude { false }
  end
end
