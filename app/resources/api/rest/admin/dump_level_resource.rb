class Api::Rest::Admin::DumpLevelResource < JSONAPI::Resource
  immutable
  attributes :name, :log_sip, :log_rtp
end
