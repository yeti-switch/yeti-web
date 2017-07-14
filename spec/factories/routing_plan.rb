FactoryGirl.define do
  factory :routing_plan, class: Routing::RoutingPlan do
    sequence(:name) { |n| "routing_plan_#{n}" }
    sorting_id 1
    # more_specific_per_vendor false
    rate_delta_max 0
  end
end
