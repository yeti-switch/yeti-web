# frozen_string_literal: true

class YetiCollector < PrometheusExporter::Server::TypeCollector
  GAUGES = {
    job_delay: 'cron job delay in seconds'
  }.freeze

  def initialize
    @data = []
    @observers = {}

    GAUGES.each do |name, desc|
      @observers[name.to_s] = PrometheusExporter::Metric::Gauge.new("#{type}_#{name}", desc)
    end
  end

  def type
    'yeti'
  end

  def metrics
    return [] if @data.empty?

    metrics = {}

    @data.map do |obj|
      labels = {}
      # labels are passed by processor
      labels.merge!(obj['metric_labels']) if obj['metric_labels']
      # custom_labels are passed by PrometheusExporter::Client
      labels.merge!(obj['custom_labels']) if obj['custom_labels']

      @observers.each do |name, observer|
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
    @data << obj
  end
end
