FactoryGirl.define do
  factory :routing_group, class: RoutingGroup do
    sequence(:name) { |n| "routing_group_#{n}" }
  end
end
