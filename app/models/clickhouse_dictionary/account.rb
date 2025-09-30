# frozen_string_literal: true

module ClickhouseDictionary
  class Account < Base
    model_class ::Account

    attribute :id, sql: 'billing.accounts.id'
    attribute :name, sql: 'billing.accounts.name'
    attribute :external_id, sql: 'billing.accounts.external_id'
    attribute :balance, sql: 'billing.accounts.balance'
    attribute :min_balance, sql: 'billing.accounts.min_balance'
    attribute :max_balance, sql: 'billing.accounts.max_balance'
    attribute :origination_capacity, sql: 'billing.accounts.origination_capacity'
    attribute :termination_capacity, sql: 'billing.accounts.termination_capacity'
    attribute :total_capacity, sql: 'billing.accounts.total_capacity'
    attribute :uuid, sql: 'billing.accounts.uuid'
  end
end
