FactoryGirl.define do
  factory :package, class: Billing::Package do
    sequence(:name)           { |n| "rspec_package_#{n}" }
    price                     { 100.500                  }
    billing_interval          { 60                       }
    allow_minutes_aggregation { true                     }

    trait :with_two_configurations do
      after(:create) do |record, _|
        create_list(:package_config, 2, package: record)
      end
    end
  end
end
