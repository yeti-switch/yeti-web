# frozen_string_literal: true

class YetiCronJobCollector < PrometheusExporter::Server::TypeCollector
  def initialize
    @total_count_observer = build_count_observer(
      'total_count', 'total count of executed cron jobs'
    )
    @failed_count_observer = build_count_observer(
      'failed_count', 'count of cron jobs executed with failure'
    )
    @total_duration_observer = build_count_observer(
      'total_duration', 'cron job duration in seconds'
    )
  end

  def type
    'yeti_cron_job'
  end

  def metrics
    [@total_count_observer, @failed_count_observer, @total_duration_observer]
  end

  def collect(obj)
    labels = { name: obj['name'] }
    # labels are passed by processor
    labels.merge!(obj['metric_labels']) if obj['metric_labels']
    # custom_labels are passed by PrometheusExporter::Client
    labels.merge!(obj['custom_labels']) if obj['custom_labels']

    @total_duration_observer.observe(obj['duration'], labels)
    @total_count_observer.observe(1, labels)
    @failed_count_observer.observe(1, labels) unless obj['success']
  end

  private

  def build_count_observer(name, description)
    PrometheusExporter::Metric::Counter.new(
      "#{type}_#{name}",
      description
    )
  end
end
