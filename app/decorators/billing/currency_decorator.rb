# frozen_string_literal: true

module Billing
  class CurrencyDecorator < BillingDecorator
    decorates Billing::Currency
  end
end
