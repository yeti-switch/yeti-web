# frozen_string_literal: true

class PartitionRemoveHookCollector < PrometheusExporter::Server::TypeCollector
  MAX_METRIC_AGE = 30

  def initialize
    @data = []
    @observers = {
      'executions' => PrometheusExporter::Metric::Counter.new('ruby_yeti_partition_removing_hook_executions', 'Sum of Yeti Partition Remove Hook execution runs'),
      'errors' => PrometheusExporter::Metric::Counter.new('ruby_yeti_partition_removing_hook_errors', 'Sum of Yeti Partition Remove Hook execution fails'),
      'duration' => PrometheusExporter::Metric::Counter.new('ruby_yeti_partition_removing_hook_duration', 'Sum of Yeti Partition Remove Hook execution duration in seconds')
    }
  end

  def type
    'ruby_yeti_partition_removing_hook'
  end

  def metrics
    return [] if @data.empty?

    metrics = {}
    @data.each do |obj|
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
    now = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)

    obj['created_at'] = now
    @data.delete_if { |m| m['created_at'] + MAX_METRIC_AGE < now }
    @data << obj
  end
end
