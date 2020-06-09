# frozen_string_literal: true

module PrometheusConfig
  module_function

  def config
    Rails.configuration.yeti_web.fetch('prometheus')
  end

  def enabled?
    config['enabled'] && !Rails.env.test? && !ENV['SKIP_PROMETHEUS'] && $PROGRAM_NAME !~ /rake$/ && !ARGV[0].to_s.start_with?('db')
  end

  def host
    config['host']
  end

  def port
    config['port']
  end

  def default_labels
    config['default_labels']
  end
end
