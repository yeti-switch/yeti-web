# frozen_string_literal: true

class Api::Rest::Admin::SensorLevelResource < ::BaseResource
  model_name 'System::SensorLevel'
  immutable
  attributes :name
  paginator :paged
  filter :name
end
