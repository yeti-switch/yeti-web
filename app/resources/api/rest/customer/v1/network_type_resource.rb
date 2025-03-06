# frozen_string_literal: true

class Api::Rest::Customer::V1::NetworkTypeResource < Api::Rest::Customer::V1::BaseResource
  model_name 'System::NetworkType'

  attributes :name

  ransack_filter :name, type: :string
  def self.default_sort
    [{ field: 'name', direction: :asc }]
  end
end
