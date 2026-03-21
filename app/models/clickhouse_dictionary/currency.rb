# frozen_string_literal: true

module ClickhouseDictionary
  class Currency < Base
    model_class ::Billing::Currency

    attribute :id, sql: 'billing.currencies.id'
    attribute :name, sql: 'billing.currencies.name'
    attribute :rate, sql: 'billing.currencies.rate'
  end
end
