# frozen_string_literal: true

class RSpecTestPrometheusClient
  class_attribute :instance, instance_accessor: false
  # Stub client used by send_prometheus_metrics matcher
  attr_reader :metrics

  def initialize
    @metrics = []
  end

  def send_json(metric)
    @metrics << metric.deep_symbolize_keys
  end

  def clear!
    @metrics = []
  end
end
