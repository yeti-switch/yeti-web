# frozen_string_literal: true

module PrometheusConfig
  module_function

  def enabled?
    YetiConfig.prometheus.enabled && !Rails.env.test? && !ENV['SKIP_PROMETHEUS'] && $PROGRAM_NAME !~ /rake$/ && !ARGV[0].to_s.start_with?('db')
  end

  def host
    YetiConfig.prometheus.host
  end

  def port
    YetiConfig.prometheus.port
  end

  def default_labels
    YetiConfig.prometheus.default_labels
  end

  def partition_remove_hook_configured?
    YetiConfig.partition_remove_hook.present?
  end

  def cdr_compaction_hook_configured?
    YetiConfig.cdr_compaction_hook.present?
  end
end
