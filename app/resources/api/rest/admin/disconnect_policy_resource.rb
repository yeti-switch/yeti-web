class Api::Rest::Admin::DisconnectPolicyResource < JSONAPI::Resource

  attributes :name

  filter :name
end
