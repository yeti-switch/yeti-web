# frozen_string_literal: true

class Api::Rest::Admin::System::DtmfSendModeResource < ::BaseResource
  model_name 'System::DtmfSendMode'
  immutable
  attributes :name
  paginator :paged
  filter :name
end
