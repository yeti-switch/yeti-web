FactoryGirl.define do
  factory :package_config, class: Billing::PackageConfig do
    sequence(:prefix, 100)
    amount { 8 }

    association :package
  end
end
