# frozen_string_literal: true

class Api::Rest::Admin::Routing::RoutingTagResource < ::BaseResource
  model_name 'Routing::RoutingTag'

  attributes :name

  ransack_filter :name, type: :string
end
