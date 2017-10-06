class Api::Rest::Admin::System::SensorLevelResource < ::BaseResource
  model_name 'System::SensorLevel'
  immutable
  attributes :name
  filter :name
end
