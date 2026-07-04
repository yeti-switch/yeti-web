# frozen_string_literal: true

require 'httpx'

module CurrencyRates
  module Providers
    # Base for exchange rate providers. Subclasses declare:
    #   LABEL       - name used in error messages
    #   DEFAULT_URL - provider base url
    #   PATH        - request path appended to the base url
    #   SUPPORTED_CURRENCIES - optional allowlist (omit to support any)
    # and implement #build_rates (and optionally #request_options).
    #
    # An optional outbound HTTP proxy for all providers is read from
    # currency_rates.http_proxy in yeti_web.yml.
    class Base
      class Error < StandardError; end

      REQUEST_TIMEOUT = 30

      # @param currency_name [String] currency code.
      # @return [Boolean] whether provider publishes rates for the currency.
      def self.supports?(currency_name)
        return true unless const_defined?(:SUPPORTED_CURRENCIES)

        self::SUPPORTED_CURRENCIES.include?(currency_name)
      end

      # @param base [String] currency code rates should be expressed in.
      # @return [Hash{String => Float}] price of 1 unit of each returned currency in base currency.
      # @raise [Error]
      def rates(base:)
        response = client.get(rates_url, **request_options(base))
        response.raise_for_status
        build_rates(JSON.parse(response.body.to_s), base)
      rescue HTTPX::HTTPError => e
        raise Error, "#{label} returned HTTP #{e.status}"
      rescue HTTPX::Error => e
        raise Error, "#{label} request failed: #{e.message}"
      rescue JSON::ParserError, KeyError, TypeError, NoMethodError, ZeroDivisionError => e
        raise Error, "#{label} returned unexpected response: #{e.message}"
      end

      private

      # @param data [Object] parsed response body.
      # @param base [String] requested base currency code.
      # @return [Hash{String => Float}]
      def build_rates(_data, _base)
        raise NotImplementedError
      end

      # Extra options passed to the GET request (e.g. query params).
      def request_options(_base)
        {}
      end

      def label
        self.class::LABEL
      end

      def rates_url
        "#{self.class::DEFAULT_URL.chomp('/')}#{self.class::PATH}"
      end

      def client
        http = HTTPX.with(timeout: { request_timeout: REQUEST_TIMEOUT })
        proxy = http_proxy
        return http if proxy.blank?

        http.plugin(:proxy).with_proxy(uri: proxy)
      end

      def http_proxy
        YetiConfig.currency_rates&.http_proxy.presence
      end
    end
  end
end
