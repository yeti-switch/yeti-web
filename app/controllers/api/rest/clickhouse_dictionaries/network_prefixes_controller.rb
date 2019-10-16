# frozen_string_literal: true

class Api::Rest::ClickhouseDictionaries::NetworkPrefixesController < ::Api::RestController
  def index
    render plain: ClickhouseDictionary::NetworkPrefix.call
  end
end
