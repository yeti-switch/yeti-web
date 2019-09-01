# frozen_string_literal: true

module ClickhouseDictionary
  class Contractor < Base
    model_class ::Contractor

    attributes :id,
               :name,
               :enabled,
               :external_id,
               :vendor,
               :customer
  end
end
