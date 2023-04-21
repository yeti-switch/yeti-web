# frozen_string_literal: true

FactoryBot.define do
  factory :routing_plan, class: Routing::RoutingPlan do
    sequence(:name) { |n| "routing_plan_#{n}" }
    sorting_id { Routing::RoutingPlan::SORTING_LCR_PRIO_CONTROL }
    rate_delta_max { 0 }
    max_rerouting_attempts { 9 }
    use_lnp { false }
    validate_dst_number_format { false }
    validate_dst_number_network { false }
    validate_src_number_format { false }
    validate_src_number_network { false }

    trait :with_static_routes do
      sorting_id { Routing::RoutingPlan::SORTING_STATIC_LCR_CONTROL }
    end

    trait :filled do
      after(:create) do |record|
        FactoryBot.create_list(:customers_auth, 2, routing_plan: record)
        FactoryBot.create_list(:routing_group, 2, routing_plans: [record])
      end
    end
  end
end
