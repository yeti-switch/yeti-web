# frozen_string_literal: true

require_relative '../prometheus_config'

# Default labels for TypeCollectors that seed their counters with a zero value at process start.
#
# Such a collector must know its labels up front: a counter seeded with one label set and later
# incremented with another would be exported as two separate series. The labels must therefore
# match PrometheusConfig.default_labels, which the application process passes to
# PrometheusExporter::Client as custom_labels (config/initializers/prometheus.rb), stringified
# the same way the collectors used to stringify the labels received over the wire.
module CollectorLabels
  module_function

  # @return [Hash<String, String>] empty when YetiConfig is unavailable or defines no default_labels
  def call
    labels = PrometheusConfig.default_labels
    return {} if labels.nil?

    labels.to_h.to_h { |name, value| [name.to_s, value.to_s] }
  rescue StandardError => e
    # YetiConfig is absent when config/yeti_web.yml could not be loaded (see YetiConfigLoader).
    # Unlabelled counters are strictly better than an exporter that refuses to start.
    warn "CollectorLabels: #{e.class} #{e.message}"
    {}
  end
end
