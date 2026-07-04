# frozen_string_literal: true

module CurrencyRates
  module Providers
    # Official National Bank of Ukraine exchange rates https://bank.gov.ua.
    # Rates are published as UAH per 1 unit. Precious metals and SDR present in
    # the response are ignored via SUPPORTED_CURRENCIES.
    class Nbu < CrossRateBase
      LABEL = 'NBU'
      DEFAULT_URL = 'https://bank.gov.ua'
      PATH = '/NBUStatService/v1/statdirectory/exchange?json'

      SUPPORTED_CURRENCIES = %w[
        UAH AED AUD AZN BDT CAD CHF CNY CZK DKK DZD EGP EUR GBP GEL HKD HUF IDR ILS INR
        JPY KRW KZT LBP MDL MXN MYR NOK NZD PLN RON RSD SAR SEK SGD THB TND TRY USD VND ZAR
      ].freeze

      private

      def home_quotes(data)
        quotes = data.to_h { |row| [row.fetch('cc'), row.fetch('rate').to_f] }
        quotes['UAH'] = 1.0
        quotes
      end
    end
  end
end
