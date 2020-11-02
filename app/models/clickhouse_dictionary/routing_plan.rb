# frozen_string_literal: true

module ClickhouseDictionary
  class RoutingPlan < Base
    model_class ::Routing::RoutingPlan

    attributes :id,
               :name,
               :external_id
  end
end
