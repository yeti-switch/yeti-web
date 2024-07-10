# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routing_plan_static_routes
#
#  id                :integer(4)       not null, primary key
#  prefix            :string           default(""), not null
#  priority          :integer(2)       default(100), not null
#  weight            :integer(2)       default(100), not null
#  network_prefix_id :integer(4)
#  routing_plan_id   :integer(4)       not null
#  vendor_id         :integer(4)       not null
#
# Indexes
#
#  routing_plan_static_routes_prefix_range_vendor_id_routing_p_idx  (((prefix)::prefix_range), vendor_id, routing_plan_id) USING gist
#  routing_plan_static_routes_vendor_id_idx                         (vendor_id)
#
# Foreign Keys
#
#  routing_plan_static_routes_routing_plan_id_fkey  (routing_plan_id => routing_plans.id)
#  routing_plan_static_routes_vendor_id_fkey        (vendor_id => contractors.id)
#
FactoryBot.define do
  factory :routing_plan_static_route, class: Routing::RoutingPlanStaticRoute do
    prefix { '' }
    routing_plan { create :routing_plan, :with_static_routes }

    trait :filled do
      network_prefix { FactoryBot.create :network_prefix }
    end
  end
end
