# frozen_string_literal: true

class Api::Rest::Admin::Routing::DestinationRatePolicyResource < ::BaseResource
  model_name 'Routing::DestinationRatePolicy'

  immutable
  attributes :name
  filter :name # DEPRECATED

  ransack_filter :name, type: :string
end
