# frozen_string_literal: true

module ClickhouseDictionary
  class Account < Base
    model_class ::Account

    attributes :id,
               :name,
               :external_id,
               :origination_capacity,
               :termination_capacity,
               :total_capacity,
               :uuid
  end
end
