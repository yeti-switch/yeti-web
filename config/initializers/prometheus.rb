# frozen_string_literal: true

require 'prometheus_config'

if PrometheusConfig.enabled?

  # NOTE: as we have different processes but want 1 interface for prometheus to scrape the metrics
  # we send the metrics to a collector container
  # this process need to be started as a separate process
  #
  # Prometheus Ports:
  # https://github.com/prometheus/prometheus/wiki/Default-port-allocations

  require 'prometheus_exporter'

  require 'prometheus_exporter/metric'
  PrometheusExporter::Metric::Base.default_labels = PrometheusConfig.default_labels

  # Connect to Prometheus Collector Process
  require 'prometheus_exporter/client'
  my_client = PrometheusExporter::Client.new(
    host: PrometheusConfig.host,
    port: PrometheusConfig.port,
    custom_labels: PrometheusConfig.default_labels
  )

  # Set Default Client
  PrometheusExporter::Client.default = my_client
  # This reports stats per request like HTTP status and timings
  require 'prometheus_exporter/middleware'
  Rails.application.middleware.unshift PrometheusExporter::Middleware

  # this reports basic process stats like RSS and GC info
  require 'prometheus_exporter/instrumentation'
  PrometheusExporter::Instrumentation::DelayedJob.register_plugin

  # Keep in mind that Processors that works in separate thread should be initialized in puma config #before_fork.
  # Because after *Process.daemon* all threads will be killed with old process.
end
