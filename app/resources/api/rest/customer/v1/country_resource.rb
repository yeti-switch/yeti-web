# frozen_string_literal: true

class Api::Rest::Customer::V1::CountryResource < ::Api::Rest::Customer::V1::BaseResource
  model_name 'System::Country'
  attributes :name, :iso2
  paginator :paged
  filter :name
  filter :iso2
end
