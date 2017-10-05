class Api::Rest::Admin::Routing::RateProfitControlModeResource < ::BaseResource
  model_name 'Routing::RateProfitControlMode'
  immutable
  attributes :name
  filter :name
end
