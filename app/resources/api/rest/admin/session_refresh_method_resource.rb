class Api::Rest::Admin::SessionRefreshMethodResource < JSONAPI::Resource
  immutable
  attributes :name, :value
  filter :name
end
