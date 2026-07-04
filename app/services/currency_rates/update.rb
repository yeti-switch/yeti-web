# frozen_string_literal: true

module CurrencyRates
  # Updates rates of currencies that have rate_provider_id assigned.
  # Rates are expressed in the default currency, so a provider failure or
  # a currency missing in the provider response skips that currency only.
  class Update < ApplicationService
    def call
      return if currencies.empty?

      currencies.group_by(&:rate_provider_id).each do |provider_id, provider_currencies|
        update_from_provider(provider_id, provider_currencies)
      end
    end

    private

    def currencies
      @currencies ||= Billing::Currency.where.not(rate_provider_id: nil).to_a
    end

    def base_currency_name
      @base_currency_name ||= Billing::Currency.find(0).name
    end

    def update_from_provider(provider_id, provider_currencies)
      provider = Billing::CurrencyRateProvider.find(provider_id)
      rates = provider.service_class.constantize.new.rates(base: base_currency_name)

      provider_currencies.each do |currency|
        update_currency(currency, rates[currency.name], provider)
      end
    rescue Providers::Base::Error => e
      capture_error(e, extra: { provider: provider.name, currencies: provider_currencies.map(&:name) })
    end

    def update_currency(currency, rate, provider)
      if rate.nil? || !rate.finite? || !rate.positive?
        error = Error.new("#{provider.name} returned no usable #{base_currency_name} rate for #{currency.name}: #{rate.inspect}")
        capture_error(error, extra: { provider: provider.name, currency: currency.name, rate: rate })
        return
      end

      currency.update!(rate: rate)
    rescue ActiveRecord::RecordInvalid => e
      capture_error(e, extra: { provider: provider.name, currency: currency.name, rate: rate })
    end

    def capture_error(error, extra:)
      logger.error { "#{self.class}: #{error.message} #{extra.inspect}" }
      CaptureError.capture(error, extra: extra)
    end
  end
end
