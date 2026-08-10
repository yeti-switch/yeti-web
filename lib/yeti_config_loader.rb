# frozen_string_literal: true

require 'config'

# Loads config/yeti_web.yml into YetiConfig for processes that never boot Rails,
# such as the standalone prometheus_exporter (see lib/prometheus_collectors.rb).
#
# The Rails application loads the same file, additionally validating it against a schema,
# from config/initializers/config.rb. Schema validation is skipped here because the application
# already fails loudly on an invalid config; the file itself, however, must be there and must
# parse. A process that carried on without it would read nil for every setting and export
# whatever that happened to produce, which is harder to diagnose than not starting at all.
module YetiConfigLoader
  class Error < StandardError; end

  CONFIG_PATH = File.expand_path('../config/yeti_web.yml', __dir__)

  module_function

  # @param path [String]
  # @raise [YetiConfigLoader::Error] when the file is missing
  # @raise [StandardError] whatever Config raises when the file does not parse
  def call(path = CONFIG_PATH)
    return if defined?(::YetiConfig)

    # Config.load_and_set_settings does not object to a path that does not exist: it defines an
    # empty YetiConfig and returns, so the absence has to be caught here. Checked before
    # Config.setup so a failure leaves no half-applied global configuration behind.
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
