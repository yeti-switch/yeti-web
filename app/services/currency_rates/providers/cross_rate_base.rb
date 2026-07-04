# frozen_string_literal: true

module CurrencyRates
  module Providers
    # Base for providers that quote every currency against a single home currency
    # (e.g. ILS for Bank of Israel, UAH for NBU). Cross rates to the requested
    # base are calculated from those home-currency quotes. Subclasses implement
    # #home_quotes, returning the price of 1 unit of each currency in the home currency.
    class CrossRateBase < Base
      private

      def build_rates(data, base)
        quotes = home_quotes(data)
        base_rate = quotes[base]
        raise Error, "#{label} has no #{base} rate to calculate cross rates" if base_rate.nil?

        quotes.transform_values { |value| value / base_rate }
      end

      # @param data [Object] parsed response body.
      # @return [Hash{String => Float}] price of 1 unit of each currency in the home currency,
      #   including the home currency itself mapped to 1.0.
      def home_quotes(_data)
        raise NotImplementedError
      end
    end
  end
end
