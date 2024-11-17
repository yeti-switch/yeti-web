# frozen_string_literal: true

class Api::Rest::Admin::GatewayNetworkProtocolPriorityResource < BaseResource
  model_name 'Equipment::GatewayNetworkProtocolPriority'
  immutable
  attributes :name
  paginator :paged
  filter :name
end
