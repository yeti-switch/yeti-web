# frozen_string_literal: true

class Api::Rest::ClickhouseDictionaries::NetworksController < ::Api::RestController
  def index
    render plain: ClickhouseDictionary::Network.call
  end
end
