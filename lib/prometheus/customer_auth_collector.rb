# frozen_string_literal: true

class CustomerAuthCollector < PrometheusExporter::Server::TypeCollector
  MAX_METRIC_AGE = 30
  GAUGES = {
    last24h_customer_price: 'total customer price originated by customer auth in last 24 hours'
  }.freeze

  def initialize
    @data = []

    @observers = {}
    GAUGES.each do |name, desc|
      @observers[name.to_s] = PrometheusExporter::Metric::Gauge.new("#{type}_#{name}", desc)
    end

    @customer_auths = []
  end

  def type
    'yeti_ca'
  end

  def metrics
    @observers.each_value(&:reset!)

    @customer_auths.each do |ca_labels|
      @observers.each do |_, observer|
        observer.observe(0, ca_labels)
      end
    end

    @data.each do |obj|
      labels = gather_labels(obj)

      @observers.each do |name, observer|
        value = obj[name]
        observer.observe(value, labels) if value
      end
    end

    @observers.values
  end

  #   @example { metric_labels, custom_labels, last24h_customer_price }
  def collect(obj)
    labels = gather_labels(obj)
    if labels.key?('customer_auth_id') && obj.key?('last24h_customer_price')
      @customer_auths.push(labels) unless @customer_auths.include?(labels)
    end

    now = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
    obj['created_at'] = now
    @data.delete_if { |m| m['created_at'] + MAX_METRIC_AGE < now }
    @data << obj
  end

  private

  def gather_labels(obj)
    labels = {}
    # labels are passed by processor
    labels.merge!(obj['metric_labels']) if obj['metric_labels']
    # custom_labels are passed by PrometheusExporter::Client
    labels.merge!(obj['custom_labels']) if obj['custom_labels']
    labels
  end
end
