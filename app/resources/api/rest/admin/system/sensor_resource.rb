class Api::Rest::Admin::System::SensorResource < ::BaseResource
  model_name 'System::Sensor'

  attributes :name, :mode_id, :source_interface, :target_mac, :use_routing, :target_ip, :source_ip

  filter :name
end
