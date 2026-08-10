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

  # Whether the optional shell hooks are configured, for the collectors that seed their counters
  # with a zero value at process start. Seeding gives a "the hook has not run" alert a series to
  # evaluate against; where no hook is configured that series would describe a switched-off feature
  # and the alert would fire forever.
  def partition_remove_hook_configured?
    YetiConfig.partition_remove_hook.present?
  end

  def cdr_compaction_hook_configured?
    YetiConfig.cdr_compaction_hook.present?
  end
end
