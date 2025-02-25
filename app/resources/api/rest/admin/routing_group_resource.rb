# frozen_string_literal: true

class Api::Rest::Admin::RoutingGroupResource < ::BaseResource
  model_name 'Routing::RoutingGroup'
  attributes :name

  paginator :paged

  has_many :routing_plans, class_name: 'RoutingPlan',
                           exclude_links: %i[default self],
                           relation_name: :routing_plans,
                           foreign_key_on: :related

  filter :name # DEPRECATED

  ransack_filter :name, type: :string

  def self.updatable_fields(_context)
    %i[name routing_plans]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
