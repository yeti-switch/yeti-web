# frozen_string_literal: true

module ClickhouseDictionary
  class Rateplan < Base
    model_class Routing::Rateplan

    attributes :id,
               :name,
               :uuid,
               :external_id
  end
end
