# frozen_string_literal: true

class Api::Rest::Admin::RateGroupResource < BaseResource
  model_name 'Routing::RateGroup'

  attributes :name, :external_id

  ransack_filter :name, type: :string

  def self.updatable_fields(_context)
    %i[
      name
      external_id
    ]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
