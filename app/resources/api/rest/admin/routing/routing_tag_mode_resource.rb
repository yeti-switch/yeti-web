class Api::Rest::Admin::Routing::RoutingTagModeResource < ::BaseResource
  model_name 'Routing::RoutingTagMode'
  immutable
  attributes :name
  filter :name
end
