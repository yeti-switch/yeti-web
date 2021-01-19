# frozen_string_literal: true

class Api::Rest::ClickhouseDictionaries::PopsController < ::Api::RestController
  def index
    render plain: ClickhouseDictionary::Pop.call
  end
end
