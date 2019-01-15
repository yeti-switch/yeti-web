# frozen_string_literal: true

class Api::Rest::Admin::RoutingGroupResource < JSONAPI::Resource
  attributes :name

  filter :name

  def self.updatable_fields(_context)
    [:name]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
