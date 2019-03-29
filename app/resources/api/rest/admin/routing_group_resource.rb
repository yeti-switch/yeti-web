# frozen_string_literal: true

class Api::Rest::Admin::RoutingGroupResource < ::BaseResource
  attributes :name

  filter :name # DEPRECATED

  ransack_filter :name, type: :string

  def self.updatable_fields(_context)
    [:name]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
