class Api::Rest::Admin::DestinationRatePolicyResource < JSONAPI::Resource
  immutable
  attributes :name
  filter :name
end
