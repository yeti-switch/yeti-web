# frozen_string_literal: true

class YetiInfoProcessor < PrometheusExporterExt::PeriodicProcessor
  self.logger = Rails.logger
  self.type = 'yeti_info'

  def collect
    version = Rails.application.config.app_build_info.fetch('version', 'unknown')

    [
      format_metric(
        online: 1,
        labels: { version: version }
      )
    ]
  end
end
