# frozen_string_literal: true

class Api::Rest::ClickhouseDictionaries::GatewaysController < ::Api::RestController
  def index
    render plain: ClickhouseDictionary::Gateway.call
  end
end
