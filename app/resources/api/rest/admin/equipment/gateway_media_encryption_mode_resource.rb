# frozen_string_literal: true

class Api::Rest::Admin::Equipment::GatewayMediaEncryptionModeResource < BaseResource
  model_name 'Equipment::GatewayMediaEncryptionMode'
  immutable
  attributes :name
  paginator :paged
  filter :name
end
