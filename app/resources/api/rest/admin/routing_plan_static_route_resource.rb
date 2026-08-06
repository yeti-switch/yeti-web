# frozen_string_literal: true

class Api::Rest::Admin::RoutingPlanStaticRouteResource < BaseResource
  model_name 'Routing::RoutingPlanStaticRoute'

  paginator :paged

  # network_prefix_id is detected from prefix by Yeti::NetworkDetector, so it is read-only
  attributes :prefix, :priority, :weight, :network_prefix_id

  has_one :routing_plan, class_name: 'RoutingPlan', always_include_linkage_data: true
  has_one :vendor, class_name: 'Contractor', always_include_linkage_data: true

  ransack_filter :prefix, type: :string
  ransack_filter :priority, type: :number
  ransack_filter :weight, type: :number
  ransack_filter :routing_plan_id, type: :number
  ransack_filter :vendor_id, type: :number
  ransack_filter :network_prefix_id, type: :number

  def self.updatable_fields(_context)
    %i[
      prefix
      priority
      weight
      routing_plan
      vendor
    ]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
