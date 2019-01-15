# frozen_string_literal: true

class Api::Rest::Admin::SortingResource < JSONAPI::Resource
  attributes :name, :description, :use_static_routes
  filter :name
end
