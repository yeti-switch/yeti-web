# frozen_string_literal: true

class Api::Rest::Admin::Routing::RoutingTagModeResource < ::BaseResource
  model_name 'Routing::RoutingTagMode'
  immutable
  attributes :name
  filter :name

  ransack_filter :name, type: :string
end
