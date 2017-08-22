class Api::Rest::Private::System::SensorLevelResource < ::BaseResource
  immutable
  model_name 'System::SensorLevel'
  type 'system/sensor_levels'

  attributes :name
end
