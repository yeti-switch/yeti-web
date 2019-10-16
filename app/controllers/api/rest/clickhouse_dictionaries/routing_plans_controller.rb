# frozen_string_literal: true

class Api::Rest::ClickhouseDictionaries::RoutingPlansController < ::Api::RestController
  def index
    render plain: ClickhouseDictionary::RoutingPlan.call
  end
end
