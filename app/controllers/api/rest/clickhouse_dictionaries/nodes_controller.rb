# frozen_string_literal: true

class Api::Rest::ClickhouseDictionaries::NodesController < ::Api::RestController
  def index
    render plain: ClickhouseDictionary::Node.call
  end
end
