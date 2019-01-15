# frozen_string_literal: true

class Api::Rest::Admin::System::DtmfReceiveModeResource < ::BaseResource
  model_name 'System::DtmfReceiveMode'
  immutable
  attributes :name
  filter :name
end
