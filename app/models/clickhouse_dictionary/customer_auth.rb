# frozen_string_literal: true

module ClickhouseDictionary
  class CustomerAuth < Base
    model_class ::CustomersAuth

    attributes :id,
               :name,
               :external_id,
               :customer_id,
               :account_id,
               :enabled
  end
end
