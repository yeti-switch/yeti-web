# frozen_string_literal: true

require_relative '../yeti_log_stats'

# Queue state of the logging pipeline of every yeti-web process, see YetiLogStats.
#
# Buffered rather than accumulated, as YetiInfoCollector does it: a process that stops
# reporting has to stop being exported instead of freezing at its last value.
class SemanticLoggerCollector < PrometheusExporter::Server::TypeCollector
  # Twice the reporting interval, so a scrape between two reports still finds one.
  class_attribute :max_metric_age, instance_writer: false, default: 60

  GAUGES = {
    'queue_size' => ['yeti_log_queue_size', 'Log records waiting to be written'],
    'max_queue_size' => ['yeti_log_queue_max_size',
                         'Log records the queue holds, -1 when it is unbounded'],
    'thread_active' => ['yeti_log_thread_active', 'Whether the thread draining the queue is running']
  }.freeze

  # Cumulative in the process already, so they are set rather than incremented.
  COUNTERS = {
    'processed' => ['yeti_log_processed_total', 'Log records written'],
    'dropped' => ['yeti_log_dropped_total', 'Log records dropped because the queue was full']
  }.freeze

  def initialize
    @data = []
    @gauges = GAUGES.transform_values { |name, desc| PrometheusExporter::Metric::Gauge.new(name, desc) }
    @counters = COUNTERS.transform_values { |name, desc| PrometheusExporter::Metric::Counter.new(name, desc) }
  end

  def type
    YetiLogStats::TYPE
  end

  def collect(obj)
    obj['created_at'] = monotonic_now
    @data << obj
  end

  def metrics
    clean_old_data
    return [] if @data.empty?

    (@gauges.values + @counters.values).each(&:reset!)
    @data.each do |obj|
      labels = gather_labels(obj)
      @gauges.each { |field, gauge| gauge.observe(obj[field], labels) unless obj[field].nil? }
      @counters.each { |field, counter| counter.reset(labels, obj[field]) unless obj[field].nil? }
    end

    @gauges.values + @counters.values
  end

  private

  def clean_old_data
    @data.delete_if { |obj| obj['created_at'] + max_metric_age < monotonic_now }
  end

  def monotonic_now
    ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
  end

  def gather_labels(obj)
    labels = {}
    labels.merge!(obj['metric_labels']) if obj['metric_labels']
    labels.merge!(obj['custom_labels']) if obj['custom_labels']
    labels.stringify_keys.transform_values(&:to_s)
  end
end
