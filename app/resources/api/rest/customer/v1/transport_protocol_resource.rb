# frozen_string_literal: true

class Api::Rest::Customer::V1::TransportProtocolResource < Api::Rest::Customer::V1::BaseResource
  model_name 'Equipment::TransportProtocol'
  primary_key :id
  key_type :integer
  paginator :none

  attributes :name
end
