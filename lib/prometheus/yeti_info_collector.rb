# frozen_string_literal: true

require_relative '../prometheus_exporter_ext/s_exporter_ext/lib/prometheus_exporter_ext/expired_collector'

class YetiInfoCollector < PrometheusExporterExt::ExpiredCollector
  self.type = 'yeti_info'
  self.max_metric_age = 30
  self.clear_expired_on = :metrics

  define_metric_gauge :online, 'application version'
end
