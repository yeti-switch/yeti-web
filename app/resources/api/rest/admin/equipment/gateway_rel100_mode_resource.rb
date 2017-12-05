class Api::Rest::Admin::Equipment::GatewayRel100ModeResource < ::BaseResource
  model_name 'Equipment::GatewayRel100Mode'
  immutable
  attributes :name
  filter :name
end
