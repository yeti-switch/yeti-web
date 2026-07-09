# frozen_string_literal: true

require 'config'

# Loads config/yeti_web.yml into YetiConfig for processes that never boot Rails,
# such as the standalone prometheus_exporter (see lib/prometheus_collectors.rb).
#
# The Rails application loads the same file, additionally validating it against a schema,
# from config/initializers/config.rb. Schema validation is skipped here: the application
# already fails loudly on an invalid config, and the exporter must keep exporting metrics
# of every other yeti process regardless.
module YetiConfigLoader
  CONFIG_PATH = File.expand_path('../config/yeti_web.yml', __dir__)

  module_function

  # @param path [String]
  # @return [Boolean] whether YetiConfig is available afterwards
  def call(path = CONFIG_PATH)
    return true if defined?(::YetiConfig)

    Config.setup do |config|
      config.const_name = 'YetiConfig'
      config.use_env = false
    end
    Config.evaluate_erb_in_yaml = true
    Config.load_and_set_settings(path)
    true
  rescue StandardError => e
    # A missing or broken config must not prevent the exporter from starting, otherwise every
    # metric of every yeti process disappears at once.
    warn "YetiConfigLoader: #{e.class} #{e.message}"
    false
  end
end
