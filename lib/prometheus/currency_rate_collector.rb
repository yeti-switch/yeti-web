# frozen_string_literal: true

# Metrics for currency rate autoupdate (CurrencyRates::Update), labeled by provider.
#   yeti_currency_rate_updates   - successfully updated currency rates
#   yeti_currency_rate_errors    - provider/currency update failures
#   yeti_currency_rate_duration  - accumulated per-provider fetch+update time in seconds
# Provider failures do not fail the cron job (updates are resilient per provider),
# so alert on errors instead, e.g. increase(yeti_currency_rate_errors[2h]) > 0.
# Performance: rate(yeti_currency_rate_duration[1h]) by (provider).
class CurrencyRateCollector < PrometheusExporter::Server::TypeCollector
  def initialize
    @observers = {
      'updates' => PrometheusExporter::Metric::Counter.new('yeti_currency_rate_updates', 'Sum of successfully updated currency rates'),
      'errors' => PrometheusExporter::Metric::Counter.new('yeti_currency_rate_errors', 'Sum of currency rate update failures'),
      'duration' => PrometheusExporter::Metric::Counter.new('yeti_currency_rate_duration', 'Sum of currency rate provider fetch+update duration in seconds')
    }
  end

  def type
    'yeti_currency_rate'
  end

  def metrics
    @observers.values
  end

  def collect(obj)
    labels = gather_labels(obj)

    @observers.each do |name, observer|
      value = obj[name]
      observer.observe(value, labels) if value
    end
  end

  private

  def gather_labels(obj)
    labels = {}
    # labels are passed by processor
    labels.merge!(obj['metric_labels']) if obj['metric_labels']
    # custom_labels are passed by PrometheusExporter::Client
    labels.merge!(obj['custom_labels']) if obj['custom_labels']
    labels.stringify_keys.transform_values(&:to_s)
  end
end
