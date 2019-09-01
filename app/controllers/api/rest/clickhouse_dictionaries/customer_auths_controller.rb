# frozen_string_literal: true

class Api::Rest::ClickhouseDictionaries::CustomerAuthsController < ::Api::RestController
  def index
    render plain: ClickhouseDictionary::CustomerAuth.call
  end
end
