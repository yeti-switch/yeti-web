# frozen_string_literal: true

class Api::Rest::Admin::RateGroupResource < BaseResource
  model_name 'Routing::RateGroup'

  attributes :name, :external_id

  has_many :rateplans, class_name: 'Rateplan',
                       exclude_links: %i[default self],
                       relation_name: :rateplans,
                       foreign_key_on: :related

  ransack_filter :name, type: :string

  def self.updatable_fields(_context)
    %i[
      name
      external_id
      rateplans
    ]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
