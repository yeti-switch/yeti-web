# frozen_string_literal: true

FactoryGirl.define do
  factory :routing_plan, class: Routing::RoutingPlan do
    sequence(:name) { |n| "routing_plan_#{n}" }
    sorting_id 1
    rate_delta_max 0
    max_rerouting_attempts 9
    use_lnp false

    trait :with_static_routes do
      sorting_id { FactoryGirl.create(:sorting, use_static_routes: true).id }
    end

    trait :filled do
      customers_auths { build_list :customers_auth, 2 }
      routing_groups { build_list :routing_group, 2 }
    end
  end
end
