# frozen_string_literal: true

class Api::Rest::ClickhouseDictionaries::AreasController < ::Api::RestController
  def index
    render plain: ClickhouseDictionary::Area.call
  end
end
