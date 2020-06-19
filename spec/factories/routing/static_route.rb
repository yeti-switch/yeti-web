# frozen_string_literal: true

FactoryBot.define do
  factory :static_route, class: Routing::RoutingPlanStaticRoute do
    routing_plan { create :routing_plan, :with_static_routes }
    vendor { FactoryBot.create :vendor }

    trait :filled do
      network_prefix { FactoryBot.create :network_prefix }
    end
  end
end
