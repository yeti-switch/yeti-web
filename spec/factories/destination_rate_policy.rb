FactoryGirl.define do
  factory :destination_rate_policy, class: DestinationRatePolicy do
    sequence(:name) { |n| "destination_rate_policy#{n}" }
  end
end
