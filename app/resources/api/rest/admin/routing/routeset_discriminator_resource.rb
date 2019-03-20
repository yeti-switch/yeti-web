# frozen_string_literal: true

class Api::Rest::Admin::Routing::RoutesetDiscriminatorResource < ::BaseResource
  model_name 'Routing::RoutesetDiscriminator'

  attributes :name
  filter :name

  ransack_filter :name, type: :string

  def self.updatable_fields(_context)
    [:name]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
