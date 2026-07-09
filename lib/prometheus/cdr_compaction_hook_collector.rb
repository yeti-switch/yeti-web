# frozen_string_literal: true

require_relative './collector_labels'

class CdrCompactionHookCollector < PrometheusExporter::Server::TypeCollector
  # Labels are resolved here instead of being taken from the payload, so that the counters can be
  # exported with a zero value from process start. Otherwise they only appear once the hook runs for
  # the first time, and an alert on "no executions" has no series to evaluate against.
  def initialize(labels = CollectorLabels.call)
    super()

    @labels = labels
    @observers = {
      'executions' => PrometheusExporter::Metric::Counter.new('yeti_cdr_compaction_hook_executions', 'Sum of Yeti CDR Compaction Hook execution runs'),
      'success' => PrometheusExporter::Metric::Counter.new('yeti_cdr_compaction_hook_success', 'Sum of Yeti CDR Compaction Hook successful executions'),
      'errors' => PrometheusExporter::Metric::Counter.new('yeti_cdr_compaction_hook_errors', 'Sum of Yeti CDR Compaction Hook execution fails'),
      'duration' => PrometheusExporter::Metric::Counter.new('yeti_cdr_compaction_hook_duration', 'Sum of Yeti CDR Compaction Hook execution duration in seconds')
    }
    @observers.each_value { |observer| observer.observe(0, @labels) }
  end

  def type
    'yeti_cdr_compaction_hook'
  end

  def metrics
    @observers.values
  end

  # Labels attached by the sender (metric_labels of the processor, custom_labels of
  # PrometheusExporter::Client) are ignored on purpose: merging them would produce a second series
  # next to the seeded one.
  def collect(obj)
    @observers.each do |name, observer|
      value = obj[name]
      observer.observe(value, @labels) if value
    end
  end
end
