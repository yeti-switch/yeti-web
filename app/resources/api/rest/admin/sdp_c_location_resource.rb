class Api::Rest::Admin::SdpCLocationResource < JSONAPI::Resource
  immutable
  attributes :name
  filter :name
end
