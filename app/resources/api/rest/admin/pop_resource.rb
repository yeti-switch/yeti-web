# frozen_string_literal: true

class Api::Rest::Admin::PopResource < JSONAPI::Resource
  attributes :name
  filter :name
end
