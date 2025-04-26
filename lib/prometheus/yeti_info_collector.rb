# frozen_string_literal: true

class YetiInfoCollector < PrometheusExporter::Server::TypeCollector
  class_attribute :max_metric_age, instance_writer: false, default: 30

  GAUGES = {
    online: 'yeti application online status with version'
  }.freeze

  def initialize
    @data = []
    @observers = {}

    GAUGES.each do |name, desc|
      @observers[name.to_s] = PrometheusExporter::Metric::Gauge.new("#{type}_#{name}", desc)
    end
  end

  def type
    'yeti_info'
  end

  def metrics
    clean_old_data
    return [] if @data.empty?

    @observers.each_value(&:reset!)
    metrics = {}

    @data.map do |obj|
      labels = gather_labels(obj)
      @observers.each do |name, observer|
        name = name.to_s
        value = obj[name]
        if value
          observer.observe(value, labels)
          metrics[name] = observer
        end
      end
    end

    metrics.values
  end

  def collect(obj)
    obj['created_at'] = monotonic_now
    @data << obj
  end

  def clean_old_data
    @data.delete_if { |m| m['created_at'] + max_metric_age < monotonic_now }
  end

  def monotonic_now
    ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
  end

  private

  def gather_labels(obj)
    labels = {}
    labels.merge!(obj['metric_labels']) if obj['metric_labels']
    labels.merge!(obj['custom_labels']) if obj['custom_labels']
    labels.stringify_keys.transform_values(&:to_s)
  end
end
