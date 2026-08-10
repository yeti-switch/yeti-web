# frozen_string_literal: true

require 'config'

# Loads config/yeti_web.yml into YetiConfig for processes that never boot Rails,
# such as the standalone prometheus_exporter (see lib/prometheus_collectors.rb).
#
# Schema validation is skipped here: the Rails application loads the same file from
# config/initializers/config.rb and already fails loudly on an invalid config.
module YetiConfigLoader
  class Error < StandardError; end

  CONFIG_PATH = File.expand_path('../config/yeti_web.yml', __dir__)

  module_function

  # @param path [String]
  # @raise [YetiConfigLoader::Error] when the file is missing
  def call(path = CONFIG_PATH)
    return if defined?(::YetiConfig)

    # Config.load_and_set_settings accepts a missing path and defines an empty YetiConfig, so the
    # absence has to be caught here. Checked before Config.setup to leave no global config applied.
    raise Error, "config file not found: #{path}" unless File.exist?(path)

    Config.setup do |config|
      config.const_name = 'YetiConfig'
      config.use_env = false
    end
    Config.evaluate_erb_in_yaml = true
    Config.load_and_set_settings(path)
    nil
  end
end
