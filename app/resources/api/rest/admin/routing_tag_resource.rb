# frozen_string_literal: true

class Api::Rest::Admin::RoutingTagResource < ::BaseResource
  model_name 'Routing::RoutingTag'

  attributes :name

  paginator :paged

  ransack_filter :name, type: :string
end
