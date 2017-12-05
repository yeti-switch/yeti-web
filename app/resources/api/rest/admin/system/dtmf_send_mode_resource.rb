class Api::Rest::Admin::System::DtmfSendModeResource < ::BaseResource
  model_name 'System::DtmfSendMode'
  immutable
  attributes :name
  filter :name
end
