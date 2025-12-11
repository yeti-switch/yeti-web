# frozen_string_literal: true

class Api::Rest::Customer::V1::CountryResource < ::Api::Rest::Customer::V1::BaseResource
  model_name 'System::Country'
  primary_key :id
  key_type :string
  attributes :name, :iso2
  paginator :paged
  filter :name
  filter :iso2

  def self.default_sort
    [{ field: 'name', direction: :asc }]
  end
end
