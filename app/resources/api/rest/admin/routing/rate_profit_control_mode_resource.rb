# frozen_string_literal: true

class Api::Rest::Admin::Routing::RateProfitControlModeResource < ::BaseResource
  model_name 'Routing::RateProfitControlMode'
  immutable
  attributes :name
  paginator :paged
  filter :name

  ransack_filter :name, type: :string
end
