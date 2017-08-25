FactoryGirl.define do
  factory :diversion_policy, class: DiversionPolicy do
    sequence(:name) { |n| "diversion_policy#{n}" }
  end
end
