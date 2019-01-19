# frozen_string_literal: true

class Api::Rest::Admin::Equipment::GatewayMediaEncryptionModeResource < JSONAPI::Resource
  model_name 'Equipment::GatewayMediaEncryptionMode'
  immutable
  attributes :name
  filter :name
end
