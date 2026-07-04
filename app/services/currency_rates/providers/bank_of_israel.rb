# frozen_string_literal: true

module CurrencyRates
  module Providers
    # Official Bank of Israel exchange rates https://boi.org.il.
    # Rates are published as ILS per unit (some currencies are quoted per 10/100 units).
    class BankOfIsrael < CrossRateBase
      LABEL = 'Bank of Israel'
      DEFAULT_URL = 'https://boi.org.il'
      PATH = '/PublicApi/GetExchangeRates'

      SUPPORTED_CURRENCIES = %w[
        ILS USD GBP JPY EUR AUD CAD DKK NOK ZAR SEK CHF JOD LBP EGP
      ].freeze

      private

      def home_quotes(data)
        quotes = data.fetch('exchangeRates').to_h do |row|
          [row.fetch('key'), row.fetch('currentExchangeRate').to_f / row.fetch('unit')]
        end
        quotes['ILS'] = 1.0
        quotes
      end
    end
  end
end
