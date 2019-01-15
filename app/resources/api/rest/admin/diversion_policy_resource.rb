# frozen_string_literal: true

class Api::Rest::Admin::DiversionPolicyResource < JSONAPI::Resource
  immutable
  attributes :name
  filter :name
end
