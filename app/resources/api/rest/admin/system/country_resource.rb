# frozen_string_literal: true

class Api::Rest::Admin::System::CountryResource < ::BaseResource
  model_name 'System::Country'
  attributes :name, :iso2
  filter :name
  filter :iso2
end
