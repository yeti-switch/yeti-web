class Api::Rest::Admin::Equipment::GatewayNetworkProtocolPriorityResource < JSONAPI::Resource
  model_name 'Equipment::GatewayNetworkProtocolPriority'
  immutable
  attributes :name
  filter :name
end
