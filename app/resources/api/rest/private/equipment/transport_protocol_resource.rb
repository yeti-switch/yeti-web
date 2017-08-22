class Api::Rest::Private::Equipment::TransportProtocolResource < ::BaseResource
  immutable
  model_name 'Equipment::TransportProtocol'
  type 'equipment/transport_protocols'

  attributes :name
end
