# frozen_string_literal: true

module CurrencyRates
  module Providers
    # Free ECB-based exchange rates API https://frankfurter.dev.
    class Frankfurter < Base
      LABEL = 'Frankfurter'
      DEFAULT_URL = 'https://api.frankfurter.dev'
      PATH = '/v1/latest'

      # ECB reference rates set, see https://api.frankfurter.dev/v1/currencies
      SUPPORTED_CURRENCIES = %w[
        AUD BRL CAD CHF CNY CZK DKK EUR GBP HKD HUF IDR ILS INR ISK JPY KRW MXN MYR NOK
        NZD PHP PLN RON SEK SGD THB TRY USD ZAR
      ].freeze

      private

      def request_options(base)
        { params: { base: base } }
      end

      # Frankfurter returns how much of each currency 1 unit of base buys,
      # so values are inverted to get the price of 1 unit in base currency.
      def build_rates(data, _base)
        data.fetch('rates').transform_values { |value| 1.0 / value }
      end
    end
  end
end
