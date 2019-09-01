# frozen_string_literal: true

class Api::Rest::ClickhouseDictionaries::CountriesController < ::Api::RestController
  def index
    render plain: ClickhouseDictionary::Country.call
  end
end
