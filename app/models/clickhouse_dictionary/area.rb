# frozen_string_literal: true

module ClickhouseDictionary
  class Area < Base
    model_class ::Routing::Area

    attributes :id,
               :name
  end
end
