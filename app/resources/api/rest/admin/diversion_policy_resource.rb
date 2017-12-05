class Api::Rest::Admin::DiversionPolicyResource < JSONAPI::Resource
  immutable
  attributes :name
  filter :name
end
