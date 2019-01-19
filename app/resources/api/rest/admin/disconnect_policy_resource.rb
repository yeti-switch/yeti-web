# frozen_string_literal: true

class Api::Rest::Admin::DisconnectPolicyResource < JSONAPI::Resource
  attributes :name

  filter :name
end
