class Api::Rest::Admin::Equipment::GatewayInboundDtmfFilteringModeResource < ::BaseResource
  model_name 'Equipment::GatewayInboundDtmfFilteringMode'
  immutable
  attributes :name
  filter :name
end
