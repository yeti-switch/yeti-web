# frozen_string_literal: true

class IpAccessCollector < PrometheusExporter::Server::TypeCollector
  def initialize
    @observers = {
      'clickhouse_errors' => PrometheusExporter::Metric::Counter.new(
        'yeti_ip_access_clickhouse_errors',
        'Number of ClickHouse fetch failures while building GET /api/rest/system/ip-access response'
      )
    }
  end

  def type
    'yeti_ip_access'
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
