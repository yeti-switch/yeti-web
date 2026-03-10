# frozen_string_literal: true

class CdrProcessorCollector < PrometheusExporter::Server::TypeCollector
  def initialize
    @batches = PrometheusExporter::Metric::Counter.new(
      'yeti_cdr_processor_batches_total', 'Total number of processed CDR batches'
    )
    @events = PrometheusExporter::Metric::Counter.new(
      'yeti_cdr_processor_events_total', 'Total number of processed CDR events'
    )
    @duration = PrometheusExporter::Metric::Counter.new(
      'yeti_cdr_processor_duration_ms_total', 'Total time spent processing CDR batches in milliseconds'
    )
    @perform_group_duration = PrometheusExporter::Metric::Counter.new(
      'yeti_cdr_processor_perform_group_duration_ms_total', 'Total time spent sending data to target in milliseconds'
    )
  end

  def type
    'yeti_cdr_processor'
  end

  def metrics
    [@batches, @events, @duration, @perform_group_duration]
  end

  def collect(obj)
    labels = gather_labels(obj)

    @batches.observe(obj['batches'], labels) if obj['batches']
    @events.observe(obj['events'], labels) if obj['events']
    @duration.observe(obj['duration'], labels) if obj['duration']
    @perform_group_duration.observe(obj['perform_group_duration'], labels) if obj['perform_group_duration']
  end

  private

  def gather_labels(obj)
    labels = {}
    labels.merge!(obj['metric_labels']) if obj['metric_labels']
    labels.merge!(obj['custom_labels']) if obj['custom_labels']
    labels.stringify_keys.transform_values(&:to_s)
  end
end
