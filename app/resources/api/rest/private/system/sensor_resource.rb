class Api::Rest::Private::System::SensorResource < ::BaseResource
  immutable
  model_name 'System::Sensor'
  type 'system/sensors'

  attributes :name, :source_interface, :target_mac, :use_routing, :target_ip, :source_ip

end