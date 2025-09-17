# frozen_string_literal: true

class Api::Rest::Admin::GatewayGroupResource < BaseResource
  attributes :name, :balancing_mode_id, :max_rerouting_attempts

  paginator :paged

  has_one :vendor, class_name: 'Contractor', always_include_linkage_data: true

  filter :name
  ransack_filter :name, type: :string
  ransack_filter :balancing_mode_id, type: :number
  ransack_filter :max_rerouting_attempts, type: :number

  def self.updatable_fields(_context)
    %i[
      name
      vendor
      balancing_mode_id
      max_rerouting_attempts
    ]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
