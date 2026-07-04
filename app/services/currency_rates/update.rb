# frozen_string_literal: true

require 'prometheus/currency_rate_processor'

module CurrencyRates
  # Updates rates of currencies that have rate_provider_id assigned.
  # Rates are expressed in the default currency, so a provider failure or
  # a currency missing in the provider response skips that currency only.
  # Provider/currency failures are captured (Sentry + logs) and exposed as
  # prometheus metrics (see CurrencyRateCollector) - they do not fail the job.
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
      started_at = monotonic_time
      provider = Billing::CurrencyRateProvider.find(provider_id)
      rates = provider.service_class.constantize.new.rates(base: base_currency_name)

      updated = provider_currencies.count { |currency| update_currency(currency, rates[currency.name], provider) }
      record_updates(provider, updated)
    rescue Providers::Base::Error => e
      capture_error(e, extra: { provider: provider.name, currencies: provider_currencies.map(&:name) })
      record_error(provider)
    ensure
      record_duration(provider, monotonic_time - started_at) if provider
    end

    # @return [Boolean] whether the rate was updated.
    def update_currency(currency, rate, provider)
      if rate.nil? || !rate.finite? || !rate.positive?
        error = Error.new("#{provider.name} returned no usable #{base_currency_name} rate for #{currency.name}: #{rate.inspect}")
        capture_error(error, extra: { provider: provider.name, currency: currency.name, rate: rate })
        record_error(provider)
        return false
      end

      currency.update!(rate: rate)
      true
    rescue ActiveRecord::RecordInvalid => e
      capture_error(e, extra: { provider: provider.name, currency: currency.name, rate: rate })
      record_error(provider)
      false
    end

    def capture_error(error, extra:)
      logger.error { "#{self.class}: #{error.message} #{extra.inspect}" }
      CaptureError.capture(error, extra: extra)
    end

    def record_updates(provider, updated_count)
      return unless PrometheusConfig.enabled?
      return unless updated_count.positive?

      CurrencyRateProcessor.collect_updates_metric(updated_count, provider.name)
    end

    def record_error(provider)
      return unless PrometheusConfig.enabled?

      CurrencyRateProcessor.collect_error_metric(provider.name)
    end

    def record_duration(provider, duration)
      return unless PrometheusConfig.enabled?

      CurrencyRateProcessor.collect_duration_metric(duration, provider.name)
    end

    def monotonic_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
