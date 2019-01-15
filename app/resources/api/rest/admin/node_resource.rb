# frozen_string_literal: true

class Api::Rest::Admin::NodeResource < JSONAPI::Resource
  attributes :name
  filter :name
end
