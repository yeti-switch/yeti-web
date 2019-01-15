# frozen_string_literal: true

class Api::Rest::Admin::Equipment::TransportProtocolResource < ::BaseResource
  model_name 'Equipment::TransportProtocol'
  immutable
  attributes :name
  filter :name
end
