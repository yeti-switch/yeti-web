# frozen_string_literal: true

class Api::Rest::ClickhouseDictionaries::CurrenciesController < ::Api::RestController
  def index
    render plain: ClickhouseDictionary::Currency.call
  end
end
