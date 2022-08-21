# frozen_string_literal: true

class Api::Rest::Admin::Equipment::GatewayDiversionSendModeResource < ::BaseResource
  model_name 'Equipment::GatewayDiversionSendMode'
  immutable
  attributes :name
  paginator :paged
  filter :name
end
