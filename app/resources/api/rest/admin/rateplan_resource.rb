# frozen_string_literal: true

class Api::Rest::Admin::RateplanResource < BaseResource
  model_name 'Routing::Rateplan'

  attributes :name, :profit_control_mode_id

  paginator :paged

  filter :name # DEPRECATED

  has_many :rate_groups,
           class_name: 'RateGroup',
           exclude_links: %i[default self],
           relation_name: :rate_groups,
           foreign_key_on: :related

  ransack_filter :name, type: :string
  ransack_filter :profit_control_mode_id, type: :number

  def self.updatable_fields(_context)
    %i[
      name
      profit_control_mode_id
      rate_groups
    ]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
