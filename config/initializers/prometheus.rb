# frozen_string_literal: true

if !Rails.env.test? && Rails.configuration.yeti_web['prometheus']['enabled'] && !defined?(::Rake)

  # NOTE: as we have different processes but want 1 interface for prometheus to scrape the metrics
  # we send the metrics to a collector container
  # this process need to be started as a separate process
  #
  # Prometheus Ports:
  # https://github.com/prometheus/prometheus/wiki/Default-port-allocations

  require 'prometheus_exporter'

  require 'prometheus_exporter/metric'
  PrometheusExporter::Metric::Base.default_labels = Rails.configuration.yeti_web['prometheus']['default_labels']

  # Connect to Prometheus Collector Process
  require 'prometheus_exporter/client'
  my_client = PrometheusExporter::Client.new(
    host: Rails.configuration.yeti_web['prometheus']['host'],
    port: Rails.configuration.yeti_web['prometheus']['port'],
    custom_labels: Rails.configuration.yeti_web['prometheus']['default_labels']
  )

  # Set Default Client
  PrometheusExporter::Client.default = my_client
  # This reports stats per request like HTTP status and timings
  require 'prometheus_exporter/middleware'
  Rails.application.middleware.unshift PrometheusExporter::Middleware

  # this reports basic process stats like RSS and GC info
  require 'prometheus_exporter/instrumentation'
  PrometheusExporter::Instrumentation::DelayedJob.register_plugin

  PrometheusExporter::Instrumentation::Process.start(
    type: 'master',
    labels: Rails.configuration.yeti_web['prometheus']['default_labels']
  )
end
