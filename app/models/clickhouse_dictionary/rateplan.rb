# frozen_string_literal: true

module ClickhouseDictionary
  class Rateplan < Base
    model_class ::Rateplan

    attributes :id,
               :name,
               :uuid
  end
end
