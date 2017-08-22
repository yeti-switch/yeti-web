class Api::Rest::Private::DumpLevelResource < JSONAPI::Resource
  immutable

  attributes :name, :log_sip, :log_rtp
end
