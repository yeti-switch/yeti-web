# frozen_string_literal: true

require 'prometheus_config'
require 'prometheus_exporter'
require 'prometheus_exporter/metric'
require 'prometheus_exporter/client'
require 'prometheus_exporter/middleware'
require 'prometheus_exporter/instrumentation'

if PrometheusConfig.enabled?

  # NOTE: as we have different processes but want 1 interface for prometheus to scrape the metrics
  # we send the metrics to a collector container
  # this process need to be started as a separate process
  #
  # Prometheus Ports:
  # https://github.com/prometheus/prometheus/wiki/Default-port-allocations

  PrometheusExporter::Metric::Base.default_labels = PrometheusConfig.default_labels

  # Connect to Prometheus Collector Process
  my_client = PrometheusExporter::Client.new(
    host: PrometheusConfig.host,
    port: PrometheusConfig.port,
    custom_labels: PrometheusConfig.default_labels
  )

  # Set Default Client
  PrometheusExporter::Client.default = my_client
  # This reports stats per request like HTTP status and timings
  Rails.application.middleware.unshift PrometheusExporter::Middleware

  # this reports basic process stats like RSS and GC info
  PrometheusExporter::Instrumentation::DelayedJob.register_plugin

  # Keep in mind that Processors that works in separate thread should be initialized in puma config #before_fork.
  # Because after *Process.daemon* all threads will be killed with old process.
end
