# frozen_string_literal: true

class Api::Rest::Admin::RoutingPlanResource < BaseResource
  model_name 'Routing::RoutingPlan'

  attributes :name, :rate_delta_max, :use_lnp, :max_rerouting_attempts

  has_one :sorting

  filter :name # DEPRECATED in favor of name_eq

  ransack_filter :name, type: :string
  ransack_filter :rate_delta_max, type: :number
  ransack_filter :use_lnp, type: :boolean
  ransack_filter :max_rerouting_attempts, type: :number
  ransack_filter :validate_dst_number_format, type: :boolean
  ransack_filter :validate_dst_number_network, type: :boolean
  ransack_filter :external_id, type: :number

  def self.updatable_fields(_context)
    %i[
      name
      rate_delta_max
      use_lnp
      sorting
      max_rerouting_attempts
      validate_dst_number_format
      validate_dst_number_network
      external_id
    ]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
