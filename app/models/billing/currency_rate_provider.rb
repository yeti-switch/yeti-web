# frozen_string_literal: true

class Billing::CurrencyRateProvider < ApplicationEnum
  FRANKFURTER = 1
  BANK_OF_ISRAEL = 2
  NBU = 3

  setup_collection do
    [
      { id: FRANKFURTER, name: 'Frankfurter', service_class: 'CurrencyRates::Providers::Frankfurter' },
      { id: BANK_OF_ISRAEL, name: 'Bank of Israel', service_class: 'CurrencyRates::Providers::BankOfIsrael' },
      { id: NBU, name: 'National Bank of Ukraine', service_class: 'CurrencyRates::Providers::Nbu' }
    ]
  end

  attribute :name
  attribute :service_class
end
