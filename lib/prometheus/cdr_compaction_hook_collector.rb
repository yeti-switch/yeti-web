# frozen_string_literal: true

class CdrCompactionHookCollector < PrometheusExporter::Server::TypeCollector
  def initialize
    @observers = {
      'executions' => PrometheusExporter::Metric::Counter.new('yeti_cdr_compaction_hook_executions', 'Sum of Yeti CDR Compaction Hook execution runs'),
      'errors' => PrometheusExporter::Metric::Counter.new('yeti_cdr_compaction_hook_errors', 'Sum of Yeti CDR Compaction Hook execution fails'),
      'duration' => PrometheusExporter::Metric::Counter.new('yeti_cdr_compaction_hook_duration', 'Sum of Yeti CDR Compaction Hook execution duration in seconds')
    }
  end

  def type
    'yeti_cdr_compaction_hook'
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
