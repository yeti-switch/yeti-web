FactoryGirl.define do
  factory :routing_plan, class: Routing::RoutingPlan do
    name nil
    sorting_id 1
    more_specific_per_vendor false
    rate_delta_max 0
  end
end
