class Api::Rest::Admin::System::NetworkResource < ::BaseResource
  model_name 'System::Network'
  attributes :name
  filter :name
end
