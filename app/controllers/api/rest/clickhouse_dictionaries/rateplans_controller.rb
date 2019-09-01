# frozen_string_literal: true

class Api::Rest::ClickhouseDictionaries::RateplansController < ::Api::RestController
  def index
    render plain: ClickhouseDictionary::Rateplan.call
  end
end
