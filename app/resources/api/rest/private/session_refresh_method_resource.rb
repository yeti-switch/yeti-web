class Api::Rest::Private::SessionRefreshMethodResource < JSONAPI::Resource
  immutable

  attributes :name, :value
end
